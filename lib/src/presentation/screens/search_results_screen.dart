import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/domain/entities/issue_list.dart';
import 'package:takion/src/domain/entities/issue_search_page.dart';
import 'package:takion/src/domain/entities/series_list.dart';
import 'package:takion/src/domain/entities/series_search_page.dart';
import 'package:takion/src/presentation/providers/issue_search_provider.dart';
import 'package:takion/src/presentation/providers/repository_providers.dart';
import 'package:takion/src/presentation/providers/series_cover_provider.dart';
import 'package:takion/src/presentation/providers/series_search_provider.dart';
import 'package:takion/src/presentation/providers/sort_preferences_provider.dart';
import 'package:takion/src/presentation/sorting/content_sorting.dart';
import 'package:takion/src/presentation/widgets/async_state_panel.dart';
import 'package:takion/src/presentation/widgets/display_settings_button.dart';
import 'package:takion/src/presentation/widgets/empty_content_state.dart';
import 'package:takion/src/presentation/widgets/issue_list_tile.dart';
import 'package:takion/src/presentation/widgets/page_navigation_bar.dart';
import 'package:takion/src/presentation/widgets/series_list_tile.dart';

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
    final pageSize = pageData.results.isEmpty ? 100 : pageData.results.length;
    return (pageData.count / pageSize).ceil().clamp(1, 99999);
  }

  int _estimatedSeriesTotalPages(SeriesSearchPage pageData) {
    final pageSize = pageData.results.isEmpty ? 100 : pageData.results.length;
    return (pageData.count / pageSize).ceil().clamp(1, 99999);
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
                DisplaySettingsButton(
                  selectedOption: sortOption,
                  optionLabel: _isSeriesSearch
                      ? seriesSortLabel
                      : issueSortLabel,
                  onSelected: (option) {
                    ref
                        .read(sortPreferencesProvider.notifier)
                        .setPreference(sortContext, option);
                  },
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
          ? seriesResultsAsync!.when(
              loading: () => const SizedBox.shrink(),
              error: (error, _) =>
                  AsyncStatePanel.error(errorMessage: 'Search failed: $error'),
              data: (pageData) {
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
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${pageData.count} results for "${widget.query}" in ${widget.searchChoice}',
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Sorted by ${seriesSortLabel(sortOption)}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: sortedSeries.isEmpty
                              ? RefreshIndicator(
                                  onRefresh: _forceRefreshResults,
                                  child: CustomScrollView(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    slivers: [
                                      SliverFillRemaining(
                                        hasScrollBody: false,
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                            bottom: hasPagination ? 96 : 12,
                                          ),
                                          child: const EmptyContentState(
                                            icon: Icons
                                                .collections_bookmark_outlined,
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
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    padding: EdgeInsets.fromLTRB(
                                      0,
                                      12,
                                      0,
                                      hasPagination ? 96 : 12,
                                    ),
                                    itemCount: sortedSeries.length,
                                    itemBuilder: (context, index) {
                                      _maybeExpandSeriesCoverFetchLimit(
                                        index: index,
                                        total: sortedSeries.length,
                                      );
                                      final series = sortedSeries[index];
                                      return SeriesListTile(
                                        series: series,
                                        allowRemoteCoverFetch:
                                            index < _seriesCoverFetchLimit,
                                        heroTag: 'series-cover-${series.id}',
                                        onTap: () {
                                          context.pushRoute(
                                            SeriesDetailsRoute(
                                              seriesId: series.id,
                                            ),
                                          );
                                        },
                                        isFirst: index == 0,
                                        isLast:
                                            index == sortedSeries.length - 1,
                                      );
                                    },
                                  ),
                                ),
                        ),
                      ],
                    ),
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
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            )
          : issueResultsAsync!.when(
              loading: () => const SizedBox.shrink(),
              error: (error, _) =>
                  AsyncStatePanel.error(errorMessage: 'Search failed: $error'),
              data: (pageData) {
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
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${pageData.count} results for "${widget.query}" in ${widget.searchChoice}',
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Sorted by ${issueSortLabel(sortOption)}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: sortedIssues.isEmpty
                              ? RefreshIndicator(
                                  onRefresh: _forceRefreshResults,
                                  child: CustomScrollView(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    slivers: [
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
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    padding: EdgeInsets.fromLTRB(
                                      0,
                                      12,
                                      0,
                                      hasPagination ? 96 : 12,
                                    ),
                                    itemCount: sortedIssues.length,
                                    itemBuilder: (context, index) {
                                      final issue = sortedIssues[index];
                                      return IssueListTile(
                                        issue: issue,
                                        isFirst: index == 0,
                                        isLast:
                                            index == sortedIssues.length - 1,
                                      );
                                    },
                                  ),
                                ),
                        ),
                      ],
                    ),
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
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
