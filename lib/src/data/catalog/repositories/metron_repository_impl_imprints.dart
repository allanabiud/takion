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
        results: remotePage.results.map((entry) => entry.toEntity()).toList(),
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
    final cached = await _metronEntityDao.getImprint(imprintId);

    if (!forceRefresh && cached != null && cached.isFullyHydrated) {
      AppPerformanceMetrics.instance.recordCacheHit('imprint_details');
      return _imprintRowToEntity(cached);
    }

    AppPerformanceMetrics.instance.recordCacheMiss('imprint_details');

    try {
      final dto = await _remoteDataSource.getImprintDetails(imprintId);
      if (cached != null &&
          cached.modified != null &&
          dto.modified != null &&
          cached.modified == dto.modified) {
        return _imprintRowToEntity(cached);
      }
      await _upsertImprintDetails(dto);
      return _imprintRowToEntity(
        await _metronEntityDao.getImprint(imprintId) ??
            (throw StateError('Imprint $imprintId not found after upsert')),
      );
    } catch (e) {
      AppLogger.error('Failed to fetch imprint details', error: e);
      if (cached != null) {
        return _imprintRowToEntity(cached);
      }
      rethrow;
    }
  }

  Future<void> _upsertImprintDetails(ImprintDetailsDto dto) async {
    if (dto.publisher != null) {
      await _metronEntityDao.upsertPublisher(
        MetronPublishersCompanion(
          id: Value(dto.publisher!.id),
          name: Value(dto.publisher!.name),
          isFullyHydrated: const Value(false),
        ),
      );
    }
    await _metronEntityDao.upsertImprint(
      MetronImprintsCompanion(
        id: Value(dto.id),
        name: Value(dto.name),
        publisherId: Value(dto.publisher?.id),
        imageUrl: Value(dto.image),
        description: Value(dto.desc),
        founded: Value(dto.founded),
        cvId: Value(dto.cvId),
        gcdId: Value(dto.gcdId),
        resourceUrl: Value(dto.resourceUrl),
        modified: Value(dto.modified),
        isFullyHydrated: const Value(true),
      ),
    );
  }

  ImprintDetails _imprintRowToEntity(MetronImprint row) {
    return ImprintDetails(
      id: row.id,
      name: row.name,
      publisher: row.publisherId != null
          ? ImprintNamedRef(id: row.publisherId!, name: '')
          : null,
      founded: row.founded,
      desc: row.description,
      image: row.imageUrl,
      cvId: row.cvId,
      gcdId: row.gcdId,
      resourceUrl: row.resourceUrl,
      modified: row.modified != null ? DateTime.tryParse(row.modified!) : null,
    );
  }
}
