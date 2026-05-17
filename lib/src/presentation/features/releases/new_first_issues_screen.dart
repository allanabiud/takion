import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/presentation/features/issues/providers/issues_provider.dart';
import 'package:takion/src/presentation/providers/sort_preferences_provider.dart';
import 'package:takion/src/presentation/logic/content_sorting.dart';
import 'package:takion/src/presentation/components/list_header.dart';
import 'package:takion/src/presentation/components/sort_bottom_sheet.dart';
import 'package:takion/src/presentation/features/releases/weekly_issue_list_scaffold.dart';

@RoutePage()
class NewFirstIssuesScreen extends ConsumerWidget {
  const NewFirstIssuesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedWeekProvider);
    final sortOption = ref.watch(
      sortPreferenceForContextProvider(SortPreferenceContext.releasesNewFirst),
    );
    final issuesAsync = ref.watch(weeklyReleasesProvider(selectedDate));

    return WeeklyIssueListScaffold(
      title: 'New #1 Issues',
      issuesAsync: issuesAsync,
      emptyMessage: 'No new #1s this week',
      emptyIcon: Icons.looks_one_outlined,
      transformIssues: (issues) => sortIssues(
        issues.where((issue) => issue.number == '1').toList(),
        sortOption,
      ),
      header: issuesAsync.maybeWhen(
        data: (issues) {
          final firstIssues = issues.where((i) => i.number == '1').toList();
          return ListHeader(
            count: firstIssues.length,
            unit: 'issue',
            sortLabel: issueSortLabel(sortOption),
            onSortTap: () => showSortBottomSheet(
              context,
              ref,
              SortPreferenceContext.releasesNewFirst,
              issueSortLabel,
            ),
          );
        },
        orElse: () => null,
      ),
    );
  }
}
