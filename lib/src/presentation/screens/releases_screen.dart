import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/presentation/providers/issues_provider.dart';
import 'package:takion/src/presentation/providers/pulls_provider.dart';
import 'package:takion/src/presentation/widgets/action_card.dart';
import 'package:takion/src/presentation/widgets/compact_list_section.dart';
import 'package:takion/src/presentation/widgets/media_card.dart';
import 'package:takion/src/presentation/widgets/takion_alerts.dart';

@RoutePage()
class ReleasesScreen extends ConsumerWidget {
  const ReleasesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // This provider always fetches for the actual current week (DateTime.now)
    final currentIssuesAsync = ref.watch(currentWeeklyReleasesProvider);
    final pullsCountAsync = ref.watch(currentWeekPullsCountProvider);

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
          crossAxisAlignment: CrossAxisAlignment.start,
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
                      error: (_, _) => '!',
                    ),
                    label: 'This Week',
                    onTap: () {
                      ref.read(selectedWeekProvider.notifier).setDate(DateTime.now());
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
                      error: (_, _) => '!',
                    ),
                    label: 'New #1s',
                    onTap: () {
                      ref.read(selectedWeekProvider.notifier).setDate(DateTime.now());
                      context.pushRoute(const NewFirstIssuesRoute());
                    },
                  ),
                  const SizedBox(width: 8),
                  ActionCard(
                    icon: Icons.shopping_bag_outlined,
                    value: pullsCountAsync.when(
                      data: (count) => count.toString(),
                      loading: () => '--',
                      error: (_, _) => '!',
                    ),
                    label: 'Your Pulls',
                    onTap: () {
                      ref.read(selectedWeekProvider.notifier).setDate(DateTime.now());
                      context.pushRoute(const MyPullsRoute());
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'This Week Preview',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 10),
            currentIssuesAsync.when(
              data: (issues) {
                if (issues.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('No releases found for this week.'),
                  );
                }

                final previewIssues = issues.take(10).toList();

                return SizedBox(
                  height: 232,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: previewIssues.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final issue = previewIssues[index];
                      final issueId = issue.id;

                      return MediaCard(
                        imageUrl: issue.image,
                        title: issue.name,
                        heroTag: issueId != null ? 'issue-cover-$issueId' : null,
                        onTap: issueId == null
                            ? null
                            : () {
                                context.pushRoute(
                                  IssueDetailsRoute(
                                    issueId: issueId,
                                    initialImageUrl: issue.image,
                                  ),
                                );
                              },
                      );
                    },
                  ),
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  height: 232,
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (_, _) => const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text('Could not load this week preview.'),
              ),
            ),
            const SizedBox(height: 16),
            CompactListSection(
              title: 'Browse',
              items: [
                CompactListSectionItem(
                  icon: Icons.calendar_month_outlined,
                  label: 'FOC Calendar',
                  onTap: () {
                    TakionAlerts.comingSoon(context, 'FOC Calendar');
                  },
                ),
                CompactListSectionItem(
                  icon: Icons.upcoming_outlined,
                  label: 'Upcoming #1s',
                  onTap: () {
                    TakionAlerts.comingSoon(context, 'Upcoming #1s');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
