import "package:takion/src/data/catalog/datasources/local/metron_page_cache_keys.dart";
import "package:takion/src/data/catalog/datasources/local/paged_local_cache.dart";
import "package:takion/src/data/catalog/dto/dto.dart";
import "package:takion/src/data/common/drift/database.dart";
import "package:takion/src/data/reading_list/dto/reading_list_dto.dart";

abstract class MetronListLocalDataSource {
  Future<void> cacheIssueListResults(
    List<IssueListDto> issues, {
    required int page,
    String? ordering,
    DateTime? modifiedGt,
    int? limit,
    required int count,
    String? next,
    String? previous,
  });
  Future<List<IssueListDto>?> getIssueListResults({
    required int page,
    String? ordering,
    DateTime? modifiedGt,
    int? limit,
  });
  Future<DateTime?> getIssueListResultsCachedAt({
    required int page,
    String? ordering,
    DateTime? modifiedGt,
    int? limit,
  });
  Future<PageCacheMeta?> getIssueListResultsMeta({
    required int page,
    String? ordering,
    DateTime? modifiedGt,
    int? limit,
  });

  Future<void> cacheSeriesListResults(
    List<SeriesListDto> series, {
    required int page,
    required int limit,
    DateTime? modifiedGt,
    required int count,
    String? next,
    String? previous,
  });
  Future<List<SeriesListDto>?> getSeriesListResults({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  });
  Future<DateTime?> getSeriesListResultsCachedAt({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  });
  Future<PageCacheMeta?> getSeriesListResultsMeta({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  });

