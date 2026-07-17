part of 'metron_repository_impl.dart';

mixin _CreatorsRepositoryMixin on _RepositoryState {

  Future<CreatorListPage> getCreatorList({
    String? nextUrl,
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  }) async {
    final dto = nextUrl != null
        ? await _remoteDataSource.getCreatorList(
            nextUrl: Uri.parse(nextUrl),
            limit: limit,
            cancelToken: cancelToken,
          )
        : await _remoteDataSource.getCreatorList(
            page: page,
            limit: limit,
            cancelToken: cancelToken,
          );
    return CreatorListPage(
      count: dto.count,
      next: dto.next,
      previous: dto.previous,
      results: dto.results.map((e) => e.toEntity()).toList(),
      currentPage: page,
    );
  }

  Future<CreatorListPage> searchCreators(
    String query, {
    String? nextUrl,
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  }) async {
    final cachedDtos = await _localDataSource.getCreatorSearchResults(
      query,
      page: page,
      limit: limit,
    );
    final cachedAt = await _localDataSource.getCreatorSearchResultsCachedAt(
      query,
      page: page,
      limit: limit,
    );
    final cachedMeta = await _localDataSource.getCreatorSearchResultsMeta(
      query,
      page: page,
      limit: limit,
    );

    if (!forceRefresh && cachedDtos != null && cachedDtos.isNotEmpty) {
      final isFresh =
          cachedAt != null &&
          MetronCachePolicies.creatorSearchResults.isFresh(cachedAt, _now());
      if (!isFresh) {
        _refreshInBackground(
          task: () async {
            final remotePage = nextUrl != null
                ? await _remoteDataSource.searchCreators(
                    query,
                    nextUrl: Uri.parse(nextUrl),
                    limit: limit,
                    cancelToken: cancelToken,
                  )
                : await _remoteDataSource.searchCreators(
                    query,
                    page: page,
                    limit: limit,
                    cancelToken: cancelToken,
                  );
            await _localDataSource.cacheCreatorSearchResults(
              query,
              remotePage.results,
              page: page,
              limit: limit,
              count: remotePage.count,
              next: remotePage.next,
              previous: remotePage.previous,
            );
          },
          cacheKey: nextUrl ?? 'search:creator:$query:$page',
          cooldown: MetronCachePolicies.creatorSearchResults.refreshCooldown,
        );
      }
      if (cachedMeta != null) {
        return CreatorListPage(
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
          ? await _remoteDataSource.searchCreators(
              query,
              nextUrl: Uri.parse(nextUrl),
              limit: limit,
              cancelToken: cancelToken,
            )
          : await _remoteDataSource.searchCreators(
              query,
              page: page,
              limit: limit,
              cancelToken: cancelToken,
            );
      await _localDataSource.cacheCreatorSearchResults(
        query,
        remotePage.results,
        page: page,
        limit: limit,
        count: remotePage.count,
        next: remotePage.next,
        previous: remotePage.previous,
      );
      return CreatorListPage(
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
        return CreatorListPage(
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

  Future<CreatorDetails> getCreatorDetails(
    int creatorId, {
    bool forceRefresh = false,
  }) async {
    final cachedDto = await _localDataSource.getCreatorDetails(creatorId);
    final cachedAt =
        await _localDataSource.getCreatorDetailsCachedAt(creatorId);

    if (!forceRefresh && cachedDto != null) {
      final isFresh =
          cachedAt != null &&
          MetronCachePolicies.creatorDetails.isFresh(cachedAt, _now());
      if (!isFresh) {
        _refreshInBackground(
          task: () async {
            await _creatorDetailsGate.acquire();
            try {
              final remoteDto =
                  await _remoteDataSource.getCreatorDetails(creatorId);
              await _localDataSource.cacheCreatorDetails(remoteDto);
            } finally {
              _creatorDetailsGate.release();
            }
          },
          cacheKey: 'creator_details:$creatorId',
          cooldown: MetronCachePolicies.creatorDetails.refreshCooldown,
        );
      }
      return cachedDto.toEntity();
    }

    try {
      await _creatorDetailsGate.acquire();
      try {
        final remoteDto =
            await _remoteDataSource.getCreatorDetails(creatorId);
        await _localDataSource.cacheCreatorDetails(remoteDto);
        return remoteDto.toEntity();
      } finally {
        _creatorDetailsGate.release();
      }
    } catch (e) {
      AppLogger.error('Failed to fetch creator details', error: e);
      if (cachedDto != null) {
        return cachedDto.toEntity();
      }
      rethrow;
    }
  }
}
