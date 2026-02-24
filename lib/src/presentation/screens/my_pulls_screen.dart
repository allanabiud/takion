import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/presentation/providers/issues_provider.dart';
import 'package:takion/src/presentation/providers/pulls_provider.dart';
import 'package:takion/src/presentation/widgets/weekly_issue_list_scaffold.dart';

@RoutePage()
class MyPullsScreen extends ConsumerWidget {
  const MyPullsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedWeekProvider);
    final pullsAsync = ref.watch(pullsIssuesForWeekProvider(selectedDate));

    return WeeklyIssueListScaffold(
      title: 'My Pulls',
      issuesAsync: pullsAsync,
      emptyMessage: 'No pulls for this week.',
      errorTextBuilder: (error) => 'Failed to load pulls: $error',
    );
  }
}
