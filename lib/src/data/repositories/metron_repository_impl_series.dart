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
    CancelToken? cancelToken,
  }) async {
    final cachedDtos = await _localDataSource.getSeriesListResults(
      page: page,
      limit: limit,
    );
    final cachedAt = await _localDataSource.getSeriesListResultsCachedAt(
      page: page,
      limit: limit,
    );
    final cachedMeta = await _localDataSource.getSeriesListResultsMeta(
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
            final remotePage = nextUrl != null
                ? await _remoteDataSource.getSeriesList(
                    nextUrl: Uri.parse(nextUrl),
                    limit: limit,
                    cancelToken: cancelToken,
                  )
                : await _remoteDataSource.getSeriesList(
                    page: page,
                    limit: limit,
                    cancelToken: cancelToken,
                  );
            await _localDataSource.cacheSeriesListResults(
              remotePage.results,
              page: page,
              limit: limit,
              count: remotePage.count,
              next: remotePage.next,
              previous: remotePage.previous,
            );
          },
          cacheKey: 'series_list:${nextUrl ?? "$page"}',
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
      final key = '${nextUrl ?? "$page"}|$forceRefresh';
      return _coalesce(_seriesListInFlight, key, () async {
        final remotePage = nextUrl != null
            ? await _remoteDataSource.getSeriesList(
                nextUrl: Uri.parse(nextUrl),
                limit: limit,
                cancelToken: cancelToken,
              )
            : await _remoteDataSource.getSeriesList(
                page: page,
                limit: limit,
                cancelToken: cancelToken,
              );
        await _localDataSource.cacheSeriesListResults(
          remotePage.results,
          page: page,
          limit: limit,
          count: remotePage.count,
          next: remotePage.next,
          previous: remotePage.previous,
        );
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
    final cachedDto = await _localDataSource.getSeriesDetails(seriesId);
    final cachedAt =
        await _localDataSource.getSeriesDetailsCachedAt(seriesId);

    if (!forceRefresh && cachedDto != null) {
      final isFresh =
          cachedAt != null &&
          MetronCachePolicies.seriesDetails.isFresh(cachedAt, _now());
      if (!isFresh) {
        _refreshInBackground(
          task: () async {
            await _fetchWithConditional<SeriesDetails>(
              fetch: _remoteDataSource.getSeriesDetails(seriesId),
              cached: () async {
                final dto = await _localDataSource.getSeriesDetails(seriesId);
                return dto!.toEntity();
              },
              cache: (response) async {
                final remoteDto = SeriesDetailsDto.fromJson(
                    response.data as Map<String, dynamic>);
                await _localDataSource.cacheSeriesDetails(remoteDto);
                _indexSeriesName(remoteDto.name);
              },
              updateTtl: () async {
                await _localDataSource.cacheSeriesDetails(cachedDto);
              },
            );
          },
          cacheKey: 'series_details:$seriesId',
          cooldown: MetronCachePolicies.seriesDetails.refreshCooldown,
        );
      }
      return cachedDto.toEntity();
    }

    try {
      final key = '$seriesId|$forceRefresh';
      return _coalesce(_seriesDetailsInFlight, key, () async {
        return await _fetchWithConditional<SeriesDetails>(
          fetch: _remoteDataSource.getSeriesDetails(seriesId),
          cached: () async {
            final dto = await _localDataSource.getSeriesDetails(seriesId);
            return dto!.toEntity();
          },
          cache: (response) async {
            final remoteDto = SeriesDetailsDto.fromJson(
                response.data as Map<String, dynamic>);
            await _localDataSource.cacheSeriesDetails(remoteDto);
            _indexSeriesName(remoteDto.name);
          },
          updateTtl: () async {
            if (cachedDto != null) {
              await _localDataSource.cacheSeriesDetails(cachedDto);
            }
          },
        );
      }, timeout: const Duration(seconds: 30));
    } catch (e) {
      AppLogger.error('Failed to fetch series details', error: e);
      if (cachedDto != null) {
        return cachedDto.toEntity();
      }
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
    final hasFilters = ordering != null ||
        storeDateGte != null ||
        storeDateLte != null;

    if (!forceRefresh && !hasFilters) {
      final cachedDtos = await _localDataSource.getSeriesIssueListResults(
        seriesId,
        page: page,
        limit: limit,
      );
      final cachedAt =
          await _localDataSource.getSeriesIssueListResultsCachedAt(
        seriesId,
        page: page,
        limit: limit,
      );
      final cachedMeta =
          await _localDataSource.getSeriesIssueListResultsMeta(
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
      final key = '$seriesId|${nextUrl ?? "$page"}|$forceRefresh|$ordering|${storeDateGte?.millisecondsSinceEpoch}|${storeDateLte?.millisecondsSinceEpoch}';
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
          _indexSeriesNamesFromIssueList(remotePage.results);
        }
        return SeriesIssueListPage(
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
      if (!hasFilters) {
        final cachedDtos = await _localDataSource.getSeriesIssueListResults(
          seriesId,
          page: page,
          limit: limit,
        );
        final cachedMeta =
            await _localDataSource.getSeriesIssueListResultsMeta(
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
}
