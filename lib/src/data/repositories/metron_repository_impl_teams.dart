part of 'metron_repository_impl.dart';

mixin _TeamsRepositoryMixin on _RepositoryState {

  Future<TeamListPage> getTeamList({
    String? nextUrl,
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  }) async {
    final dto = nextUrl != null
        ? await _remoteDataSource.getTeamList(
            nextUrl: Uri.parse(nextUrl),
            limit: limit,
            cancelToken: cancelToken,
          )
        : await _remoteDataSource.getTeamList(
            page: page,
            limit: limit,
            cancelToken: cancelToken,
          );
    return TeamListPage(
      count: dto.count,
      next: dto.next,
      previous: dto.previous,
      results: dto.results.map((e) => e.toEntity()).toList(),
      currentPage: page,
    );
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
                    limit: limit,
                    cancelToken: cancelToken,
                  )
                : await _remoteDataSource.searchTeams(
                    query,
                    page: page,
                    limit: limit,
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
          cacheKey: nextUrl ?? 'search:team:$query:$page',
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
      final remotePage = nextUrl != null
          ? await _remoteDataSource.searchTeams(
              query,
              nextUrl: Uri.parse(nextUrl),
              limit: limit,
              cancelToken: cancelToken,
            )
          : await _remoteDataSource.searchTeams(
              query,
              page: page,
              limit: limit,
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
    final cachedDto = await _localDataSource.getTeamDetails(teamId);
    final cachedAt =
        await _localDataSource.getTeamDetailsCachedAt(teamId);

    if (!forceRefresh && cachedDto != null) {
      final isFresh =
          cachedAt != null &&
          MetronCachePolicies.teamDetails.isFresh(cachedAt, _now());
      if (!isFresh) {
        _refreshInBackground(
          task: () async {
            await _teamDetailsGate.acquire();
            try {
              final remoteDto =
                  await _remoteDataSource.getTeamDetails(teamId);
              await _localDataSource.cacheTeamDetails(remoteDto);
            } finally {
              _teamDetailsGate.release();
            }
          },
          cacheKey: 'team_details:$teamId',
          cooldown: MetronCachePolicies.teamDetails.refreshCooldown,
        );
      }
      return cachedDto.toEntity();
    }

    try {
      await _teamDetailsGate.acquire();
      try {
        final remoteDto =
            await _remoteDataSource.getTeamDetails(teamId);
        await _localDataSource.cacheTeamDetails(remoteDto);
        return remoteDto.toEntity();
      } finally {
        _teamDetailsGate.release();
      }
    } catch (e) {
      AppLogger.error('Failed to fetch team details', error: e);
      if (cachedDto != null) {
        return cachedDto.toEntity();
      }
      rethrow;
    }
  }
}
