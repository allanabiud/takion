import "package:drift/drift.dart";
import "package:takion/src/core/logging/app_logger.dart";
import "package:takion/src/core/sync/adapters/remote_sync_adapter.dart";
import "package:takion/src/data/common/drift/daos/sync_cursor_dao.dart";
import "package:takion/src/data/common/drift/daos/wishlist_dao.dart";
import "package:takion/src/data/common/drift/database.dart";
import "package:takion/src/data/wishlist/datasources/remote/metron_wishlist_remote_data_source.dart";
import "package:takion/src/data/wishlist/dto/wishlist_dto.dart";
import "package:uuid/uuid.dart";

class WishlistSnapshotAdapter implements RemoteSyncAdapter {
  WishlistSnapshotAdapter({
    required AppDatabase db,
    required MetronWishlistRemoteDataSource remoteDataSource,
    required WishlistDao wishlistDao,
    required SyncCursorDao cursorDao,
  }) : _db = db,
       _remoteDataSource = remoteDataSource,
       _wishlistDao = wishlistDao,
       _cursorDao = cursorDao;

  @override
  String get resource => "wishlist";

  final AppDatabase _db;
  final MetronWishlistRemoteDataSource _remoteDataSource;
  final WishlistDao _wishlistDao;
  final SyncCursorDao _cursorDao;
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

    final bool isResuming = cursor.nextUrl != null && cursor.scanId != null;
    final String scanId = isResuming ? cursor.scanId! : _uuid.v4();
    final DateTime scanStartedAt = isResuming
        ? (cursor.scanStartedAt ?? now)
        : now;

    Uri? nextUrl = cursor.nextUrl;
    var totalFetched = 0;
    var totalUpdated = 0;

    AppLogger.info(
      "Starting Wishlist snapshot sync (resuming: $isResuming, nextUrl: $nextUrl, scanId: $scanId)",
    );

    try {
      while (budget.canMakeAnotherRequest) {
        budget.recordRequest();

        final page = await _remoteDataSource.getWishListPage(pageUrl: nextUrl);

        totalFetched += page.items.length;

        await _db.transaction(() async {
          final updatedInPage = await _ingestWishlistItems(
            page.items,
            scanId: scanId,
            accountId: accountId,
          );
          totalUpdated += updatedInPage;
          onProgress?.call(totalUpdated);

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
        // Authoritative complete snapshot: safe to reconcile missing wishlist items
        final removed = await _wishlistDao.reconcileMissingFromScan(scanId);
        AppLogger.info(
          "Wishlist complete snapshot reconciled: $removed items removed",
        );

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
      AppLogger.error("Wishlist sync error: $e", error: e, stackTrace: st);
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

  Future<int> _ingestWishlistItems(
    List<WishListItemDto> items, {
    required String scanId,
    required String accountId,
  }) async {
    final nowIso = DateTime.now().toUtc().toIso8601String();
    var count = 0;

    for (final item in items) {
      final existing = await _wishlistDao.getByIssueId(item.issueId);

      // Preserve local uncommitted modifications
      if (existing != null && existing.syncStatus != "synced") {
        continue;
      }

      final addedOnDate = item.addedOn != null
          ? DateTime.tryParse(item.addedOn!)
          : existing?.addedOn;
      final addedOnIso = item.addedOn ?? existing?.createdAt ?? nowIso;
      final modifiedIso = item.modified ?? nowIso;

      await _wishlistDao.upsert(
        WishlistItemsCompanion(
          id: Value(item.id),
          issueId: Value(item.issueId),
          seriesId: Value(item.seriesId),
          seriesName: Value(item.seriesName),
          issueNumber: Value(item.issueNumber),
          seriesVolume: Value(item.seriesVolume),
          seriesYearBegan: Value(item.seriesYearBegan),
          coverDate: Value(
            item.coverDate != null ? DateTime.tryParse(item.coverDate!) : null,
          ),
          storeDate: Value(
            item.storeDate != null ? DateTime.tryParse(item.storeDate!) : null,
          ),
          imageUrl: Value(item.imageUrl),
          priority: Value(item.priority),
          desiredGrade: Value(item.desiredGrade),
          maxPrice: Value(item.maxPrice),
          maxPriceCurrency: Value(item.maxPriceCurrency),
          notes: Value(item.notes),
          addedOn: Value(addedOnDate),
          syncStatus: const Value("synced"),
          createdAt: Value(existing?.createdAt ?? addedOnIso),
          updatedAt: Value(modifiedIso),
          remoteModified: Value(modifiedIso),
          lastSeenScanId: Value(scanId),
          deletedAt: const Value(null),
        ),
      );
      count++;
    }

    return count;
  }
}
