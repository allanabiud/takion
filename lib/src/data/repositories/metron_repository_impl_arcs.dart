part of 'metron_repository_impl.dart';

mixin _ArcsRepositoryMixin on _RepositoryState {

  Future<ArcListPage> getArcList({
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  }) async {
    final dto = await _remoteDataSource.getArcList(
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
            final remotePage = await _remoteDataSource.searchArcs(
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
          cacheKey: 'search:arc:$query:$page',
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
      final key = '$query|$page|$limit|$forceRefresh';
      return _coalesce(_arcSearchInFlight, key, () async {
        final remotePage = await _remoteDataSource.searchArcs(
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
    final cachedDto = await _localDataSource.getArcDetails(arcId);
    final cachedAt =
        await _localDataSource.getArcDetailsCachedAt(arcId);

    if (!forceRefresh && cachedDto != null) {
      final isFresh =
          cachedAt != null &&
          MetronCachePolicies.arcDetails.isFresh(cachedAt, _now());
      if (!isFresh) {
        _refreshInBackground(
          task: () async {
            await _arcDetailsGate.acquire();
            try {
              final remoteDto =
                  await _remoteDataSource.getArcDetails(arcId);
              await _localDataSource.cacheArcDetails(remoteDto);
            } finally {
              _arcDetailsGate.release();
            }
          },
          cacheKey: 'arc_details:$arcId',
          cooldown: MetronCachePolicies.arcDetails.refreshCooldown,
        );
      }
      return cachedDto.toEntity();
    }

    try {
      await _arcDetailsGate.acquire();
      try {
        final remoteDto =
            await _remoteDataSource.getArcDetails(arcId);
        await _localDataSource.cacheArcDetails(remoteDto);
        return remoteDto.toEntity();
      } finally {
        _arcDetailsGate.release();
      }
    } catch (_) {
      if (cachedDto != null) {
        return cachedDto.toEntity();
      }
      rethrow;
    }
  }

  Future<ArcIssueListPage> getArcIssueList(
    int arcId, {
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
    final cachedAt =
        await _localDataSource.getArcIssueListResultsCachedAt(
      arcId,
      page: page,
      limit: limit,
    );
    final cachedMeta =
        await _localDataSource.getArcIssueListResultsMeta(
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
            final remotePage = await _remoteDataSource.getArcIssueList(
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
          cacheKey: 'arc_issue_list:$arcId:$page',
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
      final key = '$arcId|$page|$forceRefresh';
      return _coalesce(_arcIssueListInFlight, key, () async {
        final remotePage = await _remoteDataSource.getArcIssueList(
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
          results:
              remotePage.results.map((entry) => entry.toEntity()).toList(),
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
}
