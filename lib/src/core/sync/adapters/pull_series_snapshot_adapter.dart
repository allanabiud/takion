import "package:drift/drift.dart";
import "package:takion/src/core/logging/app_logger.dart";
import "package:takion/src/core/sync/adapters/remote_sync_adapter.dart";
import "package:takion/src/data/common/drift/daos/subscription_dao.dart";
import "package:takion/src/data/common/drift/daos/sync_cursor_dao.dart";
import "package:takion/src/data/common/drift/database.dart";
import "package:takion/src/data/pull_list/datasources/remote/metron_pull_list_remote_data_source.dart";
import "package:takion/src/data/pull_list/dto/pull_list_dto.dart";
import "package:uuid/uuid.dart";

class PullSeriesSnapshotAdapter implements RemoteSyncAdapter {
  PullSeriesSnapshotAdapter({
    required AppDatabase db,
    required MetronPullListRemoteDataSource remoteDataSource,
    required SubscriptionDao subscriptionDao,
    required SyncCursorDao cursorDao,
  }) : _db = db,
       _remoteDataSource = remoteDataSource,
       _subscriptionDao = subscriptionDao,
       _cursorDao = cursorDao;

  @override
  String get resource => "pull_series";

  final AppDatabase _db;
  final MetronPullListRemoteDataSource _remoteDataSource;
  final SubscriptionDao _subscriptionDao;
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
      "Starting PullSeries snapshot sync (resuming: $isResuming, nextUrl: $nextUrl, scanId: $scanId)",
    );

    try {
      while (budget.canMakeAnotherRequest) {
        budget.recordRequest();

        final page = await _remoteDataSource.getPullListSeriesPage(
          pageUrl: nextUrl,
        );

        totalFetched += page.items.length;

        await _db.transaction(() async {
          final updatedInPage = await _ingestSubscriptions(
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
        // Authoritative complete snapshot: safe to reconcile missing subscriptions
        final removed = await _subscriptionDao.reconcileMissingFromScan(scanId);
        AppLogger.info(
          "PullSeries complete snapshot reconciled: $removed subscriptions marked inactive",
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
      AppLogger.error("PullSeries sync error: $e", error: e, stackTrace: st);
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

  Future<int> _ingestSubscriptions(
    List<PullListSeriesDto> seriesItems, {
    required String scanId,
    required String accountId,
  }) async {
    final nowIso = DateTime.now().toUtc().toIso8601String();
    var count = 0;

    for (final series in seriesItems) {
      final existing = await _subscriptionDao.getBySeriesId(series.seriesId);

      // Preserve local uncommitted modifications
      if (existing != null && existing.syncStatus != "synced") {
        continue;
      }

      await _subscriptionDao.upsert(
        SeriesSubscriptionsCompanion(
          id: Value(existing?.id ?? "sub-${series.seriesId}"),
          userId: Value(accountId),
          metronSeriesId: Value(series.seriesId),
          metronPullListId: Value(series.id),
          syncStatus: const Value("synced"),
          isActive: const Value(true),
          autoAddPull: Value(existing?.autoAddPull ?? true),
          subscribedAt: Value(
            series.addedOn ?? existing?.subscribedAt ?? nowIso,
          ),
          createdAt: Value(existing?.createdAt ?? nowIso),
          updatedAt: Value(nowIso),
          lastSeenScanId: Value(scanId),
          deletedAt: const Value(null),
        ),
      );
      count++;
    }

    return count;
  }
}