  Future<void> cacheSeriesIssueListResults(
    int seriesId,
    List<IssueListDto> issues, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
    String? ordering,
    DateTime? storeDateGte,
    DateTime? storeDateLte,
  });
  Future<List<IssueListDto>?> getSeriesIssueListResults(
    int seriesId, {
    required int page,
    required int limit,
    String? ordering,
    DateTime? storeDateGte,
    DateTime? storeDateLte,
  });
  Future<DateTime?> getSeriesIssueListResultsCachedAt(
    int seriesId, {
    required int page,
    required int limit,
    String? ordering,
    DateTime? storeDateGte,
    DateTime? storeDateLte,
  });
  Future<PageCacheMeta?> getSeriesIssueListResultsMeta(
    int seriesId, {
    required int page,
    required int limit,
    String? ordering,
    DateTime? storeDateGte,
    DateTime? storeDateLte,
  });

  Future<void> cacheCharacterListResults(
    List<CharacterListDto> characters, {
    required int page,
    required int limit,
    DateTime? modifiedGt,
    required int count,
    String? next,
    String? previous,
  });
  Future<List<CharacterListDto>?> getCharacterListResults({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  });
  Future<DateTime?> getCharacterListResultsCachedAt({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  });
  Future<PageCacheMeta?> getCharacterListResultsMeta({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  });

  Future<void> cacheCharacterIssueListResults(
    int characterId,
    List<IssueListDto> issues, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  });
  Future<List<IssueListDto>?> getCharacterIssueListResults(
    int characterId, {
    required int page,
    required int limit,
  });
  Future<DateTime?> getCharacterIssueListResultsCachedAt(
    int characterId, {
    required int page,
    required int limit,
  });
  Future<PageCacheMeta?> getCharacterIssueListResultsMeta(
    int characterId, {
    required int page,
    required int limit,
  });

  Future<void> cacheCreatorListResults(
    List<CreatorListDto> creators, {
    required int page,
    required int limit,
    DateTime? modifiedGt,
    required int count,
    String? next,
    String? previous,
  });
  Future<List<CreatorListDto>?> getCreatorListResults({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  });
  Future<DateTime?> getCreatorListResultsCachedAt({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  });
  Future<PageCacheMeta?> getCreatorListResultsMeta({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  });

  Future<void> cacheImprintListResults(
    List<ImprintListDto> imprints, {
    required int page,
    required int limit,
    DateTime? modifiedGt,
    required int count,
    String? next,
    String? previous,
  });
  Future<List<ImprintListDto>?> getImprintListResults({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  });
  Future<DateTime?> getImprintListResultsCachedAt({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  });
  Future<PageCacheMeta?> getImprintListResultsMeta({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  });

  Future<void> cachePublisherListResults(
    List<PublisherListDto> publishers, {
    required int page,
    required int limit,
    DateTime? modifiedGt,
    required int count,
    String? next,
    String? previous,
  });
  Future<List<PublisherListDto>?> getPublisherListResults({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  });
  Future<DateTime?> getPublisherListResultsCachedAt({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  });
  Future<PageCacheMeta?> getPublisherListResultsMeta({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  });

  Future<void> cachePublisherSeriesListResults(
    int publisherId,
    List<SeriesListDto> series, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  });
  Future<List<SeriesListDto>?> getPublisherSeriesListResults(
    int publisherId, {
    required int page,
    required int limit,
  });
  Future<DateTime?> getPublisherSeriesListResultsCachedAt(
    int publisherId, {
    required int page,
    required int limit,
  });
  Future<PageCacheMeta?> getPublisherSeriesListResultsMeta(
    int publisherId, {
    required int page,
    required int limit,
  });

  Future<void> cacheTeamListResults(
    List<TeamListDto> teams, {
    required int page,
    required int limit,
    DateTime? modifiedGt,
    required int count,
    String? next,
    String? previous,
  });
  Future<List<TeamListDto>?> getTeamListResults({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  });
  Future<DateTime?> getTeamListResultsCachedAt({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  });
  Future<PageCacheMeta?> getTeamListResultsMeta({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  });

  Future<void> cacheTeamIssueListResults(
    int teamId,
    List<IssueListDto> issues, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  });
  Future<List<IssueListDto>?> getTeamIssueListResults(
    int teamId, {
    required int page,
    required int limit,
  });
  Future<DateTime?> getTeamIssueListResultsCachedAt(
    int teamId, {
    required int page,
    required int limit,
  });
  Future<PageCacheMeta?> getTeamIssueListResultsMeta(
    int teamId, {
    required int page,
    required int limit,
  });

  Future<void> cacheUniverseListResults(
    List<UniverseListDto> universes, {
    required int page,
    required int limit,
    DateTime? modifiedGt,
    required int count,
    String? next,
    String? previous,
  });
  Future<List<UniverseListDto>?> getUniverseListResults({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  });
  Future<DateTime?> getUniverseListResultsCachedAt({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  });
  Future<PageCacheMeta?> getUniverseListResultsMeta({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  });

  Future<void> cacheArcListResults(
    List<ArcListDto> arcs, {
    required int page,
    required int limit,
    DateTime? modifiedGt,
    required int count,
    String? next,
    String? previous,
  });
  Future<List<ArcListDto>?> getArcListResults({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  });
  Future<DateTime?> getArcListResultsCachedAt({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  });
  Future<PageCacheMeta?> getArcListResultsMeta({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  });

  Future<void> cacheArcIssueListResults(
    int arcId,
    List<IssueListDto> issues, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  });
  Future<List<IssueListDto>?> getArcIssueListResults(
    int arcId, {
    required int page,
    required int limit,
  });
  Future<DateTime?> getArcIssueListResultsCachedAt(
    int arcId, {
    required int page,
    required int limit,
  });
  Future<PageCacheMeta?> getArcIssueListResultsMeta(
    int arcId, {
    required int page,
    required int limit,
  });

  Future<void> cacheReadingListResults(
    List<ReadingListDto> readingLists, {
    required int page,
    required int limit,
    DateTime? modifiedGt,
    String? name,
    String? listType,
    String? attributionSource,
    String? publisher,
    required int count,
    String? next,
    String? previous,
  });
  Future<List<ReadingListDto>?> getReadingListResults({
    required int page,
    required int limit,
    DateTime? modifiedGt,
    String? name,
    String? listType,
    String? attributionSource,
    String? publisher,
  });
  Future<DateTime?> getReadingListResultsCachedAt({
    required int page,
    required int limit,
    DateTime? modifiedGt,
    String? name,
    String? listType,
    String? attributionSource,
    String? publisher,
  });
  Future<PageCacheMeta?> getReadingListResultsMeta({
    required int page,
    required int limit,
    DateTime? modifiedGt,
    String? name,
    String? listType,
    String? attributionSource,
    String? publisher,
  });
}

