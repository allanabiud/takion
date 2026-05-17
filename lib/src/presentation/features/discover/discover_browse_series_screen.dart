import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities/series_list.dart';
import 'package:takion/src/presentation/features/series/providers/series_cover_provider.dart';
import 'package:takion/src/presentation/features/series/providers/series_list_provider.dart';
import 'package:takion/src/presentation/providers/sort_preferences_provider.dart';
import 'package:takion/src/presentation/logic/content_sorting.dart';
import 'package:takion/src/presentation/components/browse_paged_list_screen.dart';
import 'package:takion/src/presentation/components/list_header.dart';
import 'package:takion/src/presentation/components/sort_bottom_sheet.dart';
import 'package:takion/src/presentation/features/series/series_list_tile.dart';

@RoutePage()
class DiscoverBrowseSeriesScreen extends ConsumerStatefulWidget {
  const DiscoverBrowseSeriesScreen({super.key});

  @override
  ConsumerState<DiscoverBrowseSeriesScreen> createState() =>
      _DiscoverBrowseSeriesScreenState();
}

class _DiscoverBrowseSeriesScreenState
    extends ConsumerState<DiscoverBrowseSeriesScreen> {
  int _page = 1;
  int? _lastCount;
  int _coverFetchLimit = seriesCoverFetchBudgetPerSession;
  bool _coverLimitUpdateScheduled = false;

  void _resetCoverFetchLimit() {
    _coverFetchLimit = seriesCoverFetchBudgetPerSession;
    _coverLimitUpdateScheduled = false;
  }

  void _maybeExpandCoverFetchLimit({required int index, required int total}) {
    if (index < _coverFetchLimit - 2) return;
    if (_coverFetchLimit >= total) return;
    if (_coverLimitUpdateScheduled) return;

    _coverLimitUpdateScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _coverFetchLimit = (_coverFetchLimit + seriesCoverFetchBudgetPerSession)
            .clamp(seriesCoverFetchBudgetPerSession, total);
        _coverLimitUpdateScheduled = false;
      });
    });
  }

  Future<void> _refreshPage() async {
    ref.invalidate(seriesListProvider(_page));
    await ref.read(seriesListProvider(_page).future);
  }

  @override
  Widget build(BuildContext context) {
    final sortOption = ref.watch(
      sortPreferenceForContextProvider(SortPreferenceContext.browseSeries),
    );
    final pageAsync = ref.watch(seriesListProvider(_page));

    if (pageAsync.hasValue) {
      _lastCount = pageAsync.value?.count;
    }

    final browsePageAsync = pageAsync.whenData((pageData) {
      return BrowsePagedData<SeriesList>(
        results: sortSeries(pageData.results, sortOption),
        count: pageData.count,
        currentPage: _page,
        hasPrevious: pageData.hasPrevious,
        hasNext: pageData.hasNext,
        previousPage: pageData.previousPage,
        nextPage: pageData.nextPage,
      );
    });

    final displayCount = pageAsync.value?.count ?? _lastCount;

    return BrowsePagedListScreen<SeriesList>(
      title: 'Browse Series',
      pageAsync: browsePageAsync,
      header: displayCount != null
          ? ListHeader(
              count: displayCount,
              unit: 'series',
              pluralUnit: 'series',
              enabled: !pageAsync.isLoading,
              sortLabel: seriesSortLabel(sortOption),
              onSortTap: () => showSortBottomSheet(
                context,
                ref,
                SortPreferenceContext.browseSeries,
                seriesSortLabel,
              ),
            )
          : null,
      onRefresh: _refreshPage,
      onPrevious: () {
        final current = pageAsync.asData?.value;
        final previousPage = current?.previousPage;
        if (previousPage == null) return;
        setState(() {
          _page = previousPage;
          _resetCoverFetchLimit();
        });
      },
      onNext: () {
        final current = pageAsync.asData?.value;
        final nextPage = current?.nextPage;
        if (nextPage == null) return;
        setState(() {
          _page = nextPage;
          _resetCoverFetchLimit();
        });
      },
      itemBuilder: (context, item, index, total) {
        _maybeExpandCoverFetchLimit(index: index, total: total);
        return SeriesListTile(
          series: item,
          allowRemoteCoverFetch: index < _coverFetchLimit,
          isFirst: index == 0,
          isLast: index == total - 1,
        );
      },
      emptyMessage: 'No series available.',
      emptyIcon: Icons.collections_bookmark_outlined,
      errorPrefix: 'Failed to load series',
    );
  }
}
