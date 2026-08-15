part of "metron_repository_impl.dart";

mixin _ImprintsRepositoryMixin on _RepositoryState {
  Future<ImprintListPage> getImprintList({
    String? nextUrl,
    int page = 1,
    int limit = metronDefaultPageSize,
    DateTime? modifiedGt,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  }) async {
    final cachedDtos = await _localDataSource.getImprintListResults(
      page: page,
      limit: limit,
      modifiedGt: modifiedGt,
    );
    final cachedAt = await _localDataSource.getImprintListResultsCachedAt(
      page: page,
      limit: limit,
      modifiedGt: modifiedGt,
    );
    final cachedMeta = await _localDataSource.getImprintListResultsMeta(
      page: page,
      limit: limit,
      modifiedGt: modifiedGt,
    );

    if (!forceRefresh && cachedDtos != null && cachedDtos.isNotEmpty) {
      final isFresh =
          cachedAt != null &&
          MetronCachePolicies.imprintList.isFresh(cachedAt, _now());
      if (!isFresh) {
        _refreshInBackground(
          task: () async {
            final remotePage = nextUrl != null
                ? await _remoteDataSource.getImprintList(
                    nextUrl: Uri.parse(nextUrl),
                    modifiedGt: modifiedGt,
                    cancelToken: cancelToken,
                  )
                : await _remoteDataSource.getImprintList(
                    page: page,
                    modifiedGt: modifiedGt,
                    cancelToken: cancelToken,
                  );
            await _localDataSource.cacheImprintListResults(
              remotePage.results,
              page: page,
              limit: limit,
              modifiedGt: modifiedGt,
              count: remotePage.count,
              next: remotePage.next,
              previous: remotePage.previous,
            );
          },
          cacheKey: 'imprint_list:${nextUrl ?? "$page"}|$modifiedGt',
          cooldown: MetronCachePolicies.imprintList.refreshCooldown,
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
      final key = '${nextUrl ?? "$page"}|$modifiedGt|$forceRefresh';
      return _coalesce(_imprintListInFlight, key, () async {
        final remotePage = nextUrl != null
            ? await _remoteDataSource.getImprintList(
                nextUrl: Uri.parse(nextUrl),
                modifiedGt: modifiedGt,
                cancelToken: cancelToken,
              )
            : await _remoteDataSource.getImprintList(
                page: page,
                modifiedGt: modifiedGt,
                cancelToken: cancelToken,
              );
        await _localDataSource.cacheImprintListResults(
          remotePage.results,
          page: page,
          limit: limit,
          modifiedGt: modifiedGt,
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
      }, timeout: const Duration(seconds: 30));
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
          MetronCachePolicies.imprintSearchResults.isFresh(cachedAt, _now());
      if (!isFresh) {
        _refreshInBackground(
          task: () async {
            final remotePage = nextUrl != null
                ? await _remoteDataSource.searchImprints(
                    query,
                    nextUrl: Uri.parse(nextUrl),
                    cancelToken: cancelToken,
                  )
                : await _remoteDataSource.searchImprints(
                    query,
                    page: page,
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
          cacheKey: nextUrl ?? "search:imprint:$query:$page",
          cooldown: MetronCachePolicies.imprintSearchResults.refreshCooldown,
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
      final key = nextUrl ?? "$query|$page|$limit|$forceRefresh";
      return _coalesce(_imprintSearchInFlight, key, () async {
        final remotePage = nextUrl != null
            ? await _remoteDataSource.searchImprints(
                query,
                nextUrl: Uri.parse(nextUrl),
                cancelToken: cancelToken,
              )
            : await _remoteDataSource.searchImprints(
                query,
                page: page,
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
      }, timeout: const Duration(seconds: 30));
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
      AppPerformanceMetrics.instance.recordCacheHit("imprint_details");
      return _imprintRowToEntity(cached);
    }

    final cachedJson =
        await _localDataSource.getCachedImprintDetailsResponse(imprintId);
    if (cachedJson != null && !forceRefresh) {
      final cachedAt =
          await _localDataSource.getCachedImprintDetailsCachedAt(imprintId);
      final now = _now();
      if (cachedAt != null &&
          MetronCachePolicies.imprintDetails.isFresh(cachedAt, now)) {
        AppPerformanceMetrics.instance.recordCacheHit(
          "imprint_details_response",
        );
        final dto = ImprintDetailsDto.fromJson(cachedJson);
        await _upsertImprintDetails(dto);
        return _imprintRowToEntity(
          await _metronEntityDao.getImprint(imprintId) ??
              (throw StateError("Imprint $imprintId not found after upsert")),
        );
      }
    }

    AppPerformanceMetrics.instance.recordCacheMiss("imprint_details");

    try {
      final response = await _remoteDataSource.getImprintDetails(imprintId);
      if (response.statusCode == 304) {
        final cachedJson =
            await _localDataSource.getCachedImprintDetailsResponse(imprintId);
        if (cachedJson != null) {
          await _localDataSource.cacheImprintDetailsResponse(
            imprintId,
            cachedJson,
          );
          final dto = ImprintDetailsDto.fromJson(cachedJson);
          await _upsertImprintDetails(dto);
          return _imprintRowToEntity(
            await _metronEntityDao.getImprint(imprintId) ??
                (throw StateError("Imprint $imprintId not found after upsert")),
          );
        }
        return _imprintRowToEntity(
          cached ?? (throw StateError("Imprint $imprintId not found")),
        );
      }
      final data = response.data as Map<String, dynamic>;
      final dto = ImprintDetailsDto.fromJson(data);
      if (!forceRefresh &&
          cached != null &&
          cached.isFullyHydrated &&
          cached.modified != null &&
          dto.modified != null &&
          cached.modified == dto.modified) {
        return _imprintRowToEntity(cached);
      }
      await _upsertImprintDetails(dto);
      await _localDataSource.cacheImprintDetailsResponse(imprintId, data);
      return _imprintRowToEntity(
        await _metronEntityDao.getImprint(imprintId) ??
            (throw StateError("Imprint $imprintId not found after upsert")),
      );
    } catch (e) {
      AppLogger.error("Failed to fetch imprint details", error: e);
      final cachedJson =
          await _localDataSource.getCachedImprintDetailsResponse(imprintId);
      if (cachedJson != null) {
        final dto = ImprintDetailsDto.fromJson(cachedJson);
        await _upsertImprintDetails(dto);
        return _imprintRowToEntity(
          await _metronEntityDao.getImprint(imprintId) ??
              (throw StateError("Imprint $imprintId not found after upsert")),
        );
      }
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
          ? ImprintNamedRef(id: row.publisherId!, name: "")
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
