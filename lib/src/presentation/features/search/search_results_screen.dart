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
import 'package:takion/src/domain/entities/team_list.dart';
import 'package:takion/src/domain/entities/team_list_page.dart';
import 'package:takion/src/domain/entities/publisher_list.dart';
import 'package:takion/src/domain/entities/publisher_list_page.dart';
import 'package:takion/src/domain/entities/arc_list.dart';
import 'package:takion/src/domain/entities/arc_list_page.dart';
import 'package:takion/src/presentation/features/publishers/providers/publisher_search_provider.dart';
import 'package:takion/src/presentation/components/publisher_list_tile.dart';
import 'package:takion/src/presentation/features/arcs/providers/arc_search_provider.dart';
import 'package:takion/src/presentation/components/arc_list_tile.dart';
import 'package:takion/src/presentation/features/characters/providers/character_search_provider.dart';
import 'package:takion/src/presentation/features/creators/providers/creator_search_provider.dart';
import 'package:takion/src/presentation/features/issues/providers/issue_search_provider.dart';
import 'package:takion/src/presentation/providers/repository_providers.dart';
import 'package:takion/src/presentation/features/series/providers/series_cover_provider.dart';
import 'package:takion/src/presentation/features/series/providers/series_search_provider.dart';
import 'package:takion/src/presentation/features/universes/providers/universe_search_provider.dart';
import 'package:takion/src/presentation/features/imprints/providers/imprint_search_provider.dart';
import 'package:takion/src/presentation/features/teams/providers/team_search_provider.dart';
import 'package:takion/src/presentation/components/team_list_tile.dart';
import 'package:takion/src/presentation/providers/sort_preferences_provider.dart';
import 'package:takion/src/presentation/logic/content_sorting.dart';
import 'package:takion/src/presentation/common/async_state_panel.dart';
import 'package:takion/src/presentation/components/person_list_tile.dart';
import 'package:takion/src/presentation/components/universe_list_tile.dart';
import 'package:takion/src/presentation/components/imprint_list_tile.dart';
import 'package:takion/src/presentation/features/issues/issue_list_tile.dart';
import 'package:takion/src/presentation/features/series/series_list_tile.dart';
import 'package:takion/src/presentation/components/paged_search_section.dart';

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
  TeamListPage? _lastTeamPage;
  ArcListPage? _lastArcPage;
  PublisherListPage? _lastPublisherPage;
  bool get _isSeriesSearch => widget.searchChoice.toLowerCase() == 'series';
  bool get _isCharacterSearch =>
      widget.searchChoice.toLowerCase() == 'characters';
  bool get _isCreatorSearch =>
      widget.searchChoice.toLowerCase() == 'creators';
  bool get _isUniverseSearch =>
      widget.searchChoice.toLowerCase() == 'universes';
  bool get _isImprintSearch =>
      widget.searchChoice.toLowerCase() == 'imprints';
  bool get _isTeamSearch =>
      widget.searchChoice.toLowerCase() == 'teams';
  bool get _isPublisherSearch =>
      widget.searchChoice.toLowerCase() == 'publishers';
  bool get _isArcSearch =>
      widget.searchChoice.toLowerCase() == 'arcs';

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
  TeamSearchArgs get _currentTeamArgs =>
      TeamSearchArgs(query: widget.query, page: _page);
  PublisherSearchArgs get _currentPublisherArgs =>
      PublisherSearchArgs(query: widget.query, page: _page);
  ArcSearchArgs get _currentArcArgs =>
      ArcSearchArgs(query: widget.query, page: _page);

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
    } else if (_isTeamSearch) {
      await ref
          .read(metronRepositoryProvider)
          .searchTeams(widget.query, page: _page, forceRefresh: true);
      ref.invalidate(teamSearchResultsProvider(_currentTeamArgs));
      await ref
          .read(teamSearchResultsProvider(_currentTeamArgs).future);
    } else if (_isPublisherSearch) {
      await ref
          .read(metronRepositoryProvider)
          .searchPublishers(widget.query, page: _page, forceRefresh: true);
      ref.invalidate(publisherSearchResultsProvider(_currentPublisherArgs));
      await ref
          .read(publisherSearchResultsProvider(_currentPublisherArgs).future);
    } else if (_isArcSearch) {
      await ref
          .read(metronRepositoryProvider)
          .searchArcs(widget.query, page: _page, forceRefresh: true);
      ref.invalidate(arcSearchResultsProvider(_currentArcArgs));
      await ref
          .read(arcSearchResultsProvider(_currentArcArgs).future);
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

  int _estimatedTeamTotalPages(TeamListPage pageData) {
    return (pageData.count / metronDefaultPageSize).ceil().clamp(1, 99999);
  }

  List<TeamList> _applyTeamFilter(List<TeamList> teams) {
    final filter = _filterController.text.trim().toLowerCase();
    if (filter.isEmpty) return teams;

    return teams.where((entry) {
      final name = entry.name.toLowerCase();
      return name.contains(filter);
    }).toList();
  }

  int _estimatedPublisherTotalPages(PublisherListPage pageData) {
    return (pageData.count / metronDefaultPageSize).ceil().clamp(1, 99999);
  }

  int _estimatedArcTotalPages(ArcListPage pageData) {
    return (pageData.count / metronDefaultPageSize).ceil().clamp(1, 99999);
  }

  List<PublisherList> _applyPublisherFilter(List<PublisherList> publishers) {
    final filter = _filterController.text.trim().toLowerCase();
    if (filter.isEmpty) return publishers;

    return publishers.where((entry) {
      final name = entry.name.toLowerCase();
      return name.contains(filter);
    }).toList();
  }

  List<ArcList> _applyArcFilter(List<ArcList> arcs) {
    final filter = _filterController.text.trim().toLowerCase();
    if (filter.isEmpty) return arcs;

    return arcs.where((entry) {
      final name = entry.name.toLowerCase();
      return name.contains(filter);
    }).toList();
  }

  Widget _buildPublisherBody(
    AsyncValue<PublisherListPage> async,
    ContentSortOption sortOption,
    SortPreferenceContext sortContext,
  ) {
    if (async.hasError) {
      return AsyncStatePanel.error(
        errorMessage: 'Search failed: ${async.error}',
      );
    }
    final pageData = async.asData?.value ?? _lastPublisherPage;
    if (pageData == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final sortedItems = sortPublishers(
      _applyPublisherFilter(pageData.results),
      sortOption,
    );
    return PagedSearchSection<PublisherList>(
      items: sortedItems,
      totalCount: pageData.count,
      currentPage: _page,
      totalPages: _estimatedPublisherTotalPages(pageData),
      hasPrevious: pageData.hasPrevious,
      hasNext: pageData.hasNext,
      onPreviousPage: pageData.hasPrevious && pageData.previousPage != null
          ? () => setState(() => _page = pageData.previousPage!)
          : null,
      onNextPage: pageData.hasNext && pageData.nextPage != null
          ? () => setState(() => _page = pageData.nextPage!)
          : null,
      sortOption: sortOption,
      sortContext: sortContext,
      sortLabelFn: publisherSortLabel,
      onRefresh: _forceRefreshResults,
      isFiltering: _isFiltering,
      isLoading: async.isLoading,
      emptyIcon: Icons.business,
      emptyMessage: 'No publishers found.',
      itemBuilder: (context, index, item, isFirst, isLast) =>
          PublisherListTile(
            publisherId: item.id,
            name: item.name,
            isFirst: isFirst,
            isLast: isLast,
          ),
    );
  }

  Widget _buildArcBody(
    AsyncValue<ArcListPage> async,
    ContentSortOption sortOption,
    SortPreferenceContext sortContext,
  ) {
    if (async.hasError) {
      return AsyncStatePanel.error(
        errorMessage: 'Search failed: ${async.error}',
      );
    }
    final pageData = async.asData?.value ?? _lastArcPage;
    if (pageData == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final sortedItems = sortArcs(
      _applyArcFilter(pageData.results),
      sortOption,
    );
    return PagedSearchSection<ArcList>(
      items: sortedItems,
      totalCount: pageData.count,
      currentPage: _page,
      totalPages: _estimatedArcTotalPages(pageData),
      hasPrevious: pageData.hasPrevious,
      hasNext: pageData.hasNext,
      onPreviousPage: pageData.hasPrevious && pageData.previousPage != null
          ? () => setState(() => _page = pageData.previousPage!)
          : null,
      onNextPage: pageData.hasNext && pageData.nextPage != null
          ? () => setState(() => _page = pageData.nextPage!)
          : null,
      sortOption: sortOption,
      sortContext: sortContext,
      sortLabelFn: arcSortLabel,
      onRefresh: _forceRefreshResults,
      isFiltering: _isFiltering,
      isLoading: async.isLoading,
      emptyIcon: Icons.auto_stories_outlined,
      emptyMessage: 'No arcs found.',
      itemBuilder: (context, index, item, isFirst, isLast) =>
          ArcListTile(
            arcId: item.id,
            name: item.name,
            isFirst: isFirst,
            isLast: isLast,
          ),
    );
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
    final sortedItems = sortUniverses(
      _applyUniverseFilter(pageData.results),
      sortOption,
    );
    return PagedSearchSection<UniverseList>(
      items: sortedItems,
      totalCount: pageData.count,
      currentPage: _page,
      totalPages: _estimatedUniverseTotalPages(pageData),
      hasPrevious: pageData.hasPrevious,
      hasNext: pageData.hasNext,
      onPreviousPage: pageData.hasPrevious && pageData.previousPage != null
          ? () => setState(() => _page = pageData.previousPage!)
          : null,
      onNextPage: pageData.hasNext && pageData.nextPage != null
          ? () => setState(() => _page = pageData.nextPage!)
          : null,
      sortOption: sortOption,
      sortContext: sortContext,
      sortLabelFn: universeSortLabel,
      onRefresh: _forceRefreshResults,
      isFiltering: _isFiltering,
      isLoading: async.isLoading,
      emptyIcon: Icons.language_outlined,
      emptyMessage: 'No universes found.',
      itemBuilder: (context, index, item, isFirst, isLast) =>
          UniverseListTile(
            universeId: item.id,
            name: item.name,
            isFirst: isFirst,
            isLast: isLast,
          ),
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
    final sortedItems = sortImprints(
      _applyImprintFilter(pageData.results),
      sortOption,
    );
    return PagedSearchSection<ImprintList>(
      items: sortedItems,
      totalCount: pageData.count,
      currentPage: _page,
      totalPages: _estimatedImprintTotalPages(pageData),
      hasPrevious: pageData.hasPrevious,
      hasNext: pageData.hasNext,
      onPreviousPage: pageData.hasPrevious && pageData.previousPage != null
          ? () => setState(() => _page = pageData.previousPage!)
          : null,
      onNextPage: pageData.hasNext && pageData.nextPage != null
          ? () => setState(() => _page = pageData.nextPage!)
          : null,
      sortOption: sortOption,
      sortContext: sortContext,
      sortLabelFn: imprintSortLabel,
      onRefresh: _forceRefreshResults,
      isFiltering: _isFiltering,
      isLoading: async.isLoading,
      emptyIcon: Icons.business_outlined,
      emptyMessage: 'No imprints found.',
      itemBuilder: (context, index, item, isFirst, isLast) =>
          ImprintListTile(
            imprintId: item.id,
            name: item.name,
            isFirst: isFirst,
            isLast: isLast,
          ),
    );
  }

  Widget _buildTeamBody(
    AsyncValue<TeamListPage> async,
    ContentSortOption sortOption,
    SortPreferenceContext sortContext,
  ) {
    if (async.hasError) {
      return AsyncStatePanel.error(
        errorMessage: 'Search failed: ${async.error}',
      );
    }
    final pageData = async.asData?.value ?? _lastTeamPage;
    if (pageData == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final sortedItems = sortTeams(
      _applyTeamFilter(pageData.results),
      sortOption,
    );
    return PagedSearchSection<TeamList>(
      items: sortedItems,
      totalCount: pageData.count,
      currentPage: _page,
      totalPages: _estimatedTeamTotalPages(pageData),
      hasPrevious: pageData.hasPrevious,
      hasNext: pageData.hasNext,
      onPreviousPage: pageData.hasPrevious && pageData.previousPage != null
          ? () => setState(() => _page = pageData.previousPage!)
          : null,
      onNextPage: pageData.hasNext && pageData.nextPage != null
          ? () => setState(() => _page = pageData.nextPage!)
          : null,
      sortOption: sortOption,
      sortContext: sortContext,
      sortLabelFn: teamSortLabel,
      onRefresh: _forceRefreshResults,
      isFiltering: _isFiltering,
      isLoading: async.isLoading,
      emptyIcon: Icons.groups_outlined,
      emptyMessage: 'No teams found.',
      itemBuilder: (context, index, item, isFirst, isLast) =>
          TeamListTile(
            teamId: item.id,
            name: item.name,
            isFirst: isFirst,
            isLast: isLast,
          ),
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
    final sortedItems = sortCreators(
      _applyCreatorFilter(pageData.results),
      sortOption,
    );
    return PagedSearchSection<CreatorList>(
      items: sortedItems,
      totalCount: pageData.count,
      currentPage: _page,
      totalPages: _estimatedCreatorTotalPages(pageData),
      hasPrevious: pageData.hasPrevious,
      hasNext: pageData.hasNext,
      onPreviousPage: pageData.hasPrevious && pageData.previousPage != null
          ? () => setState(() => _page = pageData.previousPage!)
          : null,
      onNextPage: pageData.hasNext && pageData.nextPage != null
          ? () => setState(() => _page = pageData.nextPage!)
          : null,
      sortOption: sortOption,
      sortContext: sortContext,
      sortLabelFn: creatorSortLabel,
      onRefresh: _forceRefreshResults,
      isFiltering: _isFiltering,
      isLoading: async.isLoading,
      emptyIcon: Icons.person_outline,
      emptyMessage: 'No creators found.',
      itemBuilder: (context, index, item, isFirst, isLast) =>
          PersonListTile(
            creatorId: item.id,
            name: item.name,
            isFirst: isFirst,
            isLast: isLast,
          ),
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
    final sortedItems = sortCharacters(
      _applyCharacterFilter(pageData.results),
      sortOption,
    );
    return PagedSearchSection<CharacterList>(
      items: sortedItems,
      totalCount: pageData.count,
      currentPage: _page,
      totalPages: _estimatedCharacterTotalPages(pageData),
      hasPrevious: pageData.hasPrevious,
      hasNext: pageData.hasNext,
      onPreviousPage: pageData.hasPrevious && pageData.previousPage != null
          ? () => setState(() => _page = pageData.previousPage!)
          : null,
      onNextPage: pageData.hasNext && pageData.nextPage != null
          ? () => setState(() => _page = pageData.nextPage!)
          : null,
      sortOption: sortOption,
      sortContext: sortContext,
      sortLabelFn: characterSortLabel,
      onRefresh: _forceRefreshResults,
      isFiltering: _isFiltering,
      isLoading: async.isLoading,
      emptyIcon: Icons.people_outline,
      emptyMessage: 'No characters found.',
      itemBuilder: (context, index, item, isFirst, isLast) =>
          PersonListTile(
            characterId: item.id,
            name: item.name,
            isFirst: isFirst,
            isLast: isLast,
          ),
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
    final sortedItems = sortSeries(
      _applySeriesFilter(pageData.results),
      sortOption,
    );
    return PagedSearchSection<SeriesList>(
      items: sortedItems,
      totalCount: pageData.count,
      currentPage: _page,
      totalPages: _estimatedSeriesTotalPages(pageData),
      hasPrevious: pageData.hasPrevious,
      hasNext: pageData.hasNext,
      onPreviousPage: pageData.hasPrevious && pageData.previousPage != null
          ? () => setState(() {
              _page = pageData.previousPage!;
              _resetSeriesCoverFetchLimit();
            })
          : null,
      onNextPage: pageData.hasNext && pageData.nextPage != null
          ? () => setState(() {
              _page = pageData.nextPage!;
              _resetSeriesCoverFetchLimit();
            })
          : null,
      sortOption: sortOption,
      sortContext: sortContext,
      sortLabelFn: seriesSortLabel,
      onRefresh: _forceRefreshResults,
      isFiltering: _isFiltering,
      isLoading: async.isLoading,
      emptyIcon: Icons.collections_bookmark_outlined,
      emptyMessage: 'No series found.',
      itemBuilder: (context, index, item, isFirst, isLast) =>
          SeriesListTile(
            series: item,
            allowRemoteCoverFetch: index < _seriesCoverFetchLimit,
            heroTag: 'series-cover-${item.id}',
            isFirst: isFirst,
            isLast: isLast,
          ),
      onItemIndexed: (index, total) =>
          _maybeExpandSeriesCoverFetchLimit(index: index, total: total),
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
    final sortedItems = sortIssues(
      _applyFilter(pageData.results),
      sortOption,
    );
    return PagedSearchSection<IssueList>(
      items: sortedItems,
      totalCount: pageData.count,
      currentPage: _page,
      totalPages: _estimatedTotalPages(pageData),
      hasPrevious: pageData.hasPrevious,
      hasNext: pageData.hasNext,
      onPreviousPage: pageData.hasPrevious && pageData.previousPage != null
          ? () => setState(() => _page = pageData.previousPage!)
          : null,
      onNextPage: pageData.hasNext && pageData.nextPage != null
          ? () => setState(() => _page = pageData.nextPage!)
          : null,
      sortOption: sortOption,
      sortContext: sortContext,
      sortLabelFn: issueSortLabel,
      onRefresh: _forceRefreshResults,
      isFiltering: _isFiltering,
      isLoading: async.isLoading,
      emptyIcon: Icons.menu_book_outlined,
      emptyMessage: 'No issues found.',
      itemBuilder: (context, index, item, isFirst, isLast) =>
          IssueListTile(
            issue: item,
            isFirst: isFirst,
            isLast: isLast,
          ),
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
                    : _isTeamSearch
                        ? SortPreferenceContext.searchTeams
                        : _isPublisherSearch
                            ? SortPreferenceContext.searchPublishers
                            : _isArcSearch
                                ? SortPreferenceContext.searchTeams
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
    final teamResultsAsync = _isTeamSearch
        ? ref.watch(teamSearchResultsProvider(_currentTeamArgs))
        : null;
    final publisherResultsAsync = _isPublisherSearch
        ? ref.watch(publisherSearchResultsProvider(_currentPublisherArgs))
        : null;
    final arcResultsAsync = _isArcSearch
        ? ref.watch(arcSearchResultsProvider(_currentArcArgs))
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
            _isImprintSearch ||
            _isTeamSearch ||
            _isPublisherSearch ||
            _isArcSearch
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
                    : _isTeamSearch
                        ? teamResultsAsync?.isLoading == true
                        : _isPublisherSearch
                            ? publisherResultsAsync?.isLoading == true
                            : _isArcSearch
                                ? arcResultsAsync?.isLoading == true
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
    } else if (_isTeamSearch) {
      if (teamResultsAsync?.hasValue == true) {
        _lastTeamPage = teamResultsAsync!.value;
      }
    } else if (_isPublisherSearch) {
      if (publisherResultsAsync?.hasValue == true) {
        _lastPublisherPage = publisherResultsAsync!.value;
      }
    } else if (_isArcSearch) {
      if (arcResultsAsync?.hasValue == true) {
        _lastArcPage = arcResultsAsync!.value;
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
        centerTitle: !_isFiltering,
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
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Search Results'),
                  Text(
                    '${widget.query} - ${widget.searchChoice}',
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
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
                      : _isTeamSearch
                          ? _buildTeamBody(
                              teamResultsAsync!, sortOption, sortContext)
                          : _isPublisherSearch
                              ? _buildPublisherBody(
                                  publisherResultsAsync!, sortOption, sortContext)
                              : _isArcSearch
                                  ? _buildArcBody(
                                      arcResultsAsync!, sortOption, sortContext)
                                  : _isSeriesSearch
                                  ? _buildSeriesBody(
                                      seriesResultsAsync!, sortOption, sortContext)
                                  : _buildIssueBody(
                                      issueResultsAsync!, sortOption, sortContext),
    );
  }
}
