import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/domain/entities/entities.dart';
import 'package:takion/src/presentation/features/home/main_screen.dart';
import 'package:takion/src/presentation/features/library/providers/continue_reading_provider.dart';
import 'package:takion/src/presentation/features/home/providers/home_trending_provider.dart';
import 'package:takion/src/presentation/features/issues/providers/issue_collection_status_provider.dart';
import 'package:takion/src/presentation/features/releases/providers/selected_week_provider.dart';
import 'package:takion/src/presentation/features/releases/providers/weekly_releases_provider.dart';
import 'package:takion/src/presentation/features/library/providers/pulls_provider.dart';
import 'package:takion/src/presentation/features/issues/issue_card.dart';

@RoutePage()
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static const _trendingAutoScrollInterval = Duration(seconds: 10);
  final PageController _trendingPageController = PageController(
    viewportFraction: 1,
  );
  Timer? _trendingAutoScrollTimer;
  int _trendingPage = 0;
  int _trendingCount = 0;
  bool _trendingAutoAdvancing = false;

  void _stopTrendingAutoScroll() {
    _trendingAutoScrollTimer?.cancel();
    _trendingAutoScrollTimer = null;
  }

  void _restartTrendingAutoScroll() {
    _stopTrendingAutoScroll();
    if (_trendingCount <= 1) return;

    _trendingAutoScrollTimer = Timer.periodic(_trendingAutoScrollInterval, (_) {
      if (!mounted ||
          !_trendingPageController.hasClients ||
          _trendingCount <= 1) {
        return;
      }
      final nextPage = (_trendingPage + 1) % _trendingCount;
      _trendingAutoAdvancing = true;
      _trendingPageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    });
  }

  void _syncTrendingAutoScroll(int itemCount) {
    _trendingCount = itemCount;
    if (_trendingPage >= itemCount) {
      _trendingPage = 0;
    }
    _restartTrendingAutoScroll();
  }

  void _handleTrendingPageChanged(int index) {
    _trendingPage = index;
    if (_trendingAutoAdvancing) {
      _trendingAutoAdvancing = false;
      return;
    }
    _restartTrendingAutoScroll();
  }

  @override
  void dispose() {
    _stopTrendingAutoScroll();
    _trendingPageController.dispose();
    super.dispose();
  }

  DateTime _weekStart(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    final offset = normalized.weekday % 7;
    return normalized.subtract(Duration(days: offset));
  }

  void _openWeeklyReleasesForWeek(
    BuildContext context,
    WidgetRef ref,
    DateTime weekDate,
  ) {
    ref.read(selectedWeekProvider.notifier).setDate(weekDate);
    context.pushRoute(const WeeklyReleasesRoute());
  }

  Widget _buildWeeklyReleaseSection({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required String emptyMessage,
    required DateTime weekDate,
    required AsyncValue<List<IssueList>> issuesAsync,
  }) {
    Widget buildSectionContent(List<IssueList> issues) {
      if (issues.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(emptyMessage),
        );
      }

      final previewIssues = issues.take(10).toList();
      return SizedBox(
        height: 250,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          itemCount: previewIssues.length,
          separatorBuilder: (_, _) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            final issue = previewIssues[index];
            final issueId = issue.id;
            final collectionStatus = issueId == null
                ? null
                : ref.watch(issueCollectionStatusProvider(issueId));
            final pullEntry = issueId == null
                ? null
                : ref.watch(issuePullListEntryProvider(issueId));

            return IssueCard(
              issueId: issueId,
              imageUrl: issue.image,
              title: '${issue.series?.name ?? issue.name} #${issue.number}',
              isCollected: collectionStatus?.isCollected ?? false,
              isWishlisted: collectionStatus?.isWishlisted ?? false,
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
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: InkWell(
            onTap: () => _openWeeklyReleasesForWeek(context, ref, weekDate),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        issuesAsync.when(
          data: buildSectionContent,
          loading: () => const SizedBox(
            height: 250,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, _) => const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('Could not load releases right now.'),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final suggestionsAsync = ref.watch(homeTrendingProvider);
    final continueReadingAsync = ref.watch(continueReadingSuggestionsProvider);
    final thisWeekStart = _weekStart(DateTime.now());
    final nextWeekStart = thisWeekStart.add(const Duration(days: 7));
    final thisWeekReleasesAsync = ref.watch(
      weeklyReleasesProvider(thisWeekStart),
    );
    final nextWeekReleasesAsync = ref.watch(
      weeklyReleasesProvider(nextWeekStart),
    );

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: InkWell(
                onTap: () {
                  context
                      .findAncestorStateOfType<MainScreenState>()
                      ?.openSearch();
                },
                borderRadius: BorderRadius.circular(28),
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      Icon(
                        Icons.search,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Search comics...',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            suggestionsAsync.when(
              data: (suggestions) {
                _syncTrendingAutoScroll(suggestions.length);
                if (suggestions.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('No trending releases available yet.'),
                  );
                }

                return SizedBox(
                  height: 240,
                  child: PageView.builder(
                    controller: _trendingPageController,
                    onPageChanged: _handleTrendingPageChanged,
                    itemCount: suggestions.length,
                    itemBuilder: (context, index) {
                      final suggestion = suggestions[index];
                      final issue = suggestion.issue;
                      final series = issue.series;
                      final backdropUrl = issue.image;
                      final issueId = issue.id;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
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
                                          DecoratedBox(
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
                                  child: LayoutBuilder(
                                    builder: (context, constraints) {
                                      final badgeMaxWidth =
                                          constraints.maxWidth * 0.72;
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ConstrainedBox(
                                            constraints: BoxConstraints(
                                              maxWidth: badgeMaxWidth,
                                            ),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 5,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.primaryContainer,
                                                borderRadius:
                                                    BorderRadius.circular(999),
                                              ),
                                              child: Text(
                                                suggestion.reason,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelMedium
                                                    ?.copyWith(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onPrimaryContainer,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                              ),
                                            ),
                                          ),
                                          const Spacer(),
                                          Text(
                                            '${series?.name ?? issue.name} #${issue.number}',
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleLarge
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w800,
                                                  color: Colors.white,
                                                ),
                                          ),
                                        ],
                                      );
                                    },
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
              loading: () {
                _stopTrendingAutoScroll();
                return SizedBox(
                  height: 240,
                  child: PageView.builder(
                    controller: PageController(viewportFraction: 1),
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
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
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
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
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
              error: (_, _) {
                _stopTrendingAutoScroll();
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Could not load trending releases right now.'),
                );
              },
            ),
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Browse Metron',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 44,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: 9,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      return _buildBrowsePill(context: context, index: index);
                    },
                  ),
                ),
              ],
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
                      child: InkWell(
                        onTap: () {
                          context.pushRoute(const ContinueReadingRoute());
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Continue Reading',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const Icon(Icons.chevron_right),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
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
                    const SizedBox(height: 20),
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
                    const SizedBox(height: 8),
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
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              error: (_, _) => const SizedBox.shrink(),
            ),

            _buildWeeklyReleaseSection(
              context: context,
              ref: ref,
              title: 'This Week\'s Releases',
              emptyMessage: 'No new releases this week.',
              weekDate: thisWeekStart,
              issuesAsync: thisWeekReleasesAsync,
            ),
            const SizedBox(height: 20),
            _buildWeeklyReleaseSection(
              context: context,
              ref: ref,
              title: 'Upcoming Releases',
              emptyMessage: 'No upcoming releases for next week.',
              weekDate: nextWeekStart,
              issuesAsync: nextWeekReleasesAsync,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrowsePill({required BuildContext context, required int index}) {
    final theme = Theme.of(context);
    final actions = [
      (
        Icons.list_alt_rounded,
        'Reading Lists',
        () => context.pushRoute(const MetronReadingListBrowserRoute()),
      ),
      (
        Icons.business,
        'Publishers',
        () => context.pushRoute(const PublisherBrowseRoute()),
      ),
      (
        Icons.auto_stories,
        'Story Arcs',
        () => context.pushRoute(const ArcBrowseRoute()),
      ),
      (Icons.groups, 'Teams', () => context.pushRoute(const TeamBrowseRoute())),
      (
        Icons.people,
        'Characters',
        () => context.pushRoute(const CharacterBrowseRoute()),
      ),
      (
        Icons.collections_bookmark,
        'Series',
        () => context.pushRoute(const SeriesBrowseRoute()),
      ),
      (
        Icons.language,
        'Universes',
        () => context.pushRoute(const UniverseBrowseRoute()),
      ),
      (
        Icons.business,
        'Imprints',
        () => context.pushRoute(const ImprintBrowseRoute()),
      ),
      (
        Icons.person,
        'Creators',
        () => context.pushRoute(const CreatorBrowseRoute()),
      ),
    ];
    final action = actions[index];
    return Material(
      color: theme.colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: action.$3,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(action.$1, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                action.$2,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
