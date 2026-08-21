part of "metron_repository_impl.dart";

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
                    modifiedGt: modifiedGt,
                    cancelToken: cancelToken,
                  )
                : await _remoteDataSource.getCharacterList(
                    page: page,
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
                modifiedGt: modifiedGt,
                cancelToken: cancelToken,
              )
            : await _remoteDataSource.getCharacterList(
                page: page,
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
                    cancelToken: cancelToken,
                  )
                : await _remoteDataSource.searchCharacters(
                    query,
                    page: page,
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
          cacheKey: nextUrl ?? "search:character:$query:$page",
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
      final key = nextUrl ?? "$query|$page|$limit|$forceRefresh";
      return _coalesce(_characterSearchInFlight, key, () async {
        final remotePage = nextUrl != null
            ? await _remoteDataSource.searchCharacters(
                query,
                nextUrl: Uri.parse(nextUrl),
                cancelToken: cancelToken,
              )
            : await _remoteDataSource.searchCharacters(
                query,
                page: page,
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

  Future<CharacterDetails> getCharacterDetails(
    int characterId, {
    bool forceRefresh = false,
  }) async {
    final cached = await _metronEntityDao.getCharacter(characterId);

    if (!forceRefresh && cached != null && cached.isFullyHydrated) {
      AppPerformanceMetrics.instance.recordCacheHit("character_details");
      return _characterRowToEntity(characterId);
    }

    final cachedJson = await _localDataSource.getCachedCharacterDetailsResponse(
      characterId,
    );
    if (cachedJson != null && !forceRefresh) {
      final cachedAt = await _localDataSource.getCachedCharacterDetailsCachedAt(
        characterId,
      );
      final now = _now();
      if (cachedAt != null &&
          MetronCachePolicies.characterDetails.isFresh(cachedAt, now)) {
        AppPerformanceMetrics.instance.recordCacheHit(
          "character_details_response",
        );
        final dto = CharacterDetailsDto.fromJson(cachedJson);
        await _upsertCharacterDetails(dto);
        return dto.toEntity();
      }
    }

    AppPerformanceMetrics.instance.recordCacheMiss("character_details");

    try {
      final response = await _remoteDataSource.getCharacterDetails(characterId);
      if (response.statusCode == 304) {
        final cachedJson = await _localDataSource
            .getCachedCharacterDetailsResponse(characterId);
        if (cachedJson != null) {
          await _localDataSource.cacheCharacterDetailsResponse(
            characterId,
            cachedJson,
          );
          final dto = CharacterDetailsDto.fromJson(cachedJson);
          await _upsertCharacterDetails(dto);
          return dto.toEntity();
        }
        if (cached != null) {
          return await _characterRowToEntity(characterId);
        }
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: "304 Not Modified and no cached data available",
        );
      }
      final data = response.data as Map<String, dynamic>;
      final dto = CharacterDetailsDto.fromJson(data);
      if (!forceRefresh &&
          cached != null &&
          cached.isFullyHydrated &&
          cached.modified != null &&
          dto.modified != null &&
          cached.modified == dto.modified) {
        return await _characterRowToEntity(characterId);
      }
      await _upsertCharacterDetails(dto);
      await _localDataSource.cacheCharacterDetailsResponse(characterId, data);
      return dto.toEntity();
    } catch (e) {
      AppLogger.error("Failed to fetch character details", error: e);
      final cachedJson = await _localDataSource
          .getCachedCharacterDetailsResponse(characterId);
      if (cachedJson != null) {
        final dto = CharacterDetailsDto.fromJson(cachedJson);
        if (!forceRefresh &&
            cached != null &&
            cached.modified != null &&
            dto.modified != null &&
            cached.modified == dto.modified) {
          return await _characterRowToEntity(characterId);
        }
        await _upsertCharacterDetails(dto);
        return dto.toEntity();
      }
      if (cached != null) {
        return await _characterRowToEntity(characterId);
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
                    cancelToken: cancelToken,
                  )
                : await _remoteDataSource.getCharacterIssueList(
                    characterId,
                    page: page,
                    cancelToken: cancelToken,
                  );
            if (_isValidIssueListPage(
              count: remotePage.count,
              resultCount: remotePage.results.length,
            )) {
              await _localDataSource.cacheCharacterIssueListResults(
                characterId,
                remotePage.results,
                page: page,
                limit: limit,
                count: remotePage.count,
                next: remotePage.next,
                previous: remotePage.previous,
              );
            }
            _indexSeriesNamesFromIssueList(remotePage.results);
          },
          cacheKey: nextUrl ?? "character_issue_list:$characterId:$page",
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
          realPageSize: _issuePageSize(
            resultCount: cachedDtos.length,
            hasNext: cachedMeta.next != null,
          ),
        );
      }
    }

    try {
      final key = nextUrl ?? "$characterId|$page|$forceRefresh|$limit";
      return _coalesce(_characterIssueListInFlight, key, () async {
        final remotePage = nextUrl != null
            ? await _remoteDataSource.getCharacterIssueList(
                characterId,
                nextUrl: Uri.parse(nextUrl),
                cancelToken: cancelToken,
              )
            : await _remoteDataSource.getCharacterIssueList(
                characterId,
                page: page,
                cancelToken: cancelToken,
              );
        if (_isValidIssueListPage(
          count: remotePage.count,
          resultCount: remotePage.results.length,
        )) {
          await _localDataSource.cacheCharacterIssueListResults(
            characterId,
            remotePage.results,
            page: page,
            limit: limit,
            count: remotePage.count,
            next: remotePage.next,
            previous: remotePage.previous,
          );
        }
        _indexSeriesNamesFromIssueList(remotePage.results);
        return CharacterIssueListPage(
          count: remotePage.count,
          next: remotePage.next,
          previous: remotePage.previous,
          results: remotePage.results.map((entry) => entry.toEntity()).toList(),
          currentPage: page,
          realPageSize: _issuePageSize(
            resultCount: remotePage.results.length,
            hasNext: remotePage.next != null,
          ),
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
          realPageSize: _issuePageSize(
            resultCount: cachedDtos.length,
            hasNext: cachedMeta.next != null,
          ),
        );
      }
      rethrow;
    }
  }

  Future<void> _upsertCharacterDetails(CharacterDetailsDto dto) async {
    if (dto.name.trim().isNotEmpty) {
      _metadataCache?.indexCharacter(dto.id, dto.name.trim());
    }
    for (final c in dto.creators) {
      if (c.id > 0 && c.name.trim().isNotEmpty) {
        _metadataCache?.indexCreator(c.id, c.name.trim());
      }
    }
    await _metronEntityDao.attachedDatabase.transaction(() async {
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

      final validCreators = dto.creators.where((c) => c.id > 0).toList();
      for (final creator in validCreators) {
        await _metronEntityDao.upsertCreator(
          MetronCreatorsCompanion(
            id: Value(creator.id),
            name: Value(creator.name),
            isFullyHydrated: const Value(false),
          ),
        );
      }
      if (validCreators.isNotEmpty) {
        await _junctionDao.batchInsertCharacterCreators(
          validCreators
              .map(
                (c) => CharacterCreatorsCompanion(
                  characterId: Value(dto.id),
                  creatorId: Value(c.id),
                ),
              )
              .toList(),
        );
      }

      final validTeams = dto.teams.where((t) => t.id > 0).toList();
      for (final team in validTeams) {
        await _metronEntityDao.upsertTeam(
          MetronTeamsCompanion(
            id: Value(team.id),
            name: Value(team.name),
            isFullyHydrated: const Value(false),
          ),
        );
      }
      if (validTeams.isNotEmpty) {
        await _junctionDao.batchInsertCharacterTeams(
          validTeams
              .map(
                (t) => CharacterTeamsCompanion(
                  characterId: Value(dto.id),
                  teamId: Value(t.id),
                ),
              )
              .toList(),
        );
      }

      final validUniverses = dto.universes.where((u) => u.id > 0).toList();
      for (final universe in validUniverses) {
        await _metronEntityDao.upsertUniverse(
          MetronUniversesCompanion(
            id: Value(universe.id),
            name: Value(universe.name),
            isFullyHydrated: const Value(false),
          ),
        );
      }
      if (validUniverses.isNotEmpty) {
        await _junctionDao.batchInsertCharacterUniverses(
          validUniverses
              .map(
                (u) => CharacterUniversesCompanion(
                  characterId: Value(dto.id),
                  universeId: Value(u.id),
                ),
              )
              .toList(),
        );
      }
    });
  }

  Future<CharacterDetails> _characterRowToEntity(int characterId) async {
    final row = await _metronEntityDao.getCharacter(characterId);
    if (row == null) {
      throw StateError("Character not found in cache: $characterId");
    }

    final creatorJunctions = await _junctionDao.getCharacterCreators(
      characterId,
    );
    final creators = <CharacterDetailsNamedRef>[];
    for (final j in creatorJunctions) {
      final c = await _metronEntityDao.getCreator(j.creatorId);
      creators.add(
        CharacterDetailsNamedRef(id: j.creatorId, name: c?.name ?? ""),
      );
    }

    final teamJunctions = await _junctionDao.getCharacterTeams(characterId);
    final teams = <CharacterDetailsNamedRef>[];
    for (final j in teamJunctions) {
      final t = await _metronEntityDao.getTeam(j.teamId);
      teams.add(CharacterDetailsNamedRef(id: j.teamId, name: t?.name ?? ""));
    }

    final universeJunctions = await _junctionDao.getCharacterUniverses(
      characterId,
    );
    final universes = <CharacterDetailsNamedRef>[];
    for (final j in universeJunctions) {
      final u = await _metronEntityDao.getUniverse(j.universeId);
      universes.add(
        CharacterDetailsNamedRef(id: j.universeId, name: u?.name ?? ""),
      );
    }

    return CharacterDetails(
      id: row.id,
      name: row.name,
      slug: "",
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
