import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/presentation/features/library/providers/category_series_providers.dart';
import 'package:takion/src/presentation/shared/widgets/async_state_panel.dart';
import 'package:takion/src/presentation/shared/widgets/empty_content_state.dart';
import 'package:takion/src/presentation/shared/widgets/components.dart';
import 'package:takion/src/presentation/features/series/series_list_tile.dart';
import 'package:takion/src/presentation/providers/providers.dart';
import 'package:takion/src/domain/common/content_sorting.dart';

@RoutePage()
class UnratedScreen extends ConsumerStatefulWidget {
  const UnratedScreen({super.key});

  @override
  ConsumerState<UnratedScreen> createState() => _UnratedScreenState();
}

class _UnratedScreenState extends ConsumerState<UnratedScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewAsync = ref.watch(
      categorySeriesViewProvider(
        (category: 'unrated', query: _isSearching ? _searchController.text : ''),
      ),
    );
    final sortOption = ref.watch(
      sortPreferenceForContextProvider(SortPreferenceContext.libraryUnrated),
    );

    return Scaffold(
      appBar: AppBar(
        titleSpacing: _isSearching ? 0 : null,
        title: _isSearching
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
            : const Text('Unrated Comics'),
        actions: _isSearching
            ? null
            : [
                IconButton(
                  tooltip: 'Search',
                  onPressed: () => setState(() => _isSearching = true),
                  icon: const Icon(Icons.search),
                ),
              ],
      ),
      body: viewAsync.when(
        loading: () => const AsyncStatePanel.loading(),
        error: (error, _) => AsyncStatePanel.error(
          errorMessage: 'Failed to load unrated series',
        ),
        data: (view) {
          final filtered = view.series;
          final categoryCounts = view.categoryCounts;
          if (filtered.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async => ref.invalidate(unratedSeriesProvider),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: const [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyContentState(
                      icon: Icons.star_border_outlined,
                      message: 'No unrated comics.',
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(unratedSeriesProvider),
            child: CustomScrollView(
              slivers: [
                PinnedListHeader(
                  child: ListHeader(
                    count: filtered.length,
                    unit: 'series',
                    pluralUnit: 'series',
                    enabled: true,
                    sortLabel: seriesSortLabel(sortOption),
                    onSortTap: () => showSortBottomSheet(
                      context,
                      ref,
                      SortPreferenceContext.libraryUnrated,
                      seriesSortLabel,
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final summary = filtered[index];
                    return SeriesListTile(
                      series: summary,
                      categoryCount: categoryCounts[summary.id],
                      categoryLabel: 'unrated',
                      showProgressBar: true,
                      isFirst: index == 0,
                      isLast: index == filtered.length - 1,
                      onTap: () => context.pushRoute(
                        LibrarySeriesRoute(
                          seriesId: summary.id,
                          category: 'unrated',
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
