import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/presentation/features/library/providers/category_series_providers.dart';
import 'package:takion/src/presentation/features/library/activity_log_view.dart';
import 'package:takion/src/presentation/features/library/providers/collection_stats_provider.dart';
import 'package:takion/src/presentation/features/library/providers/library_insights_provider.dart';
import 'package:takion/src/presentation/shared/widgets/async_state_panel.dart';
import 'package:takion/src/presentation/shared/alerts/takion_alerts.dart';
import 'package:takion/src/presentation/shared/widgets/empty_content_state.dart';
import 'package:takion/src/presentation/shared/widgets/components.dart';
import 'package:takion/src/domain/entities.dart';
import 'package:takion/src/presentation/features/series/series_list_tile.dart';
import 'package:takion/src/presentation/features/library/widgets/stat_card.dart';
import 'package:takion/src/presentation/features/library/widgets/library_charts.dart';
import 'package:takion/src/presentation/features/library/widgets/top_entity_tile.dart';
import 'package:takion/src/presentation/features/library/screens/top_characters_screen.dart';
import 'package:takion/src/presentation/features/library/screens/top_creators_screen.dart';
import 'package:takion/src/presentation/features/issues/issue_list_tile.dart';
import 'package:takion/src/presentation/features/library/widgets/stats_skeleton.dart';
import 'package:takion/src/presentation/providers/providers.dart';
import 'package:takion/src/domain/common/content_sorting.dart';

@RoutePage()
class MyComicsScreen extends ConsumerStatefulWidget {
  const MyComicsScreen({super.key});

  @override
  ConsumerState<MyComicsScreen> createState() => _MyComicsScreenState();
}

class _MyComicsScreenState extends ConsumerState<MyComicsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
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
            : const Text('My Comics'),
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
          _MyComicsBrowseTab(
            isSearching: _isSearching,
            searchQuery: _searchController.text,
          ),
          const ActivityLogView(typeFilter: ActivityEventType.collected),
          _MyComicsStatsTab(),
        ],
      ),
    );
  }
}

class _MyComicsBrowseTab extends ConsumerWidget {
  final bool isSearching;
  final String searchQuery;

