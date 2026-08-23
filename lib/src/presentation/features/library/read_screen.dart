import "dart:async";

import "package:auto_route/auto_route.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/core/router/app_router.gr.dart";
import "package:takion/src/presentation/features/library/providers/category_series_providers.dart";
import "package:takion/src/presentation/features/library/activity_log_view.dart";
import "package:takion/src/presentation/features/library/providers/collection_stats_provider.dart";
import "package:takion/src/presentation/features/library/providers/library_basic_stats_provider.dart";
import "package:takion/src/presentation/features/library/providers/library_entity_stats_provider.dart";
import "package:takion/src/presentation/features/library/providers/library_stats_models.dart";
import "package:takion/src/presentation/features/library/widgets/streak_calendar_widget.dart";
import "package:takion/src/presentation/features/library/widgets/stats_skeleton.dart";
import "package:takion/src/presentation/features/library/widgets/reading_goal_card.dart";
import "package:takion/src/presentation/shared/widgets/async_state_panel.dart";
import "package:takion/src/presentation/shared/widgets/empty_content_state.dart";
import "package:takion/src/presentation/shared/widgets/components.dart";
import "package:takion/src/domain/entities.dart";
import "package:takion/src/presentation/features/series/series_list_tile.dart";
import "package:takion/src/presentation/features/library/widgets/stat_card.dart";
import "package:takion/src/presentation/features/library/widgets/library_charts.dart";
import "package:takion/src/presentation/providers/providers.dart";
import "package:takion/src/domain/common/content_sorting.dart";

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
            : const Text("Read Comics"),
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
          _ReadBrowseTab(
            isSearching: _isSearching,
            searchQuery: _debouncedSearchQuery,
          ),
          const ActivityLogView(typeFilter: ActivityEventType.read),
          _ReadStatsTab(),
        ],
      ),
    );
  }
}

class _ReadBrowseTab extends ConsumerStatefulWidget {
  final bool isSearching;
  final String searchQuery;

  const _ReadBrowseTab({required this.isSearching, required this.searchQuery});

  @override
  ConsumerState<_ReadBrowseTab> createState() => _ReadBrowseTabState();
}

class _ReadBrowseTabState extends ConsumerState<_ReadBrowseTab>
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
      categorySeriesViewProvider((
        category: "read",
        query: widget.isSearching ? widget.searchQuery : "",
      )),
    );
    final sortOption = ref.watch(
      sortPreferenceForContextProvider(SortPreferenceContext.libraryRead),
    );

    ref.listen(
      categorySeriesViewProvider((
        category: "read",
        query: widget.isSearching ? widget.searchQuery : "",
      )),
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
        errorMessage: "Failed to load read series",
      ),
      data: (view) {
        final filtered = view.series;
        final categoryCounts = view.categoryCounts;
        if (filtered.isEmpty) {
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(readSeriesProvider),
            child: const CustomScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyContentState(
                    icon: Icons.bookmark_added,
                    message: "No read comics in your collection.",
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

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(readSeriesProvider),
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
                        SortPreferenceContext.libraryRead,
                        contentSortLabel,
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index >= visible.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          );
                        }
                        final summary = visible[index];
                        return RepaintBoundary(
                          child: SeriesListTile(
                            series: summary,
                            categoryCount: categoryCounts[summary.id],
                            categoryLabel: "read",
                            showProgressBar: true,
                            isFirst: index == 0,
                            isLast: !hasMore && index == visible.length - 1,
                            onTap: () => context.pushRoute(
                              LibrarySeriesRoute(
                                seriesId: summary.id,
                                category: "read",
                                seriesName: summary.name,
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: hasMore ? visible.length + 1 : visible.length,
                    ),
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
            ReadStatsCards(filter: _filter),
            const SizedBox(height: 24),
            _ReadTrendsChart(filter: _filter),
            const SizedBox(height: 24),
            const StreakCalendarWidget(),
            const SizedBox(height: 24),
            ReadingGoalCard(filter: _filter),
            const SizedBox(height: 24),
            const _ReadingHistoryTile(),
          ],
        ),
      ),
    );
  }
}

class ReadStatsCards extends ConsumerStatefulWidget {
  final LibraryFilter filter;

  const ReadStatsCards({super.key, required this.filter});

  @override
  ConsumerState<ReadStatsCards> createState() => _ReadStatsCardsState();
}

class _ReadStatsCardsState extends ConsumerState<ReadStatsCards> {
  LibraryBasicStats? _lastKnownStats;

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(libraryBasicStatsProvider(widget.filter));
    final theme = Theme.of(context);

    if (statsAsync.hasValue) {
      _lastKnownStats = statsAsync.value;
    }

    // Preserve last known stats across filter switches for smooth count transitions.
    final displayStats =
        _lastKnownStats ??
        (statsAsync.hasValue ? statsAsync.value : null) ??
        LibraryBasicStats.zero(widget.filter);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: StatCard(
                  icon: Icons.menu_book,
                  value: "${displayStats.readsInPeriod}",
                  label: "Read",
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatCard(
                  icon: Icons.percent,
                  value: "${displayStats.readPercent.toStringAsFixed(0)}%",
                  label: "Read %",
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
                  value: displayStats.averageRating > 0
                      ? displayStats.averageRating.toStringAsFixed(1)
                      : "--",
                  label: "Rating",
                  color: theme.colorScheme.tertiary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatCard(
                  icon: Icons.local_fire_department,
                  value: "${displayStats.streakDays}",
                  label: "Day Streak",
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
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
          message: "No reading trends yet.",
        ),
      ),
      data: (trends) {
        if (trends.isEmpty) {
          return const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SectionHeader(title: "READING TRENDS"),
              ),
              SizedBox(height: 12),
              EmptyContentState(
                icon: Icons.show_chart_outlined,
                message: "No reading trends available.",
              ),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SectionHeader(title: "READING TRENDS"),
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

class _ReadingHistoryTile extends StatelessWidget {
  const _ReadingHistoryTile();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => context.pushRoute(const ReadingHistoryRoute()),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Icon(Icons.history, color: theme.colorScheme.primary),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Reading History",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "View all comics you have read",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
