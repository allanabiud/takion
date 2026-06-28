import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/constants/pagination.dart';
import 'package:takion/src/domain/entities/issue_list.dart';
import 'package:takion/src/domain/entities/issue_search_page.dart';
import 'package:takion/src/domain/entities/series_list.dart';
import 'package:takion/src/domain/entities/series_search_page.dart';
import 'package:takion/src/presentation/features/issues/providers/issue_search_provider.dart';
import 'package:takion/src/presentation/providers/repository_providers.dart';
import 'package:takion/src/presentation/features/series/providers/series_cover_provider.dart';
import 'package:takion/src/presentation/features/series/providers/series_search_provider.dart';
import 'package:takion/src/presentation/providers/sort_preferences_provider.dart';
import 'package:takion/src/presentation/logic/content_sorting.dart';
import 'package:takion/src/presentation/common/async_state_panel.dart';
import 'package:takion/src/presentation/common/empty_content_state.dart';
import 'package:takion/src/presentation/features/issues/issue_list_tile.dart';
import 'package:takion/src/presentation/components/list_header.dart';
import 'package:takion/src/presentation/components/sort_bottom_sheet.dart';
import 'package:takion/src/presentation/components/page_navigation_bar.dart';
import 'package:takion/src/presentation/features/series/series_list_tile.dart';

@RoutePage()
class SearchResultsScreen extends ConsumerStatefulWidget {
  const SearchResultsScreen({
    super.key,
    required this.query,
    this.searchChoice = 'Issues',
  });

  final String query;
  final String searchChoice;

  @override
  ConsumerState<SearchResultsScreen> createState() =>
      _SearchResultsScreenState();
}

class _SearchResultsScreenState extends ConsumerState<SearchResultsScreen> {
  final TextEditingController _filterController = TextEditingController();
  bool _isFiltering = false;
  int _page = 1;
  int _seriesCoverFetchLimit = seriesCoverFetchBudgetPerSession;
  bool _seriesCoverLimitUpdateScheduled = false;
  IssueSearchPage? _lastIssuePage;
  SeriesSearchPage? _lastSeriesPage;
  bool get _isSeriesSearch => widget.searchChoice.toLowerCase() == 'series';

  IssueSearchArgs get _currentIssueArgs =>
      IssueSearchArgs(query: widget.query, page: _page);
  SeriesSearchArgs get _currentSeriesArgs =>
      SeriesSearchArgs(query: widget.query, page: _page);

  Future<void> _forceRefreshResults() async {
    if (_isSeriesSearch) {
      await ref
          .read(metronRepositoryProvider)
          .searchSeries(widget.query, page: _page, forceRefresh: true);
      ref.invalidate(seriesSearchResultsProvider(_currentSeriesArgs));
      await ref.read(seriesSearchResultsProvider(_currentSeriesArgs).future);
    } else {
      await ref
          .read(metronRepositoryProvider)
          .searchIssues(widget.query, page: _page, forceRefresh: true);
      ref.invalidate(issueSearchResultsProvider(_currentIssueArgs));
      await ref.read(issueSearchResultsProvider(_currentIssueArgs).future);
    }
  }

  void _resetSeriesCoverFetchLimit() {
    _seriesCoverFetchLimit = seriesCoverFetchBudgetPerSession;
    _seriesCoverLimitUpdateScheduled = false;
  }

