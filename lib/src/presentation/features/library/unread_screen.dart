import "dart:async";

import "package:auto_route/auto_route.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/core/router/app_router.gr.dart";
import "package:takion/src/presentation/features/library/providers/category_series_providers.dart";
import "package:takion/src/presentation/shared/widgets/async_state_panel.dart";
import "package:takion/src/presentation/shared/widgets/empty_content_state.dart";
import "package:takion/src/presentation/shared/widgets/components.dart";
import "package:takion/src/presentation/features/series/series_list_tile.dart";
import "package:takion/src/presentation/providers/providers.dart";
import "package:takion/src/domain/common/content_sorting.dart";

@RoutePage()
class UnreadScreen extends ConsumerStatefulWidget {
  const UnreadScreen({super.key});

  @override
  ConsumerState<UnreadScreen> createState() => _UnreadScreenState();
}

class _UnreadScreenState extends ConsumerState<UnreadScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounceTimer;
  String _debouncedSearchQuery = "";
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
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
    final sortOption = ref.watch(
      sortPreferenceForContextProvider(SortPreferenceContext.libraryUnread),
    );
    final viewAsync = ref.watch(
      categorySeriesViewProvider(
        (category: "unread", query: _isSearching ? _debouncedSearchQuery : ""),
      ),
    );

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
            : const Text("Unread Comics"),
        actions: _isSearching
            ? null
            : [
                IconButton(
                  tooltip: "Search",
                  onPressed: () => setState(() => _isSearching = true),
                  icon: const Icon(Icons.search),
                ),
              ],
      ),
      floatingActionButton: ScrollToTopFab(controller: _scrollController),
      body: viewAsync.when(
        loading: () => const AsyncStatePanel.loading(),
        error: (error, _) =>
            const AsyncStatePanel.error(errorMessage: "Failed to load unread series"),
        data: (view) {
          final filtered = view.series;
          final categoryCounts = view.categoryCounts;
          if (filtered.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async => ref.invalidate(unreadSeriesProvider),
              child: const CustomScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyContentState(
                      icon: Icons.bookmark_added_outlined,
                      message: "No unread comics in your collection.",
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(unreadSeriesProvider),
            child: CustomScrollView(
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
                      SortPreferenceContext.libraryUnread,
                      contentSortLabel,
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final summary = filtered[index];
                    return SeriesListTile(
                      series: summary,
                      categoryCount: categoryCounts[summary.id],
                      categoryLabel: "unread",
                      showProgressBar: true,
                      isFirst: index == 0,
                      isLast: index == filtered.length - 1,
                      onTap: () => context.pushRoute(
                        LibrarySeriesRoute(
                          seriesId: summary.id,
                          category: "unread",
                          seriesName: summary.name,
                        ),
                      ),
                    );
                  }, childCount: filtered.length),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
