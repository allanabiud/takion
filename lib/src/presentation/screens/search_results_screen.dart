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
import 'package:takion/src/presentation/providers/series_search_provider.dart';
import 'package:takion/src/presentation/widgets/issue_list_tile.dart';
import 'package:takion/src/presentation/widgets/series_list_tile.dart';

enum _SearchSortOption {
  nameAsc,
  nameDesc,
  dateAsc,
  dateDesc,
}

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
  ConsumerState<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends ConsumerState<SearchResultsScreen> {
  final TextEditingController _filterController = TextEditingController();
  bool _isFiltering = false;
  _SearchSortOption _sortOption = _SearchSortOption.nameAsc;
  int _page = 1;
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

  DateTime? _issueDate(IssueList issue) {
    return issue.storeDate ?? issue.coverDate ?? issue.modified;
  }

  List<IssueList> _applySort(List<IssueList> issues) {
    final sorted = [...issues];

    int compareByName(IssueList a, IssueList b) =>
        a.name.toLowerCase().compareTo(b.name.toLowerCase());

    int compareByDate(IssueList a, IssueList b) {
      final aDate = _issueDate(a);
      final bDate = _issueDate(b);
      if (aDate == null && bDate == null) return compareByName(a, b);
      if (aDate == null) return 1;
      if (bDate == null) return -1;
      final dateCompare = aDate.compareTo(bDate);
      if (dateCompare != 0) return dateCompare;
      return compareByName(a, b);
    }

    switch (_sortOption) {
      case _SearchSortOption.nameAsc:
        sorted.sort(compareByName);
        break;
      case _SearchSortOption.nameDesc:
        sorted.sort((a, b) => compareByName(b, a));
        break;
      case _SearchSortOption.dateAsc:
        sorted.sort(compareByDate);
        break;
      case _SearchSortOption.dateDesc:
        sorted.sort((a, b) => compareByDate(b, a));
        break;
    }

    return sorted;
  }

  List<SeriesList> _applySeriesSort(List<SeriesList> series) {
    final sorted = [...series];

    int compareByName(SeriesList a, SeriesList b) =>
        a.name.toLowerCase().compareTo(b.name.toLowerCase());

    int compareByYear(SeriesList a, SeriesList b) {
      final aYear = a.yearBegan;
      final bYear = b.yearBegan;
      if (aYear == null && bYear == null) return compareByName(a, b);
      if (aYear == null) return 1;
      if (bYear == null) return -1;
      final yearCompare = aYear.compareTo(bYear);
      if (yearCompare != 0) return yearCompare;
      return compareByName(a, b);
    }

    switch (_sortOption) {
      case _SearchSortOption.nameAsc:
        sorted.sort(compareByName);
        break;
      case _SearchSortOption.nameDesc:
        sorted.sort((a, b) => compareByName(b, a));
        break;
      case _SearchSortOption.dateAsc:
        sorted.sort(compareByYear);
        break;
      case _SearchSortOption.dateDesc:
        sorted.sort((a, b) => compareByYear(b, a));
        break;
    }

    return sorted;
  }

  int _estimatedTotalPages(IssueSearchPage pageData) {
    final pageSize = pageData.results.isEmpty ? 100 : pageData.results.length;
    return (pageData.count / pageSize).ceil().clamp(1, 99999);
  }

  int _estimatedSeriesTotalPages(SeriesSearchPage pageData) {
    final pageSize = pageData.results.isEmpty ? 100 : pageData.results.length;
    return (pageData.count / pageSize).ceil().clamp(1, 99999);
  }

  String _sortLabel() {
    switch (_sortOption) {
      case _SearchSortOption.nameAsc:
        return 'Name (A–Z)';
      case _SearchSortOption.nameDesc:
        return 'Name (Z–A)';
      case _SearchSortOption.dateAsc:
        return 'Date (Oldest first)';
      case _SearchSortOption.dateDesc:
        return 'Date (Newest first)';
    }
  }

  Widget _buildFloatingPagination({
    required int currentPage,
    required int totalPages,
    required bool hasPrevious,
    required bool hasNext,
    required VoidCallback? onPrevious,
    required VoidCallback? onNext,
  }) {
    if (totalPages <= 1) return const SizedBox.shrink();

    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(24),
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: hasPrevious ? onPrevious : null,
                      icon: const Icon(Icons.chevron_left),
                      label: const Text('Prev'),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('Page $currentPage of $totalPages'),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: hasNext ? onNext : null,
                      icon: const Icon(Icons.chevron_right),
                      label: const Text('Next'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                PopupMenuButton<_SearchSortOption>(
                  tooltip: 'Sort',
                  icon: const Icon(Icons.sort),
                  initialValue: _sortOption,
                  onSelected: (option) {
                    setState(() {
                      _sortOption = option;
                    });
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: _SearchSortOption.nameAsc,
                      child: Row(
                        children: [
                          Icon(
                            _sortOption == _SearchSortOption.nameAsc
                                ? Icons.check
                                : Icons.circle_outlined,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          const Text('Name (A–Z)'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: _SearchSortOption.nameDesc,
                      child: Row(
                        children: [
                          Icon(
                            _sortOption == _SearchSortOption.nameDesc
                                ? Icons.check
                                : Icons.circle_outlined,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          const Text('Name (Z–A)'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: _SearchSortOption.dateAsc,
                      child: Row(
                        children: [
                          Icon(
                            _sortOption == _SearchSortOption.dateAsc
                                ? Icons.check
                                : Icons.circle_outlined,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isSeriesSearch
                                ? 'Year Began (Oldest first)'
                                : 'Date (Oldest first)',
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: _SearchSortOption.dateDesc,
                      child: Row(
                        children: [
                          Icon(
                            _sortOption == _SearchSortOption.dateDesc
                                ? Icons.check
                                : Icons.circle_outlined,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isSeriesSearch
                                ? 'Year Began (Newest first)'
                                : 'Date (Newest first)',
                          ),
                        ],
                      ),
                    ),
                  ],
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
              error: (error, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Search failed: $error',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              data: (pageData) {
                final sortedSeries = _applySeriesSort(
                  _applySeriesFilter(pageData.results),
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
                                style: Theme.of(
                                  context,
                                ).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Sorted by ${_sortLabel()}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: sortedSeries.isEmpty
                              ? RefreshIndicator(
                                  onRefresh: _forceRefreshResults,
                                  child: ListView(
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    padding: EdgeInsets.only(
                                      bottom: hasPagination ? 96 : 0,
                                    ),
                                    children: const [
                                      SizedBox(height: 220),
                                      Center(child: Text('No series found.')),
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
                                      final series = sortedSeries[index];
                                      return SeriesListTile(
                                        series: series,
                                        heroTag: 'series-cover-${series.id}',
                                        onTap: () {
                                          context.pushRoute(
                                            SeriesDetailsRoute(
                                              seriesId: series.id,
                                            ),
                                          );
                                        },
                                        isFirst: index == 0,
                                        isLast: index == sortedSeries.length - 1,
                                      );
                                    },
                                  ),
                                ),
                        ),
                      ],
                    ),
                    _buildFloatingPagination(
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
                  ],
                );
              },
            )
          : issueResultsAsync!.when(
              loading: () => const SizedBox.shrink(),
              error: (error, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Search failed: $error',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              data: (pageData) {
                final sortedIssues = _applySort(_applyFilter(pageData.results));
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
                                style: Theme.of(
                                  context,
                                ).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Sorted by ${_sortLabel()}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: sortedIssues.isEmpty
                              ? RefreshIndicator(
                                  onRefresh: _forceRefreshResults,
                                  child: ListView(
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    padding: EdgeInsets.only(
                                      bottom: hasPagination ? 96 : 0,
                                    ),
                                    children: const [
                                      SizedBox(height: 220),
                                      Center(child: Text('No issues found.')),
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
                                        isLast: index == sortedIssues.length - 1,
                                      );
                                    },
                                  ),
                                ),
                        ),
                      ],
                    ),
                    _buildFloatingPagination(
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
                  ],
                );
              },
            ),
    );
  }
}
