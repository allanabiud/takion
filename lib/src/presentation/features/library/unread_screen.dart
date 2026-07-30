import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/presentation/features/library/providers/category_series_providers.dart';
import 'package:takion/src/presentation/shared/widgets/async_state_panel.dart';
import 'package:takion/src/presentation/shared/widgets/empty_content_state.dart';
import 'package:takion/src/presentation/shared/widgets/components.dart';
import 'package:takion/src/domain/entities.dart';
import 'package:takion/src/presentation/features/series/series_list_tile.dart';
import 'package:takion/src/presentation/providers/providers.dart';
import 'package:takion/src/domain/common/content_sorting.dart';

@RoutePage()
class UnreadScreen extends ConsumerStatefulWidget {
  const UnreadScreen({super.key});

  @override
  ConsumerState<UnreadScreen> createState() => _UnreadScreenState();
}

class _UnreadScreenState extends ConsumerState<UnreadScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final seriesAsync = ref.watch(unreadSeriesProvider);
    final sortOption = ref.watch(
      sortPreferenceForContextProvider(SortPreferenceContext.libraryUnread),
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
            : const Text('Unread Comics'),
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
      body: seriesAsync.when(
        loading: () => const AsyncStatePanel.loading(),
        error: (error, _) =>
            AsyncStatePanel.error(errorMessage: 'Failed to load unread series'),
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
          final query = _searchController.text.toLowerCase().trim();
          final filtered = _isSearching && query.isNotEmpty
              ? sortedResults
                    .where((s) => s.name.toLowerCase().contains(query))
                    .toList()
              : sortedResults;
          if (filtered.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async => ref.invalidate(unreadSeriesProvider),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: const [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyContentState(
                      icon: Icons.bookmark_added_outlined,
                      message: 'No unread comics in your collection.',
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(unreadSeriesProvider),
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
                          SortPreferenceContext.libraryUnread,
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
                        categoryLabel: 'unread',
                        isFirst: index == 0,
                        isLast: index == filtered.length - 1,
                        onTap: () => context.pushRoute(
                          LibrarySeriesRoute(
                            seriesId: summary.id,
                            category: 'unread',
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
      ),
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
