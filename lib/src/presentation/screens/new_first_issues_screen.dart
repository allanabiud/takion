import 'package:auto_route/auto_route.dart';
import 'package:expressive_refresh/expressive_refresh.dart';
import 'package:flutter/material.dart' hide RefreshIndicatorTriggerMode;
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
      appBar: AppBar(
        title: const Text('New #1 Issues'),
        bottom: issuesAsync.isLoading
            ? const PreferredSize(
                preferredSize: Size.fromHeight(4),
                child: LinearProgressIndicator(),
              )
            : null,
      ),
      body: Column(
        children: [
          const WeekPickerBar(),
          Expanded(
            child: ExpressiveRefreshIndicator(
              displacement: 80,
              triggerMode: RefreshIndicatorTriggerMode.anywhere,
              color: Theme.of(context).colorScheme.primary,
              onRefresh: () async {
                // ignore: unused_result
                await ref.refresh(weeklyReleasesProvider(selectedDate).future);
              },
              child: issuesAsync.when(
                data: (issues) {
                  final firstIssues = issues
                      .where((i) => i.number == '1')
                      .toList();

                  if (firstIssues.isEmpty) {
                    return const Center(child: Text('No new #1s this week'));
                  }

                  return ListView.builder(
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
                        onTap: () {},
                      );
                    },
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (err, stack) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text('Error: $err', textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
