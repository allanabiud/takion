part of 'metron_repository_impl.dart';

mixin _IssuesRepositoryMixin on _RepositoryState {

  Future<IssueDetails> getIssueDetails(
    int issueId, {
    bool forceRefresh = false,
  }) async {
    final cachedDto = await _localDataSource.getIssueDetails(issueId);
    final cachedAt = await _localDataSource.getIssueDetailsCachedAt(issueId);

    if (!forceRefresh && cachedDto != null) {
      final isFresh = cachedAt != null &&
          MetronCachePolicies.issueDetails.isFresh(cachedAt, _now());
      if (!isFresh) {
        _refreshInBackground(
          task: () async {
            await _issueDetailsGate.acquire();
            try {
              await _fetchWithConditional<IssueDetails>(
                fetch: _remoteDataSource.getIssueDetails(issueId),
                cached: () async {
                  final dto = await _localDataSource.getIssueDetails(issueId);
                  if (dto == null) {
                    throw StateError(
                      'Cached issue details missing after 304',
                    );
                  }
                  return dto.toEntity();
                },
                cache: (response) async {
                  final remoteDto = IssueDetailsDto.fromJson(
                      response.data as Map<String, dynamic>);
                  await _localDataSource.cacheIssueDetails(remoteDto);
                  _indexSeriesNamesFromIssueDetails(remoteDto);
                },
                updateTtl: () async {
                  await _localDataSource.cacheIssueDetails(cachedDto);
                },
              );
            } finally {
              _issueDetailsGate.release();
            }
          },
          cacheKey: 'issue_details:$issueId',
          cooldown: MetronCachePolicies.issueDetails.refreshCooldown,
        );
      }
      AppPerformanceMetrics.instance.recordCacheHit('issue_details');
      return cachedDto.toEntity();
    }
    AppPerformanceMetrics.instance.recordCacheMiss('issue_details');

    try {
      final key = '$issueId|$forceRefresh';
      return _coalesce(_issueDetailsInFlight, key, () async {
        await _issueDetailsGate.acquire();
        try {
          return await _fetchWithConditional<IssueDetails>(
            fetch: _remoteDataSource.getIssueDetails(issueId),
            cached: () async {
              final dto = await _localDataSource.getIssueDetails(issueId);
              if (dto == null) {
                throw StateError(
                  'Cached issue details missing after 304',
                );
              }
              return dto.toEntity();
            },
            cache: (response) async {
              final remoteDto = IssueDetailsDto.fromJson(
                  response.data as Map<String, dynamic>);
              await _localDataSource.cacheIssueDetails(remoteDto);
              _indexSeriesNamesFromIssueDetails(remoteDto);
            },
            updateTtl: () async {
              if (cachedDto != null) {
                await _localDataSource.cacheIssueDetails(cachedDto);
              }
            },
          );
        } finally {
          _issueDetailsGate.release();
        }
      });
    } catch (e) {
      AppLogger.error('Failed to fetch issue details', error: e);
      if (cachedDto != null) {
        return cachedDto.toEntity();
      }
      rethrow;
    }
  }

  Future<IssueSearchPage> searchIssues(
    String query, {
    String? nextUrl,
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  }) async {
    final cachedDtos = await _localDataSource.getIssueSearchResults(
      query,
      page: page,
      limit: limit,
    );
    final cachedAt = await _localDataSource.getIssueSearchResultsCachedAt(
      query,
      page: page,
      limit: limit,
    );
    final cachedMeta = await _localDataSource.getIssueSearchResultsMeta(
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
            final remotePage = await _remoteDataSource.searchIssues(
              corrected,
              nextUrl: nextUrl != null ? Uri.parse(nextUrl) : null,
              page: page,
              limit: limit,
              cancelToken: cancelToken,
            );
            await _localDataSource.cacheIssueSearchResults(
              query,
              remotePage.results,
              page: page,
              limit: limit,
              count: remotePage.count,
              next: remotePage.next,
              previous: remotePage.previous,
            );
            _indexSeriesNamesFromIssueList(remotePage.results);
          },
          cacheKey: nextUrl != null ? 'search:issue:$query:$nextUrl' : 'search:issue:$query:$page',
          cooldown: MetronCachePolicies.searchResults.refreshCooldown,
        );
      }
      if (cachedMeta != null) {
        return IssueSearchPage(
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
      final remotePage = await _remoteDataSource.searchIssues(
        corrected,
        nextUrl: nextUrl != null ? Uri.parse(nextUrl) : null,
        page: page,
        limit: limit,
        cancelToken: cancelToken,
      );
      await _localDataSource.cacheIssueSearchResults(
        query,
        remotePage.results,
        page: page,
        limit: limit,
        count: remotePage.count,
        next: remotePage.next,
        previous: remotePage.previous,
      );
      _indexSeriesNamesFromIssueList(remotePage.results);
      return IssueSearchPage(
        count: remotePage.count,
        next: remotePage.next,
        previous: remotePage.previous,
        results: remotePage.results.map((entry) => entry.toEntity()).toList(),
        currentPage: page,
      );
    } catch (error) {
      if (_isCancelled(error)) rethrow;
      if (cachedDtos != null && cachedDtos.isNotEmpty && cachedMeta != null) {
        return IssueSearchPage(
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

  Future<IssueSearchPage> getIssueList({
    String? nextUrl,
    int page = 1,
    bool forceRefresh = false,
    String? ordering,
    DateTime? modifiedGt,
    int? limit,
    CancelToken? cancelToken,
  }) async {
    final cachedDtos = await _localDataSource.getIssueListResults(
      page: page,
      ordering: ordering,
      modifiedGt: modifiedGt,
      limit: limit,
    );
    final cachedAt = await _localDataSource.getIssueListResultsCachedAt(
      page: page,
      ordering: ordering,
      modifiedGt: modifiedGt,
      limit: limit,
    );
    final cachedMeta = await _localDataSource.getIssueListResultsMeta(
      page: page,
      ordering: ordering,
      modifiedGt: modifiedGt,
      limit: limit,
    );

    if (!forceRefresh && cachedDtos != null && cachedDtos.isNotEmpty) {
      final isFresh =
          cachedAt != null &&
          MetronCachePolicies.searchResults.isFresh(cachedAt, _now());
      if (!isFresh) {
        final key = nextUrl ??
            '$page|${ordering ?? ''}|${modifiedGt?.toUtc().toIso8601String() ?? ''}|${limit ?? ''}';
        _refreshInBackground(
          task: () async {
            final remotePage = await _remoteDataSource.getIssueList(
              nextUrl: nextUrl != null ? Uri.parse(nextUrl) : null,
              page: page,
              ordering: ordering,
              modifiedGt: modifiedGt,
              limit: limit,
              cancelToken: cancelToken,
            );
            await _localDataSource.cacheIssueListResults(
              remotePage.results,
              page: page,
              ordering: ordering,
              modifiedGt: modifiedGt,
              limit: limit,
              count: remotePage.count,
              next: remotePage.next,
              previous: remotePage.previous,
            );
          },
          cacheKey: 'issue_list:$key',
          cooldown: MetronCachePolicies.searchResults.refreshCooldown,
        );
      }
      if (cachedMeta != null) {
        AppPerformanceMetrics.instance.recordCacheHit('issue_list');
        return IssueSearchPage(
          count: cachedMeta.count,
          next: cachedMeta.next,
          previous: cachedMeta.previous,
          results: cachedDtos.map((entry) => entry.toEntity()).toList(),
          currentPage: page,
        );
      }
    }
    AppPerformanceMetrics.instance.recordCacheMiss('issue_list');

    final key = nextUrl ??
        '$page|${ordering ?? ''}|${modifiedGt?.toUtc().toIso8601String() ?? ''}|${limit ?? ''}|$forceRefresh';
    try {
      return _coalesce(_issueListInFlight, key, () async {
        final remotePage = await _remoteDataSource.getIssueList(
          nextUrl: nextUrl != null ? Uri.parse(nextUrl) : null,
          page: page,
          ordering: ordering,
          modifiedGt: modifiedGt,
          limit: limit,
          cancelToken: cancelToken,
        );
        await _localDataSource.cacheIssueListResults(
          remotePage.results,
          page: page,
          ordering: ordering,
          modifiedGt: modifiedGt,
          limit: limit,
          count: remotePage.count,
          next: remotePage.next,
          previous: remotePage.previous,
        );
        return IssueSearchPage(
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
        return IssueSearchPage(
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

  Future<IssueSearchPage> searchIssuesByUpc(
    String upc, {
    CancelToken? cancelToken,
    bool forceRefresh = false,
  }) async {
    final cachedDtos = await _localDataSource.getIssueSearchResults(
      'upc:$upc',
      page: 1,
      limit: 1,
    );
    final cachedAt = await _localDataSource.getIssueSearchResultsCachedAt(
      'upc:$upc',
      page: 1,
      limit: 1,
    );
    final cachedMeta = await _localDataSource.getIssueSearchResultsMeta(
      'upc:$upc',
      page: 1,
      limit: 1,
    );

    if (!forceRefresh && cachedDtos != null && cachedDtos.isNotEmpty) {
      final isFresh =
          cachedAt != null &&
          MetronCachePolicies.searchResults.isFresh(cachedAt, _now());
      if (!isFresh) {
        _refreshInBackground(
          task: () async {
            final remotePage = await _remoteDataSource.searchIssuesByUpc(
              upc,
              cancelToken: cancelToken,
            );
            await _localDataSource.cacheIssueSearchResults(
              'upc:$upc',
              remotePage.results,
              page: 1,
              limit: 1,
              count: remotePage.count,
              next: remotePage.next,
              previous: remotePage.previous,
            );
          },
          cacheKey: 'search:upc:$upc',
          cooldown: MetronCachePolicies.searchResults.refreshCooldown,
        );
      }
      if (cachedMeta != null) {
        return IssueSearchPage(
          count: cachedMeta.count,
          next: cachedMeta.next,
          previous: cachedMeta.previous,
          results: cachedDtos.map((entry) => entry.toEntity()).toList(),
          currentPage: 1,
        );
      }
    }

    try {
      final remotePage = await _remoteDataSource.searchIssuesByUpc(
        upc,
        cancelToken: cancelToken,
      );
      await _localDataSource.cacheIssueSearchResults(
        'upc:$upc',
        remotePage.results,
        page: 1,
        limit: 1,
        count: remotePage.count,
        next: remotePage.next,
        previous: remotePage.previous,
      );
      return IssueSearchPage(
        count: remotePage.count,
        next: remotePage.next,
        previous: remotePage.previous,
        results: remotePage.results.map((entry) => entry.toEntity()).toList(),
        currentPage: 1,
      );
    } catch (error) {
      if (_isCancelled(error)) rethrow;
      if (cachedDtos != null && cachedDtos.isNotEmpty && cachedMeta != null) {
        return IssueSearchPage(
          count: cachedMeta.count,
          next: cachedMeta.next,
          previous: cachedMeta.previous,
          results: cachedDtos.map((entry) => entry.toEntity()).toList(),
          currentPage: 1,
        );
      }
      rethrow;
    }
  }

  Future<IssueSearchPage> searchIssuesByUpcPrefix(
    String prefix, {
    CancelToken? cancelToken,
    bool forceRefresh = false,
  }) async {
    final cachedDtos = await _localDataSource.getIssueSearchResults(
      'upc_prefix:$prefix',
      page: 1,
      limit: 1,
    );
    final cachedAt = await _localDataSource.getIssueSearchResultsCachedAt(
      'upc_prefix:$prefix',
      page: 1,
      limit: 1,
    );
    final cachedMeta = await _localDataSource.getIssueSearchResultsMeta(
      'upc_prefix:$prefix',
      page: 1,
      limit: 1,
    );

    if (!forceRefresh && cachedDtos != null && cachedDtos.isNotEmpty) {
      final isFresh =
          cachedAt != null &&
          MetronCachePolicies.searchResults.isFresh(cachedAt, _now());
      if (!isFresh) {
        _refreshInBackground(
          task: () async {
            final remotePage = await _remoteDataSource.searchIssuesByUpcPrefix(
              prefix,
              cancelToken: cancelToken,
            );
            await _localDataSource.cacheIssueSearchResults(
              'upc_prefix:$prefix',
              remotePage.results,
              page: 1,
              limit: 1,
              count: remotePage.count,
              next: remotePage.next,
              previous: remotePage.previous,
            );
          },
          cacheKey: 'search:upc_prefix:$prefix',
          cooldown: MetronCachePolicies.searchResults.refreshCooldown,
        );
      }
      if (cachedMeta != null) {
        return IssueSearchPage(
          count: cachedMeta.count,
          next: cachedMeta.next,
          previous: cachedMeta.previous,
          results: cachedDtos.map((entry) => entry.toEntity()).toList(),
          currentPage: 1,
        );
      }
    }

    try {
      final allDtos = <IssueListDto>[];
      var totalCount = 0;
      String? nextUrl;

      final firstPage = await _remoteDataSource.searchIssuesByUpcPrefix(
        prefix,
        cancelToken: cancelToken,
      );
      allDtos.addAll(firstPage.results);
      totalCount = firstPage.count;
      nextUrl = firstPage.next;

      while (nextUrl != null) {
        final page = await _remoteDataSource.getIssueSearchPage(
          nextUrl,
          cancelToken: cancelToken,
        );
        allDtos.addAll(page.results);
        nextUrl = page.next;
      }

      await _localDataSource.cacheIssueSearchResults(
        'upc_prefix:$prefix',
        allDtos,
        page: 1,
        limit: 1,
        count: totalCount,
        next: null,
        previous: null,
      );
      return IssueSearchPage(
        count: totalCount,
        results: allDtos.map((entry) => entry.toEntity()).toList(),
        currentPage: 1,
      );
    } catch (error) {
      if (_isCancelled(error)) rethrow;
      if (cachedDtos != null && cachedDtos.isNotEmpty && cachedMeta != null) {
        return IssueSearchPage(
          count: cachedMeta.count,
          next: cachedMeta.next,
          previous: cachedMeta.previous,
          results: cachedDtos.map((entry) => entry.toEntity()).toList(),
          currentPage: 1,
        );
      }
      rethrow;
    }
  }
}
