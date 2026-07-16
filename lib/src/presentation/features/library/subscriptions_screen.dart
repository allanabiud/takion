import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/constants/pagination.dart';
import 'package:takion/src/core/storage/hive_service.dart';
import 'package:takion/src/domain/entities/entities.dart';
import 'package:takion/src/presentation/features/series/providers/series_cover_provider.dart';
import 'package:takion/src/presentation/providers/providers.dart';
import 'package:takion/src/presentation/features/series/providers/subscriptions_provider.dart';
import 'package:takion/src/presentation/logic/content_sorting.dart';
import 'package:takion/src/presentation/common/async_state_panel.dart';
import 'package:takion/src/presentation/components/components.dart';
import 'package:takion/src/presentation/features/series/series_list_tile.dart';

@RoutePage()
class SubscriptionsScreen extends ConsumerStatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  ConsumerState<SubscriptionsScreen> createState() =>
      _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends ConsumerState<SubscriptionsScreen> {
  int _page = 1;
  SeriesListPage? _lastPage;
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
    await invalidateSubscriptionsLocalCacheWithHive(
      ref.read(hiveServiceProvider),
    );
    if (!mounted) return;
    setState(_resetCoverFetchLimit);
    ref.invalidate(subscribedSeriesPageProvider(_page));
  }

  @override
  Widget build(BuildContext context) {
    final sortOption = ref.watch(
      sortPreferenceForContextProvider(SortPreferenceContext.subscriptions),
    );
    final pageAsync = ref.watch(subscribedSeriesPageProvider(_page));

    if (pageAsync.hasValue) {
      _lastPage = pageAsync.value;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Subscriptions')),
      body: pageAsync.when(
        loading: () {
          if (_lastPage != null) {
            return _buildContent(_lastPage!, sortOption, isLoading: true);
          }
          return const AsyncStatePanel.loading();
        },
        error: (error, _) => AsyncStatePanel.error(
          errorMessage: 'Failed to load subscriptions: $error',
        ),
        data: (pageData) =>
            _buildContent(pageData, sortOption, isLoading: false),
      ),
    );
  }

  Widget _buildContent(
    SeriesListPage pageData,
    ContentSortOption sortOption, {
    required bool isLoading,
  }) {
    final totalPages = (pageData.count / metronDefaultPageSize).ceil().clamp(
      1,
      9999,
    );
    final sortedResults = sortSeries(pageData.results, sortOption);

    return PagedListScaffold(
      onRefresh: _refreshPage,
      currentPage: _page,
      totalPages: totalPages,
      hasPrevious: pageData.hasPrevious,
      hasNext: pageData.hasNext,
      isLoading: isLoading,
      header: ListHeader(
        count: pageData.count,
        unit: 'series',
        pluralUnit: 'series',
        enabled: !isLoading,
        sortLabel: seriesSortLabel(sortOption),
        onSortTap: () => showSortBottomSheet(
          context,
          ref,
          SortPreferenceContext.subscriptions,
          seriesSortLabel,
        ),
      ),
      onPrevious: () {
        final previousPage = pageData.previousPage;
        if (previousPage == null) return;
        setState(() {
          _page = previousPage;
          _resetCoverFetchLimit();
        });
      },
      onNext: () {
        final nextPage = pageData.nextPage;
        if (nextPage == null) return;
        setState(() {
          _page = nextPage;
          _resetCoverFetchLimit();
        });
      },
      itemCount: sortedResults.length,
      itemBuilder: (context, index) {
        _maybeExpandCoverFetchLimit(index: index, total: sortedResults.length);
        final series = sortedResults[index];
        return Opacity(
          opacity: isLoading ? 0.6 : 1.0,
          child: SeriesListTile(
            series: series,
            allowRemoteCoverFetch: index < _coverFetchLimit,
            isFirst: index == 0,
            isLast: index == sortedResults.length - 1,
          ),
        );
      },
      emptyMessage: 'No subscriptions yet.',
      emptyIcon: Icons.notifications_outlined,
    );
  }
}
