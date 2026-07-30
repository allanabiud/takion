import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/presentation/features/library/providers/category_series_providers.dart';
import 'package:takion/src/presentation/features/library/activity_log_view.dart';
import 'package:takion/src/presentation/features/library/providers/category_stats_provider.dart';
import 'package:takion/src/presentation/features/library/providers/collection_stats_provider.dart';
import 'package:takion/src/presentation/features/library/providers/library_basic_stats_provider.dart';
import 'package:takion/src/presentation/features/library/providers/library_entity_stats_provider.dart';
import 'package:takion/src/presentation/features/library/providers/library_stats_models.dart';
import 'package:takion/src/presentation/features/library/widgets/streak_calendar_widget.dart';
import 'package:takion/src/presentation/features/library/widgets/stats_skeleton.dart';
import 'package:takion/src/presentation/features/library/widgets/reading_goal_card.dart';
import 'package:takion/src/presentation/shared/widgets/async_state_panel.dart';
import 'package:takion/src/presentation/shared/widgets/empty_content_state.dart';
import 'package:takion/src/presentation/shared/widgets/components.dart';
import 'package:takion/src/domain/entities.dart';
import 'package:takion/src/presentation/features/series/series_list_tile.dart';
import 'package:takion/src/presentation/features/library/widgets/stat_card.dart';
import 'package:takion/src/presentation/features/library/widgets/library_charts.dart';
import 'package:takion/src/presentation/features/library/widgets/insight_row.dart';
import 'package:takion/src/presentation/features/issues/issue_list_tile.dart';
import 'package:takion/src/presentation/providers/providers.dart';
import 'package:takion/src/domain/common/content_sorting.dart';

@RoutePage()
class ReadScreen extends ConsumerStatefulWidget {
  const ReadScreen({super.key});

  @override
  ConsumerState<ReadScreen> createState() => _ReadScreenState();
}

class _ReadScreenState extends ConsumerState<ReadScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      setState(() {
        _isSearching = false;
        _searchController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: _isSearching && _tabController.index == 0 ? 0 : null,
        title: _isSearching && _tabController.index == 0
            ? TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search series...',
                  border: InputBorder.none,
                  isDense: true,
                  filled: false,
                  suffixIcon: IconButton(
                    tooltip: 'Close search',
                    iconSize: 28,
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _isSearching = false;
                        _searchController.clear();
                      });
                    },
                  ),
                ),
              )
            : const Text('Read Comics'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'BROWSE'),
            Tab(text: 'ACTIVITY'),
            Tab(text: 'STATS'),
          ],
        ),
        actions: _tabController.index == 0
            ? (_isSearching
                  ? null
                  : [
                      IconButton(
                        tooltip: 'Search',
                        onPressed: () => setState(() => _isSearching = true),
                        icon: const Icon(Icons.search),
                      ),
                    ])
            : null,
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ReadBrowseTab(
            isSearching: _isSearching,
            searchQuery: _searchController.text,
          ),
          const ActivityLogView(typeFilter: ActivityEventType.read),
          _ReadStatsTab(),
        ],
      ),
    );
  }
}

class _ReadBrowseTab extends ConsumerWidget {
  final bool isSearching;
  final String searchQuery;

  const _ReadBrowseTab({required this.isSearching, required this.searchQuery});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seriesAsync = ref.watch(readSeriesProvider);
    final sortOption = ref.watch(
      sortPreferenceForContextProvider(SortPreferenceContext.libraryRead),
    );

