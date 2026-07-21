import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/presentation/features/library/providers/category_series_providers.dart';
import 'package:takion/src/presentation/common/async_state_panel.dart';
import 'package:takion/src/presentation/common/empty_content_state.dart';
import 'package:takion/src/presentation/components/components.dart';
import 'package:takion/src/domain/entities/entities.dart';
import 'package:takion/src/presentation/features/series/series_list_tile.dart';
import 'package:takion/src/presentation/providers/providers.dart';
import 'package:takion/src/presentation/logic/content_sorting.dart';

@RoutePage()
class UnreadScreen extends ConsumerWidget {
  const UnreadScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seriesAsync = ref.watch(unreadSeriesProvider);
    final sortOption = ref.watch(
      sortPreferenceForContextProvider(SortPreferenceContext.libraryUnread),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Unread Comics')),
      body: seriesAsync.when(
        loading: () => const AsyncStatePanel.loading(),
        error: (error, _) =>
            AsyncStatePanel.error(errorMessage: 'Failed to load unread series'),
        data: (seriesList) {
          final sortedResults = sortSeries(
            seriesList
                .map(
                  (s) => SeriesList(
                    id: s.seriesId,
                    name: s.seriesName,
                    volume: s.volume,
                    yearBegan: s.yearBegan,
                    issueCount: s.categoryCount,
                  ),
                )
                .toList(),
            sortOption,
          );
          if (sortedResults.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async => ref.invalidate(unreadSeriesProvider),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: const [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyContentState(
                      icon: Icons.bookmark_border_outlined,
                      message: 'No unread comics in your collection.',
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(unreadSeriesProvider),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 12),
              itemCount: sortedResults.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: ListHeader(
                      count: sortedResults.length,
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
                  );
                }
                final summary = sortedResults[index - 1];
                return SeriesListTile(
                  series: summary,
                  categoryCount: summary.issueCount,
                  categoryLabel: 'unread',
                  isFirst: index == 1,
                  isLast: index == sortedResults.length,
                  onTap: () => context.pushRoute(
                    LibrarySeriesRoute(
                      seriesId: summary.id,
                      category: 'unread',
                      seriesName: summary.name,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
