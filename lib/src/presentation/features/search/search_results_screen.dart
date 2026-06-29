import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/constants/pagination.dart';
import 'package:takion/src/domain/entities/character_list.dart';
import 'package:takion/src/domain/entities/character_list_page.dart';
import 'package:takion/src/domain/entities/creator_list.dart';
import 'package:takion/src/domain/entities/creator_list_page.dart';
import 'package:takion/src/domain/entities/issue_list.dart';
import 'package:takion/src/domain/entities/issue_search_page.dart';
import 'package:takion/src/domain/entities/series_list.dart';
import 'package:takion/src/domain/entities/series_search_page.dart';
import 'package:takion/src/domain/entities/universe_list.dart';
import 'package:takion/src/domain/entities/universe_list_page.dart';
import 'package:takion/src/domain/entities/imprint_list.dart';
import 'package:takion/src/domain/entities/imprint_list_page.dart';
import 'package:takion/src/presentation/features/characters/providers/character_search_provider.dart';
import 'package:takion/src/presentation/features/creators/providers/creator_search_provider.dart';
import 'package:takion/src/presentation/features/issues/providers/issue_search_provider.dart';
import 'package:takion/src/presentation/providers/repository_providers.dart';
import 'package:takion/src/presentation/features/series/providers/series_cover_provider.dart';
import 'package:takion/src/presentation/features/series/providers/series_search_provider.dart';
import 'package:takion/src/presentation/features/universes/providers/universe_search_provider.dart';
import 'package:takion/src/presentation/features/imprints/providers/imprint_search_provider.dart';
import 'package:takion/src/presentation/providers/sort_preferences_provider.dart';
import 'package:takion/src/presentation/logic/content_sorting.dart';
import 'package:takion/src/presentation/common/async_state_panel.dart';
import 'package:takion/src/presentation/components/person_list_tile.dart';
import 'package:takion/src/presentation/components/universe_list_tile.dart';
import 'package:takion/src/presentation/components/imprint_list_tile.dart';
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
  CharacterListPage? _lastCharacterPage;
  CreatorListPage? _lastCreatorPage;
  UniverseListPage? _lastUniversePage;
  ImprintListPage? _lastImprintPage;
  bool get _isSeriesSearch => widget.searchChoice.toLowerCase() == 'series';
  bool get _isCharacterSearch =>
      widget.searchChoice.toLowerCase() == 'characters';
  bool get _isCreatorSearch =>
      widget.searchChoice.toLowerCase() == 'creators';
  bool get _isUniverseSearch =>
      widget.searchChoice.toLowerCase() == 'universes';
  bool get _isImprintSearch =>
      widget.searchChoice.toLowerCase() == 'imprints';

  IssueSearchArgs get _currentIssueArgs =>
      IssueSearchArgs(query: widget.query, page: _page);
  SeriesSearchArgs get _currentSeriesArgs =>
      SeriesSearchArgs(query: widget.query, page: _page);
  CharacterSearchArgs get _currentCharacterArgs =>
      CharacterSearchArgs(query: widget.query, page: _page);
  CreatorSearchArgs get _currentCreatorArgs =>
      CreatorSearchArgs(query: widget.query, page: _page);
  UniverseSearchArgs get _currentUniverseArgs =>
      UniverseSearchArgs(query: widget.query, page: _page);
  ImprintSearchArgs get _currentImprintArgs =>
      ImprintSearchArgs(query: widget.query, page: _page);

  Future<void> _forceRefreshResults() async {
    if (_isCharacterSearch) {
      await ref
          .read(metronRepositoryProvider)
          .searchCharacters(widget.query, page: _page, forceRefresh: true);
      ref.invalidate(characterSearchResultsProvider(_currentCharacterArgs));
      await ref
          .read(characterSearchResultsProvider(_currentCharacterArgs).future);
    } else if (_isCreatorSearch) {
      await ref
          .read(metronRepositoryProvider)
          .searchCreators(widget.query, page: _page, forceRefresh: true);
      ref.invalidate(creatorSearchResultsProvider(_currentCreatorArgs));
      await ref
          .read(creatorSearchResultsProvider(_currentCreatorArgs).future);
    } else if (_isUniverseSearch) {
      await ref
          .read(metronRepositoryProvider)
          .searchUniverses(widget.query, page: _page, forceRefresh: true);
      ref.invalidate(universeSearchResultsProvider(_currentUniverseArgs));
      await ref
          .read(universeSearchResultsProvider(_currentUniverseArgs).future);
    } else if (_isImprintSearch) {
      await ref
          .read(metronRepositoryProvider)
          .searchImprints(widget.query, page: _page, forceRefresh: true);
      ref.invalidate(imprintSearchResultsProvider(_currentImprintArgs));
      await ref
          .read(imprintSearchResultsProvider(_currentImprintArgs).future);
    } else if (_isSeriesSearch) {
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

  int _estimatedCharacterTotalPages(CharacterListPage pageData) {
    return (pageData.count / metronDefaultPageSize).ceil().clamp(1, 99999);
  }

  List<CharacterList> _applyCharacterFilter(List<CharacterList> characters) {
    final filter = _filterController.text.trim().toLowerCase();
    if (filter.isEmpty) return characters;

    return characters.where((entry) {
      final name = entry.name.toLowerCase();
      return name.contains(filter);
    }).toList();
  }

  int _estimatedCreatorTotalPages(CreatorListPage pageData) {
    return (pageData.count / metronDefaultPageSize).ceil().clamp(1, 99999);
  }

  List<CreatorList> _applyCreatorFilter(List<CreatorList> creators) {
    final filter = _filterController.text.trim().toLowerCase();
    if (filter.isEmpty) return creators;

    return creators.where((entry) {
      final name = entry.name.toLowerCase();
      return name.contains(filter);
    }).toList();
  }

  int _estimatedUniverseTotalPages(UniverseListPage pageData) {
    return (pageData.count / metronDefaultPageSize).ceil().clamp(1, 99999);
  }

  List<UniverseList> _applyUniverseFilter(List<UniverseList> universes) {
    final filter = _filterController.text.trim().toLowerCase();
    if (filter.isEmpty) return universes;

    return universes.where((entry) {
      final name = entry.name.toLowerCase();
      return name.contains(filter);
    }).toList();
  }

  int _estimatedImprintTotalPages(ImprintListPage pageData) {
    return (pageData.count / metronDefaultPageSize).ceil().clamp(1, 99999);
  }

  List<ImprintList> _applyImprintFilter(List<ImprintList> imprints) {
    final filter = _filterController.text.trim().toLowerCase();
    if (filter.isEmpty) return imprints;

    return imprints.where((entry) {
      final name = entry.name.toLowerCase();
      return name.contains(filter);
    }).toList();
  }

  Widget _buildUniverseBody(
    AsyncValue<UniverseListPage> async,
    ContentSortOption sortOption,
    SortPreferenceContext sortContext,
  ) {
    if (async.hasError) {
      return AsyncStatePanel.error(
        errorMessage: 'Search failed: ${async.error}',
      );
    }
    final pageData = async.asData?.value ?? _lastUniversePage;
    if (pageData == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return _buildUniverseResultsContent(
      context,
      ref,
      pageData,
      sortOption,
      sortContext,
      isLoading: async.isLoading,
    );
  }

  Widget _buildUniverseResultsContent(
    BuildContext context,
    WidgetRef ref,
    UniverseListPage pageData,
    ContentSortOption sortOption,
    SortPreferenceContext sortContext, {
    required bool isLoading,
  }) {
    final sortedUniverses = sortUniverses(
      _applyUniverseFilter(pageData.results),
      sortOption,
    );
    final totalPages = _estimatedUniverseTotalPages(pageData);
    final hasPagination = totalPages > 1;

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: sortedUniverses.isEmpty && !isLoading
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
                                  pageCount: sortedUniverses.length,
                                  sortLabel: universeSortLabel(sortOption),
                                  onSortTap: () =>
                                      showSortBottomSheet(
                                        context,
                                        ref,
                                        sortContext,
                                        universeSortLabel,
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
                                icon: Icons.language_outlined,
                                message: 'No universes found.',
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
                            sortedUniverses.length + (_isFiltering ? 0 : 1),
                        itemBuilder: (context, index) {
                          if (!_isFiltering && index == 0) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: ListHeader(
                                count: pageData.count,
                                unit: 'result',
                                pageCount: sortedUniverses.length,
                                sortLabel: universeSortLabel(sortOption),
                                onSortTap: isLoading
                                    ? null
                                    : () => showSortBottomSheet(
                                          context,
                                          ref,
                                          sortContext,
                                          universeSortLabel,
                                        ),
                              ),
                            );
                          }
                          final itemIndex = _isFiltering
                              ? index
                              : index - 1;
                          final universe = sortedUniverses[itemIndex];
                          return Opacity(
                            opacity: isLoading ? 0.6 : 1.0,
                            child: UniverseListTile(
                              universeId: universe.id,
                              name: universe.name,
                              isFirst: itemIndex == 0,
                              isLast: itemIndex == sortedUniverses.length - 1,
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

  Widget _buildImprintBody(
    AsyncValue<ImprintListPage> async,
    ContentSortOption sortOption,
    SortPreferenceContext sortContext,
  ) {
    if (async.hasError) {
      return AsyncStatePanel.error(
        errorMessage: 'Search failed: ${async.error}',
      );
    }
    final pageData = async.asData?.value ?? _lastImprintPage;
    if (pageData == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return _buildImprintResultsContent(
      context,
      ref,
      pageData,
      sortOption,
      sortContext,
      isLoading: async.isLoading,
    );
  }

  Widget _buildImprintResultsContent(
    BuildContext context,
    WidgetRef ref,
    ImprintListPage pageData,
    ContentSortOption sortOption,
    SortPreferenceContext sortContext, {
    required bool isLoading,
  }) {
    final sortedImprints = sortImprints(
      _applyImprintFilter(pageData.results),
      sortOption,
    );
    final totalPages = _estimatedImprintTotalPages(pageData);
    final hasPagination = totalPages > 1;

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: sortedImprints.isEmpty && !isLoading
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
                                  pageCount: sortedImprints.length,
                                  sortLabel: imprintSortLabel(sortOption),
                                  onSortTap: () =>
                                      showSortBottomSheet(
                                        context,
                                        ref,
                                        sortContext,
                                        imprintSortLabel,
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
                                icon: Icons.business_outlined,
                                message: 'No imprints found.',
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
                            sortedImprints.length + (_isFiltering ? 0 : 1),
                        itemBuilder: (context, index) {
                          if (!_isFiltering && index == 0) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: ListHeader(
                                count: pageData.count,
                                unit: 'result',
                                pageCount: sortedImprints.length,
                                sortLabel: imprintSortLabel(sortOption),
                                onSortTap: isLoading
                                    ? null
                                    : () => showSortBottomSheet(
                                          context,
                                          ref,
                                          sortContext,
                                          imprintSortLabel,
                                        ),
                              ),
                            );
                          }
                          final itemIndex = _isFiltering
                              ? index
                              : index - 1;
                          final imprint = sortedImprints[itemIndex];
                          return Opacity(
                            opacity: isLoading ? 0.6 : 1.0,
                            child: ImprintListTile(
                              imprintId: imprint.id,
                              name: imprint.name,
                              isFirst: itemIndex == 0,
                              isLast: itemIndex == sortedImprints.length - 1,
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

  Widget _buildCreatorBody(
    AsyncValue<CreatorListPage> async,
    ContentSortOption sortOption,
    SortPreferenceContext sortContext,
  ) {
    if (async.hasError) {
      return AsyncStatePanel.error(
        errorMessage: 'Search failed: ${async.error}',
      );
    }
    final pageData = async.asData?.value ?? _lastCreatorPage;
    if (pageData == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return _buildCreatorResultsContent(
      context,
      ref,
      pageData,
      sortOption,
      sortContext,
      isLoading: async.isLoading,
    );
  }

  Widget _buildCharacterBody(
    AsyncValue<CharacterListPage> async,
    ContentSortOption sortOption,
    SortPreferenceContext sortContext,
  ) {
    if (async.hasError) {
      return AsyncStatePanel.error(
        errorMessage: 'Search failed: ${async.error}',
      );
    }
    final pageData = async.asData?.value ?? _lastCharacterPage;
    if (pageData == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return _buildCharacterResultsContent(
      context,
      ref,
      pageData,
      sortOption,
      sortContext,
      isLoading: async.isLoading,
    );
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

  Widget _buildCharacterResultsContent(
    BuildContext context,
    WidgetRef ref,
    CharacterListPage pageData,
    ContentSortOption sortOption,
    SortPreferenceContext sortContext, {
    required bool isLoading,
  }) {
    final sortedCharacters = sortCharacters(
      _applyCharacterFilter(pageData.results),
      sortOption,
    );
    final totalPages = _estimatedCharacterTotalPages(pageData);
    final hasPagination = totalPages > 1;

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: sortedCharacters.isEmpty && !isLoading
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
                                  pageCount: sortedCharacters.length,
                                  sortLabel: characterSortLabel(sortOption),
                                  onSortTap: () =>
                                      showSortBottomSheet(
                                        context,
                                        ref,
                                        sortContext,
                                        characterSortLabel,
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
                                icon: Icons.people_outline,
                                message: 'No characters found.',
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
                            sortedCharacters.length + (_isFiltering ? 0 : 1),
                        itemBuilder: (context, index) {
                          if (!_isFiltering && index == 0) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: ListHeader(
                                count: pageData.count,
                                unit: 'result',
                                pageCount: sortedCharacters.length,
                                sortLabel: characterSortLabel(sortOption),
                                onSortTap: isLoading
                                    ? null
                                    : () => showSortBottomSheet(
                                          context,
                                          ref,
                                          sortContext,
                                          characterSortLabel,
                                        ),
                              ),
                            );
                          }
                          final itemIndex = _isFiltering
                              ? index
                              : index - 1;
                          final character = sortedCharacters[itemIndex];
                          return Opacity(
                            opacity: isLoading ? 0.6 : 1.0,
                            child: PersonListTile(
                              characterId: character.id,
                              name: character.name,
                              isFirst: itemIndex == 0,
                              isLast: itemIndex == sortedCharacters.length - 1,
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

  Widget _buildCreatorResultsContent(
    BuildContext context,
    WidgetRef ref,
    CreatorListPage pageData,
    ContentSortOption sortOption,
    SortPreferenceContext sortContext, {
    required bool isLoading,
  }) {
    final sortedCreators = sortCreators(
      _applyCreatorFilter(pageData.results),
      sortOption,
    );
    final totalPages = _estimatedCreatorTotalPages(pageData);
    final hasPagination = totalPages > 1;

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: sortedCreators.isEmpty && !isLoading
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
                                  pageCount: sortedCreators.length,
                                  sortLabel: creatorSortLabel(sortOption),
                                  onSortTap: () =>
                                      showSortBottomSheet(
                                        context,
                                        ref,
                                        sortContext,
                                        creatorSortLabel,
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
                                icon: Icons.person_outline,
                                message: 'No creators found.',
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
                            sortedCreators.length + (_isFiltering ? 0 : 1),
                        itemBuilder: (context, index) {
                          if (!_isFiltering && index == 0) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: ListHeader(
                                count: pageData.count,
                                unit: 'result',
                                pageCount: sortedCreators.length,
                                sortLabel: creatorSortLabel(sortOption),
                                onSortTap: isLoading
                                    ? null
                                    : () => showSortBottomSheet(
                                          context,
                                          ref,
                                          sortContext,
                                          creatorSortLabel,
                                        ),
                              ),
                            );
                          }
                          final itemIndex = _isFiltering
                              ? index
                              : index - 1;
                          final creator = sortedCreators[itemIndex];
                          return Opacity(
                            opacity: isLoading ? 0.6 : 1.0,
                            child: PersonListTile(
                              creatorId: creator.id,
                              name: creator.name,
                              isFirst: itemIndex == 0,
                              isLast: itemIndex == sortedCreators.length - 1,
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
    final sortContext = _isCharacterSearch
        ? SortPreferenceContext.searchCharacters
        : _isCreatorSearch
            ? SortPreferenceContext.searchCreators
            : _isUniverseSearch
                ? SortPreferenceContext.searchUniverses
                : _isImprintSearch
                    ? SortPreferenceContext.searchImprints
                    : _isSeriesSearch
                        ? SortPreferenceContext.searchSeries
                        : SortPreferenceContext.searchIssues;
    final sortOption = ref.watch(sortPreferenceForContextProvider(sortContext));
    final universeResultsAsync = _isUniverseSearch
        ? ref.watch(universeSearchResultsProvider(_currentUniverseArgs))
        : null;
    final imprintResultsAsync = _isImprintSearch
        ? ref.watch(imprintSearchResultsProvider(_currentImprintArgs))
        : null;
    final creatorResultsAsync = _isCreatorSearch
        ? ref.watch(creatorSearchResultsProvider(_currentCreatorArgs))
        : null;
    final characterResultsAsync = _isCharacterSearch
        ? ref.watch(characterSearchResultsProvider(_currentCharacterArgs))
        : null;
    final issueResultsAsync = _isSeriesSearch ||
            _isCharacterSearch ||
            _isCreatorSearch ||
            _isUniverseSearch ||
            _isImprintSearch
        ? null
        : ref.watch(issueSearchResultsProvider(_currentIssueArgs));
    final seriesResultsAsync = _isSeriesSearch
        ? ref.watch(seriesSearchResultsProvider(_currentSeriesArgs))
        : null;
    final isLoading = _isCreatorSearch
        ? creatorResultsAsync?.isLoading == true
        : _isCharacterSearch
            ? characterResultsAsync?.isLoading == true
            : _isUniverseSearch
                ? universeResultsAsync?.isLoading == true
                : _isImprintSearch
                    ? imprintResultsAsync?.isLoading == true
                    : _isSeriesSearch
                        ? seriesResultsAsync?.isLoading == true
                        : issueResultsAsync?.isLoading == true;

    if (_isCreatorSearch) {
      if (creatorResultsAsync?.hasValue == true) {
        _lastCreatorPage = creatorResultsAsync!.value;
      }
    } else if (_isCharacterSearch) {
      if (characterResultsAsync?.hasValue == true) {
        _lastCharacterPage = characterResultsAsync!.value;
      }
    } else if (_isUniverseSearch) {
      if (universeResultsAsync?.hasValue == true) {
        _lastUniversePage = universeResultsAsync!.value;
      }
    } else if (_isImprintSearch) {
      if (imprintResultsAsync?.hasValue == true) {
        _lastImprintPage = imprintResultsAsync!.value;
      }
    } else if (_isSeriesSearch) {
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
      body: _isCreatorSearch
          ? _buildCreatorBody(
              creatorResultsAsync!, sortOption, sortContext)
          : _isCharacterSearch
              ? _buildCharacterBody(
                  characterResultsAsync!, sortOption, sortContext)
              : _isUniverseSearch
                  ? _buildUniverseBody(
                      universeResultsAsync!, sortOption, sortContext)
                  : _isImprintSearch
                      ? _buildImprintBody(
                          imprintResultsAsync!, sortOption, sortContext)
                      : _isSeriesSearch
                          ? _buildSeriesBody(
                              seriesResultsAsync!, sortOption, sortContext)
                          : _buildIssueBody(
                              issueResultsAsync!, sortOption, sortContext),
    );
  }
}
