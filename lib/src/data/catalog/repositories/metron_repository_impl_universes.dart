part of 'metron_repository_impl.dart';

mixin _UniversesRepositoryMixin on _RepositoryState {
  Future<UniverseListPage> getUniverseList({
    String? nextUrl,
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  }) async {
    final dto = nextUrl != null
        ? await _remoteDataSource.getUniverseList(
            nextUrl: Uri.parse(nextUrl),
            limit: limit,
            cancelToken: cancelToken,
          )
        : await _remoteDataSource.getUniverseList(
            page: page,
            limit: limit,
            cancelToken: cancelToken,
          );
    return UniverseListPage(
      count: dto.count,
      next: dto.next,
      previous: dto.previous,
      results: dto.results.map((e) => e.toEntity()).toList(),
      currentPage: page,
    );
  }

  Future<UniverseListPage> searchUniverses(
    String query, {
    String? nextUrl,
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  }) async {
    final cachedDtos = await _localDataSource.getUniverseSearchResults(
      query,
      page: page,
      limit: limit,
    );
    final cachedAt = await _localDataSource.getUniverseSearchResultsCachedAt(
      query,
      page: page,
      limit: limit,
    );
    final cachedMeta = await _localDataSource.getUniverseSearchResultsMeta(
      query,
      page: page,
      limit: limit,
    );

    if (!forceRefresh && cachedDtos != null && cachedDtos.isNotEmpty) {
      final isFresh =
          cachedAt != null &&
          MetronCachePolicies.universeSearchResults.isFresh(cachedAt, _now());
      if (!isFresh) {
        _refreshInBackground(
          task: () async {
            final remotePage = nextUrl != null
                ? await _remoteDataSource.searchUniverses(
                    query,
                    nextUrl: Uri.parse(nextUrl),
                    limit: limit,
                    cancelToken: cancelToken,
                  )
                : await _remoteDataSource.searchUniverses(
                    query,
                    page: page,
                    limit: limit,
                    cancelToken: cancelToken,
                  );
            await _localDataSource.cacheUniverseSearchResults(
              query,
              remotePage.results,
              page: page,
              limit: limit,
              count: remotePage.count,
              next: remotePage.next,
              previous: remotePage.previous,
            );
          },
          cacheKey: nextUrl ?? 'search:universe:$query:$page',
          cooldown: MetronCachePolicies.universeSearchResults.refreshCooldown,
        );
      }
      if (cachedMeta != null) {
        return UniverseListPage(
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
          ? await _remoteDataSource.searchUniverses(
              query,
              nextUrl: Uri.parse(nextUrl),
              limit: limit,
              cancelToken: cancelToken,
            )
          : await _remoteDataSource.searchUniverses(
              query,
              page: page,
              limit: limit,
              cancelToken: cancelToken,
            );
      await _localDataSource.cacheUniverseSearchResults(
        query,
        remotePage.results,
        page: page,
        limit: limit,
        count: remotePage.count,
        next: remotePage.next,
        previous: remotePage.previous,
      );
      return UniverseListPage(
        count: remotePage.count,
        next: remotePage.next,
        previous: remotePage.previous,
        results: remotePage.results.map((entry) => entry.toEntity()).toList(),
        currentPage: page,
      );
    } catch (error) {
      if (_isCancelled(error)) rethrow;
      if (cachedDtos != null && cachedDtos.isNotEmpty && cachedMeta != null) {
        return UniverseListPage(
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

  Future<UniverseDetails> getUniverseDetails(
    int universeId, {
    bool forceRefresh = false,
  }) async {
    final cached = await _metronEntityDao.getUniverse(universeId);

    if (!forceRefresh && cached != null && cached.isFullyHydrated) {
      AppPerformanceMetrics.instance.recordCacheHit('universe_details');
      return _universeRowToEntity(cached);
    }

    AppPerformanceMetrics.instance.recordCacheMiss('universe_details');

    try {
      final dto = await _remoteDataSource.getUniverseDetails(universeId);
      if (cached != null &&
          cached.modified != null &&
          dto.modified != null &&
          cached.modified == dto.modified) {
        return _universeRowToEntity(cached);
      }
      await _upsertUniverseDetails(dto);
      return _universeRowToEntity(
        await _metronEntityDao.getUniverse(universeId) ??
            (throw StateError('Universe $universeId not found after upsert')),
      );
    } catch (e) {
      AppLogger.error('Failed to fetch universe details', error: e);
      if (cached != null) {
        return _universeRowToEntity(cached);
      }
      rethrow;
    }
  }

  Future<void> _upsertUniverseDetails(UniverseDetailsDto dto) async {
    if (dto.publisher != null) {
      await _metronEntityDao.upsertPublisher(
        MetronPublishersCompanion(
          id: Value(dto.publisher!.id),
          name: Value(dto.publisher!.name),
          isFullyHydrated: const Value(false),
        ),
      );
    }
    await _metronEntityDao.upsertUniverse(
      MetronUniversesCompanion(
        id: Value(dto.id),
        name: Value(dto.name),
        designation: Value(dto.designation),
        publisherId: Value(dto.publisher?.id),
        imageUrl: Value(dto.image),
        description: Value(dto.desc),
        gcdId: Value(dto.gcdId),
        resourceUrl: Value(dto.resourceUrl),
        modified: Value(dto.modified),
        isFullyHydrated: const Value(true),
      ),
    );
  }

  UniverseDetails _universeRowToEntity(MetronUniverse row) {
    return UniverseDetails(
      id: row.id,
      name: row.name,
      publisher: row.publisherId != null
          ? UniverseNamedRef(id: row.publisherId!, name: '')
          : null,
      designation: row.designation,
      desc: row.description,
      gcdId: row.gcdId,
      image: row.imageUrl,
      resourceUrl: row.resourceUrl,
      modified: row.modified != null ? DateTime.tryParse(row.modified!) : null,
    );
  }
}
