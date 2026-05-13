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
class FocReleasesScreen extends ConsumerWidget {
  const FocReleasesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedWeekProvider);
    final sortOption = ref.watch(
      sortPreferenceForContextProvider(SortPreferenceContext.releasesFoc),
    );
    final issuesAsync = ref.watch(focReleasesProvider(selectedDate));

    return WeeklyIssueListScaffold(
      title: 'FOC Calendar',
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
            SortPreferenceContext.releasesFoc,
            issueSortLabel,
          ),
        ),
        orElse: () => null,
      ),
      emptyMessage: 'No FOC issues for this week.',
      emptyIcon: Icons.event_note_outlined,
    );
  }
}
