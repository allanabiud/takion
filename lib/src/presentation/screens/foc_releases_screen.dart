import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/presentation/providers/issues_provider.dart';
import 'package:takion/src/presentation/widgets/weekly_issue_list_scaffold.dart';

@RoutePage()
class FocReleasesScreen extends ConsumerWidget {
  const FocReleasesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedWeekProvider);
    final issuesAsync = ref.watch(focReleasesProvider(selectedDate));

    return WeeklyIssueListScaffold(
      title: 'FOC Calendar',
      issuesAsync: issuesAsync,
      emptyMessage: 'No FOC issues for this week.',
    );
  }
}
