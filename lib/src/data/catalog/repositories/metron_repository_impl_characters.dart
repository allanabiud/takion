part of 'metron_repository_impl.dart';

mixin _CharactersRepositoryMixin on _RepositoryState {
  Future<CharacterListPage> getCharacterList({
    String? nextUrl,
    int page = 1,
    int limit = metronDefaultPageSize,
    DateTime? modifiedGt,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  }) async {
    final cachedDtos = await _localDataSource.getCharacterListResults(
      page: page,
      limit: limit,
      modifiedGt: modifiedGt,
    );
    final cachedAt = await _localDataSource.getCharacterListResultsCachedAt(
      page: page,
      limit: limit,
      modifiedGt: modifiedGt,
    );
    final cachedMeta = await _localDataSource.getCharacterListResultsMeta(
      page: page,
      limit: limit,
      modifiedGt: modifiedGt,
    );

    if (!forceRefresh && cachedDtos != null && cachedDtos.isNotEmpty) {
      final isFresh =
          cachedAt != null &&
          MetronCachePolicies.characterList.isFresh(cachedAt, _now());
      if (!isFresh) {
        _refreshInBackground(
          task: () async {
            final remotePage = nextUrl != null
                ? await _remoteDataSource.getCharacterList(
                    nextUrl: Uri.parse(nextUrl),
                    limit: limit,
                    modifiedGt: modifiedGt,
                    cancelToken: cancelToken,
                  )
                : await _remoteDataSource.getCharacterList(
                    page: page,
                    limit: limit,
                    modifiedGt: modifiedGt,
                    cancelToken: cancelToken,
                  );
            await _localDataSource.cacheCharacterListResults(
              remotePage.results,
              page: page,
              limit: limit,
              modifiedGt: modifiedGt,
              count: remotePage.count,
              next: remotePage.next,
              previous: remotePage.previous,
            );
          },
          cacheKey: 'character_list:${nextUrl ?? "$page"}|$modifiedGt',
          cooldown: MetronCachePolicies.characterList.refreshCooldown,
        );
      }
      if (cachedMeta != null) {
        return CharacterListPage(
          count: cachedMeta.count,
          next: cachedMeta.next,
          previous: cachedMeta.previous,
          results: cachedDtos.map((entry) => entry.toEntity()).toList(),
          currentPage: page,
        );
      }
    }

    try {
      final key = '${nextUrl ?? "$page"}|$modifiedGt|$forceRefresh';
      return _coalesce(_characterListInFlight, key, () async {
        final remotePage = nextUrl != null
            ? await _remoteDataSource.getCharacterList(
                nextUrl: Uri.parse(nextUrl),
                limit: limit,
                modifiedGt: modifiedGt,
                cancelToken: cancelToken,
              )
            : await _remoteDataSource.getCharacterList(
                page: page,
                limit: limit,
                modifiedGt: modifiedGt,
                cancelToken: cancelToken,
              );
        await _localDataSource.cacheCharacterListResults(
          remotePage.results,
          page: page,
          limit: limit,
          modifiedGt: modifiedGt,
          count: remotePage.count,
          next: remotePage.next,
          previous: remotePage.previous,
        );
        return CharacterListPage(
          count: remotePage.count,
          next: remotePage.next,
          previous: remotePage.previous,
          results: remotePage.results.map((entry) => entry.toEntity()).toList(),
          currentPage: page,
        );
      }, timeout: const Duration(seconds: 30));
    } catch (error) {
      if (_isCancelled(error)) rethrow;
      if (cachedDtos != null && cachedDtos.isNotEmpty && cachedMeta != null) {
        return CharacterListPage(
          count: cachedMeta.count,
          next: cachedMeta.next,
          previous: cachedMeta.previous,
          results: cachedDtos.map((entry) => entry.toEntity()).toList(),
          currentPage: page,
        );
      }
      rethrow;
    }
  }

  Future<int> refreshCharacterListDelta({DateTime? modifiedGt}) async {
    var page = 1;
    var synced = 0;
    while (true) {
      final result = await getCharacterList(
        page: page,
        limit: metronDefaultPageSize,
        modifiedGt: modifiedGt,
        forceRefresh: true,
      );
      for (final item in result.results) {
        await getCharacterDetails(item.id, forceRefresh: true);
        synced++;
      }
      if (!result.hasNext) break;
      page++;
    }
    return synced;
  }

  Future<CharacterListPage> searchCharacters(
    String query, {
    String? nextUrl,
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  }) async {
    final cachedDtos = await _localDataSource.getCharacterSearchResults(
      query,
      page: page,
      limit: limit,
    );
    final cachedAt = await _localDataSource.getCharacterSearchResultsCachedAt(
      query,
      page: page,
      limit: limit,
    );
    final cachedMeta = await _localDataSource.getCharacterSearchResultsMeta(
      query,
      page: page,
      limit: limit,
    );

    if (!forceRefresh && cachedDtos != null && cachedDtos.isNotEmpty) {
      final isFresh =
          cachedAt != null &&
          MetronCachePolicies.searchResults.isFresh(cachedAt, _now());
      if (!isFresh) {
        _refreshInBackground(
          task: () async {
            final remotePage = nextUrl != null
                ? await _remoteDataSource.searchCharacters(
                    query,
                    nextUrl: Uri.parse(nextUrl),
                    limit: limit,
                    cancelToken: cancelToken,
                  )
                : await _remoteDataSource.searchCharacters(
                    query,
                    page: page,
                    limit: limit,
                    cancelToken: cancelToken,
                  );
            await _localDataSource.cacheCharacterSearchResults(
              query,
              remotePage.results,
              page: page,
              limit: limit,
              count: remotePage.count,
              next: remotePage.next,
              previous: remotePage.previous,
            );
          },
          cacheKey: nextUrl ?? 'search:character:$query:$page',
          cooldown: MetronCachePolicies.searchResults.refreshCooldown,
        );
      }
      if (cachedMeta != null) {
        return CharacterListPage(
          count: cachedMeta.count,
          next: cachedMeta.next,
          previous: cachedMeta.previous,
          results: cachedDtos.map((entry) => entry.toEntity()).toList(),
          currentPage: page,
        );
      }
    }

    try {
      final remotePage = nextUrl != null
          ? await _remoteDataSource.searchCharacters(
              query,
              nextUrl: Uri.parse(nextUrl),
              limit: limit,
              cancelToken: cancelToken,
            )
          : await _remoteDataSource.searchCharacters(
              query,
              page: page,
              limit: limit,
              cancelToken: cancelToken,
            );
      await _localDataSource.cacheCharacterSearchResults(
        query,
        remotePage.results,
        page: page,
        limit: limit,
        count: remotePage.count,
        next: remotePage.next,
        previous: remotePage.previous,
      );
      return CharacterListPage(
        count: remotePage.count,
        next: remotePage.next,
        previous: remotePage.previous,
        results: remotePage.results.map((entry) => entry.toEntity()).toList(),
        currentPage: page,
      );
    } catch (error) {
      if (_isCancelled(error)) rethrow;
      if (cachedDtos != null && cachedDtos.isNotEmpty && cachedMeta != null) {
        return CharacterListPage(
          count: cachedMeta.count,
          next: cachedMeta.next,
          previous: cachedMeta.previous,
          results: cachedDtos.map((entry) => entry.toEntity()).toList(),
          currentPage: page,
        );
      }
      rethrow;
    }
  }

  Future<CharacterDetails> getCharacterDetails(
    int characterId, {
    bool forceRefresh = false,
  }) async {
    final cached = await _metronEntityDao.getCharacter(characterId);

    if (!forceRefresh && cached != null && cached.isFullyHydrated) {
      AppPerformanceMetrics.instance.recordCacheHit('character_details');
      return _characterRowToEntity(characterId);
    }

    AppPerformanceMetrics.instance.recordCacheMiss('character_details');

    try {
      final response = await _remoteDataSource.getCharacterDetails(
        characterId,
      );
      if (response.statusCode == 304) {
        return _characterRowToEntity(characterId);
      }
      final dto = CharacterDetailsDto.fromJson(
        response.data as Map<String, dynamic>,
      );
      if (cached != null &&
          cached.modified != null &&
          dto.modified != null &&
          cached.modified == dto.modified) {
        return _characterRowToEntity(characterId);
      }
      await _upsertCharacterDetails(dto);
      return _characterRowToEntity(characterId);
    } catch (e) {
      AppLogger.error('Failed to fetch character details', error: e);
      if (cached != null) {
        return _characterRowToEntity(characterId);
      }
      rethrow;
    }
  }

  Future<CharacterIssueListPage> getCharacterIssueList(
    int characterId, {
    String? nextUrl,
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  }) async {
    final cachedDtos = await _localDataSource.getCharacterIssueListResults(
      characterId,
      page: page,
      limit: limit,
    );
    final cachedAt = await _localDataSource
        .getCharacterIssueListResultsCachedAt(
          characterId,
          page: page,
          limit: limit,
        );
    final cachedMeta = await _localDataSource.getCharacterIssueListResultsMeta(
      characterId,
      page: page,
      limit: limit,
    );

    if (!forceRefresh && cachedDtos != null && cachedDtos.isNotEmpty) {
      final isFresh =
          cachedAt != null &&
          MetronCachePolicies.characterIssueList.isFresh(cachedAt, _now());
      if (!isFresh) {
        _refreshInBackground(
          task: () async {
            final remotePage = nextUrl != null
                ? await _remoteDataSource.getCharacterIssueList(
                    characterId,
                    nextUrl: Uri.parse(nextUrl),
                    limit: limit,
                    cancelToken: cancelToken,
                  )
                : await _remoteDataSource.getCharacterIssueList(
                    characterId,
                    page: page,
                    limit: limit,
                    cancelToken: cancelToken,
                  );
            await _localDataSource.cacheCharacterIssueListResults(
              characterId,
              remotePage.results,
              page: page,
              limit: limit,
              count: remotePage.count,
              next: remotePage.next,
              previous: remotePage.previous,
            );
            _indexSeriesNamesFromIssueList(remotePage.results);
          },
          cacheKey: nextUrl ?? 'character_issue_list:$characterId:$page',
          cooldown: MetronCachePolicies.characterIssueList.refreshCooldown,
        );
      }
      if (cachedMeta != null) {
        return CharacterIssueListPage(
          count: cachedMeta.count,
          next: cachedMeta.next,
          previous: cachedMeta.previous,
          results: cachedDtos.map((entry) => entry.toEntity()).toList(),
          currentPage: page,
        );
      }
    }

    try {
      final key = nextUrl ?? '$characterId|$page|$forceRefresh';
      return _coalesce(_characterIssueListInFlight, key, () async {
        final remotePage = nextUrl != null
            ? await _remoteDataSource.getCharacterIssueList(
                characterId,
                nextUrl: Uri.parse(nextUrl),
                limit: limit,
                cancelToken: cancelToken,
              )
            : await _remoteDataSource.getCharacterIssueList(
                characterId,
                page: page,
                limit: limit,
                cancelToken: cancelToken,
              );
        await _localDataSource.cacheCharacterIssueListResults(
          characterId,
          remotePage.results,
          page: page,
          limit: limit,
          count: remotePage.count,
          next: remotePage.next,
          previous: remotePage.previous,
        );
        _indexSeriesNamesFromIssueList(remotePage.results);
        return CharacterIssueListPage(
          count: remotePage.count,
          next: remotePage.next,
          previous: remotePage.previous,
          results: remotePage.results.map((entry) => entry.toEntity()).toList(),
          currentPage: page,
        );
      }, timeout: const Duration(seconds: 30));
    } catch (error) {
      if (_isCancelled(error)) rethrow;
      if (cachedDtos != null && cachedDtos.isNotEmpty && cachedMeta != null) {
        return CharacterIssueListPage(
          count: cachedMeta.count,
          next: cachedMeta.next,
          previous: cachedMeta.previous,
          results: cachedDtos.map((entry) => entry.toEntity()).toList(),
          currentPage: page,
        );
      }
      rethrow;
    }
  }

  Future<void> _upsertCharacterDetails(CharacterDetailsDto dto) async {
    await _metronEntityDao.upsertCharacter(
      MetronCharactersCompanion(
        id: Value(dto.id),
        name: Value(dto.name),
        imageUrl: Value(dto.image),
        description: Value(dto.desc),
        cvId: Value(dto.cvId),
        gcdId: Value(dto.gcdId),
        resourceUrl: Value(dto.resourceUrl),
        modified: Value(dto.modified),
        isFullyHydrated: const Value(true),
      ),
    );

    await _junctionDao.clearCharacterJunctions(dto.id);

    for (final creator in dto.creators) {
      await _metronEntityDao.upsertCreator(
        MetronCreatorsCompanion(
          id: Value(creator.id),
          name: Value(creator.name),
          isFullyHydrated: const Value(false),
        ),
      );
    }
    if (dto.creators.isNotEmpty) {
      await _junctionDao.batchInsertCharacterCreators(
        dto.creators
            .map(
              (c) => CharacterCreatorsCompanion(
                characterId: Value(dto.id),
                creatorId: Value(c.id),
              ),
            )
            .toList(),
      );
    }

    for (final team in dto.teams) {
      await _metronEntityDao.upsertTeam(
        MetronTeamsCompanion(
          id: Value(team.id),
          name: Value(team.name),
          isFullyHydrated: const Value(false),
        ),
      );
    }
    if (dto.teams.isNotEmpty) {
      await _junctionDao.batchInsertCharacterTeams(
        dto.teams
            .map(
              (t) => CharacterTeamsCompanion(
                characterId: Value(dto.id),
                teamId: Value(t.id),
              ),
            )
            .toList(),
      );
    }

    for (final universe in dto.universes) {
      await _metronEntityDao.upsertUniverse(
        MetronUniversesCompanion(
          id: Value(universe.id),
          name: Value(universe.name),
          isFullyHydrated: const Value(false),
        ),
      );
    }
    if (dto.universes.isNotEmpty) {
      await _junctionDao.batchInsertCharacterUniverses(
        dto.universes
            .map(
              (u) => CharacterUniversesCompanion(
                characterId: Value(dto.id),
                universeId: Value(u.id),
              ),
            )
            .toList(),
      );
    }
  }

  Future<CharacterDetails> _characterRowToEntity(int characterId) async {
    final row = await _metronEntityDao.getCharacter(characterId);
    if (row == null) {
      throw StateError('Character not found in cache: $characterId');
    }

    final creatorJunctions = await _junctionDao.getCharacterCreators(
      characterId,
    );
    final creators = <CharacterDetailsNamedRef>[];
    for (final j in creatorJunctions) {
      final c = await _metronEntityDao.getCreator(j.creatorId);
      creators.add(
        CharacterDetailsNamedRef(id: j.creatorId, name: c?.name ?? ''),
      );
    }

    final teamJunctions = await _junctionDao.getCharacterTeams(characterId);
    final teams = <CharacterDetailsNamedRef>[];
    for (final j in teamJunctions) {
      final t = await _metronEntityDao.getTeam(j.teamId);
      teams.add(CharacterDetailsNamedRef(id: j.teamId, name: t?.name ?? ''));
    }

    final universeJunctions = await _junctionDao.getCharacterUniverses(
      characterId,
    );
    final universes = <CharacterDetailsNamedRef>[];
    for (final j in universeJunctions) {
      final u = await _metronEntityDao.getUniverse(j.universeId);
      universes.add(
        CharacterDetailsNamedRef(id: j.universeId, name: u?.name ?? ''),
      );
    }

    return CharacterDetails(
      id: row.id,
      name: row.name,
      slug: '',
      alias: row.aliasJson,
      desc: row.description,
      image: row.imageUrl,
      creators: creators,
      teams: teams,
      universes: universes,
      cvId: row.cvId,
      gcdId: row.gcdId,
      resourceUrl: row.resourceUrl,
      modified: row.modified != null ? DateTime.tryParse(row.modified!) : null,
    );
  }
}
