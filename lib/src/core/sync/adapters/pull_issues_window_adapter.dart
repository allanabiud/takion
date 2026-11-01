import "package:drift/drift.dart";
import "package:takion/src/core/logging/app_logger.dart";
import "package:takion/src/core/sync/adapters/remote_sync_adapter.dart";
import "package:takion/src/data/common/drift/daos/pull_list_dao.dart";
import "package:takion/src/data/common/drift/daos/sync_cursor_dao.dart";
import "package:takion/src/data/common/drift/database.dart";
import "package:takion/src/data/pull_list/datasources/remote/metron_pull_list_remote_data_source.dart";
import "package:takion/src/data/pull_list/dto/pull_list_dto.dart";
import "package:uuid/uuid.dart";

class PullIssuesWindowAdapter implements RemoteSyncAdapter {
  PullIssuesWindowAdapter({
    required AppDatabase db,
    required MetronPullListRemoteDataSource remoteDataSource,
    required PullListDao pullListDao,
    required SyncCursorDao cursorDao,
    this.pastDays = 30,
    this.futureDays = 60,
  }) : _db = db,
       _remoteDataSource = remoteDataSource,
       _pullListDao = pullListDao,
       _cursorDao = cursorDao;

  @override
  String get resource => "pull_issues";

  final AppDatabase _db;
  final MetronPullListRemoteDataSource _remoteDataSource;
  final PullListDao _pullListDao;
  final SyncCursorDao _cursorDao;
  final int pastDays;
  final int futureDays;
  static const _uuid = Uuid();

  @override
  Future<SyncAdapterResult> sync({
    required String accountId,
    required SyncBudget budget,
    bool forceFullSync = false,
    void Function(int count)? onProgress,
  }) async {
    final now = DateTime.now().toUtc();
    final defaultAfter = now.subtract(Duration(days: pastDays));
    final defaultBefore = now.add(Duration(days: futureDays));

    var cursor = await _cursorDao.loadCursor(accountId, resource);

    final bool isResuming = cursor.nextUrl != null && cursor.scanId != null;
    final String scanId = isResuming ? cursor.scanId! : _uuid.v4();
    final DateTime scanStartedAt = isResuming
        ? (cursor.scanStartedAt ?? now)
        : now;

    // Use stored window dates if resuming, or calculate new window
    final DateTime storeDateAfter =
        isResuming && cursor.extra["storeDateAfter"] != null
        ? DateTime.parse(cursor.extra["storeDateAfter"] as String)
        : defaultAfter;
    final DateTime storeDateBefore =
        isResuming && cursor.extra["storeDateBefore"] != null
        ? DateTime.parse(cursor.extra["storeDateBefore"] as String)
        : defaultBefore;

    Uri? nextUrl = cursor.nextUrl;
    var totalFetched = 0;
    var totalUpdated = 0;
    final seenIssueIds = <int>{};

    AppLogger.info(
      "Starting PullIssues window sync (resuming: $isResuming, nextUrl: $nextUrl, window: $storeDateAfter -> $storeDateBefore)",
    );

    try {
      while (budget.canMakeAnotherRequest) {
        budget.recordRequest();

        final page = await _remoteDataSource.getPullListIssuesPage(
          pageUrl: nextUrl,
          storeDateAfter: nextUrl == null ? storeDateAfter : null,
          storeDateBefore: nextUrl == null ? storeDateBefore : null,
        );

        totalFetched += page.items.length;
        for (final item in page.items) {
          seenIssueIds.add(item.issueId);
        }

        await _db.transaction(() async {
          final updatedInPage = await _ingestIssues(
            page.items,
            accountId: accountId,
          );
          totalUpdated += updatedInPage;
          onProgress?.call(totalUpdated);

          cursor = cursor.copyWith(
            scanId: scanId,
            scanStartedAt: scanStartedAt,
            nextUrl: page.next,
            clearNextUrl: page.next == null,
            extra: {
              "storeDateAfter": storeDateAfter.toIso8601String(),
              "storeDateBefore": storeDateBefore.toIso8601String(),
            },
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
        // Complete scan: prune only within the exact completed store-date window
        final pruned = await _pullListDao.reconcileMissingInWindow(
          storeDateAfter: storeDateAfter,
          storeDateBefore: storeDateBefore,
          seenIssueIds: seenIssueIds,
        );
        AppLogger.info(
          "PullIssues window complete: pruned $pruned missing issues from window",
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
      AppLogger.error("PullIssues sync error: $e", error: e, stackTrace: st);
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

  Future<int> _ingestIssues(
    List<PullListIssueDto> remoteIssues, {
    required String accountId,
  }) async {
    if (remoteIssues.isEmpty) return 0;

    final nowIso = DateTime.now().toUtc().toIso8601String();
    final companions = <PullListEntriesCompanion>[];

    for (final issue in remoteIssues) {
      final existing = await _pullListDao.getByIssueId(issue.issueId);

      // Preserve local uncommitted modifications
      if (existing != null && existing.syncStatus != "synced") {
        continue;
      }

      final storeDate = issue.storeDate != null
          ? DateTime.tryParse(issue.storeDate!)
          : (issue.coverDate != null
                ? DateTime.tryParse(issue.coverDate!)
                : null);

      companions.add(
        PullListEntriesCompanion(
          id: Value(existing?.id ?? "pull-${issue.issueId}"),
          userId: Value(accountId),
          metronIssueId: Value(issue.issueId),
          metronSeriesId: Value(issue.seriesId),
          metronPullListId: Value(issue.id),
          syncStatus: const Value("synced"),
          entryStatus: Value(existing?.entryStatus ?? "upcoming"),
          releaseDate: Value(storeDate),
          source: const Value("subscription"),
          generatedAt: Value(existing?.generatedAt ?? nowIso),
          createdAt: Value(existing?.createdAt ?? nowIso),
          updatedAt: Value(nowIso),
        ),
      );
    }

    if (companions.isNotEmpty) {
      await _pullListDao.batchUpsert(companions);
    }

    return companions.length;
  }
}
