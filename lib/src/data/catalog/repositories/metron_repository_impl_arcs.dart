part of 'metron_repository_impl.dart';

mixin _ArcsRepositoryMixin on _RepositoryState {
  Future<ArcListPage> getArcList({
    String? nextUrl,
    int page = 1,
    int limit = metronDefaultPageSize,
    DateTime? modifiedGt,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  }) async {
    final cachedDtos = await _localDataSource.getArcListResults(
      page: page,
      limit: limit,
      modifiedGt: modifiedGt,
    );
    final cachedAt = await _localDataSource.getArcListResultsCachedAt(
      page: page,
      limit: limit,
      modifiedGt: modifiedGt,
    );
    final cachedMeta = await _localDataSource.getArcListResultsMeta(
      page: page,
      limit: limit,
      modifiedGt: modifiedGt,
    );

    if (!forceRefresh && cachedDtos != null && cachedDtos.isNotEmpty) {
      final isFresh =
          cachedAt != null &&
          MetronCachePolicies.arcList.isFresh(cachedAt, _now());
      if (!isFresh) {
        _refreshInBackground(
          task: () async {
            final remotePage = nextUrl != null
                ? await _remoteDataSource.getArcList(
                    nextUrl: Uri.parse(nextUrl),
                    limit: limit,
                    modifiedGt: modifiedGt,
                    cancelToken: cancelToken,
                  )
                : await _remoteDataSource.getArcList(
                    page: page,
                    limit: limit,
                    modifiedGt: modifiedGt,
                    cancelToken: cancelToken,
                  );
            await _localDataSource.cacheArcListResults(
              remotePage.results,
              page: page,
              limit: limit,
              modifiedGt: modifiedGt,
              count: remotePage.count,
              next: remotePage.next,
              previous: remotePage.previous,
            );
          },
          cacheKey: 'arc_list:${nextUrl ?? "$page"}|$modifiedGt',
          cooldown: MetronCachePolicies.arcList.refreshCooldown,
        );
      }
      if (cachedMeta != null) {
        return ArcListPage(
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
      return _coalesce(_arcListInFlight, key, () async {
        final remotePage = nextUrl != null
            ? await _remoteDataSource.getArcList(
                nextUrl: Uri.parse(nextUrl),
                limit: limit,
                modifiedGt: modifiedGt,
                cancelToken: cancelToken,
              )
            : await _remoteDataSource.getArcList(
                page: page,
                limit: limit,
                modifiedGt: modifiedGt,
                cancelToken: cancelToken,
              );
        await _localDataSource.cacheArcListResults(
          remotePage.results,
          page: page,
          limit: limit,
          modifiedGt: modifiedGt,
          count: remotePage.count,
          next: remotePage.next,
          previous: remotePage.previous,
        );
        return ArcListPage(
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
        return ArcListPage(
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

  Future<int> refreshArcListDelta({DateTime? modifiedGt}) async {
    var page = 1;
    var synced = 0;
    while (true) {
      final result = await getArcList(
        page: page,
        limit: metronDefaultPageSize,
        modifiedGt: modifiedGt,
        forceRefresh: true,
      );
      for (final item in result.results) {
        await getArcDetails(item.id, forceRefresh: true);
        synced++;
      }
      if (!result.hasNext) break;
      page++;
    }
    return synced;
  }

  Future<ArcListPage> searchArcs(
    String query, {
    String? nextUrl,
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  }) async {
    final cachedDtos = await _localDataSource.getArcSearchResults(
      query,
      page: page,
      limit: limit,
    );
    final cachedAt = await _localDataSource.getArcSearchResultsCachedAt(
      query,
      page: page,
      limit: limit,
    );
    final cachedMeta = await _localDataSource.getArcSearchResultsMeta(
      query,
      page: page,
      limit: limit,
    );

    if (!forceRefresh && cachedDtos != null && cachedDtos.isNotEmpty) {
      final isFresh =
          cachedAt != null &&
          MetronCachePolicies.arcSearchResults.isFresh(cachedAt, _now());
      if (!isFresh) {
        _refreshInBackground(
          task: () async {
            final remotePage = nextUrl != null
                ? await _remoteDataSource.searchArcs(
                    query,
                    nextUrl: Uri.parse(nextUrl),
                    limit: limit,
                    cancelToken: cancelToken,
                  )
                : await _remoteDataSource.searchArcs(
                    query,
                    page: page,
                    limit: limit,
                    cancelToken: cancelToken,
                  );
            await _localDataSource.cacheArcSearchResults(
              query,
              remotePage.results,
              page: page,
              limit: limit,
              count: remotePage.count,
              next: remotePage.next,
              previous: remotePage.previous,
            );
          },
          cacheKey: nextUrl ?? 'search:arc:$query:$page',
          cooldown: MetronCachePolicies.arcSearchResults.refreshCooldown,
        );
      }
      if (cachedMeta != null) {
        return ArcListPage(
          count: cachedMeta.count,
          next: cachedMeta.next,
          previous: cachedMeta.previous,
          results: cachedDtos.map((entry) => entry.toEntity()).toList(),
          currentPage: page,
        );
      }
    }

    try {
      final key = nextUrl ?? '$query|$page|$limit|$forceRefresh';
      return _coalesce(_arcSearchInFlight, key, () async {
        final remotePage = nextUrl != null
            ? await _remoteDataSource.searchArcs(
                query,
                nextUrl: Uri.parse(nextUrl),
                limit: limit,
                cancelToken: cancelToken,
              )
            : await _remoteDataSource.searchArcs(
                query,
                page: page,
                limit: limit,
                cancelToken: cancelToken,
              );
        await _localDataSource.cacheArcSearchResults(
          query,
          remotePage.results,
          page: page,
          limit: limit,
          count: remotePage.count,
          next: remotePage.next,
          previous: remotePage.previous,
        );
        return ArcListPage(
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
        return ArcListPage(
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

  Future<ArcDetails> getArcDetails(
    int arcId, {
    bool forceRefresh = false,
  }) async {
    final cached = await _metronEntityDao.getArc(arcId);

    if (!forceRefresh && cached != null && cached.isFullyHydrated) {
      AppPerformanceMetrics.instance.recordCacheHit('arc_details');
      return _arcRowToEntity(cached);
    }

    final cachedJson =
        await _localDataSource.getCachedArcDetailsResponse(arcId);
    if (cachedJson != null && !forceRefresh) {
      final cachedAt =
          await _localDataSource.getCachedArcDetailsCachedAt(arcId);
      final now = _now();
      if (cachedAt != null &&
          MetronCachePolicies.arcDetails.isFresh(cachedAt, now)) {
        AppPerformanceMetrics.instance.recordCacheHit(
          'arc_details_response',
        );
        final dto = ArcDetailsDto.fromJson(cachedJson);
        await _upsertArcDetails(dto);
        return _arcRowToEntity(
          await _metronEntityDao.getArc(arcId) ??
              (throw StateError('Arc $arcId not found')),
        );
      }
    }

    AppPerformanceMetrics.instance.recordCacheMiss('arc_details');

    try {
      final response = await _remoteDataSource.getArcDetails(arcId);
      if (response.statusCode == 304) {
        final cachedJson =
            await _localDataSource.getCachedArcDetailsResponse(arcId);
        if (cachedJson != null) {
          await _localDataSource.cacheArcDetailsResponse(arcId, cachedJson);
          final dto = ArcDetailsDto.fromJson(cachedJson);
          await _upsertArcDetails(dto);
          return _arcRowToEntity(
            await _metronEntityDao.getArc(arcId) ??
                (throw StateError('Arc $arcId not found')),
          );
        }
        return _arcRowToEntity(
          cached ?? (throw StateError('Arc $arcId not found')),
        );
      }
      final rawData = response.data;
      final Map<String, dynamic> data;
      if (rawData is Map<String, dynamic>) {
        data = rawData;
      } else if (rawData is Map) {
        data = Map<String, dynamic>.from(rawData);
      } else if (rawData is String) {
        final decoded = jsonDecode(rawData);
        data = decoded is Map ? Map<String, dynamic>.from(decoded) : <String, dynamic>{};
      } else {
        data = <String, dynamic>{};
      }
      final dto = ArcDetailsDto.fromJson(data);
      if (!forceRefresh &&
          cached != null &&
          cached.isFullyHydrated &&
          cached.modified != null &&
          dto.modified != null &&
          cached.modified == dto.modified) {
        return _arcRowToEntity(cached);
      }
      await _upsertArcDetails(dto);
      await _localDataSource.cacheArcDetailsResponse(arcId, data);
      return _arcRowToEntity(
        await _metronEntityDao.getArc(arcId) ??
            (throw StateError('Arc $arcId not found after upsert')),
      );
    } catch (e) {
      AppLogger.error('Failed to fetch arc details', error: e);
      final cachedJson =
          await _localDataSource.getCachedArcDetailsResponse(arcId);
      if (cachedJson != null) {
        final dto = ArcDetailsDto.fromJson(cachedJson);
        await _upsertArcDetails(dto);
        return _arcRowToEntity(
          await _metronEntityDao.getArc(arcId) ??
              (throw StateError('Arc $arcId not found after upsert')),
        );
      }
      if (cached != null) {
        return _arcRowToEntity(cached);
      }
      rethrow;
    }
  }

  Future<ArcIssueListPage> getArcIssueList(
    int arcId, {
    String? nextUrl,
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  }) async {
    final cachedDtos = await _localDataSource.getArcIssueListResults(
      arcId,
      page: page,
      limit: limit,
    );
    final cachedAt = await _localDataSource.getArcIssueListResultsCachedAt(
      arcId,
      page: page,
      limit: limit,
    );
    final cachedMeta = await _localDataSource.getArcIssueListResultsMeta(
      arcId,
      page: page,
      limit: limit,
    );

    if (!forceRefresh && cachedDtos != null && cachedDtos.isNotEmpty) {
      final isFresh =
          cachedAt != null &&
          MetronCachePolicies.arcIssueList.isFresh(cachedAt, _now());
      if (!isFresh) {
        _refreshInBackground(
          task: () async {
            final remotePage = nextUrl != null
                ? await _remoteDataSource.getArcIssueList(
                    arcId,
                    nextUrl: Uri.parse(nextUrl),
                    limit: limit,
                    cancelToken: cancelToken,
                  )
                : await _remoteDataSource.getArcIssueList(
                    arcId,
                    page: page,
                    limit: limit,
                    cancelToken: cancelToken,
                  );
            await _localDataSource.cacheArcIssueListResults(
              arcId,
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
          cacheKey: nextUrl ?? 'arc_issue_list:$arcId:$page',
          cooldown: MetronCachePolicies.arcIssueList.refreshCooldown,
        );
      }
      if (cachedMeta != null) {
        return ArcIssueListPage(
          count: cachedMeta.count,
          next: cachedMeta.next,
          previous: cachedMeta.previous,
          results: cachedDtos.map((entry) => entry.toEntity()).toList(),
          currentPage: page,
        );
      }
    }

    try {
      final key = nextUrl ?? '$arcId|$page|$forceRefresh';
      return _coalesce(_arcIssueListInFlight, key, () async {
        final remotePage = nextUrl != null
            ? await _remoteDataSource.getArcIssueList(
                arcId,
                nextUrl: Uri.parse(nextUrl),
                limit: limit,
                cancelToken: cancelToken,
              )
            : await _remoteDataSource.getArcIssueList(
                arcId,
                page: page,
                limit: limit,
                cancelToken: cancelToken,
              );
        await _localDataSource.cacheArcIssueListResults(
          arcId,
          remotePage.results,
          page: page,
          limit: limit,
          count: remotePage.count,
          next: remotePage.next,
          previous: remotePage.previous,
        );
        _upsertIssueListStubs(remotePage.results);
        _indexSeriesNamesFromIssueList(remotePage.results);
        return ArcIssueListPage(
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
        return ArcIssueListPage(
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

  Future<List<IssueList>> getArcIssueListAll(
    int arcId, {
    bool forceRefresh = false,
  }) async {
    final allIssues = <IssueList>[];
    Uri? nextUrl;

    while (true) {
      final page = await _remoteDataSource.getArcIssueList(
        arcId,
        nextUrl: nextUrl,
        limit: metronDefaultPageSize,
      );
      _upsertIssueListStubs(page.results);
      _indexSeriesNamesFromIssueList(page.results);
      for (final dto in page.results) {
        allIssues.add(dto.toEntity());
      }
      if (page.next == null) break;
      nextUrl = Uri.parse(page.next!);
    }

    return allIssues;
  }

  Future<void> _upsertArcDetails(ArcDetailsDto dto) async {
    await _metronEntityDao.upsertArc(
      MetronArcsCompanion(
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
  }

  ArcDetails _arcRowToEntity(MetronArc row) {
    return ArcDetails(
      id: row.id,
      name: row.name,
      desc: row.description,
      image: row.imageUrl,
      cvId: row.cvId,
      gcdId: row.gcdId,
      resourceUrl: row.resourceUrl,
      modified: row.modified != null ? DateTime.tryParse(row.modified!) : null,
    );
  }
}
