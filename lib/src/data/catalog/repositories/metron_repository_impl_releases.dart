part of "metron_repository_impl.dart";

mixin _ReleasesRepositoryMixin on _RepositoryState {
  Future<List<IssueList>> getWeeklyReleasesForDate(
    DateTime date, {
    bool forceRefresh = false,
    CancelToken? cancelToken,
  }) async {
    final cachedDtos = await _localDataSource.getWeeklyReleases(date);
    final cachedAt = await _localDataSource.getWeeklyReleasesCachedAt(date);

    final policy = MetronCachePolicies.weeklyReleasesForDate(date);

    if (!forceRefresh && cachedDtos != null && cachedDtos.isNotEmpty) {
      final isFresh = cachedAt != null && policy.isFresh(cachedAt, _now());
      if (!isFresh) {
        _refreshInBackground(
          task: () async {
            await _fetchWithConditional<List<IssueList>>(
              fetch: _remoteDataSource.getWeeklyReleasesForDate(date),
              cached: () async {
                final dtos = await _localDataSource.getWeeklyReleases(date);
                return dtos!.map((e) => e.toEntity()).toList();
              },
              cache: (response) async {
                final List results = response.data["results"];
                final remoteDtos = results
                    .map((e) => IssueListDto.fromJson(e))
                    .toList();
                await _localDataSource.cacheWeeklyReleases(date, remoteDtos);
                _upsertIssueListStubs(remoteDtos);
                _indexSeriesNamesFromIssueList(remoteDtos);
              },
              updateTtl: () async {
                await _localDataSource.cacheWeeklyReleases(date, cachedDtos);
              },
            );
          },
          cacheKey: "weekly_releases:${date.year}-${date.month}-${date.day}",
          cooldown: policy.refreshCooldown,
        );
      }
      AppPerformanceMetrics.instance.recordCacheHit("weekly_releases");
      return cachedDtos.map((entry) => entry.toEntity()).toList();
    }
    AppPerformanceMetrics.instance.recordCacheMiss("weekly_releases");

    try {
      final key = "${date.year}-${date.month}-${date.day}|$forceRefresh";
      return _coalesce(_weeklyInFlight, key, () async {
        return _fetchWithConditional<List<IssueList>>(
          fetch: _remoteDataSource.getWeeklyReleasesForDate(
            date,
            cancelToken: cancelToken,
          ),
          cached: () async {
            final dtos = await _localDataSource.getWeeklyReleases(date) ?? [];
            return dtos.map((e) => e.toEntity()).toList();
          },
          cache: (response) async {
            final List results = response.data["results"];
            final remoteDtos = results
                .map((e) => IssueListDto.fromJson(e))
                .toList();
            await _localDataSource.cacheWeeklyReleases(date, remoteDtos);
            _upsertIssueListStubs(remoteDtos);
            _indexSeriesNamesFromIssueList(remoteDtos);
          },
          updateTtl: () async {
            if (cachedDtos != null) {
              await _localDataSource.cacheWeeklyReleases(date, cachedDtos);
            }
          },
        );
      }, timeout: const Duration(seconds: 30));
    } catch (e) {
      AppLogger.error("Failed to fetch weekly releases", error: e);
      if (cachedDtos != null && cachedDtos.isNotEmpty) {
        return cachedDtos.map((entry) => entry.toEntity()).toList();
      }
      rethrow;
    }
  }

  Future<List<IssueList>> getFocReleasesForDate(
    DateTime date, {
    bool forceRefresh = false,
    CancelToken? cancelToken,
  }) async {
    final cachedDtos = await _localDataSource.getFocReleases(date);
    final cachedAt = await _localDataSource.getFocReleasesCachedAt(date);

    final policy = MetronCachePolicies.weeklyReleasesForDate(date);

    if (!forceRefresh && cachedDtos != null && cachedDtos.isNotEmpty) {
      final isFresh = cachedAt != null && policy.isFresh(cachedAt, _now());
      if (!isFresh) {
        _refreshInBackground(
          task: () async {
            await _fetchWithConditional<List<IssueList>>(
              fetch: _remoteDataSource.getFocReleasesForDate(date),
              cached: () async {
                final dtos = await _localDataSource.getFocReleases(date);
                return dtos!.map((e) => e.toEntity()).toList();
              },
              cache: (response) async {
                final List results = response.data["results"];
                final remoteDtos = results
                    .map((e) => IssueListDto.fromJson(e))
                    .toList();
                await _localDataSource.cacheFocReleases(date, remoteDtos);
                _upsertIssueListStubs(remoteDtos);
                _indexSeriesNamesFromIssueList(remoteDtos);
              },
              updateTtl: () async {
                await _localDataSource.cacheFocReleases(date, cachedDtos);
              },
            );
          },
          cacheKey: "foc_releases:${date.year}-${date.month}-${date.day}",
          cooldown: policy.refreshCooldown,
        );
      }
      return cachedDtos.map((entry) => entry.toEntity()).toList();
    }

    try {
      final key = "${date.year}-${date.month}-${date.day}|$forceRefresh";
      return _coalesce(_focReleasesInFlight, key, () async {
        return _fetchWithConditional<List<IssueList>>(
          fetch: _remoteDataSource.getFocReleasesForDate(
            date,
            cancelToken: cancelToken,
          ),
          cached: () async {
            final dtos = await _localDataSource.getFocReleases(date) ?? [];
            return dtos.map((e) => e.toEntity()).toList();
          },
          cache: (response) async {
            final List results = response.data["results"];
            final remoteDtos = results
                .map((e) => IssueListDto.fromJson(e))
                .toList();
            await _localDataSource.cacheFocReleases(date, remoteDtos);
            _upsertIssueListStubs(remoteDtos);
            _indexSeriesNamesFromIssueList(remoteDtos);
          },
          updateTtl: () async {
            if (cachedDtos != null) {
              await _localDataSource.cacheFocReleases(date, cachedDtos);
            }
          },
        );
      }, timeout: const Duration(seconds: 30));
    } catch (e) {
      AppLogger.error("Failed to fetch FOC releases", error: e);
      if (cachedDtos != null && cachedDtos.isNotEmpty) {
        return cachedDtos.map((entry) => entry.toEntity()).toList();
      }
      rethrow;
    }
  }
}
