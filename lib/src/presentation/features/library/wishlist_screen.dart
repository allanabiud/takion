import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/presentation/features/library/providers/category_series_providers.dart';
import 'package:takion/src/presentation/features/library/activity_log_view.dart';
import 'package:takion/src/presentation/shared/widgets/async_state_panel.dart';
import 'package:takion/src/presentation/shared/widgets/empty_content_state.dart';
import 'package:takion/src/presentation/shared/widgets/components.dart';
import 'package:takion/src/domain/entities.dart';
import 'package:takion/src/presentation/features/series/series_list_tile.dart';
import 'package:takion/src/presentation/providers/providers.dart';
import 'package:takion/src/domain/common/content_sorting.dart';

@RoutePage()
class WishlistScreen extends ConsumerStatefulWidget {
  const WishlistScreen({super.key});

  @override
  ConsumerState<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends ConsumerState<WishlistScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
            : const Text('Wishlist'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'BROWSE'),
            Tab(text: 'ACTIVITY'),
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
          _WishlistBrowseTab(
            isSearching: _isSearching,
            searchQuery: _searchController.text,
          ),
          const ActivityLogView(typeFilter: ActivityEventType.wishlisted),
        ],
      ),
    );
  }
}

class _WishlistBrowseTab extends ConsumerStatefulWidget {
  final bool isSearching;
  final String searchQuery;

  const _WishlistBrowseTab({
    required this.isSearching,
    required this.searchQuery,
  });

  @override
  ConsumerState<_WishlistBrowseTab> createState() => _WishlistBrowseTabState();
}

class _WishlistBrowseTabState extends ConsumerState<_WishlistBrowseTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final seriesAsync = ref.watch(wishlistSeriesProvider);
    final sortOption = ref.watch(
      sortPreferenceForContextProvider(SortPreferenceContext.libraryWishlist),
    );

    return seriesAsync.when(
      loading: () => const AsyncStatePanel.loading(),
      error: (error, _) =>
          AsyncStatePanel.error(errorMessage: 'Failed to load wishlist series'),
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
        final query = widget.searchQuery.toLowerCase().trim();
        final filtered = widget.isSearching && query.isNotEmpty
            ? sortedResults
                  .where((s) => s.name.toLowerCase().contains(query))
                  .toList()
            : sortedResults;
        if (filtered.isEmpty) {
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(wishlistSeriesProvider),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: const [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyContentState(
                    icon: Icons.turned_in_not,
                    message: 'No wishlist comics.',
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(wishlistSeriesProvider),
          child: CustomScrollView(
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: _PinnedListHeaderDelegate(
                  child: Padding(
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
                        SortPreferenceContext.libraryWishlist,
                        seriesSortLabel,
                      ),
                    ),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final summary = filtered[index];
                    return SeriesListTile(
                      series: summary,
                      categoryCount: categoryCounts[summary.id],
                      categoryLabel: 'wishlist',
                      isFirst: index == 0,
                      isLast: index == filtered.length - 1,
                      onTap: () => context.pushRoute(
                        LibrarySeriesRoute(
                          seriesId: summary.id,
                          category: 'wishlist',
                          seriesName: summary.name,
                        ),
                      ),
                    );
                  },
                  childCount: filtered.length,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PinnedListHeaderDelegate extends SliverPersistentHeaderDelegate {
  _PinnedListHeaderDelegate({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: Theme.of(context).colorScheme.surface, child: child);
  }

  @override
  double get maxExtent => 80;

  @override
  double get minExtent => 56;

  @override
  bool shouldRebuild(_PinnedListHeaderDelegate oldDelegate) =>
      child != oldDelegate.child;
}
