import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities/entities.dart';
import 'package:takion/src/presentation/features/releases/providers/weekly_releases_provider.dart';
import 'package:takion/src/presentation/providers/providers.dart';
import 'package:takion/src/presentation/features/series/providers/subscriptions_provider.dart';

DateTime weekStart(DateTime date) {
  final normalized = DateTime(date.year, date.month, date.day);
  final offset = normalized.weekday % 7;
  return normalized.subtract(Duration(days: offset));
}

DateTime weekEnd(DateTime date) =>
    weekStart(date).add(const Duration(days: 6));

DateTime dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

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
        fromDate: weekStart(date),
        toDate: weekEnd(date),
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
        }
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
