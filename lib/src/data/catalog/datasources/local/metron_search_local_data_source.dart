import "package:takion/src/data/catalog/datasources/local/metron_page_cache_keys.dart";
import "package:takion/src/data/catalog/datasources/local/paged_local_cache.dart";
import "package:takion/src/data/catalog/dto/dto.dart";
import "package:takion/src/data/common/drift/database.dart";

abstract class MetronSearchLocalDataSource {
  Future<void> cacheIssueSearchResults(
    String query,
    List<IssueListDto> issues, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  });
  Future<List<IssueListDto>?> getIssueSearchResults(
    String query, {
    required int page,
    required int limit,
  });
  Future<DateTime?> getIssueSearchResultsCachedAt(
    String query, {
    required int page,
    required int limit,
  });
  Future<PageCacheMeta?> getIssueSearchResultsMeta(
    String query, {
    required int page,
    required int limit,
  });

  Future<void> cacheSeriesSearchResults(
    String query,
    List<SeriesListDto> series, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  });
  Future<List<SeriesListDto>?> getSeriesSearchResults(
    String query, {
    required int page,
    required int limit,
  });
  Future<DateTime?> getSeriesSearchResultsCachedAt(
    String query, {
    required int page,
    required int limit,
  });
  Future<PageCacheMeta?> getSeriesSearchResultsMeta(
    String query, {
    required int page,
    required int limit,
  });

  Future<void> cacheCharacterSearchResults(
    String query,
    List<CharacterListDto> characters, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  });
  Future<List<CharacterListDto>?> getCharacterSearchResults(
    String query, {
    required int page,
    required int limit,
  });
  Future<DateTime?> getCharacterSearchResultsCachedAt(
    String query, {
    required int page,
    required int limit,
  });
  Future<PageCacheMeta?> getCharacterSearchResultsMeta(
    String query, {
    required int page,
    required int limit,
  });

  Future<void> cacheCreatorSearchResults(
    String query,
    List<CreatorListDto> creators, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  });
  Future<List<CreatorListDto>?> getCreatorSearchResults(
    String query, {
    required int page,
    required int limit,
  });
  Future<DateTime?> getCreatorSearchResultsCachedAt(
    String query, {
    required int page,
    required int limit,
  });
  Future<PageCacheMeta?> getCreatorSearchResultsMeta(
    String query, {
    required int page,
    required int limit,
  });

  Future<void> cacheUniverseSearchResults(
    String query,
    List<UniverseListDto> universes, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  });
  Future<List<UniverseListDto>?> getUniverseSearchResults(
    String query, {
    required int page,
    required int limit,
  });
  Future<DateTime?> getUniverseSearchResultsCachedAt(
    String query, {
    required int page,
    required int limit,
  });
  Future<PageCacheMeta?> getUniverseSearchResultsMeta(
    String query, {
    required int page,
    required int limit,
  });

  Future<void> cacheImprintSearchResults(
    String query,
    List<ImprintListDto> imprints, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  });
  Future<List<ImprintListDto>?> getImprintSearchResults(
    String query, {
    required int page,
    required int limit,
  });
  Future<DateTime?> getImprintSearchResultsCachedAt(
    String query, {
    required int page,
    required int limit,
  });
  Future<PageCacheMeta?> getImprintSearchResultsMeta(
    String query, {
    required int page,
    required int limit,
  });

  Future<void> cacheTeamSearchResults(
    String query,
    List<TeamListDto> teams, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  });
  Future<List<TeamListDto>?> getTeamSearchResults(
    String query, {
    required int page,
    required int limit,
  });
  Future<DateTime?> getTeamSearchResultsCachedAt(
    String query, {
    required int page,
    required int limit,
  });
  Future<PageCacheMeta?> getTeamSearchResultsMeta(
    String query, {
    required int page,
    required int limit,
  });

  Future<void> cacheArcSearchResults(
    String query,
    List<ArcListDto> arcs, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  });
  Future<List<ArcListDto>?> getArcSearchResults(
    String query, {
    required int page,
    required int limit,
  });
  Future<DateTime?> getArcSearchResultsCachedAt(
    String query, {
    required int page,
    required int limit,
  });
  Future<PageCacheMeta?> getArcSearchResultsMeta(
    String query, {
    required int page,
    required int limit,
  });

  Future<void> cachePublisherSearchResults(
    String query,
    List<PublisherListDto> publishers, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  });
  Future<List<PublisherListDto>?> getPublisherSearchResults(
    String query, {
    required int page,
    required int limit,
  });
  Future<DateTime?> getPublisherSearchResultsCachedAt(
    String query, {
    required int page,
    required int limit,
  });
  Future<PageCacheMeta?> getPublisherSearchResultsMeta(
    String query, {
    required int page,
    required int limit,
  });
}

