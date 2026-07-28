part of 'metron_repository_impl.dart';

mixin _PublishersRepositoryMixin on _RepositoryState {
  Future<PublisherListPage> getPublisherList({
    String? nextUrl,
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  }) async {
    final dto = nextUrl != null
        ? await _remoteDataSource.getPublisherList(
            nextUrl: Uri.parse(nextUrl),
            limit: limit,
            cancelToken: cancelToken,
          )
        : await _remoteDataSource.getPublisherList(
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
    String? nextUrl,
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
            final remotePage = nextUrl != null
                ? await _remoteDataSource.searchPublishers(
                    query,
                    nextUrl: Uri.parse(nextUrl),
                    limit: limit,
                    cancelToken: cancelToken,
                  )
                : await _remoteDataSource.searchPublishers(
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
          cacheKey: nextUrl ?? 'search:publisher:$query:$page',
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
      final remotePage = nextUrl != null
          ? await _remoteDataSource.searchPublishers(
              query,
              nextUrl: Uri.parse(nextUrl),
              limit: limit,
              cancelToken: cancelToken,
            )
          : await _remoteDataSource.searchPublishers(
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
        results: remotePage.results.map((entry) => entry.toEntity()).toList(),
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
    final cached = await _metronEntityDao.getPublisher(publisherId);

    if (!forceRefresh && cached != null && cached.isFullyHydrated) {
      AppPerformanceMetrics.instance.recordCacheHit('publisher_details');
      return _publisherRowToEntity(cached);
    }

    AppPerformanceMetrics.instance.recordCacheMiss('publisher_details');

    try {
      final dto = await _remoteDataSource.getPublisherDetails(publisherId);
      await _upsertPublisherDetails(dto);
      return _publisherRowToEntity(
        await _metronEntityDao.getPublisher(publisherId) ??
            (throw StateError('Publisher $publisherId not found after upsert')),
      );
    } catch (e) {
      AppLogger.error('Failed to fetch publisher details', error: e);
      if (cached != null) {
        return _publisherRowToEntity(cached);
      }
      rethrow;
    }
  }

  Future<SeriesListPage> getPublisherSeriesList(
    int publisherId, {
    String? nextUrl,
    int page = 1,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  }) async {
    final cachedDtos = await _localDataSource.getPublisherSeriesListResults(
      publisherId,
      page: page,
      limit: metronDefaultPageSize,
    );
    final cachedAt = await _localDataSource
        .getPublisherSeriesListResultsCachedAt(
          publisherId,
          page: page,
          limit: metronDefaultPageSize,
        );
    final cachedMeta = await _localDataSource.getPublisherSeriesListResultsMeta(
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
            final remotePage = nextUrl != null
                ? await _remoteDataSource.getPublisherSeriesList(
                    publisherId,
                    nextUrl: Uri.parse(nextUrl),
                    cancelToken: cancelToken,
                  )
                : await _remoteDataSource.getPublisherSeriesList(
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
            _upsertSeriesListStubs(remotePage.results);
          },
          cacheKey: nextUrl ?? 'publisher_series_list:$publisherId:$page',
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
      final remotePage = nextUrl != null
          ? await _remoteDataSource.getPublisherSeriesList(
              publisherId,
              nextUrl: Uri.parse(nextUrl),
              cancelToken: cancelToken,
            )
          : await _remoteDataSource.getPublisherSeriesList(
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
      _upsertSeriesListStubs(remotePage.results);
      return SeriesListPage(
        count: remotePage.count,
        next: remotePage.next,
        previous: remotePage.previous,
        results: remotePage.results.map((entry) => entry.toEntity()).toList(),
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

  Future<void> _upsertPublisherDetails(PublisherDetailsDto dto) async {
    await _metronEntityDao.upsertPublisher(
      MetronPublishersCompanion(
        id: Value(dto.id),
        name: Value(dto.name),
        imageUrl: Value(dto.image),
        description: Value(dto.desc),
        country: Value(dto.country),
        founded: Value(dto.founded),
        cvId: Value(dto.cvId),
        gcdId: Value(dto.gcdId),
        resourceUrl: Value(dto.resourceUrl),
        modified: Value(dto.modified),
        isFullyHydrated: const Value(true),
      ),
    );
  }

  PublisherDetails _publisherRowToEntity(MetronPublisher row) {
    return PublisherDetails(
      id: row.id,
      name: row.name,
      founded: row.founded,
      country: row.country,
      desc: row.description,
      image: row.imageUrl,
      cvId: row.cvId,
      gcdId: row.gcdId,
      resourceUrl: row.resourceUrl,
      modified: row.modified != null ? DateTime.tryParse(row.modified!) : null,
    );
  }
}
