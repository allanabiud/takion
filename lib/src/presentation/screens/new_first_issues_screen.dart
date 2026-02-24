import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/presentation/providers/issues_provider.dart';
import 'package:takion/src/presentation/widgets/weekly_issue_list_scaffold.dart';

@RoutePage()
class NewFirstIssuesScreen extends ConsumerWidget {
  const NewFirstIssuesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedWeekProvider);
    final issuesAsync = ref.watch(weeklyReleasesProvider(selectedDate));

    return WeeklyIssueListScaffold(
      title: 'New #1 Issues',
      issuesAsync: issuesAsync,
      emptyMessage: 'No new #1s this week',
      transformIssues: (issues) => issues.where((issue) => issue.number == '1').toList(),
    );
  }
}