    return seriesAsync.when(
      loading: () => const AsyncStatePanel.loading(),
      error: (error, _) =>
          AsyncStatePanel.error(errorMessage: 'Failed to load read series'),
      data: (seriesList) {
        final mapped = seriesList.map((s) {
          return (
            series: SeriesList(
              id: s.seriesId,
              name: s.seriesName,
              volume: s.volume,
              yearBegan: s.yearBegan,
              issueCount: s.issueCount,
            ),
            categoryCount: s.categoryCount,
          );
        }).toList();
        final sortedResults = sortSeries(
          mapped.map((e) => e.series).toList(),
          sortOption,
        );
        final categoryCounts = <int, int>{
          for (final e in mapped) e.series.id: e.categoryCount,
        };
        final query = searchQuery.toLowerCase().trim();
        final filtered = isSearching && query.isNotEmpty
            ? sortedResults
                  .where((s) => s.name.toLowerCase().contains(query))
                  .toList()
            : sortedResults;
        if (filtered.isEmpty) {
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(readSeriesProvider),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: const [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyContentState(
                    icon: Icons.bookmark_added,
                    message: 'No read comics in your collection.',
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(readSeriesProvider),
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 12),
            itemCount: filtered.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: ListHeader(
                    count: filtered.length,
                    unit: 'series',
                    pluralUnit: 'series',
                    enabled: true,
                    sortLabel: seriesSortLabel(sortOption),
                    onSortTap: () => showSortBottomSheet(
                      context,
                      ref,
                      SortPreferenceContext.libraryRead,
                      seriesSortLabel,
                    ),
                  ),
                );
              }
              final summary = filtered[index - 1];
              return SeriesListTile(
                series: summary,
                categoryCount: categoryCounts[summary.id],
                categoryLabel: 'read',
                isFirst: index == 1,
                isLast: index == filtered.length,
                onTap: () => context.pushRoute(
                  LibrarySeriesRoute(
                    seriesId: summary.id,
                    category: 'read',
                    seriesName: summary.name,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _ReadStatsTab extends ConsumerStatefulWidget {
  @override
  ConsumerState<_ReadStatsTab> createState() => _ReadStatsTabState();
}

class _ReadStatsTabState extends ConsumerState<_ReadStatsTab>
    with AutomaticKeepAliveClientMixin {
  LibraryFilter _filter = LibraryFilter.month;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(libraryBasicStatsProvider(_filter));
        ref.invalidate(libraryEntityStatsProvider);
        ref.invalidate(libraryReadingTrendsProvider(_filter));
        ref.invalidate(libraryRecentlyFinishedProvider(_filter));
        ref.invalidate(collectionStatsProvider);
        ref.invalidate(categoryInsightsProvider);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(0, 12, 0, 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: LibraryFilter.values.map((f) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        f == LibraryFilter.allTime
                            ? 'All-Time'
                            : f.name[0].toUpperCase() + f.name.substring(1),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      selected: _filter == f,
                      onSelected: (selected) {
                        if (selected) setState(() => _filter = f);
                      },
                      shape: const StadiumBorder(),
                      showCheckmark: true,
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            _ReadStatsCards(filter: _filter),
            const SizedBox(height: 24),
            _ReadTrendsChart(filter: _filter),
            const SizedBox(height: 24),
            const StreakCalendarWidget(),
            const SizedBox(height: 24),
            ReadingGoalCard(filter: _filter),
            const SizedBox(height: 24),
            _ReadInsightsList(filter: _filter),
            const SizedBox(height: 24),
            _ReadRecentlyFinishedSection(filter: _filter),
          ],
        ),
      ),
    );
  }
}

class _ReadStatsCards extends ConsumerWidget {
  final LibraryFilter filter;

  const _ReadStatsCards({required this.filter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(libraryBasicStatsProvider(filter));
    final theme = Theme.of(context);

    return statsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: ShimmerWidget(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: SkeletonBox(height: 80)),
                  SizedBox(width: 8),
                  Expanded(child: SkeletonBox(height: 80)),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: SkeletonBox(height: 80)),
                  SizedBox(width: 8),
                  Expanded(child: SkeletonBox(height: 80)),
                ],
              ),
            ],
          ),
        ),
      ),
      error: (_, _) => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: EmptyContentState(
          icon: Icons.bar_chart_outlined,
          message: 'No stats available.',
        ),
      ),
      data: (stats) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    icon: Icons.menu_book,
                    value: '${stats.readsInPeriod}',
                    label: 'Read',
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: StatCard(
                    icon: Icons.percent,
                    value: '${stats.readPercent.toStringAsFixed(0)}%',
                    label: 'Read %',
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    icon: Icons.star_half,
                    value: stats.averageRating > 0
                        ? stats.averageRating.toStringAsFixed(1)
                        : '--',
                    label: 'Rating',
                    color: theme.colorScheme.tertiary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: StatCard(
                    icon: Icons.local_fire_department,
                    value: '${stats.streakDays}',
                    label: 'Day Streak',
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ReadTrendsChart extends ConsumerWidget {
  final LibraryFilter filter;

  const _ReadTrendsChart({required this.filter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendsAsync = ref.watch(libraryReadingTrendsProvider(filter));

    return trendsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: ShimmerWidget(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeaderSkeleton(),
              SizedBox(height: 12),
              SkeletonBox(height: 200),
            ],
          ),
        ),
      ),
      error: (_, _) => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: EmptyContentState(
          icon: Icons.show_chart_outlined,
          message: 'No reading trends yet.',
        ),
      ),
      data: (trends) {
        if (trends.isEmpty) {
          return const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SectionHeader(title: 'READING TRENDS'),
              ),
              SizedBox(height: 12),
              EmptyContentState(
                icon: Icons.show_chart_outlined,
                message: 'No reading trends available.',
              ),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SectionHeader(title: 'READING TRENDS'),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 200,
                child: ReadingTrendChart(data: trends),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ReadInsightsList extends ConsumerWidget {
  final LibraryFilter filter;

  const _ReadInsightsList({required this.filter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(libraryBasicStatsProvider(filter));
    final theme = Theme.of(context);

    return statsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: ShimmerWidget(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeaderSkeleton(),
              SizedBox(height: 12),
              _InsightRowSkeleton(),
              _InsightRowSkeleton(),
            ],
          ),
        ),
      ),
      error: (_, _) => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: EmptyContentState(
          icon: Icons.lightbulb_outline,
          message: 'No insights available.',
        ),
      ),
      data: (stats) {
        final hasInsights =
            stats.averageRating > 0 || stats.mostReadSeries != null;
        if (!hasInsights) {
          return const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SectionHeader(title: 'READING INSIGHTS'),
              ),
              SizedBox(height: 12),
              EmptyContentState(
                icon: Icons.lightbulb_outline,
                message: 'No insights available.',
              ),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SectionHeader(title: 'READING INSIGHTS'),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (stats.averageRating > 0) ...[
                    InsightRow(
                      label: 'Avg Rating',
                      value: stats.averageRating.toStringAsFixed(2),
                      icon: Icons.star,
                      iconColor: Colors.amber,
                    ),
                  ],
                  if (stats.mostReadSeries != null) ...[
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.collections_bookmark_outlined,
                          color: theme.colorScheme.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 3,
                          child: Text(
                            'Most-Read Series',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 4,
                          child: Text(
                            stats.mostReadSeriesYear != null &&
                                    stats.mostReadSeriesYear! > 0
                                ? '${stats.mostReadSeries} (${stats.mostReadSeriesYear})'
                                : stats.mostReadSeries!,
                            textAlign: TextAlign.right,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _InsightRowSkeleton extends StatelessWidget {
  const _InsightRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SkeletonBox(width: 24, height: 24),
          SizedBox(width: 16),
          Expanded(child: SkeletonBox(height: 16)),
          SizedBox(width: 12),
          SkeletonBox(width: 60, height: 16),
        ],
      ),
    );
  }
}

class _ReadRecentlyFinishedSection extends ConsumerWidget {
  final LibraryFilter filter;

  const _ReadRecentlyFinishedSection({required this.filter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final finishedAsync = ref.watch(libraryRecentlyFinishedProvider(filter));

    return finishedAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: ShimmerWidget(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeaderSkeleton(),
              SizedBox(height: 8),
              _ReadRecentIssueSkeleton(),
              _ReadRecentIssueSkeleton(),
              _ReadRecentIssueSkeleton(),
            ],
          ),
        ),
      ),
      error: (_, _) => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: EmptyContentState(
          icon: Icons.history_outlined,
          message: 'No recently finished reads.',
        ),
      ),
      data: (items) {
        if (items.isEmpty) {
          return const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SectionHeader(title: 'RECENTLY FINISHED'),
              ),
              SizedBox(height: 12),
              EmptyContentState(
                icon: Icons.history_outlined,
                message: 'No recently finished reads.',
              ),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SectionHeader(title: 'RECENTLY FINISHED'),
            ),
            const SizedBox(height: 8),
            ...items.map(
              (item) => IssueListTile(
                issue: IssueList(
                  id: item.issue?.id ?? 0,
                  name: item.issue?.series?.name ?? item.issue?.number ?? '',
                  number: item.issue?.number ?? '',
                  series: item.issue?.series != null
                      ? Series(
                          id: item.issue!.series!.id,
                          name: item.issue!.series!.name,
                          volume: item.issue!.series!.volume,
                          yearBegan: item.issue!.series!.yearBegan,
                        )
                      : null,
                  image: item.issue?.image,
                  coverDate: item.issue?.coverDate,
                  storeDate: item.issue?.storeDate,
                  modified: null,
                ),
                isCollected: item.quantity > 0,
                isRead: item.isRead,
                rating: item.rating,
                onTap: item.issue?.id != null
                    ? () => context.pushRoute(
                        IssueDetailsRoute(issueId: item.issue!.id),
                      )
                    : null,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ReadRecentIssueSkeleton extends StatelessWidget {
  const _ReadRecentIssueSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SkeletonBox(width: 60, height: 88),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(height: 16),
                const SizedBox(height: 6),
                SkeletonBox(width: 100, height: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
