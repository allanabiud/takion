import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/presentation/providers/issues_provider.dart';
import 'package:takion/src/presentation/providers/sort_preferences_provider.dart';
import 'package:takion/src/presentation/sorting/content_sorting.dart';
import 'package:takion/src/presentation/widgets/display_settings_button.dart';
import 'package:takion/src/presentation/widgets/weekly_issue_list_scaffold.dart';

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
      appBarActions: [
        DisplaySettingsButton(
          selectedOption: sortOption,
          optionLabel: issueSortLabel,
          onSelected: (option) {
            ref
                .read(sortPreferencesProvider.notifier)
                .setPreference(SortPreferenceContext.releasesNewFirst, option);
          },
        ),
      ],
    );
  }
}
