import "package:dio/dio.dart";
import "package:drift/drift.dart";
import "package:takion/src/core/logging/app_logger.dart";
import "package:takion/src/data/common/drift/database.dart" as db;
import "package:takion/src/domain/pull_list/entities/pull_list_item.dart";
import "package:takion/src/domain/pull_list/repositories/pull_list_repository.dart";

class PullListSyncResult {
  const PullListSyncResult({
    required this.seriesFetched,
    required this.issuesFetched,
    required this.isSuccess,
    required this.isFullSync,
    this.errorMessage,
  });

  final int seriesFetched;
  final int issuesFetched;
  final bool isSuccess;
  final bool isFullSync;
  final String? errorMessage;
}

class PullListSyncManager {
  PullListSyncManager({
    required db.AppDatabase database,
    required MetronPullListRepository pullListRepository,
  }) : _database = database,
       _pullListRepository = pullListRepository;

  static const String _syncMetaKey = "metron_last_pull_list_sync";
  static const String _localUserId = "local-user";

  final db.AppDatabase _database;
  final MetronPullListRepository _pullListRepository;

  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  Future<DateTime?> getLastSyncTime() async {
    final str = await _database.syncMetaDao.get(_syncMetaKey);
    return str != null ? DateTime.tryParse(str) : null;
  }