class MetronSearchLocalDataSourceImpl implements MetronSearchLocalDataSource {
  MetronSearchLocalDataSourceImpl(AppDatabase db)
      : _issueSearch = PagedLocalCache<IssueListDto>(
          db: db,
          cacheKeyPrefix: "issue_search",
          entityType: "issue_search",
          fromJson: IssueListDto.fromJson,
          toJson: (i) => i.toJson(),
        ),
        _seriesSearch = PagedLocalCache<SeriesListDto>(
          db: db,
          cacheKeyPrefix: "series_search",
          entityType: "series_search",
          fromJson: SeriesListDto.fromJson,
          toJson: (s) => s.toJson(),
        ),
        _characterSearch = PagedLocalCache<CharacterListDto>(
          db: db,
          cacheKeyPrefix: "character_search",
          entityType: "character_search",
          fromJson: CharacterListDto.fromJson,
          toJson: (c) => c.toJson(),
        ),
        _creatorSearch = PagedLocalCache<CreatorListDto>(
          db: db,
          cacheKeyPrefix: "creator_search",
          entityType: "creator_search",
          fromJson: CreatorListDto.fromJson,
          toJson: (c) => c.toJson(),
        ),
        _universeSearch = PagedLocalCache<UniverseListDto>(
          db: db,
          cacheKeyPrefix: "universe_search",
          entityType: "universe_search",
          fromJson: UniverseListDto.fromJson,
          toJson: (u) => u.toJson(),
        ),
        _imprintSearch = PagedLocalCache<ImprintListDto>(
          db: db,
          cacheKeyPrefix: "imprint_search",
          entityType: "imprint_search",
          fromJson: ImprintListDto.fromJson,
          toJson: (i) => i.toJson(),
        ),
        _teamSearch = PagedLocalCache<TeamListDto>(
          db: db,
          cacheKeyPrefix: "team_search",
          entityType: "team_search",
          fromJson: TeamListDto.fromJson,
          toJson: (t) => t.toJson(),
        ),
        _arcSearch = PagedLocalCache<ArcListDto>(
          db: db,
          cacheKeyPrefix: "arc_search",
          entityType: "arc_search",
          fromJson: ArcListDto.fromJson,
          toJson: (a) => a.toJson(),
        ),
        _publisherSearch = PagedLocalCache<PublisherListDto>(
          db: db,
          cacheKeyPrefix: "publisher_search",
          entityType: "publisher_search",
          fromJson: PublisherListDto.fromJson,
          toJson: (p) => p.toJson(),
        );

  final PagedLocalCache<IssueListDto> _issueSearch;
  final PagedLocalCache<SeriesListDto> _seriesSearch;
  final PagedLocalCache<CharacterListDto> _characterSearch;
  final PagedLocalCache<CreatorListDto> _creatorSearch;
  final PagedLocalCache<UniverseListDto> _universeSearch;
  final PagedLocalCache<ImprintListDto> _imprintSearch;
  final PagedLocalCache<TeamListDto> _teamSearch;
  final PagedLocalCache<ArcListDto> _arcSearch;
  final PagedLocalCache<PublisherListDto> _publisherSearch;

