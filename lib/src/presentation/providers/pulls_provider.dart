import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities/issue_list.dart';
import 'package:takion/src/domain/entities/pull_list_entry.dart';
import 'package:takion/src/domain/entities/series_subscription.dart';
import 'package:takion/src/presentation/providers/issues_provider.dart';
import 'package:takion/src/presentation/providers/repository_providers.dart';

DateTime _weekStart(DateTime date) {
  final normalized = DateTime(date.year, date.month, date.day);
  final offset = normalized.weekday % 7;
  return normalized.subtract(Duration(days: offset));
}

DateTime _weekEnd(DateTime date) =>
    _weekStart(date).add(const Duration(days: 6));

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

      return weeklyIssues.where((issue) {
        final issueId = issue.id;
        return issueId != null && issueIds.contains(issueId);
      }).toList();
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