  void _maybeExpandSeriesCoverFetchLimit({
    required int index,
    required int total,
  }) {
    if (index < _seriesCoverFetchLimit - 2) return;
    if (_seriesCoverFetchLimit >= total) return;
    if (_seriesCoverLimitUpdateScheduled) return;

    _seriesCoverLimitUpdateScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _seriesCoverFetchLimit =
            (_seriesCoverFetchLimit + seriesCoverFetchBudgetPerSession).clamp(
              seriesCoverFetchBudgetPerSession,
              total,
            );
        _seriesCoverLimitUpdateScheduled = false;
      });
    });
  }

  @override
  void didUpdateWidget(covariant SearchResultsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query ||
        oldWidget.searchChoice != widget.searchChoice) {
      _resetSeriesCoverFetchLimit();
    }
  }

  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
  }

  List<IssueList> _applyFilter(List<IssueList> issues) {
    final filter = _filterController.text.trim().toLowerCase();
    if (filter.isEmpty) return issues;

    return issues.where((issue) {
      final issueName = issue.name.toLowerCase();
      final seriesName = issue.series?.name.toLowerCase() ?? '';
      return issueName.contains(filter) || seriesName.contains(filter);
    }).toList();
  }

  List<SeriesList> _applySeriesFilter(List<SeriesList> series) {
    final filter = _filterController.text.trim().toLowerCase();
    if (filter.isEmpty) return series;

    return series.where((entry) {
      final name = entry.name.toLowerCase();
      return name.contains(filter);
    }).toList();
  }

  int _estimatedTotalPages(IssueSearchPage pageData) {
    return (pageData.count / metronDefaultPageSize).ceil().clamp(1, 99999);
  }

  int _estimatedSeriesTotalPages(SeriesSearchPage pageData) {
    return (pageData.count / metronDefaultPageSize).ceil().clamp(1, 99999);
  }

  Widget _buildSeriesBody(
    AsyncValue<SeriesSearchPage> async,
    ContentSortOption sortOption,
    SortPreferenceContext sortContext,
  ) {
    if (async.hasError) {
      return AsyncStatePanel.error(
        errorMessage: 'Search failed: ${async.error}',
      );
    }
    final pageData = async.asData?.value ?? _lastSeriesPage;
    if (pageData == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return _buildSeriesResultsContent(
      context,
      ref,
      pageData,
      sortOption,
      sortContext,
      isLoading: async.isLoading,
    );
  }

  Widget _buildIssueBody(
    AsyncValue<IssueSearchPage> async,
    ContentSortOption sortOption,
    SortPreferenceContext sortContext,
  ) {
    if (async.hasError) {
      return AsyncStatePanel.error(
        errorMessage: 'Search failed: ${async.error}',
      );
    }
    final pageData = async.asData?.value ?? _lastIssuePage;
    if (pageData == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return _buildIssueResultsContent(
      context,
      ref,
      pageData,
      sortOption,
      sortContext,
      isLoading: async.isLoading,
    );
  }

  Widget _buildSeriesResultsContent(
    BuildContext context,
    WidgetRef ref,
    SeriesSearchPage pageData,
    ContentSortOption sortOption,
    SortPreferenceContext sortContext, {
    required bool isLoading,
  }) {
    final sortedSeries = sortSeries(
      _applySeriesFilter(pageData.results),
      sortOption,
    );
    final totalPages = _estimatedSeriesTotalPages(pageData);
    final hasPagination = totalPages > 1;

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: sortedSeries.isEmpty && !isLoading
                  ? RefreshIndicator(
                      onRefresh: _forceRefreshResults,
                      child: CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          if (!_isFiltering)
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: ListHeader(
                                  count: pageData.count,
                                  unit: 'result',
                                  pageCount: sortedSeries.length,
                                  sortLabel: seriesSortLabel(sortOption),
                                  onSortTap: () =>
                                      showSortBottomSheet(
                                        context,
                                        ref,
                                        sortContext,
                                        seriesSortLabel,
                                      ),
                                ),
                              ),
                            ),
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: Padding(
                              padding: EdgeInsets.only(
                                bottom: hasPagination ? 96 : 12,
                              ),
                              child: const EmptyContentState(
                                icon: Icons.collections_bookmark_outlined,
                                message: 'No series found.',
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _forceRefreshResults,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(
                          0, 0, 0,
                          hasPagination ? 96 : 12,
                        ),
                        itemCount:
                            sortedSeries.length + (_isFiltering ? 0 : 1),
                        itemBuilder: (context, index) {
                          if (!_isFiltering && index == 0) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: ListHeader(
                                count: pageData.count,
                                unit: 'result',
                                pageCount: sortedSeries.length,
                                sortLabel: seriesSortLabel(sortOption),
                                onSortTap: isLoading
                                    ? null
                                    : () => showSortBottomSheet(
                                          context,
                                          ref,
                                          sortContext,
                                          seriesSortLabel,
                                        ),
                              ),
                            );
                          }
                          final itemIndex = _isFiltering
                              ? index
                              : index - 1;
                          _maybeExpandSeriesCoverFetchLimit(
                            index: itemIndex,
                            total: sortedSeries.length,
                          );
                          final series = sortedSeries[itemIndex];
                          return Opacity(
                            opacity: isLoading ? 0.6 : 1.0,
                            child: SeriesListTile(
                              series: series,
                              allowRemoteCoverFetch:
                                  itemIndex < _seriesCoverFetchLimit,
                              heroTag: 'series-cover-${series.id}',
                              isFirst: itemIndex == 0,
                              isLast: itemIndex == sortedSeries.length - 1,
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
        if (hasPagination)
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: PageNavigationBar(
                  currentPage: _page,
                  totalPages: totalPages,
                  hasPrevious: pageData.hasPrevious,
                  hasNext: pageData.hasNext,
                  onPrevious: () {
                    final previousPage = pageData.previousPage;
                    if (previousPage == null) return;
                    setState(() {
                      _page = previousPage;
                      _resetSeriesCoverFetchLimit();
                    });
                  },
                  onNext: () {
                    final nextPage = pageData.nextPage;
                    if (nextPage == null) return;
                    setState(() {
                      _page = nextPage;
                      _resetSeriesCoverFetchLimit();
                    });
                  },
                  enabled: !isLoading,
                  isLoading: isLoading,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildIssueResultsContent(
    BuildContext context,
    WidgetRef ref,
    IssueSearchPage pageData,
    ContentSortOption sortOption,
    SortPreferenceContext sortContext, {
    required bool isLoading,
  }) {
    final sortedIssues = sortIssues(
      _applyFilter(pageData.results),
      sortOption,
    );
    final totalPages = _estimatedTotalPages(pageData);
    final hasPagination = totalPages > 1;

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: sortedIssues.isEmpty && !isLoading
                  ? RefreshIndicator(
                      onRefresh: _forceRefreshResults,
                      child: CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          if (!_isFiltering)
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: ListHeader(
                                  count: pageData.count,
                                  unit: 'result',
                                  pageCount: sortedIssues.length,
                                  sortLabel: issueSortLabel(sortOption),
                                  onSortTap: () =>
                                      showSortBottomSheet(
                                        context,
                                        ref,
                                        sortContext,
                                        issueSortLabel,
                                      ),
                                ),
                              ),
                            ),
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: Padding(
                              padding: EdgeInsets.only(
                                bottom: hasPagination ? 96 : 12,
                              ),
                              child: const EmptyContentState(
                                icon: Icons.menu_book_outlined,
                                message: 'No issues found.',
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _forceRefreshResults,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(
                          0, 0, 0,
                          hasPagination ? 96 : 12,
                        ),
                        itemCount:
                            sortedIssues.length + (_isFiltering ? 0 : 1),
                        itemBuilder: (context, index) {
                          if (!_isFiltering && index == 0) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: ListHeader(
                                count: pageData.count,
                                unit: 'result',
                                pageCount: sortedIssues.length,
                                sortLabel: issueSortLabel(sortOption),
                                onSortTap: isLoading
                                    ? null
                                    : () => showSortBottomSheet(
                                          context,
                                          ref,
                                          sortContext,
                                          issueSortLabel,
                                        ),
                              ),
                            );
                          }
                          final itemIndex = _isFiltering
                              ? index
                              : index - 1;
                          final issue = sortedIssues[itemIndex];
                          return Opacity(
                            opacity: isLoading ? 0.6 : 1.0,
                            child: IssueListTile(
                              issue: issue,
                              isFirst: itemIndex == 0,
                              isLast: itemIndex == sortedIssues.length - 1,
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
        if (hasPagination)
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: PageNavigationBar(
                  currentPage: _page,
                  totalPages: totalPages,
                  hasPrevious: pageData.hasPrevious,
                  hasNext: pageData.hasNext,
                  onPrevious: () {
                    final previousPage = pageData.previousPage;
                    if (previousPage == null) return;
                    setState(() {
                      _page = previousPage;
                    });
                  },
                  onNext: () {
                    final nextPage = pageData.nextPage;
                    if (nextPage == null) return;
                    setState(() {
                      _page = nextPage;
                    });
                  },
                  enabled: !isLoading,
                  isLoading: isLoading,
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final sortContext = _isSeriesSearch
        ? SortPreferenceContext.searchSeries
        : SortPreferenceContext.searchIssues;
    final sortOption = ref.watch(sortPreferenceForContextProvider(sortContext));
    final issueResultsAsync = _isSeriesSearch
        ? null
        : ref.watch(issueSearchResultsProvider(_currentIssueArgs));
    final seriesResultsAsync = _isSeriesSearch
        ? ref.watch(seriesSearchResultsProvider(_currentSeriesArgs))
        : null;
    final isLoading = _isSeriesSearch
        ? seriesResultsAsync?.isLoading == true
        : issueResultsAsync?.isLoading == true;

    if (_isSeriesSearch) {
      if (seriesResultsAsync?.hasValue == true) {
        _lastSeriesPage = seriesResultsAsync!.value;
      }
    } else {
      if (issueResultsAsync?.hasValue == true) {
        _lastIssuePage = issueResultsAsync!.value;
      }
    }

    return Scaffold(
      appBar: AppBar(
        titleSpacing: _isFiltering ? 0 : null,
        title: _isFiltering
            ? TextField(
                controller: _filterController,
                autofocus: true,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Filter results...',
                  border: InputBorder.none,
                  isDense: true,
                  filled: false,
                  suffixIcon: IconButton(
                    tooltip: 'Close filter',
                    iconSize: 28,
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _isFiltering = false;
                        _filterController.clear();
                      });
                    },
                  ),
                ),
              )
            : null,
        actions: _isFiltering
            ? null
            : [
                IconButton(
                  tooltip: 'Search',
                  onPressed: () {
                    setState(() {
                      _isFiltering = true;
                    });
                  },
                  icon: const Icon(Icons.search),
                ),
              ],
        bottom: isLoading
            ? const PreferredSize(
                preferredSize: Size.fromHeight(4),
                child: LinearProgressIndicator(),
              )
            : null,
      ),
      body: _isSeriesSearch
          ? _buildSeriesBody(seriesResultsAsync!, sortOption, sortContext)
          : _buildIssueBody(issueResultsAsync!, sortOption, sortContext),
    );
  }
}