  Future<PullListSyncResult> syncPullList({
    bool forceFullSync = false,
    void Function(int seriesCount, int issuesCount)? onProgress,
  }) async {
    if (_isSyncing) {
      return const PullListSyncResult(
        seriesFetched: 0,
        issuesFetched: 0,
        isSuccess: false,
        isFullSync: false,
        errorMessage: "Pull list sync already in progress",
      );
    }

    _isSyncing = true;
    try {
      final lastSync = forceFullSync ? null : await getLastSyncTime();
      final isFullSync = lastSync == null;

      // 1. Sync Pull List Series (Subscriptions)
      var totalSeriesFetched = 0;
      var totalIssuesFetched = 0;
      final allSeriesItems = <PullListSeriesItem>[];
      Uri? seriesPageUrl;
      while (true) {
        final pageResult = await _pullListRepository.getPullListSeriesPage(
          pageUrl: seriesPageUrl,
        );
        final pageItems = pageResult.items;
        if (pageItems.isEmpty) break;
        totalSeriesFetched += pageItems.length;
        if (isFullSync) {
          allSeriesItems.addAll(pageItems);
        } else {
          await _ingestIncrementalSubscriptions(pageItems);
        }
        onProgress?.call(totalSeriesFetched, totalIssuesFetched);
        if (pageResult.next == null) break;
        seriesPageUrl = pageResult.next;
      }

      if (isFullSync) {
        await _reconcileSubscriptions(allSeriesItems);
      }

      // 2. Sync Pull List Issues
      Uri? issuePageUrl;
      final now = DateTime.now().toUtc();
      final storeDateAfter = now.subtract(const Duration(days: 30));
      final storeDateBefore = now.add(const Duration(days: 60));

      while (true) {
        final pageResult = await _pullListRepository.getPullListIssuesPage(
          pageUrl: issuePageUrl,
          storeDateAfter: storeDateAfter,
          storeDateBefore: storeDateBefore,
        );
        final pageIssues = pageResult.items;
        if (pageIssues.isEmpty) break;
        totalIssuesFetched += pageIssues.length;
        onProgress?.call(totalSeriesFetched, totalIssuesFetched);
        await _ingestPullListIssues(pageIssues);
        if (pageResult.next == null) break;
        issuePageUrl = pageResult.next;
      }

      await _database.syncMetaDao.set(_syncMetaKey, now.toIso8601String());

      AppLogger.info(
        "Pull list sync completed: $totalSeriesFetched series, $totalIssuesFetched issues (fullSync: $isFullSync)",
      );

      return PullListSyncResult(
        seriesFetched: totalSeriesFetched,
        issuesFetched: totalIssuesFetched,
        isSuccess: true,
        isFullSync: isFullSync,
      );
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      if (statusCode == 404) {
        AppLogger.info(
          "Pull list sync: no pull list found on remote (404), treating as empty",
        );
        final now = DateTime.now().toUtc();
        await _database.syncMetaDao.set(_syncMetaKey, now.toIso8601String());
        return const PullListSyncResult(
          seriesFetched: 0,
          issuesFetched: 0,
          isSuccess: true,
          isFullSync: true,
        );
      }
      AppLogger.error("Pull list sync failed", error: e);
      return PullListSyncResult(
        seriesFetched: 0,
        issuesFetched: 0,
        isSuccess: false,
        isFullSync: forceFullSync,
        errorMessage: e.toString(),
      );
    } catch (e, st) {
      AppLogger.error("Pull list sync failed", error: e, stackTrace: st);
      return PullListSyncResult(
        seriesFetched: 0,
        issuesFetched: 0,
        isSuccess: false,
        isFullSync: forceFullSync,
        errorMessage: e.toString(),
      );
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _ingestIncrementalSubscriptions(
    List<PullListSeriesItem> remoteSeries,
  ) async {
    final nowIso = DateTime.now().toUtc().toIso8601String();

    for (final series in remoteSeries) {
      final existing = await _database.subscriptionDao.getBySeriesId(
        series.seriesId,
      );

      if (existing != null && existing.syncStatus != "synced") {
        continue;
      }

      await _database.subscriptionDao.upsert(
        db.SeriesSubscriptionsCompanion(
          id: Value(existing?.id ?? "sub-${series.seriesId}"),
          userId: const Value(_localUserId),
          metronSeriesId: Value(series.seriesId),
          metronPullListId: Value(series.id),
          syncStatus: const Value("synced"),
          isActive: const Value(true),
          autoAddPull: Value(existing?.autoAddPull ?? true),
          subscribedAt: Value(
            series.addedOn?.toIso8601String() ??
                existing?.subscribedAt ??
                nowIso,
          ),
          createdAt: Value(existing?.createdAt ?? nowIso),
          updatedAt: Value(nowIso),
        ),
      );
    }
  }

  Future<void> _reconcileSubscriptions(
    List<PullListSeriesItem> remoteSeries,
  ) async {
    final nowIso = DateTime.now().toUtc().toIso8601String();
    final remoteSeriesIds = remoteSeries.map((s) => s.seriesId).toSet();

    for (final series in remoteSeries) {
      final existing = await _database.subscriptionDao.getBySeriesId(
        series.seriesId,
      );

      if (existing != null && existing.syncStatus != "synced") {
        continue;
      }

      await _database.subscriptionDao.upsert(
        db.SeriesSubscriptionsCompanion(
          id: Value(existing?.id ?? "sub-${series.seriesId}"),
          userId: const Value(_localUserId),
          metronSeriesId: Value(series.seriesId),
          metronPullListId: Value(series.id),
          syncStatus: const Value("synced"),
          isActive: const Value(true),
          autoAddPull: Value(existing?.autoAddPull ?? true),
          subscribedAt: Value(
            series.addedOn?.toIso8601String() ??
                existing?.subscribedAt ??
                nowIso,
          ),
          createdAt: Value(existing?.createdAt ?? nowIso),
          updatedAt: Value(nowIso),
        ),
      );
    }

    final localActive = await _database.subscriptionDao.watchActiveList();
    for (final local in localActive) {
      if (local.syncStatus == "synced" &&
          !remoteSeriesIds.contains(local.metronSeriesId)) {
        await _database.subscriptionDao.upsert(
          db.SeriesSubscriptionsCompanion(
            id: Value(local.id),
            userId: Value(local.userId),
            metronSeriesId: Value(local.metronSeriesId),
            metronPullListId: const Value(null),
            syncStatus: const Value("synced"),
            isActive: const Value(false),
            autoAddPull: Value(local.autoAddPull),
            subscribedAt: Value(local.subscribedAt),
            createdAt: Value(local.createdAt),
            updatedAt: Value(nowIso),
          ),
        );
      }
    }
  }

  Future<void> _ingestPullListIssues(
    List<PullListIssueItem> remoteIssues,
  ) async {
    if (remoteIssues.isEmpty) return;

    final nowIso = DateTime.now().toUtc().toIso8601String();
    final companions = <db.PullListEntriesCompanion>[];

    for (final issue in remoteIssues) {
      final existing = await _database.pullListDao.getByIssueId(issue.issueId);

      if (existing != null && existing.syncStatus != "synced") {
        continue;
      }

      final releaseDate = issue.storeDate ?? issue.coverDate;

      companions.add(
        db.PullListEntriesCompanion(
          id: Value(existing?.id ?? "pull-${issue.issueId}"),
          userId: const Value(_localUserId),
          metronIssueId: Value(issue.issueId),
          metronSeriesId: Value(issue.seriesId),
          metronPullListId: Value(issue.id),
          syncStatus: const Value("synced"),
          entryStatus: Value(existing?.entryStatus ?? "upcoming"),
          releaseDate: Value(releaseDate),
          source: const Value("subscription"),
          generatedAt: Value(existing?.generatedAt ?? nowIso),
          createdAt: Value(existing?.createdAt ?? nowIso),
          updatedAt: Value(nowIso),
        ),
      );
    }

    if (companions.isNotEmpty) {
      await _database.pullListDao.batchUpsert(companions);
    }
  }
}
