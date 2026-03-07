import 'dart:async';
import 'dart:collection';
import 'package:takion/src/core/cache/cache_policy.dart';
import 'package:takion/src/core/perf/performance_metrics.dart';
import 'package:takion/src/data/datasources/metron_local_data_source.dart';
import 'package:takion/src/data/datasources/metron_remote_data_source.dart';
import 'package:takion/src/domain/entities/issue_details.dart';
import 'package:takion/src/domain/entities/issue_list.dart';
import 'package:takion/src/domain/entities/issue_search_page.dart';
import 'package:takion/src/domain/entities/series_details.dart';
import 'package:takion/src/domain/entities/series_issue_list_page.dart';
import 'package:takion/src/domain/entities/series_list_page.dart';
import 'package:takion/src/domain/entities/series_search_page.dart';
import 'package:takion/src/domain/repositories/metron_repository.dart';

class MetronRepositoryImpl implements MetronRepository {
  final MetronRemoteDataSource _remoteDataSource;
  final MetronLocalDataSource _localDataSource;
  final DateTime Function() _now;
  final Map<String, Future<List<IssueList>>> _weeklyInFlight =
      <String, Future<List<IssueList>>>{};
  final Map<String, Future<IssueDetails>> _issueDetailsInFlight =
      <String, Future<IssueDetails>>{};
  final Map<String, Future<IssueSearchPage>> _issueListInFlight =
      <String, Future<IssueSearchPage>>{};
  final Map<String, Future<SeriesListPage>> _seriesListInFlight =
      <String, Future<SeriesListPage>>{};
  final Map<String, Future<SeriesIssueListPage>> _seriesIssueListInFlight =
      <String, Future<SeriesIssueListPage>>{};
  final _AsyncConcurrencyGate _issueDetailsGate = _AsyncConcurrencyGate(4);

  MetronRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource, {
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  Future<T> _coalesce<T>(
    Map<String, Future<T>> inFlight,
    String key,
    Future<T> Function() loader,
  ) {
    final existing = inFlight[key];
    if (existing != null) return existing;
    final future = loader();
    inFlight[key] = future;
    future.whenComplete(() {
      if (identical(inFlight[key], future)) {
        inFlight.remove(key);
      }
    });
    return future;
  }

  @override
  Future<List<IssueList>> getWeeklyReleasesForDate(
    DateTime date, {
    bool forceRefresh = false,
  }) async {
    final metrics = AppPerformanceMetrics.instance;
    // Updated to IssueList
    final cachedDtos = await _localDataSource.getWeeklyReleases(date);
    final cachedAt = await _localDataSource.getWeeklyReleasesCachedAt(date);

    if (!forceRefresh && cachedDtos != null && cachedDtos.isNotEmpty) {
      if (cachedAt != null &&
          MetronCachePolicies.weeklyReleases.isFresh(cachedAt, _now())) {
        metrics.recordCacheHit('weekly_releases');
        return cachedDtos.map((entry) => entry.toEntity()).toList();
      }
    }
    metrics.recordCacheMiss('weekly_releases');

    try {
      final key = '${date.year}-${date.month}-${date.day}|$forceRefresh';
      return _coalesce(_weeklyInFlight, key, () async {
        final remoteDtos = await _remoteDataSource.getWeeklyReleasesForDate(
          date,
        );
        await _localDataSource.cacheWeeklyReleases(date, remoteDtos);
        return remoteDtos.map((entry) => entry.toEntity()).toList();
      });
    } catch (_) {
      if (cachedDtos != null && cachedDtos.isNotEmpty) {
        return cachedDtos.map((entry) => entry.toEntity()).toList();
      }
      rethrow;
    }
  }

  @override
  Future<List<IssueList>> getFocReleasesForDate(
    DateTime date, {
    bool forceRefresh = false,
  }) async {
    final cachedDtos = await _localDataSource.getFocReleases(date);
    final cachedAt = await _localDataSource.getFocReleasesCachedAt(date);

    if (!forceRefresh && cachedDtos != null && cachedDtos.isNotEmpty) {
      if (cachedAt != null &&
          MetronCachePolicies.focReleases.isFresh(cachedAt, _now())) {
        return cachedDtos.map((entry) => entry.toEntity()).toList();
      }
    }

    try {
      final remoteDtos = await _remoteDataSource.getFocReleasesForDate(date);
      await _localDataSource.cacheFocReleases(date, remoteDtos);
      return remoteDtos.map((entry) => entry.toEntity()).toList();
    } catch (_) {
      if (cachedDtos != null && cachedDtos.isNotEmpty) {
        return cachedDtos.map((entry) => entry.toEntity()).toList();
      }
      rethrow;
    }
  }

  @override
  Future<IssueDetails> getIssueDetails(
    int issueId, {
    bool forceRefresh = false,
  }) async {
    final metrics = AppPerformanceMetrics.instance;
    final cachedDto = await _localDataSource.getIssueDetails(issueId);
    final cachedAt = await _localDataSource.getIssueDetailsCachedAt(issueId);
    if (!forceRefresh && cachedDto != null) {
      final isFresh =
          cachedAt != null &&
          MetronCachePolicies.issueDetails.isFresh(cachedAt, _now());
      if (isFresh) {
        metrics.recordCacheHit('issue_details');
        return cachedDto.toEntity();
      }
    }
    metrics.recordCacheMiss('issue_details');

    try {
      final key = '$issueId|$forceRefresh';
      return _coalesce(_issueDetailsInFlight, key, () async {
        await _issueDetailsGate.acquire();
        try {
          final remoteDto = await _remoteDataSource.getIssueDetails(issueId);
          await _localDataSource.cacheIssueDetails(remoteDto);
          return remoteDto.toEntity();
        } finally {
          _issueDetailsGate.release();
        }
      });
    } catch (_) {
      if (cachedDto != null) {
        return cachedDto.toEntity();
      }
      rethrow;
    }
  }

  @override
  Future<IssueSearchPage> searchIssues(
    String query, {
    int page = 1,
    bool forceRefresh = false,
  }) async {
    final cachedDtos = await _localDataSource.getIssueSearchResults(
      query,
      page: page,
    );
    final cachedAt = await _localDataSource.getIssueSearchResultsCachedAt(
      query,
      page: page,
    );
    final cachedMeta = await _localDataSource.getIssueSearchResultsMeta(
      query,
      page: page,
    );

    if (!forceRefresh && cachedDtos != null && cachedDtos.isNotEmpty) {
      final isFresh =
          cachedAt != null &&
          MetronCachePolicies.searchResults.isFresh(cachedAt, _now());
      if (isFresh && cachedMeta != null) {
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
      final remotePage = await _remoteDataSource.searchIssues(
        query,
        page: page,
      );
      await _localDataSource.cacheIssueSearchResults(
        query,
        remotePage.results,
        page: page,
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
    } catch (_) {
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

  @override
  Future<IssueSearchPage> getIssueList({
    int page = 1,
    bool forceRefresh = false,
    String? ordering,
    DateTime? modifiedGt,
    int? limit,
  }) async {
    final metrics = AppPerformanceMetrics.instance;
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
      if (isFresh && cachedMeta != null) {
        metrics.recordCacheHit('issue_list');
        return IssueSearchPage(
          count: cachedMeta.count,
          next: cachedMeta.next,
          previous: cachedMeta.previous,
          results: cachedDtos.map((entry) => entry.toEntity()).toList(),
          currentPage: page,
        );
      }
    }
    metrics.recordCacheMiss('issue_list');

    final key =
        '$page|${ordering ?? ''}|${modifiedGt?.toUtc().toIso8601String() ?? ''}|${limit ?? ''}|$forceRefresh';
    try {
      return _coalesce(_issueListInFlight, key, () async {
        final remotePage = await _remoteDataSource.getIssueList(
          page: page,
          ordering: ordering,
          modifiedGt: modifiedGt,
          limit: limit,
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
      });
    } catch (_) {
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

  @override
  Future<SeriesSearchPage> searchSeries(
    String query, {
    int page = 1,
    bool forceRefresh = false,
  }) async {
    final cachedDtos = await _localDataSource.getSeriesSearchResults(
      query,
      page: page,
    );
    final cachedAt = await _localDataSource.getSeriesSearchResultsCachedAt(
      query,
      page: page,
    );
    final cachedMeta = await _localDataSource.getSeriesSearchResultsMeta(
      query,
      page: page,
    );

    if (!forceRefresh && cachedDtos != null && cachedDtos.isNotEmpty) {
      final isFresh =
          cachedAt != null &&
          MetronCachePolicies.searchResults.isFresh(cachedAt, _now());
      if (isFresh && cachedMeta != null) {
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
      final remotePage = await _remoteDataSource.searchSeries(
        query,
        page: page,
      );
      await _localDataSource.cacheSeriesSearchResults(
        query,
        remotePage.results,
        page: page,
        count: remotePage.count,
        next: remotePage.next,
        previous: remotePage.previous,
      );
      return SeriesSearchPage(
        count: remotePage.count,
        next: remotePage.next,
        previous: remotePage.previous,
        results: remotePage.results.map((entry) => entry.toEntity()).toList(),
        currentPage: page,
      );
    } catch (_) {
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

  @override
  Future<SeriesListPage> getSeriesList({
    int page = 1,
    bool forceRefresh = false,
  }) async {
    final metrics = AppPerformanceMetrics.instance;
    final cachedDtos = await _localDataSource.getSeriesListResults(page: page);
    final cachedAt = await _localDataSource.getSeriesListResultsCachedAt(
      page: page,
    );
    final cachedMeta = await _localDataSource.getSeriesListResultsMeta(
      page: page,
    );

    if (!forceRefresh && cachedDtos != null && cachedDtos.isNotEmpty) {
      final isFresh =
          cachedAt != null &&
          MetronCachePolicies.searchResults.isFresh(cachedAt, _now());
      if (isFresh && cachedMeta != null) {
        metrics.recordCacheHit('series_list');
        return SeriesListPage(
          count: cachedMeta.count,
          next: cachedMeta.next,
          previous: cachedMeta.previous,
          results: cachedDtos.map((entry) => entry.toEntity()).toList(),
          currentPage: page,
        );
      }
    }
    metrics.recordCacheMiss('series_list');

    try {
      final key = '$page|$forceRefresh';
      return _coalesce(_seriesListInFlight, key, () async {
        final remotePage = await _remoteDataSource.getSeriesList(page: page);
        await _localDataSource.cacheSeriesListResults(
          remotePage.results,
          page: page,
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
      });
    } catch (_) {
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

  @override
  Future<SeriesDetails> getSeriesDetails(
    int seriesId, {
    bool forceRefresh = false,
  }) async {
    final cachedDto = await _localDataSource.getSeriesDetails(seriesId);
    final cachedAt = await _localDataSource.getSeriesDetailsCachedAt(seriesId);

    if (!forceRefresh && cachedDto != null) {
      final isFresh =
          cachedAt != null &&
          MetronCachePolicies.seriesDetails.isFresh(cachedAt, _now());
      if (isFresh) {
        return cachedDto.toEntity();
      }
    }

    try {
      final remoteDto = await _remoteDataSource.getSeriesDetails(seriesId);
      await _localDataSource.cacheSeriesDetails(remoteDto);
      return remoteDto.toEntity();
    } catch (_) {
      if (cachedDto != null) {
        return cachedDto.toEntity();
      }
      rethrow;
    }
  }

  @override
  Future<SeriesIssueListPage> getSeriesIssueList(
    int seriesId, {
    int page = 1,
    bool forceRefresh = false,
  }) async {
    final cachedDtos = await _localDataSource.getSeriesIssueListResults(
      seriesId,
      page: page,
    );
    final cachedAt = await _localDataSource.getSeriesIssueListResultsCachedAt(
      seriesId,
      page: page,
    );
    final cachedMeta = await _localDataSource.getSeriesIssueListResultsMeta(
      seriesId,
      page: page,
    );

    if (!forceRefresh && cachedDtos != null && cachedDtos.isNotEmpty) {
      final isFresh =
          cachedAt != null &&
          MetronCachePolicies.seriesIssueList.isFresh(cachedAt, _now());
      if (isFresh && cachedMeta != null) {
        return SeriesIssueListPage(
          count: cachedMeta.count,
          next: cachedMeta.next,
          previous: cachedMeta.previous,
          results: cachedDtos.map((entry) => entry.toEntity()).toList(),
          currentPage: page,
        );
      }
    }

    try {
      final key = '$seriesId|$page|$forceRefresh';
      return _coalesce(_seriesIssueListInFlight, key, () async {
        final remotePage = await _remoteDataSource.getSeriesIssueList(
          seriesId,
          page: page,
        );
        await _localDataSource.cacheSeriesIssueListResults(
          seriesId,
          remotePage.results,
          page: page,
          count: remotePage.count,
          next: remotePage.next,
          previous: remotePage.previous,
        );
        return SeriesIssueListPage(
          count: remotePage.count,
          next: remotePage.next,
          previous: remotePage.previous,
          results: remotePage.results.map((entry) => entry.toEntity()).toList(),
          currentPage: page,
        );
      });
    } catch (_) {
      if (cachedDtos != null && cachedDtos.isNotEmpty && cachedMeta != null) {
        return SeriesIssueListPage(
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

class _AsyncConcurrencyGate {
  _AsyncConcurrencyGate(this.maxConcurrent);

  final int maxConcurrent;
  int _active = 0;
  final Queue<Completer<void>> _queue = Queue<Completer<void>>();

  Future<void> acquire() async {
    if (_active < maxConcurrent) {
      _active++;
      return;
    }
    final waiter = Completer<void>();
    _queue.add(waiter);
    await waiter.future;
    _active++;
  }

  void release() {
    if (_active > 0) _active--;
    if (_queue.isNotEmpty) {
      final next = _queue.removeFirst();
      if (!next.isCompleted) {
        next.complete();
      }
    }
  }
}
