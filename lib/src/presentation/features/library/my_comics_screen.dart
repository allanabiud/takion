import "dart:async";

import "package:auto_route/auto_route.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/core/router/app_router.gr.dart";
import "package:takion/src/presentation/features/library/providers/category_series_providers.dart";
import "package:takion/src/presentation/features/library/activity_log_view.dart";
import "package:takion/src/presentation/features/library/providers/category_stats_provider.dart";
import "package:takion/src/presentation/features/library/providers/collection_stats_provider.dart";
import "package:takion/src/presentation/features/library/providers/library_basic_stats_provider.dart";
import "package:takion/src/presentation/features/library/providers/library_entity_stats_provider.dart";
import "package:takion/src/presentation/features/library/providers/library_stats_models.dart";
import "package:takion/src/presentation/shared/widgets/async_state_panel.dart";
import "package:takion/src/presentation/shared/widgets/empty_content_state.dart";
import "package:takion/src/presentation/shared/widgets/components.dart";
import "package:takion/src/domain/entities.dart";
import "package:takion/src/presentation/features/series/series_list_tile.dart";
import "package:takion/src/presentation/features/series/providers/series_completion_provider.dart";
import "package:takion/src/presentation/features/library/widgets/stat_card.dart";
import "package:takion/src/presentation/features/library/widgets/library_charts.dart";
import "package:takion/src/presentation/features/library/widgets/top_entity_tile.dart";
import "package:takion/src/presentation/features/issues/issue_list_tile.dart";
import "package:takion/src/presentation/features/library/widgets/stats_skeleton.dart";
import "package:takion/src/presentation/providers/providers.dart";
import "package:takion/src/domain/common/content_sorting.dart";

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
  Timer? _searchDebounceTimer;
  String _debouncedSearchQuery = "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      _searchDebounceTimer?.cancel();
      setState(() {
        _isSearching = false;
        _debouncedSearchQuery = "";
        _searchController.clear();
      });
    }
  }

  void _onSearchChanged(String query) {
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(const Duration(milliseconds: 150), () {
      if (mounted) {
        setState(() {
          _debouncedSearchQuery = query;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: _isSearching ? 0 : null,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: "Search series...",
                  border: InputBorder.none,
                  isDense: true,
                  filled: false,
                  suffixIcon: IconButton(
                    tooltip: "Close search",
                    iconSize: 28,
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      _searchDebounceTimer?.cancel();
                      setState(() {
                        _isSearching = false;
                        _debouncedSearchQuery = "";
                        _searchController.clear();
                      });
                    },
                  ),
                ),
              )
            : const Text("My Comics"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "BROWSE"),
            Tab(text: "ACTIVITY"),
            Tab(text: "STATS"),
          ],
        ),
        actions: [
          AnimatedBuilder(
            animation: _tabController,
            builder: (context, _) {
              if (_tabController.index != 0 || _isSearching) {
                return const SizedBox.shrink();
              }
              return IconButton(
                tooltip: "Search",
                onPressed: () => setState(() => _isSearching = true),
                icon: const Icon(Icons.search),
              );
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _MyComicsBrowseTab(
            isSearching: _isSearching,
            searchQuery: _debouncedSearchQuery,
          ),
          const ActivityLogView(typeFilter: ActivityEventType.collected),
          _MyComicsStatsTab(),
        ],
      ),
    );
  }
}

class _MyComicsBrowseTab extends ConsumerStatefulWidget {
  final bool isSearching;
  final String searchQuery;

  const _MyComicsBrowseTab({
    required this.isSearching,
    required this.searchQuery,
  });

  @override
  ConsumerState<_MyComicsBrowseTab> createState() =>
      _MyComicsBrowseTabState();
}

