part of 'metron_repository_impl.dart';

mixin _UniversesRepositoryMixin on _RepositoryState {

  Future<UniverseListPage> getUniverseList({
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  }) async {
    final dto = await _remoteDataSource.getUniverseList(
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
            final remotePage = await _remoteDataSource.searchUniverses(
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
          cacheKey: 'search:universe:$query:$page',
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
      final remotePage = await _remoteDataSource.searchUniverses(
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
        results:
            remotePage.results.map((entry) => entry.toEntity()).toList(),
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
    final cachedDto = await _localDataSource.getUniverseDetails(universeId);
    final cachedAt =
        await _localDataSource.getUniverseDetailsCachedAt(universeId);

    if (!forceRefresh && cachedDto != null) {
      final isFresh =
          cachedAt != null &&
          MetronCachePolicies.universeDetails.isFresh(cachedAt, _now());
      if (!isFresh) {
        _refreshInBackground(
          task: () async {
            await _universeDetailsGate.acquire();
            try {
              final remoteDto =
                  await _remoteDataSource.getUniverseDetails(universeId);
              await _localDataSource.cacheUniverseDetails(remoteDto);
            } finally {
              _universeDetailsGate.release();
            }
          },
          cacheKey: 'universe_details:$universeId',
          cooldown: MetronCachePolicies.universeDetails.refreshCooldown,
        );
      }
      return cachedDto.toEntity();
    }

    try {
      await _universeDetailsGate.acquire();
      try {
        final remoteDto =
            await _remoteDataSource.getUniverseDetails(universeId);
        await _localDataSource.cacheUniverseDetails(remoteDto);
        return remoteDto.toEntity();
      } finally {
        _universeDetailsGate.release();
      }
    } catch (e) {
      AppLogger.error('Failed to fetch universe details', error: e);
      if (cachedDto != null) {
        return cachedDto.toEntity();
      }
      rethrow;
    }
  }
}
