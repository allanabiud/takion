import "package:drift/drift.dart";
import "package:takion/src/core/logging/app_logger.dart";
import "package:takion/src/core/sync/adapters/remote_sync_adapter.dart";
import "package:takion/src/data/collection/datasources/remote/metron_collection_remote_data_source.dart";
import "package:takion/src/data/collection/dto/collection_item_dto.dart";
import "package:takion/src/data/common/drift/daos/library_item_dao.dart";
import "package:takion/src/data/common/drift/daos/sync_cursor_dao.dart";
import "package:takion/src/data/common/drift/database.dart";
import "package:uuid/uuid.dart";

class CollectionDeltaAdapter implements RemoteSyncAdapter {
  CollectionDeltaAdapter({
    required AppDatabase db,
    required MetronCollectionRemoteDataSource remoteDataSource,
    required LibraryItemDao libraryItemDao,
    required SyncCursorDao cursorDao,
    this.overlap = const Duration(minutes: 3),
  }) : _db = db,
       _remoteDataSource = remoteDataSource,
       _libraryItemDao = libraryItemDao,
       _cursorDao = cursorDao;

  @override
  String get resource => "collection";

  final AppDatabase _db;
  final MetronCollectionRemoteDataSource _remoteDataSource;
  final LibraryItemDao _libraryItemDao;
  final SyncCursorDao _cursorDao;
  final Duration overlap;
  static const _uuid = Uuid();

  @override
  Future<SyncAdapterResult> sync({
    required String accountId,
    required SyncBudget budget,
    bool forceFullSync = false,
    void Function(int count)? onProgress,
  }) async {
    final now = DateTime.now().toUtc();
    var cursor = await _cursorDao.loadCursor(accountId, resource);

    // If an in-progress scan exists with a valid nextUrl, resume from it.
    // Otherwise start fresh.
    final bool isResuming = cursor.nextUrl != null && cursor.scanId != null;
    final String scanId = isResuming ? cursor.scanId! : _uuid.v4();
    final DateTime scanStartedAt = isResuming
        ? (cursor.scanStartedAt ?? now)
        : now;

    // Full sync is triggered when forceFullSync is true, or if we have never synced (no watermark).
    final bool isFullSync =
        forceFullSync || (cursor.watermark == null && !isResuming);

    DateTime? queryModifiedAfter;
    if (!isFullSync && cursor.watermark != null) {
      queryModifiedAfter = cursor.watermark!.subtract(overlap);
    }

    Uri? nextUrl = cursor.nextUrl;
    var totalFetched = 0;
    var totalUpdated = 0;

    AppLogger.info(
      "Starting Collection sync (resuming: $isResuming, full: $isFullSync, nextUrl: $nextUrl, watermark: ${cursor.watermark})",
    );

    try {
      while (budget.canMakeAnotherRequest) {
        budget.recordRequest();

        final page = await _remoteDataSource.getCollectionPage(
          pageUrl: nextUrl,
          modifiedGt: nextUrl == null ? queryModifiedAfter : null,
        );

        totalFetched += page.items.length;

        await _db.transaction(() async {
          final updatedInPage = await _ingestItems(
            page.items,
            scanId: scanId,
            accountId: accountId,
          );
          totalUpdated += updatedInPage;
          onProgress?.call(totalUpdated);

          // Checkpoint cursor after every page
          cursor = cursor.copyWith(
            scanId: scanId,
            scanStartedAt: scanStartedAt,
            nextUrl: page.next,
            clearNextUrl: page.next == null,
          );

          await _cursorDao.saveCursor(
            accountId: accountId,
            resource: resource,
            cursor: cursor,
            isComplete: page.next == null,
          );
        });

        nextUrl = page.next;
        if (nextUrl == null) break;
      }

      final isComplete = nextUrl == null;

      if (isComplete) {
        // Complete scan: if this was a full scan, reconcile any items deleted on remote
        if (isFullSync) {
          final removed = await _libraryItemDao.reconcileMissingFromScan(
            scanId,
          );
          AppLogger.info(
            "Collection full sync reconciled deletions: $removed items removed",
          );
        }

        // Set completed watermark to scanStartedAt
        cursor = cursor.copyWith(
          watermark: scanStartedAt,
          clearNextUrl: true,
          clearScanId: true,
          clearScanStartedAt: true,
        );

        await _cursorDao.saveCursor(
          accountId: accountId,
          resource: resource,
          cursor: cursor,
          isComplete: true,
        );
      }

      return SyncAdapterResult(
        resource: resource,
        itemsFetched: totalFetched,
        itemsUpdated: totalUpdated,
        isSuccess: true,
        isComplete: isComplete,
      );
    } catch (e, st) {
      AppLogger.error("Collection sync error: $e", error: e, stackTrace: st);
      return SyncAdapterResult(
        resource: resource,
        itemsFetched: totalFetched,
        itemsUpdated: totalUpdated,
        isSuccess: false,
        isComplete: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<int> _ingestItems(
    List<CollectionItemDto> items, {
    required String scanId,
    required String accountId,
  }) async {
    if (items.isEmpty) return 0;

    final issueIds = items.map((i) => i.issueId).where((id) => id > 0).toList();
    final existingLocal = await _libraryItemDao.getByIssueIds(issueIds);

    final companions = <LibraryItemsCompanion>[];
    final nowIso = DateTime.now().toUtc().toIso8601String();

    for (final item in items) {
      final existing = existingLocal[item.issueId];

      // If existing item has unsaved local changes pending offline sync, preserve local changes
      if (existing != null && existing.syncStatus != "synced") {
        continue;
      }

      final itemId = existing?.id ?? "lib-${item.issueId}";
      final remoteModIso = item.modified ?? nowIso;

      companions.add(
        LibraryItemsCompanion(
          id: Value(itemId),
          userId: Value(accountId),
          metronIssueId: Value(item.issueId),
          metronSeriesId: Value(item.seriesId),
          ownershipStatus: const Value("owned"),
          isRead: Value(item.isRead),
          metronCollectionId: Value(item.id),
          syncStatus: const Value("synced"),
          rating: Value(item.rating),
          purchaseDate: Value(item.purchaseDate),
          pricePaid: Value(item.purchasePrice ?? existing?.pricePaid),
          quantityOwned: Value(item.quantity),
          format: Value(item.bookFormat.toLowerCase()),
          firstReadAt: Value(existing?.firstReadAt),
          conditionGrade: Value(
            item.grade != null
                ? item.grade.toString()
                : existing?.conditionGrade,
          ),
          acquiredOn: Value(existing?.acquiredOn),
          notes: Value(item.notes ?? existing?.notes),
          createdAt: Value(existing?.createdAt ?? remoteModIso),
          updatedAt: Value(remoteModIso),
          remoteModified: Value(remoteModIso),
          lastSeenScanId: Value(scanId),
          deletedAt: const Value(null),
        ),
      );
    }

    if (companions.isNotEmpty) {
      await _libraryItemDao.batchUpsert(companions);
    }

    return companions.length;
  }
}
