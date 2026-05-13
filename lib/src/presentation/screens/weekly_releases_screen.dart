import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/presentation/providers/issues_provider.dart';
import 'package:takion/src/presentation/providers/sort_preferences_provider.dart';
import 'package:takion/src/presentation/sorting/content_sorting.dart';
import 'package:takion/src/presentation/widgets/list_header.dart';
import 'package:takion/src/presentation/widgets/sort_bottom_sheet.dart';
import 'package:takion/src/presentation/widgets/weekly_issue_list_scaffold.dart';

@RoutePage()
class WeeklyReleasesScreen extends ConsumerWidget {
  const WeeklyReleasesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedWeekProvider);
    final sortOption = ref.watch(
      sortPreferenceForContextProvider(SortPreferenceContext.releasesWeekly),
    );
    final issuesAsync = ref.watch(weeklyReleasesProvider(selectedDate));

    return WeeklyIssueListScaffold(
      title: 'Weekly Releases',
      issuesAsync: issuesAsync,
      transformIssues: (issues) => sortIssues(issues, sortOption),
      header: issuesAsync.maybeWhen(
        data: (issues) => ListHeader(
          count: issues.length,
          unit: 'issue',
          sortLabel: issueSortLabel(sortOption),
          onSortTap: () => showSortBottomSheet(
            context,
            ref,
            SortPreferenceContext.releasesWeekly,
            issueSortLabel,
          ),
        ),
        orElse: () => null,
      ),
      emptyMessage: 'No weekly releases for this week.',
      emptyIcon: Icons.new_releases_outlined,
    );
  }
}
