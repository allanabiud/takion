part of 'metron_repository_impl.dart';

mixin _PublishersRepositoryMixin on _RepositoryState {

  Future<PublisherListPage> getPublisherList({
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  }) async {
    final dto = await _remoteDataSource.getPublisherList(
      page: page,
      limit: limit,
      cancelToken: cancelToken,
    );
    return PublisherListPage(
      count: dto.count,
      next: dto.next,
      previous: dto.previous,
      results: dto.results.map((e) => e.toEntity()).toList(),
      currentPage: page,
    );
  }

  Future<PublisherListPage> searchPublishers(
    String query, {
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  }) async {
    final cachedDtos = await _localDataSource.getPublisherSearchResults(
      query,
      page: page,
      limit: limit,
    );
    final cachedAt = await _localDataSource.getPublisherSearchResultsCachedAt(
      query,
      page: page,
      limit: limit,
    );
    final cachedMeta = await _localDataSource.getPublisherSearchResultsMeta(
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
            final remotePage = await _remoteDataSource.searchPublishers(
              query,
              page: page,
              limit: limit,
              cancelToken: cancelToken,
            );
            await _localDataSource.cachePublisherSearchResults(
              query,
              remotePage.results,
              page: page,
              limit: limit,
              count: remotePage.count,
              next: remotePage.next,
              previous: remotePage.previous,
            );
          },
          cacheKey: 'search:publisher:$query:$page',
          cooldown: MetronCachePolicies.universeSearchResults.refreshCooldown,
        );
      }
      if (cachedMeta != null) {
        return PublisherListPage(
          count: cachedMeta.count,
          next: cachedMeta.next,
          previous: cachedMeta.previous,
          results: cachedDtos.map((entry) => entry.toEntity()).toList(),
          currentPage: page,
        );
      }
    }

    try {
      final remotePage = await _remoteDataSource.searchPublishers(
        query,
        page: page,
        limit: limit,
        cancelToken: cancelToken,
      );
      await _localDataSource.cachePublisherSearchResults(
        query,
        remotePage.results,
        page: page,
        limit: limit,
        count: remotePage.count,
        next: remotePage.next,
        previous: remotePage.previous,
      );
      return PublisherListPage(
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
        return PublisherListPage(
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

  Future<PublisherDetails> getPublisherDetails(
    int publisherId, {
    bool forceRefresh = false,
  }) async {
    final cachedDto = await _localDataSource.getPublisherDetails(publisherId);
    final cachedAt =
        await _localDataSource.getPublisherDetailsCachedAt(publisherId);

    if (!forceRefresh && cachedDto != null) {
      final isFresh =
          cachedAt != null &&
          MetronCachePolicies.universeDetails.isFresh(cachedAt, _now());
      if (!isFresh) {
        _refreshInBackground(
          task: () async {
            await _publisherDetailsGate.acquire();
            try {
              final remoteDto =
                  await _remoteDataSource.getPublisherDetails(publisherId);
              await _localDataSource.cachePublisherDetails(remoteDto);
            } finally {
              _publisherDetailsGate.release();
            }
          },
          cacheKey: 'publisher_details:$publisherId',
          cooldown: MetronCachePolicies.universeDetails.refreshCooldown,
        );
      }
      return cachedDto.toEntity();
    }

    try {
      await _publisherDetailsGate.acquire();
      try {
        final remoteDto =
            await _remoteDataSource.getPublisherDetails(publisherId);
        await _localDataSource.cachePublisherDetails(remoteDto);
        return remoteDto.toEntity();
      } finally {
        _publisherDetailsGate.release();
      }
    } catch (_) {
      if (cachedDto != null) {
        return cachedDto.toEntity();
      }
      rethrow;
    }
  }

  Future<SeriesListPage> getPublisherSeriesList(
    int publisherId, {
    int page = 1,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  }) async {
    final cachedDtos = await _localDataSource.getPublisherSeriesListResults(
      publisherId,
      page: page,
      limit: metronDefaultPageSize,
    );
    final cachedAt =
        await _localDataSource.getPublisherSeriesListResultsCachedAt(
      publisherId,
      page: page,
      limit: metronDefaultPageSize,
    );
    final cachedMeta =
        await _localDataSource.getPublisherSeriesListResultsMeta(
      publisherId,
      page: page,
      limit: metronDefaultPageSize,
    );

    if (!forceRefresh && cachedDtos != null && cachedDtos.isNotEmpty) {
      final isFresh =
          cachedAt != null &&
          MetronCachePolicies.universeSearchResults.isFresh(cachedAt, _now());
      if (!isFresh) {
        _refreshInBackground(
          task: () async {
            final remotePage = await _remoteDataSource.getPublisherSeriesList(
              publisherId,
              page: page,
              cancelToken: cancelToken,
            );
            await _localDataSource.cachePublisherSeriesListResults(
              publisherId,
              remotePage.results,
              page: page,
              limit: metronDefaultPageSize,
              count: remotePage.count,
              next: remotePage.next,
              previous: remotePage.previous,
            );
          },
          cacheKey: 'publisher_series_list:$publisherId:$page',
          cooldown: MetronCachePolicies.universeSearchResults.refreshCooldown,
        );
      }
      if (cachedMeta != null) {
        return SeriesListPage(
          count: cachedMeta.count,
          next: cachedMeta.next,
          previous: cachedMeta.previous,
          results: cachedDtos.map((entry) => entry.toEntity()).toList(),
          currentPage: page,
        );
      }
    }

    try {
      final remotePage = await _remoteDataSource.getPublisherSeriesList(
        publisherId,
        page: page,
        cancelToken: cancelToken,
      );
      await _localDataSource.cachePublisherSeriesListResults(
        publisherId,
        remotePage.results,
        page: page,
        limit: metronDefaultPageSize,
        count: remotePage.count,
        next: remotePage.next,
        previous: remotePage.previous,
      );
      return SeriesListPage(
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
        return SeriesListPage(
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