class MetronListLocalDataSourceImpl implements MetronListLocalDataSource {
  MetronListLocalDataSourceImpl(AppDatabase db)
      : _issueList = PagedLocalCache<IssueListDto>(
          db: db,
          cacheKeyPrefix: "issue_list",
          entityType: "issue_list",
          fromJson: IssueListDto.fromJson,
          toJson: (i) => i.toJson(),
        ),
        _seriesList = PagedLocalCache<SeriesListDto>(
          db: db,
          cacheKeyPrefix: "series_list",
          entityType: "series_list",
          fromJson: SeriesListDto.fromJson,
          toJson: (s) => s.toJson(),
        ),
        _seriesIssueList = PagedLocalCache<IssueListDto>(
          db: db,
          cacheKeyPrefix: "series_issue_list",
          entityType: "series_issue_list",
          fromJson: IssueListDto.fromJson,
          toJson: (i) => i.toJson(),
        ),
        _characterList = PagedLocalCache<CharacterListDto>(
          db: db,
          cacheKeyPrefix: "character_list",
          entityType: "character_list",
          fromJson: CharacterListDto.fromJson,
          toJson: (c) => c.toJson(),
        ),
        _characterIssueList = PagedLocalCache<IssueListDto>(
          db: db,
          cacheKeyPrefix: "character_issue_list",
          entityType: "character_issue_list",
          fromJson: IssueListDto.fromJson,
          toJson: (i) => i.toJson(),
        ),
        _creatorList = PagedLocalCache<CreatorListDto>(
          db: db,
          cacheKeyPrefix: "creator_list",
          entityType: "creator_list",
          fromJson: CreatorListDto.fromJson,
          toJson: (c) => c.toJson(),
        ),
        _imprintList = PagedLocalCache<ImprintListDto>(
          db: db,
          cacheKeyPrefix: "imprint_list",
          entityType: "imprint_list",
          fromJson: ImprintListDto.fromJson,
          toJson: (i) => i.toJson(),
        ),
        _publisherList = PagedLocalCache<PublisherListDto>(
          db: db,
          cacheKeyPrefix: "publisher_list",
          entityType: "publisher_list",
          fromJson: PublisherListDto.fromJson,
          toJson: (p) => p.toJson(),
        ),
        _publisherSeriesList = PagedLocalCache<SeriesListDto>(
          db: db,
          cacheKeyPrefix: "publisher_series_list",
          entityType: "publisher_series_list",
          fromJson: SeriesListDto.fromJson,
          toJson: (s) => s.toJson(),
        ),
        _teamList = PagedLocalCache<TeamListDto>(
          db: db,
          cacheKeyPrefix: "team_list",
          entityType: "team_list",
          fromJson: TeamListDto.fromJson,
          toJson: (t) => t.toJson(),
        ),
        _teamIssueList = PagedLocalCache<IssueListDto>(
          db: db,
          cacheKeyPrefix: "team_issue_list",
          entityType: "team_issue_list",
          fromJson: IssueListDto.fromJson,
          toJson: (i) => i.toJson(),
        ),
        _universeList = PagedLocalCache<UniverseListDto>(
          db: db,
          cacheKeyPrefix: "universe_list",
          entityType: "universe_list",
          fromJson: UniverseListDto.fromJson,
          toJson: (u) => u.toJson(),
        ),
        _arcList = PagedLocalCache<ArcListDto>(
          db: db,
          cacheKeyPrefix: "arc_list",
          entityType: "arc_list",
          fromJson: ArcListDto.fromJson,
          toJson: (a) => a.toJson(),
        ),
        _arcIssueList = PagedLocalCache<IssueListDto>(
          db: db,
          cacheKeyPrefix: "arc_issue_list",
          entityType: "arc_issue_list",
          fromJson: IssueListDto.fromJson,
          toJson: (i) => i.toJson(),
        ),
        _readingList = PagedLocalCache<ReadingListDto>(
          db: db,
          cacheKeyPrefix: "reading_list",
          entityType: "reading_list",
          fromJson: ReadingListDto.fromJson,
          toJson: (r) => r.toJson(),
        );

