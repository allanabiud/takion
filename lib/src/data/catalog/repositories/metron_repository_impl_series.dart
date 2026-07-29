part of 'metron_repository_impl.dart';

mixin _SeriesRepositoryMixin on _RepositoryState {
  Future<SeriesSearchPage> searchSeries(
    String query, {
    String? nextUrl,
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  }) async {
    final cachedDtos = await _localDataSource.getSeriesSearchResults(
      query,
      page: page,
      limit: limit,
    );
    final cachedAt = await _localDataSource.getSeriesSearchResultsCachedAt(
      query,
      page: page,
      limit: limit,
    );
    final cachedMeta = await _localDataSource.getSeriesSearchResultsMeta(
      query,
      page: page,
      limit: limit,
    );

    if (!forceRefresh && cachedDtos != null && cachedDtos.isNotEmpty) {
      final isFresh =
          cachedAt != null &&
          MetronCachePolicies.searchResults.isFresh(cachedAt, _now());
      if (!isFresh) {
        _refreshInBackground(
          task: () async {
            final corrected = await _correctSearchQuery(query);
            final remotePage = nextUrl != null
                ? await _remoteDataSource.searchSeries(
                    corrected,
                    nextUrl: Uri.parse(nextUrl),
                    limit: limit,
                    cancelToken: cancelToken,
                  )
                : await _remoteDataSource.searchSeries(
                    corrected,
                    page: page,
                    limit: limit,
                    cancelToken: cancelToken,
                  );
            await _localDataSource.cacheSeriesSearchResults(
              query,
              remotePage.results,
              page: page,
              limit: limit,
              count: remotePage.count,
              next: remotePage.next,
              previous: remotePage.previous,
            );
            _upsertSeriesListStubs(remotePage.results);
            for (final dto in remotePage.results) {
              if (dto.series.trim().isNotEmpty) _indexSeriesName(dto.series);
            }
          },
          cacheKey: 'search:series:$query:${nextUrl ?? "$page"}',
          cooldown: MetronCachePolicies.searchResults.refreshCooldown,
        );
      }
      if (cachedMeta != null) {
        return SeriesSearchPage(
          count: cachedMeta.count,
          next: cachedMeta.next,
          previous: cachedMeta.previous,
          results: cachedDtos.map((entry) => entry.toEntity()).toList(),
          currentPage: page,
        );
      }
    }

    try {
      final corrected = await _correctSearchQuery(query);
      final remotePage = nextUrl != null
          ? await _remoteDataSource.searchSeries(
              corrected,
              nextUrl: Uri.parse(nextUrl),
              limit: limit,
              cancelToken: cancelToken,
            )
          : await _remoteDataSource.searchSeries(
              corrected,
              page: page,
              limit: limit,
              cancelToken: cancelToken,
            );
      await _localDataSource.cacheSeriesSearchResults(
        query,
        remotePage.results,
        page: page,
        limit: limit,
        count: remotePage.count,
        next: remotePage.next,
        previous: remotePage.previous,
      );
      _upsertSeriesListStubs(remotePage.results);
      for (final dto in remotePage.results) {
        if (dto.series.trim().isNotEmpty) _indexSeriesName(dto.series);
      }
      return SeriesSearchPage(
        count: remotePage.count,
        next: remotePage.next,
        previous: remotePage.previous,
        results: remotePage.results.map((entry) => entry.toEntity()).toList(),
        currentPage: page,
      );
    } catch (error) {
      if (_isCancelled(error)) rethrow;
      if (cachedDtos != null && cachedDtos.isNotEmpty && cachedMeta != null) {
        return SeriesSearchPage(
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

  Future<SeriesListPage> getSeriesList({
    String? nextUrl,
    int page = 1,
    bool forceRefresh = false,
    int limit = metronDefaultPageSize,
    DateTime? modifiedGt,
    CancelToken? cancelToken,
  }) async {
    final cachedDtos = await _localDataSource.getSeriesListResults(
      page: page,
      limit: limit,
      modifiedGt: modifiedGt,
    );
    final cachedAt = await _localDataSource.getSeriesListResultsCachedAt(
      page: page,
      limit: limit,
      modifiedGt: modifiedGt,
    );
    final cachedMeta = await _localDataSource.getSeriesListResultsMeta(
      page: page,
      limit: limit,
      modifiedGt: modifiedGt,
    );

    if (!forceRefresh && cachedDtos != null && cachedDtos.isNotEmpty) {
      final isFresh =
          cachedAt != null &&
          MetronCachePolicies.searchResults.isFresh(cachedAt, _now());
      if (!isFresh) {
        _refreshInBackground(
          task: () async {
            final remotePage = nextUrl != null
                ? await _remoteDataSource.getSeriesList(
                    nextUrl: Uri.parse(nextUrl),
                    limit: limit,
                    modifiedGt: modifiedGt,
                    cancelToken: cancelToken,
                  )
                : await _remoteDataSource.getSeriesList(
                    page: page,
                    limit: limit,
                    modifiedGt: modifiedGt,
                    cancelToken: cancelToken,
                  );
            await _localDataSource.cacheSeriesListResults(
              remotePage.results,
              page: page,
              limit: limit,
              modifiedGt: modifiedGt,
              count: remotePage.count,
              next: remotePage.next,
              previous: remotePage.previous,
            );
            _upsertSeriesListStubs(remotePage.results);
          },
          cacheKey: 'series_list:${nextUrl ?? "$page"}|$modifiedGt',
          cooldown: MetronCachePolicies.searchResults.refreshCooldown,
        );
      }
      if (cachedMeta != null) {
        AppPerformanceMetrics.instance.recordCacheHit('series_list');
        return SeriesListPage(
          count: cachedMeta.count,
          next: cachedMeta.next,
          previous: cachedMeta.previous,
          results: cachedDtos.map((entry) => entry.toEntity()).toList(),
          currentPage: page,
        );
      }
    }
    AppPerformanceMetrics.instance.recordCacheMiss('series_list');

    try {
      final key = '${nextUrl ?? "$page"}|$modifiedGt|$forceRefresh';
      return _coalesce(_seriesListInFlight, key, () async {
        final remotePage = nextUrl != null
            ? await _remoteDataSource.getSeriesList(
                nextUrl: Uri.parse(nextUrl),
                limit: limit,
                modifiedGt: modifiedGt,
                cancelToken: cancelToken,
              )
            : await _remoteDataSource.getSeriesList(
                page: page,
                limit: limit,
                modifiedGt: modifiedGt,
                cancelToken: cancelToken,
              );
        await _localDataSource.cacheSeriesListResults(
          remotePage.results,
          page: page,
          limit: limit,
          modifiedGt: modifiedGt,
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
      }, timeout: const Duration(seconds: 30));
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

  Future<SeriesDetails> getSeriesDetails(
    int seriesId, {
    bool forceRefresh = false,
  }) async {
    final cached = await _metronEntityDao.getSeries(seriesId);

    if (!forceRefresh && cached != null && cached.isFullyHydrated) {
      AppPerformanceMetrics.instance.recordCacheHit('series_details');
      return _seriesRowToEntity(cached);
    }

    final cachedJson = await _localDataSource.getCachedSeriesDetailsResponse(
      seriesId,
    );
    if (cachedJson != null && !forceRefresh) {
      final cachedAt = await _localDataSource.getCachedSeriesDetailsCachedAt(
        seriesId,
      );
      final now = _now();
      if (cachedAt != null &&
          MetronCachePolicies.seriesDetails.isFresh(cachedAt, now)) {
        AppPerformanceMetrics.instance.recordCacheHit(
          'series_details_response',
        );
        final dto = SeriesDetailsDto.fromJson(cachedJson);
        await _upsertSeriesDetails(dto);
        _indexSeriesName(dto.name);
        return dto.toEntity();
      }
    }

    AppPerformanceMetrics.instance.recordCacheMiss('series_details');

    try {
      final key = '$seriesId|$forceRefresh';
      return _coalesce(_seriesDetailsInFlight, key, () async {
        final response = await _remoteDataSource.getSeriesDetails(seriesId);
        if (response.statusCode == 304) {
          final cachedJson = await _localDataSource
              .getCachedSeriesDetailsResponse(seriesId);
          if (cachedJson != null) {
            await _localDataSource.cacheSeriesDetailsResponse(
              seriesId,
              cachedJson,
            );
            final dto = SeriesDetailsDto.fromJson(cachedJson);
            await _upsertSeriesDetails(dto);
            _indexSeriesName(dto.name);
            return dto.toEntity();
          }
          if (cached != null) {
            return _seriesRowToEntity(cached);
          }
          throw DioException(
            requestOptions: response.requestOptions,
            response: response,
            message: '304 Not Modified and no cached data available',
          );
        }
        final data = response.data as Map<String, dynamic>;
        final dto = SeriesDetailsDto.fromJson(data);
        if (cached != null &&
            cached.modified != null &&
            dto.modified != null &&
            cached.modified == dto.modified) {
          return _seriesRowToEntity(cached);
        }
        await _upsertSeriesDetails(dto);
        await _localDataSource.cacheSeriesDetailsResponse(seriesId, data);
        _indexSeriesName(dto.name);
        return dto.toEntity();
      }, timeout: const Duration(seconds: 30));
    } catch (e) {
      final cachedJson = await _localDataSource.getCachedSeriesDetailsResponse(
        seriesId,
      );
      if (cachedJson != null) {
        final dto = SeriesDetailsDto.fromJson(cachedJson);
        if (cached != null &&
            cached.modified != null &&
            dto.modified != null &&
            cached.modified == dto.modified) {
          return _seriesRowToEntity(cached);
        }
        await _upsertSeriesDetails(dto);
        _indexSeriesName(dto.name);
        return dto.toEntity();
      }
      if (cached != null) {
        return _seriesRowToEntity(cached);
      }
      AppLogger.error('Failed to fetch series details', error: e);
      rethrow;
    }
  }

  Future<SeriesIssueListPage> getSeriesIssueList(
    int seriesId, {
    String? nextUrl,
    int page = 1,
    int limit = metronDefaultPageSize,
    String? ordering,
    DateTime? storeDateGte,
    DateTime? storeDateLte,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  }) async {
    final hasFilters =
        ordering != null || storeDateGte != null || storeDateLte != null;

    if (!forceRefresh && !hasFilters) {
      final cachedDtos = await _localDataSource.getSeriesIssueListResults(
        seriesId,
        page: page,
        limit: limit,
      );
      final cachedAt = await _localDataSource.getSeriesIssueListResultsCachedAt(
        seriesId,
        page: page,
        limit: limit,
      );
      final cachedMeta = await _localDataSource.getSeriesIssueListResultsMeta(
        seriesId,
        page: page,
        limit: limit,
      );

      if (cachedDtos != null && cachedDtos.isNotEmpty) {
        final isFresh =
            cachedAt != null &&
            MetronCachePolicies.seriesIssueList.isFresh(cachedAt, _now());
        if (!isFresh) {
          _refreshInBackground(
            task: () async {
              final remotePage = nextUrl != null
                  ? await _remoteDataSource.getSeriesIssueList(
                      seriesId,
                      nextUrl: Uri.parse(nextUrl),
                      limit: limit,
                      cancelToken: cancelToken,
                    )
                  : await _remoteDataSource.getSeriesIssueList(
                      seriesId,
                      page: page,
                      limit: limit,
                      cancelToken: cancelToken,
                    );
              await _localDataSource.cacheSeriesIssueListResults(
                seriesId,
                remotePage.results,
                page: page,
                limit: limit,
                count: remotePage.count,
                next: remotePage.next,
                previous: remotePage.previous,
              );
              _upsertIssueListStubs(remotePage.results);
              _indexSeriesNamesFromIssueList(remotePage.results);
            },
            cacheKey: 'series_issue_list:$seriesId:${nextUrl ?? "$page"}',
            cooldown: MetronCachePolicies.seriesIssueList.refreshCooldown,
          );
        }
        if (cachedMeta != null) {
          return SeriesIssueListPage(
            count: cachedMeta.count,
            next: cachedMeta.next,
            previous: cachedMeta.previous,
            results: cachedDtos.map((entry) => entry.toEntity()).toList(),
            currentPage: page,
          );
        }
      }
    }

    try {
      final key =
          '$seriesId|${nextUrl ?? "$page"}|$forceRefresh|$ordering|${storeDateGte?.millisecondsSinceEpoch}|${storeDateLte?.millisecondsSinceEpoch}';
      return _coalesce(_seriesIssueListInFlight, key, () async {
        final remotePage = nextUrl != null
            ? await _remoteDataSource.getSeriesIssueList(
                seriesId,
                nextUrl: Uri.parse(nextUrl),
                limit: limit,
                ordering: ordering,
                storeDateGte: storeDateGte,
                storeDateLte: storeDateLte,
                cancelToken: cancelToken,
              )
            : await _remoteDataSource.getSeriesIssueList(
                seriesId,
                page: page,
                limit: limit,
                ordering: ordering,
                storeDateGte: storeDateGte,
                storeDateLte: storeDateLte,
                cancelToken: cancelToken,
              );
        if (!hasFilters) {
          await _localDataSource.cacheSeriesIssueListResults(
            seriesId,
            remotePage.results,
            page: page,
            limit: limit,
            count: remotePage.count,
            next: remotePage.next,
            previous: remotePage.previous,
          );
          _upsertIssueListStubs(remotePage.results);
          _indexSeriesNamesFromIssueList(remotePage.results);
        }
        return SeriesIssueListPage(
          count: remotePage.count,
          next: remotePage.next,
          previous: remotePage.previous,
          results: remotePage.results.map((entry) => entry.toEntity()).toList(),
          currentPage: page,
        );
      }, timeout: const Duration(seconds: 30));
    } catch (error) {
      if (_isCancelled(error)) rethrow;
      if (!hasFilters) {
        final cachedDtos = await _localDataSource.getSeriesIssueListResults(
          seriesId,
          page: page,
          limit: limit,
        );
        final cachedMeta = await _localDataSource.getSeriesIssueListResultsMeta(
          seriesId,
          page: page,
          limit: limit,
        );
        if (cachedDtos != null && cachedDtos.isNotEmpty && cachedMeta != null) {
          return SeriesIssueListPage(
            count: cachedMeta.count,
            next: cachedMeta.next,
            previous: cachedMeta.previous,
            results: cachedDtos.map((entry) => entry.toEntity()).toList(),
            currentPage: page,
          );
        }
      }
      rethrow;
    }
  }

  Future<void> _upsertSeriesDetails(SeriesDetailsDto dto) async {
    final coverUrl = await _metronEntityDao.computeSeriesCoverUrl(dto.id);
    if (dto.publisher != null) {
      await _metronEntityDao.upsertPublisher(
        MetronPublishersCompanion(
          id: Value(dto.publisher!.id),
          name: Value(dto.publisher!.name),
          isFullyHydrated: const Value(false),
        ),
      );
    }
    if (dto.imprint != null) {
      await _metronEntityDao.upsertImprint(
        MetronImprintsCompanion(
          id: Value(dto.imprint!.id),
          name: Value(dto.imprint!.name),
          isFullyHydrated: const Value(false),
        ),
      );
    }
    await _metronEntityDao.upsertSeries(
      MetronSeriesCompanion(
        id: Value(dto.id),
        name: Value(dto.name),
        sortName: Value(dto.sortName),
        volume: Value(dto.volume),
        seriesTypeId: Value(dto.seriesType?.id),
        status: Value(dto.status),
        publisherId: Value(dto.publisher?.id),
        imprintId: Value(dto.imprint?.id),
        yearBegan: Value(dto.yearBegan),
        yearEnd: Value(dto.yearEnd),
        description: Value(dto.description),
        issueCount: Value(dto.issueCount),
        computedCoverUrl: Value(coverUrl),
        cvId: Value(dto.cvId),
        gcdId: Value(dto.gcdId),
        resourceUrl: Value(dto.resourceUrl),
        modified: Value(dto.modified),
        isFullyHydrated: const Value(true),
      ),
    );

    for (final associated in dto.associated) {
      await _metronEntityDao.upsertSeries(
        MetronSeriesCompanion(
          id: Value(associated.id),
          name: Value(associated.series),
          isFullyHydrated: const Value(false),
        ),
      );
      await _junctionDao.insertIgnoreAssociatedSeries(
        AssociatedSeriesCompanion(
          seriesId: Value(dto.id),
          associatedSeriesId: Value(associated.id),
        ),
      );
    }
  }

  Future<SeriesDetails> _seriesRowToEntity(MetronSery row) async {
    SeriesDetailsNamedRef? publisher;
    if (row.publisherId != null) {
      final p = await _metronEntityDao.getPublisher(row.publisherId!);
      if (p != null) {
        publisher = SeriesDetailsNamedRef(id: p.id, name: p.name);
      }
    }

    return SeriesDetails(
      id: row.id,
      name: row.name,
      sortName: row.sortName,
      volume: row.volume,
      status: row.status,
      yearBegan: row.yearBegan,
      yearEnd: row.yearEnd,
      description: row.description,
      issueCount: row.issueCount,
      image: row.computedCoverUrl,
      publisher: publisher,
      cvId: row.cvId,
      gcdId: row.gcdId,
      resourceUrl: row.resourceUrl,
      modified: row.modified != null ? DateTime.tryParse(row.modified!) : null,
    );
  }
}
