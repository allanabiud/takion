import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/presentation/providers/issues_provider.dart';
import 'package:takion/src/presentation/widgets/issue_list_tile.dart';
import 'package:takion/src/presentation/widgets/week_picker_bar.dart';

@RoutePage()
class WeeklyReleasesScreen extends ConsumerWidget {
  const WeeklyReleasesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedWeekProvider);
    final issuesAsync = ref.watch(weeklyReleasesProvider(selectedDate));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Releases'),
        bottom: issuesAsync.isLoading || issuesAsync.isRefreshing
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
            child: RefreshIndicator(
              onRefresh: () async {
                await ref
                    .read(weeklyReleasesProvider(selectedDate).notifier)
                    .refresh();
              },
              child: issuesAsync.when(
                data: (issues) => ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: issues.length,
                  itemBuilder: (context, index) {
                    final issue = issues[index];
                    final isFirst = index == 0;
                    final isLast = index == issues.length - 1;

                    return IssueListTile(
                      issue: issue,
                      isFirst: isFirst,
                      isLast: isLast,
                      onTap: () {},
                    );
                  },
                ),
                loading: () => const SizedBox.shrink(),
                error: (err, stack) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
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
          ),
        ],
      ),
    );
  }
}
