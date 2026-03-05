import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/presentation/providers/because_you_pulled_provider.dart';
import 'package:takion/src/presentation/providers/continue_reading_provider.dart';
import 'package:takion/src/presentation/providers/home_trending_provider.dart';
import 'package:takion/src/presentation/providers/issue_collection_status_provider.dart';
import 'package:takion/src/presentation/providers/pulls_provider.dart';
import 'package:takion/src/presentation/widgets/issue_card.dart';

@RoutePage()
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestionsAsync = ref.watch(homeTrendingProvider);
    final continueReadingAsync = ref.watch(continueReadingSuggestionsProvider);
    final becauseYouPulledAsync = ref.watch(becauseYouPulledIssuesProvider);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 20, bottom: 20),
        child: Column(
          children: [
            suggestionsAsync.when(
              data: (suggestions) {
                if (suggestions.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('No trending releases available yet.'),
                  );
                }

                return SizedBox(
                  height: 240,
                  child: PageView.builder(
                    controller: PageController(viewportFraction: 0.92),
                    itemCount: suggestions.length,
                    itemBuilder: (context, index) {
                      final suggestion = suggestions[index];
                      final issue = suggestion.issue;
                      final series = issue.series;
                      final backdropUrl = issue.image;
                      final issueId = issue.id;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Card(
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: issueId == null
                                ? null
                                : () => context.pushRoute(
                                    IssueDetailsRoute(
                                      issueId: issueId,
                                      initialImageUrl: issue.image,
                                    ),
                                  ),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                if (backdropUrl != null &&
                                    backdropUrl.isNotEmpty)
                                  Positioned.fill(
                                    child: CachedNetworkImage(
                                      imageUrl: backdropUrl,
                                      imageBuilder: (_, imageProvider) =>
                                          ClipRect(
                                            child: Transform.scale(
                                              scale: 1.14,
                                              child: DecoratedBox(
                                                decoration: BoxDecoration(
                                                  color: Colors.black,
                                                  image: DecorationImage(
                                                    image: imageProvider,
                                                    fit: BoxFit.cover,
                                                    alignment: const Alignment(
                                                      0.65,
                                                      0,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                      placeholder: (_, _) => Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                              Theme.of(
                                                context,
                                              ).colorScheme.primaryContainer,
                                            ],
                                          ),
                                        ),
                                      ),
                                      errorWidget: (_, _, _) => Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                              Theme.of(
                                                context,
                                              ).colorScheme.primaryContainer,
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                else
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Theme.of(context).colorScheme.primary,
                                          Theme.of(
                                            context,
                                          ).colorScheme.primaryContainer,
                                        ],
                                      ),
                                    ),
                                  ),
                                DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.black.withValues(alpha: 0.2),
                                        Colors.black.withValues(alpha: 0.65),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primaryContainer,
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
                                        ),
                                        child: Text(
                                          suggestion.reason,
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelMedium
                                              ?.copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimaryContainer,
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        series?.name ?? issue.name,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${series?.yearBegan ?? 'Unknown'}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => SizedBox(
                height: 240,
                child: PageView.builder(
                  controller: PageController(viewportFraction: 0.92),
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Theme.of(
                                      context,
                                    ).colorScheme.surfaceContainer,
                                    Theme.of(
                                      context,
                                    ).colorScheme.surfaceContainerHigh,
                                  ],
                                ),
                              ),
                            ),
                            DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.1),
                                    Colors.black.withValues(alpha: 0.3),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 72,
                                    height: 26,
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    width: 180,
                                    height: 20,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.surfaceContainerHighest,
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    width: 64,
                                    height: 14,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.surfaceContainerHighest,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              error: (_, _) => const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('Could not load trending releases right now.'),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _QuickActionTile(
                      icon: Icons.search,
                      label: 'Search',
                      onTap: () => context.pushRoute(const SearchRoute()),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _QuickActionTile(
                      icon: Icons.star_border,
                      label: 'Rate',
                      onTap: () =>
                          context.pushRoute(const UnratedIssuesRoute()),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _QuickActionTile(
                      icon: Icons.shopping_bag_outlined,
                      label: 'Pulls',
                      onTap: () => context.pushRoute(const MyPullsRoute()),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            continueReadingAsync.when(
              data: (items) {
                if (items.isEmpty) return const SizedBox.shrink();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Continue Reading',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 250,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final issue = item.issue;
                          final issueId = issue.id;
                          final collectionStatus = issueId == null
                              ? null
                              : ref.watch(
                                  issueCollectionStatusProvider(issueId),
                                );
                          final pullEntry = issueId == null
                              ? null
                              : ref.watch(issuePullListEntryProvider(issueId));

                          return IssueCard(
                            imageUrl: issue.image,
                            title:
                                '${issue.series?.name ?? 'Issue'} #${issue.number}',
                            heroTag: issueId == null
                                ? null
                                : 'issue-cover-$issueId',
                            isCollected: collectionStatus?.isCollected ?? false,
                            isWishlisted:
                                collectionStatus?.isWishlisted ?? false,
                            isRead: collectionStatus?.isRead ?? false,
                            isPulled: pullEntry?.asData?.value != null,
                            onTap: issueId == null
                                ? null
                                : () => context.pushRoute(
                                    IssueDetailsRoute(
                                      issueId: issueId,
                                      initialImageUrl: issue.image,
                                    ),
                                  ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
              loading: () => SizedBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Continue Reading',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      height: 250,
                      child: ListView.separated(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: 3,
                        separatorBuilder: (_, _) => SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          return SizedBox(
                            width: 120,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Card(
                                  clipBehavior: Clip.antiAlias,
                                  child: AspectRatio(
                                    aspectRatio: 2 / 3,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Theme.of(
                                              context,
                                            ).colorScheme.surfaceContainer,
                                            Theme.of(
                                              context,
                                            ).colorScheme.surfaceContainerHigh,
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width: 110,
                                  height: 12,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHighest,
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  width: 82,
                                  height: 12,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHighest,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              error: (_, _) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 20),
            becauseYouPulledAsync.when(
              data: (issues) {
                if (issues.isEmpty) return const SizedBox.shrink();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Because You Pulled',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 250,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: issues.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final issue = issues[index];
                          final issueId = issue.id;
                          final collectionStatus = issueId == null
                              ? null
                              : ref.watch(
                                  issueCollectionStatusProvider(issueId),
                                );
                          final pullEntry = issueId == null
                              ? null
                              : ref.watch(issuePullListEntryProvider(issueId));

                          return IssueCard(
                            imageUrl: issue.image,
                            title:
                                '${issue.series?.name ?? 'Issue'} #${issue.number}',
                            heroTag: issueId == null
                                ? null
                                : 'issue-cover-$issueId',
                            isCollected: collectionStatus?.isCollected ?? false,
                            isWishlisted:
                                collectionStatus?.isWishlisted ?? false,
                            isRead: collectionStatus?.isRead ?? false,
                            isPulled: pullEntry?.asData?.value != null,
                            onTap: issueId == null
                                ? null
                                : () => context.pushRoute(
                                    IssueDetailsRoute(
                                      issueId: issueId,
                                      initialImageUrl: issue.image,
                                    ),
                                  ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 74,
      child: Card(
        elevation: 0,
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
