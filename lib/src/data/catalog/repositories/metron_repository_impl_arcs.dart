part of 'metron_repository_impl.dart';

mixin _ArcsRepositoryMixin on _RepositoryState {
  Future<ArcListPage> getArcList({
    String? nextUrl,
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  }) async {
    final dto = nextUrl != null
        ? await _remoteDataSource.getArcList(
            nextUrl: Uri.parse(nextUrl),
            limit: limit,
            cancelToken: cancelToken,
          )
        : await _remoteDataSource.getArcList(
            page: page,
            limit: limit,
            cancelToken: cancelToken,
          );
    return ArcListPage(
      count: dto.count,
      next: dto.next,
      previous: dto.previous,
      results: dto.results.map((e) => e.toEntity()).toList(),
      currentPage: page,
    );
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

    AppPerformanceMetrics.instance.recordCacheMiss('arc_details');

    try {
      final dto = await _remoteDataSource.getArcDetails(arcId);
      await _upsertArcDetails(dto);
      return _arcRowToEntity(
        await _metronEntityDao.getArc(arcId) ??
            (throw StateError('Arc $arcId not found after upsert')),
      );
    } catch (e) {
      AppLogger.error('Failed to fetch arc details', error: e);
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
