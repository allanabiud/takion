import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/presentation/providers/issues_provider.dart';
import 'package:takion/src/presentation/widgets/issue_list_tile.dart';

@RoutePage()
class ReleasesScreen extends ConsumerWidget {
  const ReleasesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final issuesAsync = ref.watch(weeklyReleasesProvider);

    return issuesAsync.when(
      data: (issues) => RefreshIndicator(
        onRefresh: () => ref.refresh(weeklyReleasesProvider.future),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: issues.length,
          itemBuilder: (context, index) {
            final issue = issues[index];
            final isFirst = index == 0;
            final isLast = index == issues.length - 1;

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
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }
}