  final PagedLocalCache<IssueListDto> _issueList;
  final PagedLocalCache<SeriesListDto> _seriesList;
  final PagedLocalCache<IssueListDto> _seriesIssueList;
  final PagedLocalCache<CharacterListDto> _characterList;
  final PagedLocalCache<IssueListDto> _characterIssueList;
  final PagedLocalCache<CreatorListDto> _creatorList;
  final PagedLocalCache<ImprintListDto> _imprintList;
  final PagedLocalCache<PublisherListDto> _publisherList;
  final PagedLocalCache<SeriesListDto> _publisherSeriesList;
  final PagedLocalCache<TeamListDto> _teamList;
  final PagedLocalCache<IssueListDto> _teamIssueList;
  final PagedLocalCache<UniverseListDto> _universeList;
  final PagedLocalCache<ArcListDto> _arcList;
  final PagedLocalCache<IssueListDto> _arcIssueList;
  final PagedLocalCache<ReadingListDto> _readingList;

  @override
  Future<void> cacheIssueListResults(
    List<IssueListDto> issues, {
    required int page,
    String? ordering,
    DateTime? modifiedGt,
    int? limit,
    required int count,
    String? next,
    String? previous,
  }) async {
    final key = MetronPageCacheKeys.issueList(
      page: page,
      ordering: ordering,
      modifiedGt: modifiedGt,
      limit: limit,
    );
    await _issueList.cache(
      key,
      issues,
      count: count,
      next: next,
      previous: previous,
    );
  }

  @override
  Future<List<IssueListDto>?> getIssueListResults({
    required int page,
    String? ordering,
    DateTime? modifiedGt,
    int? limit,
  }) async {
    final key = MetronPageCacheKeys.issueList(
      page: page,
      ordering: ordering,
      modifiedGt: modifiedGt,
      limit: limit,
    );
    return _issueList.get(key);
  }

  @override
  Future<DateTime?> getIssueListResultsCachedAt({
    required int page,
    String? ordering,
    DateTime? modifiedGt,
    int? limit,
  }) async {
    final key = MetronPageCacheKeys.issueList(
      page: page,
      ordering: ordering,
      modifiedGt: modifiedGt,
      limit: limit,
    );
    return _issueList.cachedAt(key);
  }

  @override
  Future<PageCacheMeta?> getIssueListResultsMeta({
    required int page,
    String? ordering,
    DateTime? modifiedGt,
    int? limit,
  }) async {
    final key = MetronPageCacheKeys.issueList(
      page: page,
      ordering: ordering,
      modifiedGt: modifiedGt,
      limit: limit,
    );
    return _issueList.meta(key);
  }

  @override
  Future<void> cacheSeriesListResults(
    List<SeriesListDto> series, {
    required int page,
    required int limit,
    DateTime? modifiedGt,
    required int count,
    String? next,
    String? previous,
  }) async {
    final key = MetronPageCacheKeys.seriesList(page, limit, modifiedGt: modifiedGt);
    await _seriesList.cache(
      key,
      series,
      count: count,
      next: next,
      previous: previous,
    );
  }

  @override
  Future<List<SeriesListDto>?> getSeriesListResults({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  }) async {
    final key = MetronPageCacheKeys.seriesList(page, limit, modifiedGt: modifiedGt);
    return _seriesList.get(key);
  }

  @override
  Future<DateTime?> getSeriesListResultsCachedAt({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  }) async {
    final key = MetronPageCacheKeys.seriesList(page, limit, modifiedGt: modifiedGt);
    return _seriesList.cachedAt(key);
  }

  @override
  Future<PageCacheMeta?> getSeriesListResultsMeta({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  }) async {
    final key = MetronPageCacheKeys.seriesList(page, limit, modifiedGt: modifiedGt);
    return _seriesList.meta(key);
  }

