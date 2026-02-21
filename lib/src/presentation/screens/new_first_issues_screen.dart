import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/presentation/providers/issues_provider.dart';
import 'package:takion/src/presentation/widgets/issue_list_tile.dart';
import 'package:takion/src/presentation/widgets/week_picker_bar.dart';

@RoutePage()
class NewFirstIssuesScreen extends ConsumerWidget {
  const NewFirstIssuesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedWeekProvider);
    final issuesAsync = ref.watch(weeklyReleasesProvider(selectedDate));

    return Scaffold(
      appBar: AppBar(title: const Text('New #1 Issues')),
      body: Column(
        children: [
          const WeekPickerBar(),
          issuesAsync.when(
            data: (issues) {
              final firstIssuesCount = issues.where((i) => i.number == '1').length;
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Found $firstIssuesCount new #1s',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          Expanded(
            child: issuesAsync.when(
              data: (issues) {
                final firstIssues = issues
                    .where((i) => i.number == '1')
                    .toList();

                if (firstIssues.isEmpty) {
                  return const Center(child: Text('No new #1s this week'));
                }

                return RefreshIndicator(
                  onRefresh: () =>
                      ref.refresh(weeklyReleasesProvider(selectedDate).future),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: firstIssues.length,
                    itemBuilder: (context, index) {
                      final issue = firstIssues[index];
                      final isFirst = index == 0;
                      final isLast = index == firstIssues.length - 1;

                      return IssueListTile(
                        issue: issue,
                        isFirst: isFirst,
                        isLast: isLast,
                        onTap: () {
                          // Navigate to details
                        },
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}
