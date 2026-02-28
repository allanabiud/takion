import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities/issue_list.dart';
import 'package:takion/src/domain/entities/series.dart';
import 'package:takion/src/presentation/providers/collection_items_provider.dart';
import 'package:takion/src/presentation/providers/issues_provider.dart';

String _normalizeSeriesName(String name) {
  return name.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}

String _seriesKey(Series series) {
  return '${_normalizeSeriesName(series.name)}|${series.volume ?? -1}|${series.yearBegan ?? -1}';
}

final pullsIssuesForWeekProvider = FutureProvider.autoDispose
    .family<List<IssueList>, DateTime>((ref, date) async {
      final weeklyIssues = await ref.watch(weeklyReleasesProvider(date).future);
      final collectionSeriesKeys = await ref.watch(
        collectionSeriesKeysProvider.future,
      );

      return weeklyIssues.where((issue) {
        final series = issue.series;
        if (series == null) return false;
        return collectionSeriesKeys.contains(_seriesKey(series));
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