  @override
  Future<void> cacheSeriesIssueListResults(
    int seriesId,
    List<IssueListDto> issues, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
    String? ordering,
    DateTime? storeDateGte,
    DateTime? storeDateLte,
  }) async {
    final key = MetronPageCacheKeys.seriesIssueList(
      seriesId,
      page,
      limit,
      ordering: ordering,
      storeDateGte: storeDateGte,
      storeDateLte: storeDateLte,
    );
    await _seriesIssueList.cache(
      key,
      issues,
      count: count,
      next: next,
      previous: previous,
    );
  }

  @override
  Future<List<IssueListDto>?> getSeriesIssueListResults(
    int seriesId, {
    required int page,
    required int limit,
    String? ordering,
    DateTime? storeDateGte,
    DateTime? storeDateLte,
  }) async {
    final key = MetronPageCacheKeys.seriesIssueList(
      seriesId,
      page,
      limit,
      ordering: ordering,
      storeDateGte: storeDateGte,
      storeDateLte: storeDateLte,
    );
    return _seriesIssueList.get(key);
  }

  @override
  Future<DateTime?> getSeriesIssueListResultsCachedAt(
    int seriesId, {
    required int page,
    required int limit,
    String? ordering,
    DateTime? storeDateGte,
    DateTime? storeDateLte,
  }) async {
    final key = MetronPageCacheKeys.seriesIssueList(
      seriesId,
      page,
      limit,
      ordering: ordering,
      storeDateGte: storeDateGte,
      storeDateLte: storeDateLte,
    );
    return _seriesIssueList.cachedAt(key);
  }

  @override
  Future<PageCacheMeta?> getSeriesIssueListResultsMeta(
    int seriesId, {
    required int page,
    required int limit,
    String? ordering,
    DateTime? storeDateGte,
    DateTime? storeDateLte,
  }) async {
    final key = MetronPageCacheKeys.seriesIssueList(
      seriesId,
      page,
      limit,
      ordering: ordering,
      storeDateGte: storeDateGte,
      storeDateLte: storeDateLte,
    );
    return _seriesIssueList.meta(key);
  }

  @override
  Future<void> cacheCharacterListResults(
    List<CharacterListDto> characters, {
    required int page,
    required int limit,
    DateTime? modifiedGt,
    required int count,
    String? next,
    String? previous,
  }) async {
    final key = MetronPageCacheKeys.characterList(page, limit, modifiedGt: modifiedGt);
    await _characterList.cache(
      key,
      characters,
      count: count,
      next: next,
      previous: previous,
    );
  }

  @override
  Future<List<CharacterListDto>?> getCharacterListResults({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  }) async {
    final key = MetronPageCacheKeys.characterList(page, limit, modifiedGt: modifiedGt);
    return _characterList.get(key);
  }

  @override
  Future<DateTime?> getCharacterListResultsCachedAt({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  }) async {
    final key = MetronPageCacheKeys.characterList(page, limit, modifiedGt: modifiedGt);
    return _characterList.cachedAt(key);
  }

  @override
  Future<PageCacheMeta?> getCharacterListResultsMeta({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  }) async {
    final key = MetronPageCacheKeys.characterList(page, limit, modifiedGt: modifiedGt);
    return _characterList.meta(key);
  }

  @override
  Future<void> cacheCharacterIssueListResults(
    int characterId,
    List<IssueListDto> issues, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  }) async {
    final key = MetronPageCacheKeys.characterIssueList(characterId, page, limit);
    await _characterIssueList.cache(
      key,
      issues,
      count: count,
      next: next,
      previous: previous,
    );
  }

  @override
  Future<List<IssueListDto>?> getCharacterIssueListResults(
    int characterId, {
    required int page,
    required int limit,
  }) async {
    final key = MetronPageCacheKeys.characterIssueList(characterId, page, limit);
    return _characterIssueList.get(key);
  }

  @override
  Future<DateTime?> getCharacterIssueListResultsCachedAt(
    int characterId, {
    required int page,
    required int limit,
  }) async {
    final key = MetronPageCacheKeys.characterIssueList(characterId, page, limit);
    return _characterIssueList.cachedAt(key);
  }

  @override
  Future<PageCacheMeta?> getCharacterIssueListResultsMeta(
    int characterId, {
    required int page,
    required int limit,
  }) async {
    final key = MetronPageCacheKeys.characterIssueList(characterId, page, limit);
    return _characterIssueList.meta(key);
  }

  @override
  Future<void> cacheCreatorListResults(
    List<CreatorListDto> creators, {
    required int page,
    required int limit,
    DateTime? modifiedGt,
    required int count,
    String? next,
    String? previous,
  }) async {
    final key = MetronPageCacheKeys.creatorList(page, limit, modifiedGt: modifiedGt);
    await _creatorList.cache(
      key,
      creators,
      count: count,
      next: next,
      previous: previous,
    );
  }

  @override
  Future<List<CreatorListDto>?> getCreatorListResults({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  }) async {
    final key = MetronPageCacheKeys.creatorList(page, limit, modifiedGt: modifiedGt);
    return _creatorList.get(key);
  }

  @override
  Future<DateTime?> getCreatorListResultsCachedAt({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  }) async {
    final key = MetronPageCacheKeys.creatorList(page, limit, modifiedGt: modifiedGt);
    return _creatorList.cachedAt(key);
  }

  @override
  Future<PageCacheMeta?> getCreatorListResultsMeta({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  }) async {
    final key = MetronPageCacheKeys.creatorList(page, limit, modifiedGt: modifiedGt);
    return _creatorList.meta(key);
  }

  @override
  Future<void> cacheImprintListResults(
    List<ImprintListDto> imprints, {
    required int page,
    required int limit,
    DateTime? modifiedGt,
    required int count,
    String? next,
    String? previous,
  }) async {
    final key = MetronPageCacheKeys.imprintList(page, limit, modifiedGt: modifiedGt);
    await _imprintList.cache(
      key,
      imprints,
      count: count,
      next: next,
      previous: previous,
    );
  }

  @override
  Future<List<ImprintListDto>?> getImprintListResults({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  }) async {
    final key = MetronPageCacheKeys.imprintList(page, limit, modifiedGt: modifiedGt);
    return _imprintList.get(key);
  }

  @override
  Future<DateTime?> getImprintListResultsCachedAt({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  }) async {
    final key = MetronPageCacheKeys.imprintList(page, limit, modifiedGt: modifiedGt);
    return _imprintList.cachedAt(key);
  }

  @override
  Future<PageCacheMeta?> getImprintListResultsMeta({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  }) async {
    final key = MetronPageCacheKeys.imprintList(page, limit, modifiedGt: modifiedGt);
    return _imprintList.meta(key);
  }

  @override
  Future<void> cachePublisherListResults(
    List<PublisherListDto> publishers, {
    required int page,
    required int limit,
    DateTime? modifiedGt,
    required int count,
    String? next,
    String? previous,
  }) async {
    final key = MetronPageCacheKeys.publisherList(page, limit, modifiedGt: modifiedGt);
    await _publisherList.cache(
      key,
      publishers,
      count: count,
      next: next,
      previous: previous,
    );
  }

  @override
  Future<List<PublisherListDto>?> getPublisherListResults({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  }) async {
    final key = MetronPageCacheKeys.publisherList(page, limit, modifiedGt: modifiedGt);
    return _publisherList.get(key);
  }

  @override
  Future<DateTime?> getPublisherListResultsCachedAt({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  }) async {
    final key = MetronPageCacheKeys.publisherList(page, limit, modifiedGt: modifiedGt);
    return _publisherList.cachedAt(key);
  }

  @override
  Future<PageCacheMeta?> getPublisherListResultsMeta({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  }) async {
    final key = MetronPageCacheKeys.publisherList(page, limit, modifiedGt: modifiedGt);
    return _publisherList.meta(key);
  }

  @override
  Future<void> cachePublisherSeriesListResults(
    int publisherId,
    List<SeriesListDto> series, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  }) async {
    final key = MetronPageCacheKeys.publisherSeriesList(publisherId, page, limit);
    await _publisherSeriesList.cache(
      key,
      series,
      count: count,
      next: next,
      previous: previous,
    );
  }

  @override
  Future<List<SeriesListDto>?> getPublisherSeriesListResults(
    int publisherId, {
    required int page,
    required int limit,
  }) async {
    final key = MetronPageCacheKeys.publisherSeriesList(publisherId, page, limit);
    return _publisherSeriesList.get(key);
  }

  @override
  Future<DateTime?> getPublisherSeriesListResultsCachedAt(
    int publisherId, {
    required int page,
    required int limit,
  }) async {
    final key = MetronPageCacheKeys.publisherSeriesList(publisherId, page, limit);
    return _publisherSeriesList.cachedAt(key);
  }

  @override
  Future<PageCacheMeta?> getPublisherSeriesListResultsMeta(
    int publisherId, {
    required int page,
    required int limit,
  }) async {
    final key = MetronPageCacheKeys.publisherSeriesList(publisherId, page, limit);
    return _publisherSeriesList.meta(key);
  }

  @override
  Future<void> cacheTeamListResults(
    List<TeamListDto> teams, {
    required int page,
    required int limit,
    DateTime? modifiedGt,
    required int count,
    String? next,
    String? previous,
  }) async {
    final key = MetronPageCacheKeys.teamList(page, limit, modifiedGt: modifiedGt);
    await _teamList.cache(
      key,
      teams,
      count: count,
      next: next,
      previous: previous,
    );
  }

  @override
  Future<List<TeamListDto>?> getTeamListResults({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  }) async {
    final key = MetronPageCacheKeys.teamList(page, limit, modifiedGt: modifiedGt);
    return _teamList.get(key);
  }

  @override
  Future<DateTime?> getTeamListResultsCachedAt({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  }) async {
    final key = MetronPageCacheKeys.teamList(page, limit, modifiedGt: modifiedGt);
    return _teamList.cachedAt(key);
  }

  @override
  Future<PageCacheMeta?> getTeamListResultsMeta({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  }) async {
    final key = MetronPageCacheKeys.teamList(page, limit, modifiedGt: modifiedGt);
    return _teamList.meta(key);
  }

  @override
  Future<void> cacheTeamIssueListResults(
    int teamId,
    List<IssueListDto> issues, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  }) async {
    final key = MetronPageCacheKeys.teamIssueList(teamId, page, limit);
    await _teamIssueList.cache(
      key,
      issues,
      count: count,
      next: next,
      previous: previous,
    );
  }

  @override
  Future<List<IssueListDto>?> getTeamIssueListResults(
    int teamId, {
    required int page,
    required int limit,
  }) async {
    final key = MetronPageCacheKeys.teamIssueList(teamId, page, limit);
    return _teamIssueList.get(key);
  }

  @override
  Future<DateTime?> getTeamIssueListResultsCachedAt(
    int teamId, {
    required int page,
    required int limit,
  }) async {
    final key = MetronPageCacheKeys.teamIssueList(teamId, page, limit);
    return _teamIssueList.cachedAt(key);
  }

  @override
  Future<PageCacheMeta?> getTeamIssueListResultsMeta(
    int teamId, {
    required int page,
    required int limit,
  }) async {
    final key = MetronPageCacheKeys.teamIssueList(teamId, page, limit);
    return _teamIssueList.meta(key);
  }

  @override
  Future<void> cacheUniverseListResults(
    List<UniverseListDto> universes, {
    required int page,
    required int limit,
    DateTime? modifiedGt,
    required int count,
    String? next,
    String? previous,
  }) async {
    final key = MetronPageCacheKeys.universeList(page, limit, modifiedGt: modifiedGt);
    await _universeList.cache(
      key,
      universes,
      count: count,
      next: next,
      previous: previous,
    );
  }

  @override
  Future<List<UniverseListDto>?> getUniverseListResults({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  }) async {
    final key = MetronPageCacheKeys.universeList(page, limit, modifiedGt: modifiedGt);
    return _universeList.get(key);
  }

  @override
  Future<DateTime?> getUniverseListResultsCachedAt({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  }) async {
    final key = MetronPageCacheKeys.universeList(page, limit, modifiedGt: modifiedGt);
    return _universeList.cachedAt(key);
  }

  @override
  Future<PageCacheMeta?> getUniverseListResultsMeta({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  }) async {
    final key = MetronPageCacheKeys.universeList(page, limit, modifiedGt: modifiedGt);
    return _universeList.meta(key);
  }

  @override
  Future<void> cacheArcListResults(
    List<ArcListDto> arcs, {
    required int page,
    required int limit,
    DateTime? modifiedGt,
    required int count,
    String? next,
    String? previous,
  }) async {
    final key = MetronPageCacheKeys.arcList(page, limit, modifiedGt: modifiedGt);
    await _arcList.cache(
      key,
      arcs,
      count: count,
      next: next,
      previous: previous,
    );
  }

  @override
  Future<List<ArcListDto>?> getArcListResults({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  }) async {
    final key = MetronPageCacheKeys.arcList(page, limit, modifiedGt: modifiedGt);
    return _arcList.get(key);
  }

  @override
  Future<DateTime?> getArcListResultsCachedAt({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  }) async {
    final key = MetronPageCacheKeys.arcList(page, limit, modifiedGt: modifiedGt);
    return _arcList.cachedAt(key);
  }

  @override
  Future<PageCacheMeta?> getArcListResultsMeta({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  }) async {
    final key = MetronPageCacheKeys.arcList(page, limit, modifiedGt: modifiedGt);
    return _arcList.meta(key);
  }

  @override
  Future<void> cacheArcIssueListResults(
    int arcId,
    List<IssueListDto> issues, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  }) async {
    final key = MetronPageCacheKeys.arcIssueList(arcId, page, limit);
    await _arcIssueList.cache(
      key,
      issues,
      count: count,
      next: next,
      previous: previous,
    );
  }

  @override
  Future<List<IssueListDto>?> getArcIssueListResults(
    int arcId, {
    required int page,
    required int limit,
  }) async {
    final key = MetronPageCacheKeys.arcIssueList(arcId, page, limit);
    return _arcIssueList.get(key);
  }

  @override
  Future<DateTime?> getArcIssueListResultsCachedAt(
    int arcId, {
    required int page,
    required int limit,
  }) async {
    final key = MetronPageCacheKeys.arcIssueList(arcId, page, limit);
    return _arcIssueList.cachedAt(key);
  }

  @override
  Future<PageCacheMeta?> getArcIssueListResultsMeta(
    int arcId, {
    required int page,
    required int limit,
  }) async {
    final key = MetronPageCacheKeys.arcIssueList(arcId, page, limit);
    return _arcIssueList.meta(key);
  }

  @override
  Future<void> cacheReadingListResults(
    List<ReadingListDto> readingLists, {
    required int page,
    required int limit,
    DateTime? modifiedGt,
    String? name,
    String? listType,
    String? attributionSource,
    String? publisher,
    required int count,
    String? next,
    String? previous,
  }) async {
    final key = MetronPageCacheKeys.readingList(
      page,
      limit,
      modifiedGt: modifiedGt,
      name: name,
      listType: listType,
      attributionSource: attributionSource,
      publisher: publisher,
    );
    await _readingList.cache(
      key,
      readingLists,
      count: count,
      next: next,
      previous: previous,
    );
  }

  @override
  Future<List<ReadingListDto>?> getReadingListResults({
    required int page,
    required int limit,
    DateTime? modifiedGt,
    String? name,
    String? listType,
    String? attributionSource,
    String? publisher,
  }) async {
    final key = MetronPageCacheKeys.readingList(
      page,
      limit,
      modifiedGt: modifiedGt,
      name: name,
      listType: listType,
      attributionSource: attributionSource,
      publisher: publisher,
    );
    return _readingList.get(key);
  }

  @override
  Future<DateTime?> getReadingListResultsCachedAt({
    required int page,
    required int limit,
    DateTime? modifiedGt,
    String? name,
    String? listType,
    String? attributionSource,
    String? publisher,
  }) async {
    final key = MetronPageCacheKeys.readingList(
      page,
      limit,
      modifiedGt: modifiedGt,
      name: name,
      listType: listType,
      attributionSource: attributionSource,
      publisher: publisher,
    );
    return _readingList.cachedAt(key);
  }

  @override
  Future<PageCacheMeta?> getReadingListResultsMeta({
    required int page,
    required int limit,
    DateTime? modifiedGt,
    String? name,
    String? listType,
    String? attributionSource,
    String? publisher,
  }) async {
    final key = MetronPageCacheKeys.readingList(
      page,
      limit,
      modifiedGt: modifiedGt,
      name: name,
      listType: listType,
      attributionSource: attributionSource,
      publisher: publisher,
    );
    return _readingList.meta(key);
  }
}
