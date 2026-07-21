import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/storage/hive_service.dart';
import 'package:takion/src/domain/entities/entities.dart';
import 'package:takion/src/presentation/providers/providers.dart';

DateTime _weekStart(DateTime date) {
  final normalized = DateTime(date.year, date.month, date.day);
  final offset = normalized.weekday % 7;
  return normalized.subtract(Duration(days: offset));
}

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

class SubscriptionPullReconciler {
  SubscriptionPullReconciler(this.ref);

  static const _settingsBoxName = 'settings_box';
  static const _lastRunEpochKey = 'subscription_pull_reconcile_last_run_ms';
  static const _throttleWindow = Duration(hours: 12);
  static const _subscriptionPageSize = 200;
  static const _upsertBatchSize = 250;

  final Ref ref;

  DateTime _futureHorizon(DateTime fromDate) {
    return DateTime(fromDate.year + 1, fromDate.month, fromDate.day);
  }

  Future<bool> _shouldRun({
    required bool force,
    required int? onlySeriesId,
  }) async {
    if (force || onlySeriesId != null) return true;
    final hive = ref.read(hiveServiceProvider);
    final box = await hive.openBox<dynamic>(_settingsBoxName);
    final lastRunEpoch = box.get(_lastRunEpochKey) as int?;
    if (lastRunEpoch == null) return true;
    final lastRun = DateTime.fromMillisecondsSinceEpoch(lastRunEpoch);
    return DateTime.now().difference(lastRun) >= _throttleWindow;
  }

  Future<void> _recordRun() async {
    final hive = ref.read(hiveServiceProvider);
    final box = await hive.openBox<dynamic>(_settingsBoxName);
    await box.put(_lastRunEpochKey, DateTime.now().millisecondsSinceEpoch);
  }

  Future<List<SeriesSubscription>> _listAllActiveSubscriptions() async {
    final subscriptionRepository = ref.read(subscriptionRepositoryProvider);
    final subscriptions = <SeriesSubscription>[];
    var offset = 0;

    while (true) {
      final page = await subscriptionRepository.listSubscriptions(
        limit: _subscriptionPageSize,
        offset: offset,
      );
      if (page.isEmpty) break;
      subscriptions.addAll(page);
      if (page.length < _subscriptionPageSize) break;
      offset += page.length;
    }
    return subscriptions;
  }

  Future<ReconcileResult> reconcile({
    bool force = false,
    int? onlySeriesId,
  }) async {
    final runNow = await _shouldRun(force: force, onlySeriesId: onlySeriesId);
    if (!runNow) return const ReconcileResult(upserted: 0, issueIds: []);

    final metronRepository = ref.read(metronRepositoryProvider);
    final pullListRepository = ref.read(pullListRepositoryProvider);
    final fromDate = _weekStart(DateTime.now());
    final toDate = _futureHorizon(fromDate);
    final subscriptions = await _listAllActiveSubscriptions();
    final seriesIds = subscriptions
        .where((subscription) => subscription.autoAddToPullList)
        .where(
          (subscription) =>
              onlySeriesId == null ||
              subscription.metronSeriesId == onlySeriesId,
        )
        .map((subscription) => subscription.metronSeriesId)
        .toList(growable: false);

    if (seriesIds.isEmpty) {
      if (onlySeriesId == null) {
        await _recordRun();
      }
      return const ReconcileResult(upserted: 0, issueIds: []);
    }

    final hive = ref.read(hiveServiceProvider);
    final box = await hive.openBox<dynamic>(_settingsBoxName);
    final lastRunEpoch = box.get(_lastRunEpochKey) as int?;
    final lastRun = lastRunEpoch != null
        ? DateTime.fromMillisecondsSinceEpoch(lastRunEpoch)
        : null;

    final useDelta =
        lastRun != null &&
        DateTime.now().difference(lastRun).inDays <= 30 &&
        onlySeriesId == null;

    final uniqueIssueIds = <int>{};
    final batch =
        <({int metronSeriesId, int metronIssueId, DateTime? releaseDate})>[];
    var upserted = 0;

    Future<void> flushBatch() async {
      if (batch.isEmpty) return;
      await pullListRepository.upsertSubscriptionEntries(
        List<
          ({int metronSeriesId, int metronIssueId, DateTime? releaseDate})
        >.of(batch),
      );
      upserted += batch.length;
      batch.clear();
    }

    if (useDelta) {
      String? nextUrl;
      final subscriptionSeriesIds = seriesIds.toSet();
      while (true) {
        final issuePage = await metronRepository.getIssueList(
          nextUrl: nextUrl,
          modifiedGt: lastRun,
        );
        for (final issue in issuePage.results) {
          final issueId = issue.id;
          final seriesId = issue.series?.id;
          if (issueId == null || seriesId == null) continue;
          if (!subscriptionSeriesIds.contains(seriesId)) continue;
          if (uniqueIssueIds.contains(issueId)) continue;
          final releaseDate = issue.storeDate ?? issue.coverDate;
          if (releaseDate == null) continue;
          final releaseDay = _dateOnly(releaseDate);
          if (releaseDay.isBefore(fromDate) || releaseDay.isAfter(toDate)) {
            continue;
          }
          uniqueIssueIds.add(issueId);
          batch.add((
            metronSeriesId: seriesId,
            metronIssueId: issueId,
            releaseDate: releaseDay,
          ));
          if (batch.length >= _upsertBatchSize) {
            await flushBatch();
          }
        }
        nextUrl = issuePage.next;
        if (nextUrl == null) break;
      }
    } else {
      for (final seriesId in seriesIds) {
        String? nextUrl;
        while (true) {
          final issuePage = await metronRepository.getSeriesIssueList(
            seriesId,
            nextUrl: nextUrl,
            ordering: '-store_date',
            storeDateGte: fromDate,
            storeDateLte: toDate,
          );
          var pageHasInWindow = false;
          var anyBeforeWindow = false;
          for (final issue in issuePage.results) {
            final issueId = issue.id;
            if (issueId == null || uniqueIssueIds.contains(issueId)) continue;
            final releaseDate = issue.storeDate ?? issue.coverDate;
            if (releaseDate == null) continue;
            final releaseDay = _dateOnly(releaseDate);
            if (releaseDay.isBefore(fromDate)) {
              anyBeforeWindow = true;
              continue;
            }
            if (releaseDay.isAfter(toDate)) {
              continue;
            }
            pageHasInWindow = true;
            uniqueIssueIds.add(issueId);
            batch.add((
              metronSeriesId: seriesId,
              metronIssueId: issueId,
              releaseDate: releaseDay,
            ));
            if (batch.length >= _upsertBatchSize) {
              await flushBatch();
            }
          }
          final nextPage = issuePage.nextPage;
          if (nextPage == null) break;
          // Ordered by -store_date (newest first). Once we hit a page with
          // no in-window issues and at least one issue before the window,
          // all subsequent pages will be older still — safe to break.
          if (!pageHasInWindow && anyBeforeWindow) break;
          nextUrl = issuePage.next;
        }
      }
    }

    await flushBatch();
    if (onlySeriesId == null) {
      await _recordRun();
    }
    return ReconcileResult(
      upserted: upserted,
      issueIds: uniqueIssueIds.toList(),
    );
  }
}

class ReconcileResult {
  const ReconcileResult({required this.upserted, required this.issueIds});
  final int upserted;
  final List<int> issueIds;
}

final subscriptionPullReconcilerProvider = Provider<SubscriptionPullReconciler>(
  (ref) {
    return SubscriptionPullReconciler(ref);
  },
);
