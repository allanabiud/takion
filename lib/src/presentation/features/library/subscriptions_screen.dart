import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/constants/pagination.dart';
import 'package:takion/src/domain/entities.dart';
import 'package:takion/src/presentation/features/series/providers/series_cover_provider.dart';
import 'package:takion/src/presentation/providers/providers.dart';
import 'package:takion/src/presentation/features/series/providers/subscriptions_provider.dart';
import 'package:takion/src/domain/common/content_sorting.dart';
import 'package:takion/src/presentation/shared/widgets/async_state_panel.dart';
import 'package:takion/src/presentation/shared/widgets/components.dart';
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
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

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
    ref.invalidate(subscribedSeriesPageProvider(_page));
    if (!mounted) return;
    setState(_resetCoverFetchLimit);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sortOption = ref.watch(
      sortPreferenceForContextProvider(SortPreferenceContext.subscriptions),
    );
    final pageAsync = ref.watch(subscribedSeriesPageProvider(_page));
    final query = _searchController.text.toLowerCase().trim();

    if (pageAsync.hasValue) {
      _lastPage = pageAsync.value;
    }

    return Scaffold(
      appBar: AppBar(
        titleSpacing: _isSearching ? 0 : null,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: 'Search series...',
                  border: InputBorder.none,
                  isDense: true,
                  filled: false,
                  suffixIcon: Icon(
                    Icons.search,
                  ),
                ),
              )
            : const Text('Subscriptions'),
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
      body: pageAsync.when(
        loading: () {
          if (_lastPage != null) {
            return _buildContent(_lastPage!, sortOption, isLoading: true);
          }
          return _buildSkeletonList();
        },
        error: (error, _) =>
            AsyncStatePanel.error(errorMessage: 'Failed to load subscriptions'),
        data: (pageData) {
          final filtered = _filteredPage(pageData, query);
          return _buildContent(filtered, sortOption, isLoading: false);
        },
      ),
    );
  }

  SeriesListPage _filteredPage(SeriesListPage page, String query) {
    if (query.isEmpty) return page;
    final filteredResults = page.results
        .where((s) => s.name.toLowerCase().contains(query))
        .toList();
    return SeriesListPage(
      count: filteredResults.length,
      next: null,
      previous: page.previous,
      results: filteredResults,
      currentPage: _page,
    );
  }

  Widget _buildSkeletonList() {
    return const ShimmerWidget(child: _SubscriptionSkeletonContent());
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
        count: sortedResults.length,
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
      emptyMessage: 'No subscriptions.',
      emptyIcon: Icons.notifications_outlined,
    );
  }
}

class _SubscriptionSkeletonContent extends StatelessWidget {
  const _SubscriptionSkeletonContent();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 8,
      padding: const EdgeInsets.only(bottom: 8),
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(
            left: 12,
            right: 12,
            top: index == 0 ? 12 : 2,
            bottom: index == 7 ? 12 : 2,
          ),
          child: Material(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SkeletonBox(width: 90, height: 100, borderRadius: 8),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBox(height: 16, width: double.infinity),
                        SizedBox(height: 8),
                        SkeletonBox(height: 14, width: 180),
                        SizedBox(height: 12),
                        SkeletonBox(
                          height: 6,
                          width: double.infinity,
                          borderRadius: 3,
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            SkeletonBox(width: 16, height: 16, borderRadius: 4),
                            SizedBox(width: 8),
                            SkeletonBox(width: 16, height: 16, borderRadius: 4),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
