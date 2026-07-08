part of 'metron_repository_impl.dart';

mixin _ReleasesRepositoryMixin on _RepositoryState {

  Future<List<IssueList>> getWeeklyReleasesForDate(
    DateTime date, {
    bool forceRefresh = false,
  }) async {
    final cachedDtos = await _localDataSource.getWeeklyReleases(date);
    final cachedAt = await _localDataSource.getWeeklyReleasesCachedAt(date);

    if (!forceRefresh && cachedDtos != null && cachedDtos.isNotEmpty) {
      final isFresh = cachedAt != null &&
          MetronCachePolicies.weeklyReleases.isFresh(cachedAt, _now());
      if (!isFresh) {
        _refreshInBackground(
          task: () async {
            final remoteDtos =
                await _remoteDataSource.getWeeklyReleasesForDate(date);
            await _localDataSource.cacheWeeklyReleases(date, remoteDtos);
            _indexSeriesNamesFromIssueList(remoteDtos);
          },
          cacheKey: 'weekly_releases:${date.year}-${date.month}-${date.day}',
          cooldown: MetronCachePolicies.weeklyReleases.refreshCooldown,
        );
      }
      AppPerformanceMetrics.instance.recordCacheHit('weekly_releases');
      return cachedDtos.map((entry) => entry.toEntity()).toList();
    }
    AppPerformanceMetrics.instance.recordCacheMiss('weekly_releases');

    try {
      final key = '${date.year}-${date.month}-${date.day}|$forceRefresh';
      return _coalesce(_weeklyInFlight, key, () async {
        final remoteDtos = await _remoteDataSource.getWeeklyReleasesForDate(
          date,
        );
        await _localDataSource.cacheWeeklyReleases(date, remoteDtos);
        _indexSeriesNamesFromIssueList(remoteDtos);
        return remoteDtos.map((entry) => entry.toEntity()).toList();
      }, timeout: const Duration(seconds: 30));
    } catch (_) {
      if (cachedDtos != null && cachedDtos.isNotEmpty) {
        return cachedDtos.map((entry) => entry.toEntity()).toList();
      }
      rethrow;
    }
  }

  Future<List<IssueList>> getFocReleasesForDate(
    DateTime date, {
    bool forceRefresh = false,
  }) async {
    final cachedDtos = await _localDataSource.getFocReleases(date);
    final cachedAt = await _localDataSource.getFocReleasesCachedAt(date);

    if (!forceRefresh && cachedDtos != null && cachedDtos.isNotEmpty) {
      final isFresh = cachedAt != null &&
          MetronCachePolicies.focReleases.isFresh(cachedAt, _now());
      if (!isFresh) {
        _refreshInBackground(
          task: () async {
            final remoteDtos =
                await _remoteDataSource.getFocReleasesForDate(date);
            await _localDataSource.cacheFocReleases(date, remoteDtos);
            _indexSeriesNamesFromIssueList(remoteDtos);
          },
          cacheKey: 'foc_releases:${date.year}-${date.month}-${date.day}',
          cooldown: MetronCachePolicies.focReleases.refreshCooldown,
        );
      }
      return cachedDtos.map((entry) => entry.toEntity()).toList();
    }

    try {
      final key = '${date.year}-${date.month}-${date.day}|$forceRefresh';
      return _coalesce(_focReleasesInFlight, key, () async {
        final remoteDtos =
            await _remoteDataSource.getFocReleasesForDate(date);
        await _localDataSource.cacheFocReleases(date, remoteDtos);
        _indexSeriesNamesFromIssueList(remoteDtos);
        return remoteDtos.map((entry) => entry.toEntity()).toList();
      }, timeout: const Duration(seconds: 30));
    } catch (_) {
      if (cachedDtos != null && cachedDtos.isNotEmpty) {
        return cachedDtos.map((entry) => entry.toEntity()).toList();
      }
      rethrow;
    }
  }
}