class _MyComicsBrowseTabState extends ConsumerState<_MyComicsBrowseTab>
    with AutomaticKeepAliveClientMixin {
  static const _initialVisibleCount = 200;
  static const _appendCount = 200;
  static const _nearEndExtent = 800;

  final ScrollController _scrollController = ScrollController();
  late int _visibleCount = _initialVisibleCount;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - _nearEndExtent) {
      setState(() => _visibleCount += _appendCount);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final viewAsync = ref.watch(
      categorySeriesViewProvider(
        (
          category: "collected",
          query: widget.isSearching ? widget.searchQuery : "",
        ),
      ),
    );
    final sortOption = ref.watch(
      sortPreferenceForContextProvider(SortPreferenceContext.libraryMyComics),
    );

    ref.listen(
      categorySeriesViewProvider(
        (
          category: "collected",
          query: widget.isSearching ? widget.searchQuery : "",
        ),
      ),
      (previous, next) {
        if (previous?.value != next.value &&
            _visibleCount != _initialVisibleCount) {
          _visibleCount = _initialVisibleCount;
        }
      },
    );

    return viewAsync.when(
      loading: () => const AsyncStatePanel.loading(),
      error: (error, _) => const AsyncStatePanel.error(
        errorMessage: "Failed to load collected series",
      ),
      data: (view) {
        final filtered = view.series;
        final categoryCounts = view.categoryCounts;
        if (filtered.isEmpty) {
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(collectedSeriesProvider),
            child: const CustomScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyContentState(
                    icon: Icons.inventory_2_outlined,
                    message: "No comics in your collection.",
                  ),
                ),
              ],
            ),
          );
        }

        final visibleCount = filtered.length < _visibleCount
            ? filtered.length
            : _visibleCount;
        final visible = filtered.sublist(0, visibleCount);
        final hasMore = visibleCount < filtered.length;
        final ownedCountsAsync = ref.watch(
          seriesOwnedCountsProvider(
            [for (final s in visible) s.id],
          ),
        );

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(collectedSeriesProvider),
          child: Stack(
            children: [
              CustomScrollView(
                controller: _scrollController,
                slivers: [
                  PinnedListHeader(
                    child: ListHeader(
                      count: filtered.length,
                      unit: "series",
                      pluralUnit: "series",
                      enabled: true,
                      sortLabel: contentSortLabel(sortOption),
                      onSortTap: () => showSortBottomSheet(
                        context,
                        ref,
                        SortPreferenceContext.libraryMyComics,
                        contentSortLabel,
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      if (index >= visible.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        );
                      }
                      final summary = visible[index];
                      return RepaintBoundary(
                        child: SeriesListTile(
                          series: summary,
                          categoryCount: categoryCounts[summary.id],
                          categoryLabel: "collected",
                          ownedCount: ownedCountsAsync.value?[summary.id],
                          showProgressBar: true,
                          isFirst: index == 0,
                          isLast: !hasMore && index == visible.length - 1,
                          onTap: () => context.pushRoute(
                            LibrarySeriesRoute(
                              seriesId: summary.id,
                              category: "collected",
                              seriesName: summary.name,
                            ),
                          ),
                        ),
                      );
                    }, childCount: hasMore ? visible.length + 1 : visible.length),
                  ),
                ],
              ),
              Positioned(
                right: 16,
                bottom: 16,
                child: ScrollToTopFab(controller: _scrollController),
              ),
            ],
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

class _MyComicsStatsTabState extends ConsumerState<_MyComicsStatsTab>
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
                            ? "All-Time"
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
            _StatsOverviewCards(filter: _filter),
            const SizedBox(height: 24),
            _TopPublishersSection(),
            const SizedBox(height: 24),
            _TopCharactersSection(),
            const SizedBox(height: 24),
            _TopCreatorsSection(),
            const SizedBox(height: 24),
            _RecentlyFinishedSection(filter: _filter),
          ],
        ),
      ),
    );
  }
}

class _StatsOverviewCards extends ConsumerWidget {
  final LibraryFilter filter;

  const _StatsOverviewCards({required this.filter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final basicStatsAsync = ref.watch(libraryBasicStatsProvider(filter));
    final collectionStatsAsync = ref.watch(collectionStatsProvider);
    final theme = Theme.of(context);

    // Use previous data during reloads/errors so stat cards never disappear.
    final stats = basicStatsAsync.hasValue ? basicStatsAsync.value : null;

    // Only show shimmer on the very first load when no data exists yet.
    if (stats == null && basicStatsAsync.isLoading) {
      return const Padding(
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
      );
    }

    // Always render the cards – use zero stats as a fallback.
    final displayStats = stats ?? LibraryBasicStats.zero(filter);
    final value = collectionStatsAsync.hasValue
        ? collectionStatsAsync.value!.totalValue
        : r"$0.00";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: StatCard(
                  icon: Icons.inventory_2,
                  value: "${displayStats.totalOwned}",
                  label: "Comics",
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatCard(
                  icon: Icons.shopping_bag_outlined,
                  value: "${displayStats.pullsInPeriod}",
                  label: "Pulls",
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
                  icon: Icons.notifications_outlined,
                  value: "${displayStats.subscriptionsCount}",
                  label: "Subscriptions",
                  color: theme.colorScheme.tertiary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatCard(
                  icon: Icons.account_balance_wallet_outlined,
                  value: value,
                  label: "Value",
                  color: theme.colorScheme.tertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TopPublishersSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entityStatsAsync = ref.watch(libraryEntityStatsProvider);

    return entityStatsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: ShimmerWidget(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeaderSkeleton(),
              SizedBox(height: 12),
              _PublisherBarSkeleton(),
              _PublisherBarSkeleton(),
              _PublisherBarSkeleton(),
            ],
          ),
        ),
      ),
      error: (_, _) => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: EmptyContentState(
          icon: Icons.business,
          message: "No publishers tracked.",
        ),
      ),
      data: (entityStats) {
        if (entityStats.topPublishers.isEmpty) {
          return const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SectionHeader(title: "TOP PUBLISHERS"),
              ),
              SizedBox(height: 12),
              EmptyContentState(
                icon: Icons.business,
                message: "No publishers tracked.",
              ),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SectionHeader(title: "TOP PUBLISHERS"),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: StatBarTable(items: entityStats.topPublishers),
            ),
          ],
        );
      },
    );
  }
}

