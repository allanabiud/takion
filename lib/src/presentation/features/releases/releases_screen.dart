import "package:auto_route/auto_route.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/core/router/app_router.gr.dart";
import "package:takion/src/presentation/features/library/providers/subscription_pull_reconciler.dart";
import "package:takion/src/presentation/features/releases/providers/selected_week_provider.dart";
import "package:takion/src/presentation/features/releases/providers/weekly_releases_provider.dart";
import "package:takion/src/presentation/features/library/providers/pulls_provider.dart";
import "package:takion/src/presentation/features/series/providers/subscriptions_provider.dart";
import "package:takion/src/presentation/shared/widgets/components.dart";
import "package:takion/src/presentation/features/issues/issue_card.dart";
import "package:takion/src/presentation/features/issues/providers/issue_collection_status_provider.dart";

@RoutePage()
class ReleasesScreen extends ConsumerWidget {
  const ReleasesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(subscriptionPullReconcilerProvider).browseReconcile();
    });
    final currentIssuesAsync = ref.watch(weeklyReleasesProvider());
    final pullsCountAsync = ref.watch(currentWeekPullsCountProvider);
    final pullsAsync = ref.watch(currentWeekPullsProvider);
    final subscriptionsAsync = ref.watch(activeSubscriptionsProvider);
    final subscriptionsCount = ref.watch(activeSubscriptionsCountProvider);

    return Scaffold(
      appBar: currentIssuesAsync.isLoading || pullsAsync.isLoading
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
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  ActionCard(
                    icon: Icons.new_releases_outlined,
                    value: currentIssuesAsync.when(
                      data: (issues) => issues.length.toString(),
                      loading: () => "--",
                      error: (_, _) => "!",
                    ),
                    label: "This Week",
                    onTap: () {
                      ref
                          .read(selectedWeekProvider.notifier)
                          .setDate(DateTime.now());
                      context.pushRoute(const WeeklyReleasesRoute());
                    },
                  ),
                  const SizedBox(width: 4),
                  ActionCard(
                    icon: Icons.notifications_outlined,
                    value: subscriptionsAsync.isLoading
                        ? "--"
                        : subscriptionsCount.toString(),
                    label: "Subscriptions",
                    onTap: () {
                      context.pushRoute(const SubscriptionsRoute());
                    },
                  ),
                  const SizedBox(width: 4),
                  ActionCard(
                    icon: Icons.shopping_bag_outlined,
                    value: pullsAsync.isLoading
                        ? "--"
                        : pullsCountAsync.toString(),
                    label: "Pulls",
                    onTap: () {
                      ref
                          .read(selectedWeekProvider.notifier)
                          .setDate(DateTime.now());
                      context.pushRoute(const MyPullsRoute());
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            CompactListSection(
              title: "Browse",
              items: [
                CompactListSectionItem(
                  icon: Icons.new_releases_outlined,
                  label: "New #1s",
                  onTap: () {
                    ref
                        .read(selectedWeekProvider.notifier)
                        .setDate(DateTime.now());
                    context.pushRoute(const NewFirstIssuesRoute());
                  },
                ),
                CompactListSectionItem(
                  icon: Icons.calendar_month_outlined,
                  label: "FOC Calendar",
                  onTap: () {
                    ref
                        .read(selectedWeekProvider.notifier)
                        .setDate(DateTime.now());
                    context.pushRoute(const FocReleasesRoute());
                  },
                ),
              ],
            ),
            if (pullsCountAsync > 0)
              pullsAsync.when(
                data: (issues) {
                  if (issues.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  final previewIssues = issues.take(10).toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text.rich(
                          TextSpan(
                            text: "$pullsCountAsync",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                            children: [
                              TextSpan(
                                text: pullsCountAsync == 1
                                    ? " Pull This Week"
                                    : " Pulls This Week",
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 260,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          scrollDirection: Axis.horizontal,
                          itemCount: previewIssues.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final issue = previewIssues[index];
                            final issueId = issue.id;
                            final collectionStatus = issueId != null
                                ? ref.watch(
                                    issueCollectionStatusProvider(issueId),
                                  )
                                : null;
                            final pullEntryAsync = issueId != null
                                ? ref.watch(issuePullListEntryProvider(issueId))
                                : null;
                            final isCollected =
                                collectionStatus?.isCollected ?? false;
                            final isWishlisted =
                                collectionStatus?.isWishlisted ?? false;
                            final isRead = collectionStatus?.isRead ?? false;
                            final isPulled =
                                pullEntryAsync?.asData?.value != null;

                            return IssueCard(
                              issueId: issueId,
                              imageUrl: issue.image,
                              title: issue.name,
                              seriesId: issue.series?.id,
                              seriesName: issue.series?.name,
                              issueNumber: issue.number,
                              isCollected: isCollected,
                              isWishlisted: isWishlisted,
                              isRead: isRead,
                              isPulled: isPulled,
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
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                },
                loading: () => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SizedBox(
                    height: 232,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: 5,
                      separatorBuilder: (_, _) => const SizedBox(width: 12),
                      itemBuilder: (_, _) =>
                          const ShimmerWidget(child: IssueCardSkeleton()),
                    ),
                  ),
                ),
                error: (_, _) => const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text("Could not load pulls preview."),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
