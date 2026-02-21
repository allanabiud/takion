import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/presentation/providers/issues_provider.dart';
import 'package:takion/src/presentation/widgets/action_card.dart';

@RoutePage()
class ReleasesScreen extends ConsumerWidget {
  const ReleasesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // This provider always fetches for the actual current week (DateTime.now)
    final currentIssuesAsync = ref.watch(currentWeeklyReleasesProvider);

    return Scaffold(
      appBar: currentIssuesAsync.isLoading
          ? AppBar(
              toolbarHeight: 0,
              bottom: const PreferredSize(
                preferredSize: Size.fromHeight(4),
                child: LinearProgressIndicator(),
              ),
            )
          : null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  ActionCard(
                    icon: Icons.new_releases_outlined,
                    value: currentIssuesAsync.when(
                      data: (issues) => issues.length.toString(),
                      loading: () => '--',
                      error: (_, __) => '!',
                    ),
                    label: 'This Week',
                    onTap: () {
                      ref
                          .read(selectedWeekProvider.notifier)
                          .setDate(DateTime.now());
                      context.pushRoute(const WeeklyReleasesRoute());
                    },
                  ),
                  const SizedBox(width: 8),
                  ActionCard(
                    icon: Icons.star_outline,
                    value: currentIssuesAsync.when(
                      data: (issues) => issues
                          .where((i) => i.number == '1')
                          .length
                          .toString(),
                      loading: () => '--',
                      error: (_, __) => '!',
                    ),
                    label: 'New #1s',
                    onTap: () {
                      ref
                          .read(selectedWeekProvider.notifier)
                          .setDate(DateTime.now());
                      context.pushRoute(const NewFirstIssuesRoute());
                    },
                  ),
                  const SizedBox(width: 8),
                  ActionCard(
                    icon: Icons.history_outlined,
                    value: '--',
                    label: 'Last Week',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
