import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/constants/pagination.dart';
import 'package:takion/src/domain/entities.dart';
import 'package:takion/src/presentation/shared/widgets/async_state_panel.dart';
import 'package:takion/src/presentation/shared/widgets/empty_content_state.dart';
import 'package:takion/src/presentation/shared/widgets/components.dart';
import 'package:takion/src/presentation/features/publishers/providers/publisher_details_provider.dart';
import 'package:takion/src/presentation/features/publishers/providers/publisher_series_list_provider.dart';
import 'package:takion/src/presentation/features/series/series_list_tile.dart';
import 'package:takion/src/domain/common/content_sorting.dart';
import 'package:takion/src/presentation/providers/providers.dart';

@RoutePage()
class PublisherSeriesScreen extends ConsumerStatefulWidget {
  const PublisherSeriesScreen({
    super.key,
    @pathParam required this.publisherId,
  });

  final int publisherId;

  @override
  ConsumerState<PublisherSeriesScreen> createState() =>
      _PublisherSeriesScreenState();
}

class _PublisherSeriesScreenState extends ConsumerState<PublisherSeriesScreen> {
  int _page = 1;
  SeriesListPage? _lastPage;
  int _totalPages = 1;
  final _overlapHandle = SliverOverlapAbsorberHandle();

  @override
  void dispose() {
    _overlapHandle.dispose();
    super.dispose();
  }

  bool get _pageHasPrevious => _lastPage?.hasPrevious ?? false;
  bool get _pageHasNext => _lastPage?.hasNext ?? false;

  @override
  Widget build(BuildContext context) {
    final sortOption = ref.watch(
      sortPreferenceForContextProvider(SortPreferenceContext.publisherSeries),
    );
    final detailsAsync = ref.watch(
      publisherDetailsProvider(widget.publisherId),
    );
    final args = PublisherSeriesListArgs(
      publisherId: widget.publisherId,
      page: _page,
    );
    final seriesAsync = ref.watch(publisherSeriesListPaginatedProvider(args));
    final isLoading = seriesAsync.isLoading;
    final publisherName = detailsAsync.asData?.value.name ?? '';

    if (seriesAsync.hasValue) {
      _lastPage = seriesAsync.value;
      _totalPages =
          ((seriesAsync.value!.count - 1) ~/ metronDefaultPageSize) + 1;
    }

    final body = seriesAsync.when(
      loading: () {
        if (_lastPage != null) {
          return _buildContent(
            context,
            _lastPage!,
            sortOption,
            isLoading: true,
          );
        }
        return const AsyncStatePanel.loading();
      },
      error: (error, _) =>
          AsyncStatePanel.error(errorMessage: 'Failed to load series'),
      data: (seriesPage) =>
          _buildContent(context, seriesPage, sortOption, isLoading: false),
    );

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Series'),
            if (publisherName.isNotEmpty)
              Text(
                publisherName,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
      body: body,
      bottomNavigationBar: _totalPages > 1
          ? BottomAppBar(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: isLoading || !_pageHasPrevious
                        ? null
                        : () => setState(() => _page--),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Page $_page of $_totalPages',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: isLoading || !_pageHasNext
                        ? null
                        : () => setState(() => _page++),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  Widget _buildContent(
    BuildContext context,
    SeriesListPage seriesPage,
    ContentSortOption sortOption, {
    required bool isLoading,
  }) {
    final results = sortSeries(seriesPage.results, sortOption);
    final seriesCount = seriesPage.count;

    return CustomScrollView(
      slivers: [
        SliverOverlapAbsorber(
          handle: _overlapHandle,
          sliver: SliverPersistentHeader(
            pinned: true,
            delegate: _PinnedHeaderDelegate(
              isLoading: isLoading,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ListHeader(
                    count: seriesCount,
                    unit: 'series',
                    pluralUnit: 'series',
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sortLabel: seriesSortLabel(sortOption),
                    onSortTap: isLoading
                        ? null
                        : () => showSortBottomSheet(
                            context,
                            ref,
                            SortPreferenceContext.publisherSeries,
                            seriesSortLabel,
                          ),
                  ),
                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: LinearProgressIndicator(minHeight: 2),
                    ),
                ],
              ),
            ),
          ),
        ),
        SliverOverlapInjector(handle: _overlapHandle),
        results.isEmpty && !isLoading
            ? SliverFillRemaining(
                hasScrollBody: false,
                child: SizedBox(
                  height: 360,
                  child: EmptyContentState(
                    icon: Icons.collections_bookmark_outlined,
                    message: 'No series available.',
                  ),
                ),
              )
            : SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final series = results[index];
                  return Opacity(
                    opacity: isLoading ? 0.6 : 1.0,
                    child: SeriesListTile(
                      series: series,
                      isFirst: index == 0,
                      isLast: index == results.length - 1,
                    ),
                  );
                }, childCount: results.length),
              ),
      ],
    );
  }
}

class _PinnedHeaderDelegate extends SliverPersistentHeaderDelegate {
  _PinnedHeaderDelegate({required this.isLoading, required this.child});

  final bool isLoading;
  final Widget child;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final theme = Theme.of(context);
    final borderSide = overlapsContent
        ? BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: 1.0,
          )
        : BorderSide.none;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(bottom: borderSide),
      ),
      child: child,
    );
  }

  @override
  double get maxExtent => isLoading ? 60 : 50;

  @override
  double get minExtent => isLoading ? 60 : 50;

  @override
  bool shouldRebuild(covariant _PinnedHeaderDelegate oldDelegate) {
    return oldDelegate.isLoading != isLoading || oldDelegate.child != child;
  }
}
