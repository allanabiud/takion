part of 'metron_repository_impl.dart';

mixin _IssuesRepositoryMixin on _RepositoryState {
  Future<IssueDetails> getIssueDetails(
    int issueId, {
    bool forceRefresh = false,
  }) async {
    final cached = await _metronEntityDao.getIssue(issueId);

    if (!forceRefresh && cached != null && cached.isFullyHydrated) {
      AppPerformanceMetrics.instance.recordCacheHit('issue_details');
      return _issueRowToEntity(cached);
    }

    final cachedJson = await _localDataSource.getCachedIssueDetailsResponse(
      issueId,
    );
    if (cachedJson != null) {
      final cachedAt = await _localDataSource.getCachedIssueDetailsCachedAt(
        issueId,
      );
      final now = _now();
      if (cachedAt != null &&
          MetronCachePolicies.issueDetails.isFresh(cachedAt, now)) {
        AppPerformanceMetrics.instance.recordCacheHit('issue_details_response');
        final dto = IssueDetailsDto.fromJson(cachedJson);
        await _upsertIssueDetails(dto);
        _indexSeriesNamesFromIssueDetails(dto);
        return dto.toEntity();
      }
    }

    AppPerformanceMetrics.instance.recordCacheMiss('issue_details');

    try {
      final key = '$issueId|$forceRefresh';
      return _coalesce(_issueDetailsInFlight, key, () async {
        await _issueDetailsGate.acquire();
        try {
          final response = await _remoteDataSource.getIssueDetails(issueId);
          if (response.statusCode == 304) {
            final cachedJson = await _localDataSource
                .getCachedIssueDetailsResponse(issueId);
            if (cachedJson != null) {
              final dto = IssueDetailsDto.fromJson(cachedJson);
              await _upsertIssueDetails(dto);
              _indexSeriesNamesFromIssueDetails(dto);
              return dto.toEntity();
            }
            if (cached != null) {
              return _issueRowToEntity(cached);
            }
            throw DioException(
              requestOptions: response.requestOptions,
              response: response,
              message: '304 Not Modified and no cached data available',
            );
          }
          final data = response.data as Map<String, dynamic>;
          final dto = IssueDetailsDto.fromJson(data);
          await _upsertIssueDetails(dto);
          await _localDataSource.cacheIssueDetailsResponse(issueId, data);
          _indexSeriesNamesFromIssueDetails(dto);
          return dto.toEntity();
        } finally {
          _issueDetailsGate.release();
        }
      }, timeout: const Duration(seconds: 30));
    } catch (e) {
      final cachedJson = await _localDataSource.getCachedIssueDetailsResponse(
        issueId,
      );
      if (cachedJson != null) {
        final dto = IssueDetailsDto.fromJson(cachedJson);
        await _upsertIssueDetails(dto);
        _indexSeriesNamesFromIssueDetails(dto);
        return dto.toEntity();
      }
      if (cached != null) {
        return _issueRowToEntity(cached);
      }
      AppLogger.error('Failed to fetch issue details', error: e);
      rethrow;
    }
  }

  Future<IssueSearchPage> searchIssues(
    String query, {
    String? nextUrl,
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  }) async {
    final cachedDtos = await _localDataSource.getIssueSearchResults(
      query,
      page: page,
      limit: limit,
    );
    final cachedAt = await _localDataSource.getIssueSearchResultsCachedAt(
      query,
      page: page,
      limit: limit,
    );
    final cachedMeta = await _localDataSource.getIssueSearchResultsMeta(
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
            final corrected = await _correctSearchQuery(query);
            final remotePage = await _remoteDataSource.searchIssues(
              corrected,
              nextUrl: nextUrl != null ? Uri.parse(nextUrl) : null,
              page: page,
              limit: limit,
              cancelToken: cancelToken,
            );
            await _localDataSource.cacheIssueSearchResults(
              query,
              remotePage.results,
              page: page,
              limit: limit,
              count: remotePage.count,
              next: remotePage.next,
              previous: remotePage.previous,
            );
            _upsertIssueListStubs(remotePage.results);
            _indexSeriesNamesFromIssueList(remotePage.results);
          },
          cacheKey: nextUrl != null
              ? 'search:issue:$query:$nextUrl'
              : 'search:issue:$query:$page',
          cooldown: MetronCachePolicies.searchResults.refreshCooldown,
        );
      }
      if (cachedMeta != null) {
        return IssueSearchPage(
          count: cachedMeta.count,
          next: cachedMeta.next,
          previous: cachedMeta.previous,
          results: cachedDtos.map((entry) => entry.toEntity()).toList(),
          currentPage: page,
        );
      }
    }

    try {
      final corrected = await _correctSearchQuery(query);
      final remotePage = await _remoteDataSource.searchIssues(
        corrected,
        nextUrl: nextUrl != null ? Uri.parse(nextUrl) : null,
        page: page,
        limit: limit,
        cancelToken: cancelToken,
      );
      await _localDataSource.cacheIssueSearchResults(
        query,
        remotePage.results,
        page: page,
        limit: limit,
        count: remotePage.count,
        next: remotePage.next,
        previous: remotePage.previous,
      );
      _upsertIssueListStubs(remotePage.results);
      _indexSeriesNamesFromIssueList(remotePage.results);
      return IssueSearchPage(
        count: remotePage.count,
        next: remotePage.next,
        previous: remotePage.previous,
        results: remotePage.results.map((entry) => entry.toEntity()).toList(),
        currentPage: page,
      );
    } catch (error) {
      if (_isCancelled(error)) rethrow;
      if (cachedDtos != null && cachedDtos.isNotEmpty && cachedMeta != null) {
        return IssueSearchPage(
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

  Future<IssueSearchPage> getIssueList({
    String? nextUrl,
    int page = 1,
    bool forceRefresh = false,
    String? ordering,
    DateTime? modifiedGt,
    int? limit,
    CancelToken? cancelToken,
  }) async {
    final cachedDtos = await _localDataSource.getIssueListResults(
      page: page,
      ordering: ordering,
      modifiedGt: modifiedGt,
      limit: limit,
    );
    final cachedAt = await _localDataSource.getIssueListResultsCachedAt(
      page: page,
      ordering: ordering,
      modifiedGt: modifiedGt,
      limit: limit,
    );
    final cachedMeta = await _localDataSource.getIssueListResultsMeta(
      page: page,
      ordering: ordering,
      modifiedGt: modifiedGt,
      limit: limit,
    );

    if (!forceRefresh && cachedDtos != null && cachedDtos.isNotEmpty) {
      final isFresh =
          cachedAt != null &&
          MetronCachePolicies.searchResults.isFresh(cachedAt, _now());
      if (!isFresh) {
        final key =
            nextUrl ??
            '$page|${ordering ?? ''}|${modifiedGt?.toUtc().toIso8601String() ?? ''}|${limit ?? ''}';
        _refreshInBackground(
          task: () async {
            final remotePage = await _remoteDataSource.getIssueList(
              nextUrl: nextUrl != null ? Uri.parse(nextUrl) : null,
              page: page,
              ordering: ordering,
              modifiedGt: modifiedGt,
              limit: limit,
              cancelToken: cancelToken,
            );
            await _localDataSource.cacheIssueListResults(
              remotePage.results,
              page: page,
              ordering: ordering,
              modifiedGt: modifiedGt,
              limit: limit,
              count: remotePage.count,
              next: remotePage.next,
              previous: remotePage.previous,
            );
            _upsertIssueListStubs(remotePage.results);
          },
          cacheKey: 'issue_list:$key',
          cooldown: MetronCachePolicies.searchResults.refreshCooldown,
        );
      }
      if (cachedMeta != null) {
        AppPerformanceMetrics.instance.recordCacheHit('issue_list');
        return IssueSearchPage(
          count: cachedMeta.count,
          next: cachedMeta.next,
          previous: cachedMeta.previous,
          results: cachedDtos.map((entry) => entry.toEntity()).toList(),
          currentPage: page,
        );
      }
    }
    AppPerformanceMetrics.instance.recordCacheMiss('issue_list');

    final key =
        nextUrl ??
        '$page|${ordering ?? ''}|${modifiedGt?.toUtc().toIso8601String() ?? ''}|${limit ?? ''}|$forceRefresh';
    try {
      return _coalesce(_issueListInFlight, key, () async {
        final remotePage = await _remoteDataSource.getIssueList(
          nextUrl: nextUrl != null ? Uri.parse(nextUrl) : null,
          page: page,
          ordering: ordering,
          modifiedGt: modifiedGt,
          limit: limit,
          cancelToken: cancelToken,
        );
        await _localDataSource.cacheIssueListResults(
          remotePage.results,
          page: page,
          ordering: ordering,
          modifiedGt: modifiedGt,
          limit: limit,
          count: remotePage.count,
          next: remotePage.next,
          previous: remotePage.previous,
        );
        _upsertIssueListStubs(remotePage.results);
        return IssueSearchPage(
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
        return IssueSearchPage(
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

  Future<IssueSearchPage> searchIssuesByUpc(
    String upc, {
    CancelToken? cancelToken,
    bool forceRefresh = false,
  }) async {
    final cachedDtos = await _localDataSource.getIssueSearchResults(
      'upc:$upc',
      page: 1,
      limit: 1,
    );
    final cachedAt = await _localDataSource.getIssueSearchResultsCachedAt(
      'upc:$upc',
      page: 1,
      limit: 1,
    );
    final cachedMeta = await _localDataSource.getIssueSearchResultsMeta(
      'upc:$upc',
      page: 1,
      limit: 1,
    );

    if (!forceRefresh && cachedDtos != null && cachedDtos.isNotEmpty) {
      final isFresh =
          cachedAt != null &&
          MetronCachePolicies.searchResults.isFresh(cachedAt, _now());
      if (!isFresh) {
        _refreshInBackground(
          task: () async {
            final remotePage = await _remoteDataSource.searchIssuesByUpc(
              upc,
              cancelToken: cancelToken,
            );
            await _localDataSource.cacheIssueSearchResults(
              'upc:$upc',
              remotePage.results,
              page: 1,
              limit: 1,
              count: remotePage.count,
              next: remotePage.next,
              previous: remotePage.previous,
            );
            _upsertIssueListStubs(remotePage.results);
          },
          cacheKey: 'search:upc:$upc',
          cooldown: MetronCachePolicies.searchResults.refreshCooldown,
        );
      }
      if (cachedMeta != null) {
        return IssueSearchPage(
          count: cachedMeta.count,
          next: cachedMeta.next,
          previous: cachedMeta.previous,
          results: cachedDtos.map((entry) => entry.toEntity()).toList(),
          currentPage: 1,
        );
      }
    }

    try {
      final remotePage = await _remoteDataSource.searchIssuesByUpc(
        upc,
        cancelToken: cancelToken,
      );
      await _localDataSource.cacheIssueSearchResults(
        'upc:$upc',
        remotePage.results,
        page: 1,
        limit: 1,
        count: remotePage.count,
        next: remotePage.next,
        previous: remotePage.previous,
      );
      _upsertIssueListStubs(remotePage.results);
      return IssueSearchPage(
        count: remotePage.count,
        next: remotePage.next,
        previous: remotePage.previous,
        results: remotePage.results.map((entry) => entry.toEntity()).toList(),
        currentPage: 1,
      );
    } catch (error) {
      if (_isCancelled(error)) rethrow;
      if (cachedDtos != null && cachedDtos.isNotEmpty && cachedMeta != null) {
        return IssueSearchPage(
          count: cachedMeta.count,
          next: cachedMeta.next,
          previous: cachedMeta.previous,
          results: cachedDtos.map((entry) => entry.toEntity()).toList(),
          currentPage: 1,
        );
      }
      rethrow;
    }
  }

  Future<IssueSearchPage> searchIssuesByUpcPrefix(
    String prefix, {
    CancelToken? cancelToken,
    bool forceRefresh = false,
  }) async {
    final cachedDtos = await _localDataSource.getIssueSearchResults(
      'upc_prefix:$prefix',
      page: 1,
      limit: 1,
    );
    final cachedAt = await _localDataSource.getIssueSearchResultsCachedAt(
      'upc_prefix:$prefix',
      page: 1,
      limit: 1,
    );
    final cachedMeta = await _localDataSource.getIssueSearchResultsMeta(
      'upc_prefix:$prefix',
      page: 1,
      limit: 1,
    );

    if (!forceRefresh && cachedDtos != null && cachedDtos.isNotEmpty) {
      final isFresh =
          cachedAt != null &&
          MetronCachePolicies.searchResults.isFresh(cachedAt, _now());
      if (!isFresh) {
        _refreshInBackground(
          task: () async {
            final remotePage = await _remoteDataSource.searchIssuesByUpcPrefix(
              prefix,
              cancelToken: cancelToken,
            );
            await _localDataSource.cacheIssueSearchResults(
              'upc_prefix:$prefix',
              remotePage.results,
              page: 1,
              limit: 1,
              count: remotePage.count,
              next: remotePage.next,
              previous: remotePage.previous,
            );
            _upsertIssueListStubs(remotePage.results);
          },
          cacheKey: 'search:upc_prefix:$prefix',
          cooldown: MetronCachePolicies.searchResults.refreshCooldown,
        );
      }
      if (cachedMeta != null) {
        return IssueSearchPage(
          count: cachedMeta.count,
          next: cachedMeta.next,
          previous: cachedMeta.previous,
          results: cachedDtos.map((entry) => entry.toEntity()).toList(),
          currentPage: 1,
        );
      }
    }

    try {
      final allDtos = <IssueListDto>[];
      var totalCount = 0;
      String? nextUrl;

      final firstPage = await _remoteDataSource.searchIssuesByUpcPrefix(
        prefix,
        cancelToken: cancelToken,
      );
      allDtos.addAll(firstPage.results);
      totalCount = firstPage.count;
      nextUrl = firstPage.next;

      while (nextUrl != null) {
        final page = await _remoteDataSource.getIssueSearchPage(
          nextUrl,
          cancelToken: cancelToken,
        );
        allDtos.addAll(page.results);
        nextUrl = page.next;
      }

      await _localDataSource.cacheIssueSearchResults(
        'upc_prefix:$prefix',
        allDtos,
        page: 1,
        limit: 1,
        count: totalCount,
        next: null,
        previous: null,
      );
      _upsertIssueListStubs(allDtos);
      return IssueSearchPage(
        count: totalCount,
        results: allDtos.map((entry) => entry.toEntity()).toList(),
        currentPage: 1,
      );
    } catch (error) {
      if (_isCancelled(error)) rethrow;
      if (cachedDtos != null && cachedDtos.isNotEmpty && cachedMeta != null) {
        return IssueSearchPage(
          count: cachedMeta.count,
          next: cachedMeta.next,
          previous: cachedMeta.previous,
          results: cachedDtos.map((entry) => entry.toEntity()).toList(),
          currentPage: 1,
        );
      }
      rethrow;
    }
  }

  Future<void> _upsertIssueDetails(IssueDetailsDto dto) async {
    if (dto.publisher != null) {
      await _metronEntityDao.upsertPublisher(
        MetronPublishersCompanion(
          id: Value(dto.publisher!.id),
          name: Value(dto.publisher!.name),
          isFullyHydrated: const Value(false),
        ),
      );
    }
    if (dto.imprint != null) {
      await _metronEntityDao.upsertImprint(
        MetronImprintsCompanion(
          id: Value(dto.imprint!.id),
          name: Value(dto.imprint!.name),
          isFullyHydrated: const Value(false),
        ),
      );
    }
    if (dto.series != null) {
      await _metronEntityDao.upsertSeries(
        MetronSeriesCompanion(
          id: Value(dto.series!.id),
          name: Value(dto.series!.name),
          sortName: Value(dto.series!.sortName),
          volume: Value(dto.series!.volume),
          yearBegan: Value(dto.series!.yearBegan),
          seriesTypeId: Value(dto.series!.seriesType?.id),
          isFullyHydrated: const Value(false),
        ),
      );
    }

    await _metronEntityDao.upsertIssue(
      MetronIssuesCompanion(
        id: Value(dto.id),
        number: Value(dto.number),
        seriesId: Value(dto.series?.id),
        coverDate: Value(dto.coverDate),
        storeDate: Value(dto.storeDate),
        focDate: Value(dto.focDate),
        imageUrl: Value(dto.image),
        description: Value(dto.description),
        pageCount: Value(dto.page),
        price: Value(dto.price),
        sku: Value(dto.sku),
        upc: Value(dto.upc),
        isbn: Value(dto.isbn),
        coverHash: Value(dto.coverHash),
        publisherId: Value(dto.publisher?.id),
        imprintId: Value(dto.imprint?.id),
        cvId: Value(dto.cvId),
        gcdId: Value(dto.gcdId),
        resourceUrl: Value(dto.resourceUrl),
        modified: Value(dto.modified),
        isFullyHydrated: const Value(true),
      ),
    );

    await _junctionDao.clearIssueJunctions(dto.id);

    await _metronEntityDao.upsertCharacterStubsBatch(
      dto.characters
          .map(
            (c) => MetronCharactersCompanion(
              id: Value(c.id),
              name: Value(c.name),
              isFullyHydrated: const Value(false),
            ),
          )
          .toList(),
    );
    if (dto.characters.isNotEmpty) {
      await _junctionDao.batchInsertIssueCharacters(
        dto.characters
            .asMap()
            .entries
            .map(
              (e) => IssueCharactersCompanion(
                issueId: Value(dto.id),
                characterId: Value(e.value.id),
                sortOrder: Value(e.key),
              ),
            )
            .toList(),
      );
    }

    await _metronEntityDao.upsertCreatorStubsBatch(
      dto.credits
          .map((credit) {
            final creatorId =
                (credit.creatorId != null && credit.creatorId! > 0)
                ? credit.creatorId!
                : credit.id;
            if (creatorId <= 0) return null;
            return MetronCreatorsCompanion(
              id: Value(creatorId),
              name: Value(credit.creator ?? ''),
              isFullyHydrated: const Value(false),
            );
          })
          .whereType<MetronCreatorsCompanion>()
          .toList(),
    );
    if (dto.credits.isNotEmpty) {
      await _junctionDao.batchInsertIssueCreators(
        dto.credits.map((credit) {
          final creatorId = (credit.creatorId != null && credit.creatorId! > 0)
              ? credit.creatorId!
              : credit.id;
          return IssueCreatorsCompanion(
            issueId: Value(dto.id),
            creatorId: Value(creatorId),
            role: Value(
              credit.roles.isNotEmpty
                  ? credit.roles.map((r) => r.name).join(', ')
                  : null,
            ),
            sortOrder: Value(dto.credits.indexOf(credit)),
          );
        }).toList(),
      );
    }

    await _metronEntityDao.upsertArcStubsBatch(
      dto.arcs
          .map(
            (a) => MetronArcsCompanion(
              id: Value(a.id),
              name: Value(a.name),
              isFullyHydrated: const Value(false),
            ),
          )
          .toList(),
    );
    if (dto.arcs.isNotEmpty) {
      await _junctionDao.batchInsertIssueArcs(
        dto.arcs
            .asMap()
            .entries
            .map(
              (e) => IssueArcsCompanion(
                issueId: Value(dto.id),
                arcId: Value(e.value.id),
                sortOrder: Value(e.key),
              ),
            )
            .toList(),
      );
    }

    await _metronEntityDao.upsertTeamStubsBatch(
      dto.teams
          .map(
            (t) => MetronTeamsCompanion(
              id: Value(t.id),
              name: Value(t.name),
              isFullyHydrated: const Value(false),
            ),
          )
          .toList(),
    );
    if (dto.teams.isNotEmpty) {
      await _junctionDao.batchInsertIssueTeams(
        dto.teams
            .asMap()
            .entries
            .map(
              (e) => IssueTeamsCompanion(
                issueId: Value(dto.id),
                teamId: Value(e.value.id),
                sortOrder: Value(e.key),
              ),
            )
            .toList(),
      );
    }

    await _metronEntityDao.upsertUniverseStubsBatch(
      dto.universes
          .map(
            (u) => MetronUniversesCompanion(
              id: Value(u.id),
              name: Value(u.name),
              isFullyHydrated: const Value(false),
            ),
          )
          .toList(),
    );
    if (dto.universes.isNotEmpty) {
      await _junctionDao.batchInsertIssueUniverses(
        dto.universes
            .asMap()
            .entries
            .map(
              (e) => IssueUniversesCompanion(
                issueId: Value(dto.id),
                universeId: Value(e.value.id),
                sortOrder: Value(e.key),
              ),
            )
            .toList(),
      );
    }
  }

  Future<IssueDetails> _issueRowToEntity(MetronIssue row) async {
    IssueDetailsSeries? series;
    if (row.seriesId != null) {
      final s = await _metronEntityDao.getSeries(row.seriesId!);
      if (s != null) {
        series = IssueDetailsSeries(
          id: s.id,
          name: s.name,
          sortName: s.sortName,
          volume: s.volume,
          yearBegan: s.yearBegan,
        );
      }
    }

    IssueDetailsNamedRef? publisher;
    if (row.publisherId != null) {
      final p = await _metronEntityDao.getPublisher(row.publisherId!);
      if (p != null) {
        publisher = IssueDetailsNamedRef(id: p.id, name: p.name);
      }
    }

    IssueDetailsNamedRef? imprint;
    if (row.imprintId != null) {
      final i = await _metronEntityDao.getImprint(row.imprintId!);
      if (i != null) {
        imprint = IssueDetailsNamedRef(id: i.id, name: i.name);
      }
    }

    final characterJunctions = await _junctionDao.getIssueCharacters(row.id);
    final characterIds = characterJunctions.map((j) => j.characterId).toList();
    final characterMap = await _metronEntityDao.getCharactersByIds(
      characterIds,
    );
    final characters = characterJunctions
        .map(
          (j) => IssueDetailsParticipation(
            id: j.characterId,
            name: characterMap[j.characterId]?.name ?? '',
          ),
        )
        .toList();

    final arcJunctions = await _junctionDao.getIssueArcs(row.id);
    final arcIds = arcJunctions.map((j) => j.arcId).toList();
    final arcMap = await _metronEntityDao.getArcsByIds(arcIds);
    final arcs = arcJunctions
        .map(
          (j) => IssueDetailsParticipation(
            id: j.arcId,
            name: arcMap[j.arcId]?.name ?? '',
          ),
        )
        .toList();

    final teamJunctions = await _junctionDao.getIssueTeams(row.id);
    final teamIds = teamJunctions.map((j) => j.teamId).toList();
    final teamMap = await _metronEntityDao.getTeamsByIds(teamIds);
    final teams = teamJunctions
        .map(
          (j) => IssueDetailsParticipation(
            id: j.teamId,
            name: teamMap[j.teamId]?.name ?? '',
          ),
        )
        .toList();

    final universeJunctions = await _junctionDao.getIssueUniverses(row.id);
    final universeIds = universeJunctions.map((j) => j.universeId).toList();
    final universeMap = await _metronEntityDao.getUniversesByIds(universeIds);
    final universes = universeJunctions
        .map(
          (j) => IssueDetailsParticipation(
            id: j.universeId,
            name: universeMap[j.universeId]?.name ?? '',
          ),
        )
        .toList();

    final creditJunctions = await _junctionDao.getIssueCreators(row.id);
    final creatorIds = creditJunctions.map((j) => j.creatorId).toList();
    final creatorMap = await _metronEntityDao.getCreatorsByIds(creatorIds);
    final credits = creditJunctions
        .map(
          (j) => IssueDetailsCredit(
            id: j.creatorId,
            creator: creatorMap[j.creatorId]?.name,
            creatorId: j.creatorId,
            roles: j.role != null
                ? j.role!
                      .split(', ')
                      .map((r) => IssueDetailsCreditRole(id: 0, name: r))
                      .toList()
                : const [],
          ),
        )
        .toList();

    return IssueDetails(
      id: row.id,
      number: row.number,
      series: series,
      publisher: publisher,
      imprint: imprint,
      coverDate: row.coverDate != null
          ? DateTime.tryParse(row.coverDate!)
          : null,
      storeDate: row.storeDate != null
          ? DateTime.tryParse(row.storeDate!)
          : null,
      focDate: row.focDate != null ? DateTime.tryParse(row.focDate!) : null,
      image: row.imageUrl,
      description: row.description,
      page: row.pageCount,
      price: row.price,
      sku: row.sku,
      upc: row.upc,
      isbn: row.isbn,
      coverHash: row.coverHash,
      cvId: row.cvId,
      gcdId: row.gcdId,
      resourceUrl: row.resourceUrl,
      modified: row.modified != null ? DateTime.tryParse(row.modified!) : null,
      characters: characters,
      arcs: arcs,
      teams: teams,
      universes: universes,
      credits: credits,
    );
  }
}
