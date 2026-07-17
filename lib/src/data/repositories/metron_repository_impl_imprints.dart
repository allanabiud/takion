part of 'metron_repository_impl.dart';

mixin _ImprintsRepositoryMixin on _RepositoryState {

  Future<ImprintListPage> getImprintList({
    String? nextUrl,
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  }) async {
    final dto = nextUrl != null
        ? await _remoteDataSource.getImprintList(
            nextUrl: Uri.parse(nextUrl),
            limit: limit,
            cancelToken: cancelToken,
          )
        : await _remoteDataSource.getImprintList(
            page: page,
            limit: limit,
            cancelToken: cancelToken,
          );
    return ImprintListPage(
      count: dto.count,
      next: dto.next,
      previous: dto.previous,
      results: dto.results.map((e) => e.toEntity()).toList(),
      currentPage: page,
    );
  }

  Future<ImprintListPage> searchImprints(
    String query, {
    String? nextUrl,
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  }) async {
    final cachedDtos = await _localDataSource.getImprintSearchResults(
      query,
      page: page,
      limit: limit,
    );
    final cachedAt = await _localDataSource.getImprintSearchResultsCachedAt(
      query,
      page: page,
      limit: limit,
    );
    final cachedMeta = await _localDataSource.getImprintSearchResultsMeta(
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
                ? await _remoteDataSource.searchImprints(
                    query,
                    nextUrl: Uri.parse(nextUrl),
                    limit: limit,
                    cancelToken: cancelToken,
                  )
                : await _remoteDataSource.searchImprints(
                    query,
                    page: page,
                    limit: limit,
                    cancelToken: cancelToken,
                  );
            await _localDataSource.cacheImprintSearchResults(
              query,
              remotePage.results,
              page: page,
              limit: limit,
              count: remotePage.count,
              next: remotePage.next,
              previous: remotePage.previous,
            );
          },
          cacheKey: nextUrl ?? 'search:imprint:$query:$page',
          cooldown: MetronCachePolicies.universeSearchResults.refreshCooldown,
        );
      }
      if (cachedMeta != null) {
        return ImprintListPage(
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
          ? await _remoteDataSource.searchImprints(
              query,
              nextUrl: Uri.parse(nextUrl),
              limit: limit,
              cancelToken: cancelToken,
            )
          : await _remoteDataSource.searchImprints(
              query,
              page: page,
              limit: limit,
              cancelToken: cancelToken,
            );
      await _localDataSource.cacheImprintSearchResults(
        query,
        remotePage.results,
        page: page,
        limit: limit,
        count: remotePage.count,
        next: remotePage.next,
        previous: remotePage.previous,
      );
      return ImprintListPage(
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
        return ImprintListPage(
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

  Future<ImprintDetails> getImprintDetails(
    int imprintId, {
    bool forceRefresh = false,
  }) async {
    final cachedDto = await _localDataSource.getImprintDetails(imprintId);
    final cachedAt =
        await _localDataSource.getImprintDetailsCachedAt(imprintId);

    if (!forceRefresh && cachedDto != null) {
      final isFresh =
          cachedAt != null &&
          MetronCachePolicies.imprintDetails.isFresh(cachedAt, _now());
      if (!isFresh) {
        _refreshInBackground(
          task: () async {
            await _imprintDetailsGate.acquire();
            try {
              final remoteDto =
                  await _remoteDataSource.getImprintDetails(imprintId);
              await _localDataSource.cacheImprintDetails(remoteDto);
            } finally {
              _imprintDetailsGate.release();
            }
          },
          cacheKey: 'imprint_details:$imprintId',
          cooldown: MetronCachePolicies.imprintDetails.refreshCooldown,
        );
      }
      return cachedDto.toEntity();
    }

    try {
      await _imprintDetailsGate.acquire();
      try {
        final remoteDto =
            await _remoteDataSource.getImprintDetails(imprintId);
        await _localDataSource.cacheImprintDetails(remoteDto);
        return remoteDto.toEntity();
      } finally {
        _imprintDetailsGate.release();
      }
    } catch (e) {
      AppLogger.error('Failed to fetch imprint details', error: e);
      if (cachedDto != null) {
        return cachedDto.toEntity();
      }
      rethrow;
    }
  }
}