class _PublisherBarSkeleton extends StatelessWidget {
  const _PublisherBarSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SkeletonBox(width: 100, height: 14),
          SizedBox(width: 12),
          Expanded(child: SkeletonBox(height: 18)),
          SizedBox(width: 8),
          SkeletonBox(width: 32, height: 14),
        ],
      ),
    );
  }
}

class _TopCharactersSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entityStatsAsync = ref.watch(libraryEntityStatsProvider);

    return entityStatsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: ShimmerWidget(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeaderSkeleton(showChevron: true),
              SizedBox(height: 8),
              _EntityTileSkeleton(),
              _EntityTileSkeleton(),
              _EntityTileSkeleton(),
            ],
          ),
        ),
      ),
      error: (_, _) => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: EmptyContentState(
          icon: Icons.people,
          message: "No characters tracked.",
        ),
      ),
      data: (entityStats) {
        if (entityStats.topCharacters.isEmpty) {
          return const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SectionHeader(title: "TOP CHARACTERS"),
              ),
              SizedBox(height: 12),
              EmptyContentState(
                icon: Icons.people,
                message: "No characters tracked.",
              ),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SectionHeader(
                title: "TOP CHARACTERS",
                onViewAll: entityStats.allCharacters.length > 5
                    ? () => context.router.push(
                        TopCharactersRoute(
                          characters: entityStats.allCharacters,
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 8),
            ...entityStats.topCharacters.asMap().entries.map(
              (entry) => TopEntityTile(
                index: entry.key,
                entity: entry.value,
                isCharacter: true,
                isLast:
                    entry.key == entityStats.topCharacters.length - 1 &&
                    entityStats.allCharacters.length <= 5,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TopCreatorsSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entityStatsAsync = ref.watch(libraryEntityStatsProvider);

    return entityStatsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: ShimmerWidget(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeaderSkeleton(showChevron: true),
              SizedBox(height: 8),
              _EntityTileSkeleton(),
              _EntityTileSkeleton(),
              _EntityTileSkeleton(),
            ],
          ),
        ),
      ),
      error: (_, _) => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: EmptyContentState(
          icon: Icons.person,
          message: "No creators tracked.",
        ),
      ),
      data: (entityStats) {
        if (entityStats.topCreators.isEmpty) {
          return const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SectionHeader(title: "TOP CREATORS"),
              ),
              SizedBox(height: 12),
              EmptyContentState(
                icon: Icons.person,
                message: "No creators tracked.",
              ),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SectionHeader(
                title: "TOP CREATORS",
                onViewAll: entityStats.allCreators.length > 5
                    ? () => context.router.push(
                        TopCreatorsRoute(
                          creators: entityStats.allCreators,
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 8),
            ...entityStats.topCreators.asMap().entries.map(
              (entry) => TopEntityTile(
                index: entry.key,
                entity: entry.value,
                isCharacter: false,
                isLast:
                    entry.key == entityStats.topCreators.length - 1 &&
                    entityStats.allCreators.length <= 5,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _EntityTileSkeleton extends StatelessWidget {
  const _EntityTileSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SkeletonBox(width: 28, height: 20),
          SizedBox(width: 8),
          SkeletonBox(width: 44, height: 44, borderRadius: 22),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(height: 16),
                SizedBox(height: 4),
                SkeletonBox(width: 80, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentlyFinishedSection extends ConsumerWidget {
  final LibraryFilter filter;

  const _RecentlyFinishedSection({required this.filter});

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
              _RecentIssueSkeleton(),
              _RecentIssueSkeleton(),
              _RecentIssueSkeleton(),
            ],
          ),
        ),
      ),
      error: (_, _) => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: EmptyContentState(
          icon: Icons.history_outlined,
          message: "No recently finished comics.",
        ),
      ),
      data: (items) {
        if (items.isEmpty) {
          return const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SectionHeader(title: "RECENTLY FINISHED"),
              ),
              SizedBox(height: 12),
              EmptyContentState(
                icon: Icons.history_outlined,
                message: "No recently finished comics.",
              ),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SectionHeader(title: "RECENTLY FINISHED"),
            ),
            const SizedBox(height: 8),
            ...items.map(
              (item) => IssueListTile(
                issue: IssueList(
                  id: item.issue?.id ?? 0,
                  name: item.issue?.series?.name ?? item.issue?.number ?? "",
                  number: item.issue?.number ?? "",
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

class _RecentIssueSkeleton extends StatelessWidget {
  const _RecentIssueSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SkeletonBox(width: 60, height: 88),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(height: 16),
                SizedBox(height: 6),
                SkeletonBox(width: 100, height: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