  @override
  Future<void> cacheIssueSearchResults(
    String query,
    List<IssueListDto> issues, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  }) async {
    final key = MetronPageCacheKeys.issueSearch(query, page, limit);
    await _issueSearch.cache(
      key,
      issues,
      count: count,
      next: next,
      previous: previous,
    );
  }

  @override
  Future<List<IssueListDto>?> getIssueSearchResults(
    String query, {
    required int page,
    required int limit,
  }) async {
    final key = MetronPageCacheKeys.issueSearch(query, page, limit);
    return _issueSearch.get(key);
  }

  @override
  Future<DateTime?> getIssueSearchResultsCachedAt(
    String query, {
    required int page,
    required int limit,
  }) async {
    final key = MetronPageCacheKeys.issueSearch(query, page, limit);
    return _issueSearch.cachedAt(key);
  }

  @override
  Future<PageCacheMeta?> getIssueSearchResultsMeta(
    String query, {
    required int page,
    required int limit,
  }) async {
    final key = MetronPageCacheKeys.issueSearch(query, page, limit);
    return _issueSearch.meta(key);
  }

  @override
  Future<void> cacheSeriesSearchResults(
    String query,
    List<SeriesListDto> series, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  }) async {
    final key = MetronPageCacheKeys.seriesSearch(query, page, limit);
    await _seriesSearch.cache(
      key,
      series,
      count: count,
      next: next,
      previous: previous,
    );
  }

  @override
  Future<List<SeriesListDto>?> getSeriesSearchResults(
    String query, {
    required int page,
    required int limit,
  }) async {
    final key = MetronPageCacheKeys.seriesSearch(query, page, limit);
    return _seriesSearch.get(key);
  }

  @override
  Future<DateTime?> getSeriesSearchResultsCachedAt(
    String query, {
    required int page,
    required int limit,
  }) async {
    final key = MetronPageCacheKeys.seriesSearch(query, page, limit);
    return _seriesSearch.cachedAt(key);
  }

  @override
  Future<PageCacheMeta?> getSeriesSearchResultsMeta(
    String query, {
    required int page,
    required int limit,
  }) async {
    final key = MetronPageCacheKeys.seriesSearch(query, page, limit);
    return _seriesSearch.meta(key);
  }

  @override
  Future<void> cacheCharacterSearchResults(
    String query,
    List<CharacterListDto> characters, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  }) async {
    final key = MetronPageCacheKeys.characterSearch(query, page, limit);
    await _characterSearch.cache(
      key,
      characters,
      count: count,
      next: next,
      previous: previous,
    );
  }

  @override
  Future<List<CharacterListDto>?> getCharacterSearchResults(
    String query, {
    required int page,
    required int limit,
  }) async {
    final key = MetronPageCacheKeys.characterSearch(query, page, limit);
    return _characterSearch.get(key);
  }

  @override
  Future<DateTime?> getCharacterSearchResultsCachedAt(
    String query, {
    required int page,
    required int limit,
  }) async {
    final key = MetronPageCacheKeys.characterSearch(query, page, limit);
    return _characterSearch.cachedAt(key);
  }

  @override
  Future<PageCacheMeta?> getCharacterSearchResultsMeta(
    String query, {
    required int page,
    required int limit,
  }) async {
    final key = MetronPageCacheKeys.characterSearch(query, page, limit);
    return _characterSearch.meta(key);
  }

  @override
  Future<void> cacheCreatorSearchResults(
    String query,
    List<CreatorListDto> creators, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  }) async {
    final key = MetronPageCacheKeys.creatorSearch(query, page, limit);
    await _creatorSearch.cache(
      key,
      creators,
      count: count,
      next: next,
      previous: previous,
    );
  }

  @override
  Future<List<CreatorListDto>?> getCreatorSearchResults(
    String query, {
    required int page,
    required int limit,
  }) async {
    final key = MetronPageCacheKeys.creatorSearch(query, page, limit);
    return _creatorSearch.get(key);
  }

  @override
  Future<DateTime?> getCreatorSearchResultsCachedAt(
    String query, {
    required int page,
    required int limit,
  }) async {
    final key = MetronPageCacheKeys.creatorSearch(query, page, limit);
    return _creatorSearch.cachedAt(key);
  }

  @override
  Future<PageCacheMeta?> getCreatorSearchResultsMeta(
    String query, {
    required int page,
    required int limit,
  }) async {
    final key = MetronPageCacheKeys.creatorSearch(query, page, limit);
    return _creatorSearch.meta(key);
  }

  @override
  Future<void> cacheUniverseSearchResults(
    String query,
    List<UniverseListDto> universes, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  }) async {
    final key = MetronPageCacheKeys.universeSearch(query, page, limit);
    await _universeSearch.cache(
      key,
      universes,
      count: count,
      next: next,
      previous: previous,
    );
  }

  @override
  Future<List<UniverseListDto>?> getUniverseSearchResults(
    String query, {
    required int page,
    required int limit,
  }) async {
    final key = MetronPageCacheKeys.universeSearch(query, page, limit);
    return _universeSearch.get(key);
  }

  @override
  Future<DateTime?> getUniverseSearchResultsCachedAt(
    String query, {
    required int page,
    required int limit,
  }) async {
    final key = MetronPageCacheKeys.universeSearch(query, page, limit);
    return _universeSearch.cachedAt(key);
  }

  @override
  Future<PageCacheMeta?> getUniverseSearchResultsMeta(
    String query, {
    required int page,
    required int limit,
  }) async {
    final key = MetronPageCacheKeys.universeSearch(query, page, limit);
    return _universeSearch.meta(key);
  }

  @override
  Future<void> cacheImprintSearchResults(
    String query,
    List<ImprintListDto> imprints, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  }) async {
    final key = MetronPageCacheKeys.imprintSearch(query, page, limit);
    await _imprintSearch.cache(
      key,
      imprints,
      count: count,
      next: next,
      previous: previous,
    );
  }

  @override
  Future<List<ImprintListDto>?> getImprintSearchResults(
    String query, {
    required int page,
    required int limit,
  }) async {
    final key = MetronPageCacheKeys.imprintSearch(query, page, limit);
    return _imprintSearch.get(key);
  }

  @override
  Future<DateTime?> getImprintSearchResultsCachedAt(
    String query, {
    required int page,
    required int limit,
  }) async {
    final key = MetronPageCacheKeys.imprintSearch(query, page, limit);
    return _imprintSearch.cachedAt(key);
  }

  @override
  Future<PageCacheMeta?> getImprintSearchResultsMeta(
    String query, {
    required int page,
    required int limit,
  }) async {
    final key = MetronPageCacheKeys.imprintSearch(query, page, limit);
    return _imprintSearch.meta(key);
  }

  @override
  Future<void> cacheTeamSearchResults(
    String query,
    List<TeamListDto> teams, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  }) async {
    final key = MetronPageCacheKeys.teamSearch(query, page, limit);
    await _teamSearch.cache(
      key,
      teams,
      count: count,
      next: next,
      previous: previous,
    );
  }

  @override
  Future<List<TeamListDto>?> getTeamSearchResults(
    String query, {
    required int page,
    required int limit,
  }) async {
    final key = MetronPageCacheKeys.teamSearch(query, page, limit);
    return _teamSearch.get(key);
  }

  @override
  Future<DateTime?> getTeamSearchResultsCachedAt(
    String query, {
    required int page,
    required int limit,
  }) async {
    final key = MetronPageCacheKeys.teamSearch(query, page, limit);
    return _teamSearch.cachedAt(key);
  }

  @override
  Future<PageCacheMeta?> getTeamSearchResultsMeta(
    String query, {
    required int page,
    required int limit,
  }) async {
    final key = MetronPageCacheKeys.teamSearch(query, page, limit);
    return _teamSearch.meta(key);
  }

  @override
  Future<void> cacheArcSearchResults(
    String query,
    List<ArcListDto> arcs, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  }) async {
    final key = MetronPageCacheKeys.arcSearch(query, page, limit);
    await _arcSearch.cache(
      key,
      arcs,
      count: count,
      next: next,
      previous: previous,
    );
  }

  @override
  Future<List<ArcListDto>?> getArcSearchResults(
    String query, {
    required int page,
    required int limit,
  }) async {
    final key = MetronPageCacheKeys.arcSearch(query, page, limit);
    return _arcSearch.get(key);
  }

  @override
  Future<DateTime?> getArcSearchResultsCachedAt(
    String query, {
    required int page,
    required int limit,
  }) async {
    final key = MetronPageCacheKeys.arcSearch(query, page, limit);
    return _arcSearch.cachedAt(key);
  }

  @override
  Future<PageCacheMeta?> getArcSearchResultsMeta(
    String query, {
    required int page,
    required int limit,
  }) async {
    final key = MetronPageCacheKeys.arcSearch(query, page, limit);
    return _arcSearch.meta(key);
  }

  @override
  Future<void> cachePublisherSearchResults(
    String query,
    List<PublisherListDto> publishers, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  }) async {
    final key = MetronPageCacheKeys.publisherSearch(query, page, limit);
    await _publisherSearch.cache(
      key,
      publishers,
      count: count,
      next: next,
      previous: previous,
    );
  }

  @override
  Future<List<PublisherListDto>?> getPublisherSearchResults(
    String query, {
    required int page,
    required int limit,
  }) async {
    final key = MetronPageCacheKeys.publisherSearch(query, page, limit);
    return _publisherSearch.get(key);
  }

  @override
  Future<DateTime?> getPublisherSearchResultsCachedAt(
    String query, {
    required int page,
    required int limit,
  }) async {
    final key = MetronPageCacheKeys.publisherSearch(query, page, limit);
    return _publisherSearch.cachedAt(key);
  }

  @override
  Future<PageCacheMeta?> getPublisherSearchResultsMeta(
    String query, {
    required int page,
    required int limit,
  }) async {
    final key = MetronPageCacheKeys.publisherSearch(query, page, limit);
    return _publisherSearch.meta(key);
  }
}
