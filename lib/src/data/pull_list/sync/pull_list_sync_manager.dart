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
    this.errorMessage,
  });

  final int seriesFetched;
  final int issuesFetched;
  final bool isSuccess;
  final String? errorMessage;
}

class PullListSyncManager {
  PullListSyncManager({
    required db.AppDatabase database,
    required MetronPullListRepository pullListRepository,
  })  : _database = database,
        _pullListRepository = pullListRepository;

  static const String _syncMetaKey = "metron_last_pull_list_sync";
  static const String _localUserId = "local-user";

  final db.AppDatabase _database;
  final MetronPullListRepository _pullListRepository;

  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  Future<PullListSyncResult> syncPullList() async {
    if (_isSyncing) {
      return const PullListSyncResult(
        seriesFetched: 0,
        issuesFetched: 0,
        isSuccess: false,
        errorMessage: "Pull list sync already in progress",
      );
    }

    _isSyncing = true;
    try {
      // 1. Sync Pull List Series (Subscriptions)
      var seriesPage = 1;
      final remoteSeries = <PullListSeriesItem>[];
      while (true) {
        final pageItems = await _pullListRepository.getPullListSeries(
          page: seriesPage,
        );
        if (pageItems.isEmpty) break;
        remoteSeries.addAll(pageItems);
        if (pageItems.length < 20) break;
        seriesPage++;
      }

      await _reconcileSubscriptions(remoteSeries);

      // 2. Sync Pull List Issues
      var issuePage = 1;
      final remoteIssues = <PullListIssueItem>[];
      final now = DateTime.now().toUtc();
      final storeDateAfter = now.subtract(const Duration(days: 30));
      final storeDateBefore = now.add(const Duration(days: 60));

      while (true) {
        final pageIssues = await _pullListRepository.getPullListIssues(
          page: issuePage,
          storeDateAfter: storeDateAfter,
          storeDateBefore: storeDateBefore,
        );
        if (pageIssues.isEmpty) break;
        remoteIssues.addAll(pageIssues);
        if (pageIssues.length < 20) break;
        issuePage++;
      }

      await _ingestPullListIssues(remoteIssues);

      await _database.syncMetaDao.set(_syncMetaKey, now.toIso8601String());

      AppLogger.info(
        "Pull list sync completed: ${remoteSeries.length} series, ${remoteIssues.length} issues",
      );

      return PullListSyncResult(
        seriesFetched: remoteSeries.length,
        issuesFetched: remoteIssues.length,
        isSuccess: true,
      );
    } catch (e, st) {
      AppLogger.error("Pull list sync failed", error: e, stackTrace: st);
      return PullListSyncResult(
        seriesFetched: 0,
        issuesFetched: 0,
        isSuccess: false,
        errorMessage: e.toString(),
      );
    } finally {
      _isSyncing = false;
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
        // Pending local modification, do not overwrite
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
            series.addedOn?.toIso8601String() ?? existing?.subscribedAt ?? nowIso,
          ),
          createdAt: Value(existing?.createdAt ?? nowIso),
          updatedAt: Value(nowIso),
        ),
      );
    }

    // Check for local active subscriptions no longer on remote
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

  Future<void> _ingestPullListIssues(List<PullListIssueItem> remoteIssues) async {
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