  const _MyComicsBrowseTab({
    required this.isSearching,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seriesAsync = ref.watch(collectedSeriesProvider);
    final sortOption = ref.watch(
      sortPreferenceForContextProvider(SortPreferenceContext.libraryMyComics),
    );

    return seriesAsync.when(
      loading: () => const AsyncStatePanel.loading(),
      error: (error, _) => AsyncStatePanel.error(
        errorMessage: 'Failed to load collected series',
      ),
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
                .where(
                  (s) => s.name.toLowerCase().contains(query),
                )
                .toList()
            : sortedResults;
        if (filtered.isEmpty) {
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(collectedSeriesProvider),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: const [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyContentState(
                    icon: Icons.inventory_2_outlined,
                    message: 'No comics in your collection yet.',
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(collectedSeriesProvider),
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
                      SortPreferenceContext.libraryMyComics,
                      seriesSortLabel,
                    ),
                  ),
                );
              }
              final summary = filtered[index - 1];
              return SeriesListTile(
                series: summary,
                categoryCount: categoryCounts[summary.id],
                categoryLabel: 'collected',
                isFirst: index == 1,
                isLast: index == filtered.length,
                onTap: () => context.pushRoute(
                  LibrarySeriesRoute(
                    seriesId: summary.id,
                    category: 'collected',
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

class _MyComicsStatsTab extends ConsumerStatefulWidget {
  @override
  ConsumerState<_MyComicsStatsTab> createState() => _MyComicsStatsTabState();
}

class _MyComicsStatsTabState extends ConsumerState<_MyComicsStatsTab> {
  LibraryFilter _filter = LibraryFilter.month;
  LibraryInsights? _cachedInsights;

  @override
  Widget build(BuildContext context) {
    final insightsAsync = ref.watch(libraryInsightsProvider(_filter));
    final collectionStatsAsync = ref.watch(collectionStatsProvider);
    final theme = Theme.of(context);

    if (insightsAsync.hasValue) {
      _cachedInsights = insightsAsync.value;
    }

    final insights = insightsAsync.asData?.value ?? _cachedInsights;

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(libraryInsightsProvider(_filter));
        ref.invalidate(collectionStatsProvider);
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
                        if (selected) {
                          setState(() => _filter = f);
                        }
                      },
                      shape: const StadiumBorder(),
                      showCheckmark: true,
                    ),
                  );
                }).toList(),
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: KeyedSubtree(
                key: ValueKey(_filter),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    if (insightsAsync.hasError)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 64.0,
                            horizontal: 16.0,
                          ),
                          child: Text(
                            TakionAlerts.cleanError(
                              insightsAsync.error!,
                              fallback: 'Failed to load stats',
                            ),
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      )
                    else if (insightsAsync.isLoading && _cachedInsights == null)
                      ShimmerWidget(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: const [
                                  Expanded(child: StatCardSkeleton()),
                                  SizedBox(width: 8),
                                  Expanded(child: StatCardSkeleton()),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: const [
                                  Expanded(child: StatCardSkeleton()),
                                  SizedBox(width: 8),
                                  Expanded(child: StatCardSkeleton()),
                                ],
                              ),
                              const SizedBox(height: 24),
                              const SectionHeaderSkeleton(),
                              const SizedBox(height: 12),
                              const StatBarTableSkeleton(),
                              const SizedBox(height: 24),
                              const SectionHeaderSkeleton(showChevron: true),
                              const SizedBox(height: 8),
                              ...List.generate(
                                5,
                                (index) =>
                                    TopEntityTileSkeleton(isLast: index == 4),
                              ),
                              const SizedBox(height: 24),
                              const SectionHeaderSkeleton(showChevron: true),
                              const SizedBox(height: 8),
                              ...List.generate(
                                5,
                                (index) =>
                                    TopEntityTileSkeleton(isLast: index == 4),
                              ),
                              const SizedBox(height: 24),
                              const SectionHeaderSkeleton(),
                              const SizedBox(height: 8),
                              ...List.generate(
                                3,
                                (index) => const IssueListTileSkeleton(),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (insights != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: StatCard(
                                    icon: Icons.inventory_2,
                                    value: '${insights.totalOwned}',
                                    label: 'Comics',
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: StatCard(
                                    icon: Icons.shopping_bag_outlined,
                                    value: '${insights.pullsInPeriod}',
                                    label: 'Pulls',
                                    color: Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: StatCard(
                                    icon: Icons.notifications_outlined,
                                    value: '${insights.subscriptionsCount}',
                                    label: 'Subscriptions',
                                    color: theme.colorScheme.error,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: StatCard(
                                    icon: Icons.account_balance_wallet_outlined,
                                    value:
                                        collectionStatsAsync
                                            .asData
                                            ?.value
                                            .totalValue ??
                                        '\$0.00',
                                    label: 'Value',
                                    color: theme.colorScheme.tertiary,
                                  ),
                                ),
                              ],
                            ),
                            if (insights.topPublishers.isNotEmpty) ...[
                              const SizedBox(height: 24),
                              SectionHeader(title: 'TOP PUBLISHERS'),
                              const SizedBox(height: 12),
                              StatBarTable(items: insights.topPublishers),
                            ],
                            if (insights.topCharacters.isNotEmpty) ...[
                              const SizedBox(height: 24),
                              SectionHeader(
                                title: 'TOP CHARACTERS',
                                onViewAll: insights.allCharacters.length > 5
                                    ? () => Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => TopCharactersScreen(
                                            characters: insights.allCharacters,
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                              const SizedBox(height: 8),
                              ...insights.topCharacters.asMap().entries.map(
                                (entry) => TopEntityTile(
                                  index: entry.key,
                                  entity: entry.value,
                                  isCharacter: true,
                                  isLast:
                                      entry.key ==
                                          insights.topCharacters.length - 1 &&
                                      insights.allCharacters.length <= 5,
                                ),
                              ),
                            ],
                            if (insights.topCreators.isNotEmpty) ...[
                              const SizedBox(height: 24),
                              SectionHeader(
                                title: 'TOP CREATORS',
                                onViewAll: insights.allCreators.length > 5
                                    ? () => Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => TopCreatorsScreen(
                                            creators: insights.allCreators,
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                              const SizedBox(height: 8),
                              ...insights.topCreators.asMap().entries.map(
                                (entry) => TopEntityTile(
                                  index: entry.key,
                                  entity: entry.value,
                                  isCharacter: false,
                                  isLast:
                                      entry.key ==
                                          insights.topCreators.length - 1 &&
                                      insights.allCreators.length <= 5,
                                ),
                              ),
                            ],
                            if (insights.recentlyFinished.isNotEmpty) ...[
                              const SizedBox(height: 24),
                              SectionHeader(title: 'RECENTLY FINISHED'),
                              const SizedBox(height: 8),
                              ...insights.recentlyFinished.map(
                                (item) => IssueListTile(
                                  issue: IssueList(
                                    id: item.issue?.id ?? 0,
                                    name:
                                        item.issue?.series?.name ??
                                        item.issue?.number ??
                                        '',
                                    number: item.issue?.number ?? '',
                                    series: item.issue?.series != null
                                        ? Series(
                                            id: item.issue?.series?.id ?? 0,
                                            name: item.issue!.series!.name,
                                            volume: item.issue!.series!.volume,
                                            yearBegan:
                                                item.issue!.series!.yearBegan,
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
                                          IssueDetailsRoute(
                                            issueId: item.issue!.id,
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
