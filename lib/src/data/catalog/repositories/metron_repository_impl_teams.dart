part of "metron_repository_impl.dart";

mixin _TeamsRepositoryMixin on _RepositoryState {
  Future<TeamListPage> getTeamList({
    String? nextUrl,
    int page = 1,
    int limit = metronDefaultPageSize,
    DateTime? modifiedGt,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  }) async {
    final cachedDtos = await _localDataSource.getTeamListResults(
      page: page,
      limit: limit,
      modifiedGt: modifiedGt,
    );
    final cachedAt = await _localDataSource.getTeamListResultsCachedAt(
      page: page,
      limit: limit,
      modifiedGt: modifiedGt,
    );
    final cachedMeta = await _localDataSource.getTeamListResultsMeta(
      page: page,
      limit: limit,
      modifiedGt: modifiedGt,
    );

    if (!forceRefresh && cachedDtos != null && cachedDtos.isNotEmpty) {
      final isFresh =
          cachedAt != null &&
          MetronCachePolicies.teamList.isFresh(cachedAt, _now());
      if (!isFresh) {
        _refreshInBackground(
          task: () async {
            final remotePage = nextUrl != null
                ? await _remoteDataSource.getTeamList(
                    nextUrl: Uri.parse(nextUrl),
                    modifiedGt: modifiedGt,
                    cancelToken: cancelToken,
                  )
                : await _remoteDataSource.getTeamList(
                    page: page,
                    modifiedGt: modifiedGt,
                    cancelToken: cancelToken,
                  );
            await _localDataSource.cacheTeamListResults(
              remotePage.results,
              page: page,
              limit: limit,
              modifiedGt: modifiedGt,
              count: remotePage.count,
              next: remotePage.next,
              previous: remotePage.previous,
            );
          },
          cacheKey: 'team_list:${nextUrl ?? "$page"}|$modifiedGt',
          cooldown: MetronCachePolicies.teamList.refreshCooldown,
        );
      }
      if (cachedMeta != null) {
        return TeamListPage(
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
      return _coalesce(_teamListInFlight, key, () async {
        final remotePage = nextUrl != null
            ? await _remoteDataSource.getTeamList(
                nextUrl: Uri.parse(nextUrl),
                modifiedGt: modifiedGt,
                cancelToken: cancelToken,
              )
            : await _remoteDataSource.getTeamList(
                page: page,
                modifiedGt: modifiedGt,
                cancelToken: cancelToken,
              );
        await _localDataSource.cacheTeamListResults(
          remotePage.results,
          page: page,
          limit: limit,
          modifiedGt: modifiedGt,
          count: remotePage.count,
          next: remotePage.next,
          previous: remotePage.previous,
        );
        return TeamListPage(
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
        return TeamListPage(
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

  Future<TeamListPage> searchTeams(
    String query, {
    String? nextUrl,
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  }) async {
    final cachedDtos = await _localDataSource.getTeamSearchResults(
      query,
      page: page,
      limit: limit,
    );
    final cachedAt = await _localDataSource.getTeamSearchResultsCachedAt(
      query,
      page: page,
      limit: limit,
    );
    final cachedMeta = await _localDataSource.getTeamSearchResultsMeta(
      query,
      page: page,
      limit: limit,
    );

    if (!forceRefresh && cachedDtos != null && cachedDtos.isNotEmpty) {
      final isFresh =
          cachedAt != null &&
          MetronCachePolicies.teamSearchResults.isFresh(cachedAt, _now());
      if (!isFresh) {
        _refreshInBackground(
          task: () async {
            final remotePage = nextUrl != null
                ? await _remoteDataSource.searchTeams(
                    query,
                    nextUrl: Uri.parse(nextUrl),
                    cancelToken: cancelToken,
                  )
                : await _remoteDataSource.searchTeams(
                    query,
                    page: page,
                    cancelToken: cancelToken,
                  );
            await _localDataSource.cacheTeamSearchResults(
              query,
              remotePage.results,
              page: page,
              limit: limit,
              count: remotePage.count,
              next: remotePage.next,
              previous: remotePage.previous,
            );
          },
          cacheKey: nextUrl ?? "search:team:$query:$page",
          cooldown: MetronCachePolicies.teamSearchResults.refreshCooldown,
        );
      }
      if (cachedMeta != null) {
        return TeamListPage(
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
      return _coalesce(_teamSearchInFlight, key, () async {
        final remotePage = nextUrl != null
            ? await _remoteDataSource.searchTeams(
                query,
                nextUrl: Uri.parse(nextUrl),
                cancelToken: cancelToken,
              )
            : await _remoteDataSource.searchTeams(
                query,
                page: page,
                cancelToken: cancelToken,
              );
        await _localDataSource.cacheTeamSearchResults(
          query,
          remotePage.results,
          page: page,
          limit: limit,
          count: remotePage.count,
          next: remotePage.next,
          previous: remotePage.previous,
        );
        return TeamListPage(
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
        return TeamListPage(
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

  Future<TeamDetails> getTeamDetails(
    int teamId, {
    bool forceRefresh = false,
  }) async {
    final cached = await _metronEntityDao.getTeam(teamId);

    if (!forceRefresh && cached != null && cached.isFullyHydrated) {
      AppPerformanceMetrics.instance.recordCacheHit("team_details");
      return _teamRowToEntity(teamId);
    }

    final cachedJson =
        await _localDataSource.getCachedTeamDetailsResponse(teamId);
    if (cachedJson != null && !forceRefresh) {
      final cachedAt =
          await _localDataSource.getCachedTeamDetailsCachedAt(teamId);
      final now = _now();
      if (cachedAt != null &&
          MetronCachePolicies.teamDetails.isFresh(cachedAt, now)) {
        AppPerformanceMetrics.instance.recordCacheHit(
          "team_details_response",
        );
        final dto = TeamDetailsDto.fromJson(cachedJson);
        await _upsertTeamDetails(dto);
        return dto.toEntity();
      }
    }

    AppPerformanceMetrics.instance.recordCacheMiss("team_details");

    try {
      final response = await _remoteDataSource.getTeamDetails(teamId);
      if (response.statusCode == 304) {
        final cachedJson =
            await _localDataSource.getCachedTeamDetailsResponse(teamId);
        if (cachedJson != null) {
          await _localDataSource.cacheTeamDetailsResponse(teamId, cachedJson);
          final dto = TeamDetailsDto.fromJson(cachedJson);
          await _upsertTeamDetails(dto);
          return dto.toEntity();
        }
        return await _teamRowToEntity(
          cached != null ? teamId : (throw StateError("Team $teamId not found")),
        );
      }
      final data = response.data as Map<String, dynamic>;
      final dto = TeamDetailsDto.fromJson(data);
      if (!forceRefresh &&
          cached != null &&
          cached.isFullyHydrated &&
          cached.modified != null &&
          dto.modified != null &&
          cached.modified == dto.modified) {
        return await _teamRowToEntity(teamId);
      }
      await _upsertTeamDetails(dto);
      await _localDataSource.cacheTeamDetailsResponse(teamId, data);
      return dto.toEntity();
    } catch (e) {
      AppLogger.error("Failed to fetch team details", error: e);
      final cachedJson =
          await _localDataSource.getCachedTeamDetailsResponse(teamId);
      if (cachedJson != null) {
        final dto = TeamDetailsDto.fromJson(cachedJson);
        await _upsertTeamDetails(dto);
        return dto.toEntity();
      }
      if (cached != null) {
        return await _teamRowToEntity(teamId);
      }
      rethrow;
    }
  }

  Future<void> _upsertTeamDetails(TeamDetailsDto dto) async {
    await _metronEntityDao.attachedDatabase.transaction(() async {
      await _metronEntityDao.upsertTeam(
        MetronTeamsCompanion(
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

      await _junctionDao.clearTeamJunctions(dto.id);

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
        await _junctionDao.batchInsertCreatorTeams(
          validCreators
              .map(
                (c) => CreatorTeamsCompanion(
                  creatorId: Value(c.id),
                  teamId: Value(dto.id),
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
        await _junctionDao.batchInsertTeamUniverses(
          validUniverses
              .map(
                (u) => TeamUniversesCompanion(
                  teamId: Value(dto.id),
                  universeId: Value(u.id),
                ),
              )
              .toList(),
        );
      }
    });
  }

  Future<TeamDetails> _teamRowToEntity(int teamId) async {
    final row = await _metronEntityDao.getTeam(teamId);
    if (row == null) {
      throw StateError("Team not found in cache: $teamId");
    }

    final creatorJunctions = await _junctionDao.getTeamCreators(teamId);
    final creators = <TeamCreatorRef>[];
    for (final j in creatorJunctions) {
      final c = await _metronEntityDao.getCreator(j.creatorId);
      creators.add(TeamCreatorRef(id: j.creatorId, name: c?.name ?? ""));
    }

    final universeJunctions = await _junctionDao.getTeamUniverses(teamId);
    final universes = <UniverseNamedRef>[];
    for (final j in universeJunctions) {
      final u = await _metronEntityDao.getUniverse(j.universeId);
      universes.add(UniverseNamedRef(id: j.universeId, name: u?.name ?? ""));
    }

    return TeamDetails(
      id: row.id,
      name: row.name,
      desc: row.description,
      image: row.imageUrl,
      creators: creators,
      universes: universes,
      cvId: row.cvId,
      gcdId: row.gcdId,
      resourceUrl: row.resourceUrl,
      modified: row.modified != null ? DateTime.tryParse(row.modified!) : null,
    );
  }

  Future<CharacterIssueListPage> getTeamIssueList(
    int teamId, {
    String? nextUrl,
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  }) async {
    final cachedDtos = await _localDataSource.getTeamIssueListResults(
      teamId,
      page: page,
      limit: limit,
    );
    final cachedAt = await _localDataSource.getTeamIssueListResultsCachedAt(
      teamId,
      page: page,
      limit: limit,
    );
    final cachedMeta = await _localDataSource.getTeamIssueListResultsMeta(
      teamId,
      page: page,
      limit: limit,
    );

    if (!forceRefresh && cachedDtos != null && cachedDtos.isNotEmpty) {
      final isFresh =
          cachedAt != null &&
          MetronCachePolicies.teamIssueList.isFresh(cachedAt, _now());
      if (!isFresh) {
        _refreshInBackground(
          task: () async {
            final remotePage = nextUrl != null
                ? await _remoteDataSource.getTeamIssueList(
                    teamId,
                    nextUrl: Uri.parse(nextUrl),
                    cancelToken: cancelToken,
                  )
                : await _remoteDataSource.getTeamIssueList(
                    teamId,
                    page: page,
                    cancelToken: cancelToken,
                  );
            if (_isValidIssueListPage(
              count: remotePage.count,
              resultCount: remotePage.results.length,
            )) {
              await _localDataSource.cacheTeamIssueListResults(
                teamId,
                remotePage.results,
                page: page,
                limit: limit,
                count: remotePage.count,
                next: remotePage.next,
                previous: remotePage.previous,
              );
            }
            _upsertIssueListStubs(remotePage.results);
            _indexSeriesNamesFromIssueList(remotePage.results);
          },
          cacheKey: nextUrl ?? "team_issue_list:$teamId:$page",
          cooldown: MetronCachePolicies.teamIssueList.refreshCooldown,
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
      final key = nextUrl ?? "$teamId|$page|$forceRefresh|$limit";
      return _coalesce(_teamIssueListInFlight, key, () async {
        final remotePage = nextUrl != null
            ? await _remoteDataSource.getTeamIssueList(
                teamId,
                nextUrl: Uri.parse(nextUrl),
                cancelToken: cancelToken,
              )
            : await _remoteDataSource.getTeamIssueList(
                teamId,
                page: page,
                cancelToken: cancelToken,
              );
        if (_isValidIssueListPage(
          count: remotePage.count,
          resultCount: remotePage.results.length,
        )) {
          await _localDataSource.cacheTeamIssueListResults(
            teamId,
            remotePage.results,
            page: page,
            limit: limit,
            count: remotePage.count,
            next: remotePage.next,
            previous: remotePage.previous,
          );
        }
        _upsertIssueListStubs(remotePage.results);
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
}
