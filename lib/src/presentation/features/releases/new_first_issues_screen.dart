import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/presentation/features/releases/providers/selected_week_provider.dart';
import 'package:takion/src/presentation/features/releases/providers/weekly_releases_provider.dart';
import 'package:takion/src/presentation/providers/providers.dart';
import 'package:takion/src/presentation/logic/content_sorting.dart';
import 'package:takion/src/presentation/components/components.dart';

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

    return PagedIssueListScaffold(
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
