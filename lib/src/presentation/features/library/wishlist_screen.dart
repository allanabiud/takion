import "dart:async";

import "package:auto_route/auto_route.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/core/router/app_router.gr.dart";
import "package:takion/src/presentation/features/library/providers/category_series_providers.dart";
import "package:takion/src/presentation/features/library/activity_log_view.dart";
import "package:takion/src/presentation/shared/widgets/async_state_panel.dart";
import "package:takion/src/presentation/shared/widgets/empty_content_state.dart";
import "package:takion/src/presentation/shared/widgets/components.dart";
import "package:takion/src/domain/entities.dart";
import "package:takion/src/presentation/features/series/series_list_tile.dart";
import "package:takion/src/presentation/providers/providers.dart";
import "package:takion/src/domain/common/content_sorting.dart";

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
  Timer? _searchDebounceTimer;
  String _debouncedSearchQuery = "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
            : const Text("Wishlist"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "BROWSE"),
            Tab(text: "ACTIVITY"),
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
          _WishlistBrowseTab(
            isSearching: _isSearching,
            searchQuery: _debouncedSearchQuery,
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
  late final ScrollController _scrollController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final viewAsync = ref.watch(
      categorySeriesViewProvider(
        (
          category: "wishlist",
          query: widget.isSearching ? widget.searchQuery : "",
        ),
      ),
    );
    final sortOption = ref.watch(
      sortPreferenceForContextProvider(SortPreferenceContext.libraryWishlist),
    );

    return viewAsync.when(
      loading: () => const AsyncStatePanel.loading(),
      error: (error, _) =>
          const AsyncStatePanel.error(errorMessage: "Failed to load wishlist series"),
      data: (view) {
        final filtered = view.series;
        final categoryCounts = view.categoryCounts;
        if (filtered.isEmpty) {
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(wishlistSeriesProvider),
            child: const CustomScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyContentState(
                    icon: Icons.turned_in_not,
                    message: "No wishlist comics.",
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(wishlistSeriesProvider),
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
                        SortPreferenceContext.libraryWishlist,
                        contentSortLabel,
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final summary = filtered[index];
                      return RepaintBoundary(
                        child: SeriesListTile(
                          series: summary,
                          categoryCount: categoryCounts[summary.id],
                          categoryLabel: "wishlist",
                          showProgressBar: true,
                          isFirst: index == 0,
                          isLast: index == filtered.length - 1,
                          onTap: () => context.pushRoute(
                            LibrarySeriesRoute(
                              seriesId: summary.id,
                              category: "wishlist",
                              seriesName: summary.name,
                            ),
                          ),
                        ),
                      );
                    }, childCount: filtered.length),
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
