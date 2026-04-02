import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/storage/hive_service.dart';
import 'package:takion/src/domain/entities/issue_list.dart';
import 'package:takion/src/domain/entities/pull_list_entry.dart';
import 'package:takion/src/domain/entities/series_subscription.dart';
import 'package:takion/src/presentation/providers/issues_provider.dart';
import 'package:takion/src/presentation/providers/repository_providers.dart';
import 'package:takion/src/presentation/providers/subscriptions_provider.dart';

DateTime _weekStart(DateTime date) {
  final normalized = DateTime(date.year, date.month, date.day);
  final offset = normalized.weekday % 7;
  return normalized.subtract(Duration(days: offset));
}

DateTime _weekEnd(DateTime date) =>
    _weekStart(date).add(const Duration(days: 6));

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

  Future<int> reconcile({bool force = false, int? onlySeriesId}) async {
    final runNow = await _shouldRun(force: force, onlySeriesId: onlySeriesId);
    if (!runNow) return 0;

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
      return 0;
    }

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

    for (final seriesId in seriesIds) {
      var page = 1;
      while (true) {
        final issuePage = await metronRepository.getSeriesIssueList(
          seriesId,
          page: page,
        );
        for (final issue in issuePage.results) {
          final issueId = issue.id;
          if (issueId == null || uniqueIssueIds.contains(issueId)) continue;
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
        final nextPage = issuePage.nextPage;
        if (nextPage == null) break;
        page = nextPage;
      }
    }

    await flushBatch();
    if (onlySeriesId == null) {
      await _recordRun();
    }
    return upserted;
  }
}

final subscriptionPullReconcilerProvider = Provider<SubscriptionPullReconciler>(
  (ref) {
    return SubscriptionPullReconciler(ref);
  },
);

final issuePullListEntryProvider = FutureProvider.autoDispose
    .family<PullListEntry?, int>((ref, issueId) {
      final repository = ref.watch(pullListRepositoryProvider);
      return repository.getEntryByIssueId(issueId);
    });

final seriesSubscriptionProvider = FutureProvider.autoDispose
    .family<SeriesSubscription?, int>((ref, seriesId) {
      final repository = ref.watch(subscriptionRepositoryProvider);
      return repository.getSubscriptionBySeriesId(seriesId);
    });

final pullListEntriesForWeekProvider = FutureProvider.autoDispose
    .family<List<PullListEntry>, DateTime>((ref, date) async {
      final repository = ref.watch(pullListRepositoryProvider);
      return repository.listEntries(
        fromDate: _weekStart(date),
        toDate: _weekEnd(date),
        status: PullListEntryStatus.upcoming,
        limit: 500,
      );
    });

final pullsIssuesForWeekProvider = FutureProvider.autoDispose
    .family<List<IssueList>, DateTime>((ref, date) async {
      final weeklyIssues = await ref.watch(weeklyReleasesProvider(date).future);
      final pullEntries = await ref.watch(
        pullListEntriesForWeekProvider(date).future,
      );
      final issueIds = pullEntries.map((entry) => entry.metronIssueId).toSet();

      final activeSubscriptions = await ref.watch(
        activeSubscriptionsProvider.future,
      );
      final subscribedSeriesIds = activeSubscriptions
          .map((s) => s.metronSeriesId)
          .toSet();

      final issuesToPull = <IssueList>[];
      final missingSubscriptionEntries =
          <({int metronSeriesId, int metronIssueId, DateTime? releaseDate})>[];

      for (final issue in weeklyIssues) {
        final issueId = issue.id;
        if (issueId == null) continue;

        if (issueIds.contains(issueId)) {
          issuesToPull.add(issue);
          continue;
        }

        final seriesId = issue.series?.id;
        if (seriesId != null && subscribedSeriesIds.contains(seriesId)) {
          issuesToPull.add(issue);
          missingSubscriptionEntries.add((
            metronSeriesId: seriesId,
            metronIssueId: issueId,
            releaseDate: issue.storeDate ?? issue.coverDate,
          ));
        }
      }

      if (missingSubscriptionEntries.isNotEmpty) {
        // Run this in the background to avoid blocking the UI,
        // but it will ensure the pull list is updated in Supabase
        ref
            .read(pullListRepositoryProvider)
            .upsertSubscriptionEntries(missingSubscriptionEntries)
            .then((_) {
              // Invalidate pull list provider for this week to reflect changes
              ref.invalidate(pullListEntriesForWeekProvider(date));
            });
      }

      return issuesToPull;
    });

final currentWeekPullsProvider = FutureProvider.autoDispose<List<IssueList>>((
  ref,
) async {
  final pulls = await ref.watch(
    pullsIssuesForWeekProvider(DateTime.now()).future,
  );
  return pulls;
});

final currentWeekPullsCountProvider = Provider<int>((ref) {
  final pullsAsync = ref.watch(currentWeekPullsProvider);
  return pullsAsync.maybeWhen(data: (pulls) => pulls.length, orElse: () => 0);
});
