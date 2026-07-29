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
        results: remotePage.results.map((entry) => entry.toEntity()).toList(),
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
    final cached = await _metronEntityDao.getCreator(creatorId);

    if (!forceRefresh && cached != null && cached.isFullyHydrated) {
      AppPerformanceMetrics.instance.recordCacheHit('creator_details');
      return _creatorRowToEntity(cached);
    }

    AppPerformanceMetrics.instance.recordCacheMiss('creator_details');

    try {
      final dto = await _remoteDataSource.getCreatorDetails(creatorId);
      if (cached != null &&
          cached.modified != null &&
          dto.modified != null &&
          cached.modified == dto.modified) {
        return _creatorRowToEntity(cached);
      }
      await _upsertCreatorDetails(dto);
      return _creatorRowToEntity(
        await _metronEntityDao.getCreator(creatorId) ??
            (throw StateError('Creator $creatorId not found after upsert')),
      );
    } catch (e) {
      AppLogger.error('Failed to fetch creator details', error: e);
      if (cached != null) {
        return _creatorRowToEntity(cached);
      }
      rethrow;
    }
  }

  Future<void> _upsertCreatorDetails(CreatorDetailsDto dto) async {
    await _metronEntityDao.upsertCreator(
      MetronCreatorsCompanion(
        id: Value(dto.id),
        name: Value(dto.name),
        imageUrl: Value(dto.image),
        description: Value(dto.desc),
        birth: Value(dto.birth),
        death: Value(dto.death),
        aliasJson: Value(dto.alias.isNotEmpty ? jsonEncode(dto.alias) : null),
        cvId: Value(dto.cvId),
        gcdId: Value(dto.gcdId),
        resourceUrl: Value(dto.resourceUrl),
        modified: Value(dto.modified),
        isFullyHydrated: const Value(true),
      ),
    );
  }

  CreatorDetails _creatorRowToEntity(MetronCreator row) {
    return CreatorDetails(
      id: row.id,
      name: row.name,
      birth: row.birth != null ? DateTime.tryParse(row.birth!) : null,
      death: row.death != null ? DateTime.tryParse(row.death!) : null,
      desc: row.description,
      image: row.imageUrl,
      alias: row.aliasJson != null
          ? (jsonDecode(row.aliasJson!) as List<dynamic>).cast<String>()
          : const [],
      cvId: row.cvId,
      gcdId: row.gcdId,
      resourceUrl: row.resourceUrl,
      modified: row.modified != null ? DateTime.tryParse(row.modified!) : null,
    );
  }
}
