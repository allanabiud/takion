import 'package:dio/dio.dart';
import 'dart:async';
import 'dart:collection';
import 'package:takion/src/core/constants/pagination.dart';
import 'package:takion/src/core/cache/cache_policy.dart';
import 'package:takion/src/core/perf/performance_metrics.dart';
import 'package:takion/src/data/datasources/metron_local_data_source.dart';
import 'package:takion/src/data/datasources/metron_remote_data_source.dart';
import 'package:takion/src/data/datasources/series_name_index.dart';
import 'package:takion/src/data/dto/issue_details_dto.dart';
import 'package:takion/src/data/dto/issue_list_dto.dart';
import 'package:takion/src/domain/entities/character_details.dart';
import 'package:takion/src/domain/entities/character_issue_list_page.dart';
import 'package:takion/src/domain/entities/character_list_page.dart';
import 'package:takion/src/domain/entities/creator_details.dart';
import 'package:takion/src/domain/entities/creator_list_page.dart';
import 'package:takion/src/domain/entities/universe_details.dart';
import 'package:takion/src/domain/entities/universe_list_page.dart';
import 'package:takion/src/domain/entities/imprint_details.dart';
import 'package:takion/src/domain/entities/imprint_list_page.dart';
import 'package:takion/src/domain/entities/team_details.dart';
import 'package:takion/src/domain/entities/team_list_page.dart';
import 'package:takion/src/domain/entities/publisher_details.dart';
import 'package:takion/src/domain/entities/publisher_list_page.dart';
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
  final Map<String, Future<CharacterIssueListPage>>
      _characterIssueListInFlight =
      <String, Future<CharacterIssueListPage>>{};
  final Map<String, Future<SeriesDetails>> _seriesDetailsInFlight =
      <String, Future<SeriesDetails>>{};
  final Map<String, Future<List<IssueList>>> _focReleasesInFlight =
      <String, Future<List<IssueList>>>{};
  final Map<String, Future<CharacterDetails>> _characterDetailsInFlight =
      <String, Future<CharacterDetails>>{};
  final _AsyncConcurrencyGate _issueDetailsGate = _AsyncConcurrencyGate(4);
  final _AsyncConcurrencyGate _characterDetailsGate = _AsyncConcurrencyGate(3);
  final _AsyncConcurrencyGate _creatorDetailsGate = _AsyncConcurrencyGate(3);
  final _AsyncConcurrencyGate _universeDetailsGate = _AsyncConcurrencyGate(3);
  final _AsyncConcurrencyGate _imprintDetailsGate = _AsyncConcurrencyGate(3);
  final _AsyncConcurrencyGate _teamDetailsGate = _AsyncConcurrencyGate(3);
  final _AsyncConcurrencyGate _publisherDetailsGate = _AsyncConcurrencyGate(3);
  final Map<String, DateTime> _lastBackgroundRefresh = {};
  int _backgroundRefreshCount = 0;
  static const int _maxConcurrentBackgroundRefreshes = 3;
  final SeriesNameIndex _seriesNameIndex;

  MetronRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._seriesNameIndex, {
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  Future<T> _coalesce<T>(
    Map<String, Future<T>> inFlight,
    String key,
    Future<T> Function() loader, {
    Duration timeout = const Duration(seconds: 30),
  }) {
    final existing = inFlight[key];
    if (existing != null) return existing;
    final future = loader().timeout(timeout).catchError((e) {
      inFlight.remove(key);
      throw e;
    });
    inFlight[key] = future;
    future.whenComplete(() {
      if (identical(inFlight[key], future)) {
        inFlight.remove(key);
      }
    });
    return future;
  }

  bool _isCancelled(Object error) =>
      error is DioException && error.type == DioExceptionType.cancel;

  void _refreshInBackground({
    required Future<void> Function() task,
    required String cacheKey,
    required Duration cooldown,
  }) {
    final now = _now();
    final lastRefresh = _lastBackgroundRefresh[cacheKey];
    if (lastRefresh != null && now.difference(lastRefresh) < cooldown) {
      return;
    }

    if (_backgroundRefreshCount >= _maxConcurrentBackgroundRefreshes) {
      return;
    }

    _lastBackgroundRefresh[cacheKey] = now;
    _backgroundRefreshCount++;
    unawaited(
      runZoned(
        () => task().catchError((_) {}).whenComplete(() {
          _backgroundRefreshCount--;
        }),
        zoneValues: {#opencode_background: true},
      ),
    );
  }

  void _indexSeriesName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    unawaited(_seriesNameIndex.add(trimmed));
  }

  void _indexSeriesNamesFromIssueList(Iterable<IssueListDto> issues) {
    for (final issue in issues) {
      final series = issue.series;
      if (series != null && series.name.trim().isNotEmpty) {
        _indexSeriesName(series.name);
      }
    }
  }

  void _indexSeriesNamesFromIssueDetails(IssueDetailsDto issue) {
    final series = issue.series;
    if (series != null && series.name.trim().isNotEmpty) {
      _indexSeriesName(series.name);
    }
  }

  Future<String> _correctSearchQuery(String query) async {
    final stripped = query.replaceAll(RegExp(r'\d+$'), '').trim();
    if (stripped.isNotEmpty) {
      final corrected = await _seriesNameIndex.fuzzyMatch(stripped);
      if (corrected != null) {
        final suffix = query.substring(stripped.length);
        return '$corrected$suffix';
      }
    }
    final corrected = await _seriesNameIndex.fuzzyMatch(query);
    if (corrected != null) return corrected;
    return query;
  }

  @override
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

  @override
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

  @override
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
              final remoteDto =
                  await _remoteDataSource.getIssueDetails(issueId);
              await _localDataSource.cacheIssueDetails(remoteDto);
              _indexSeriesNamesFromIssueDetails(remoteDto);
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
          final remoteDto = await _remoteDataSource.getIssueDetails(issueId);
          await _localDataSource.cacheIssueDetails(remoteDto);
          _indexSeriesNamesFromIssueDetails(remoteDto);
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
          cacheKey: 'search:issue:$query:$page',
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

  @override
  Future<IssueSearchPage> getIssueList({
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
        final key =
            '$page|${ordering ?? ''}|${modifiedGt?.toUtc().toIso8601String() ?? ''}|${limit ?? ''}';
        _refreshInBackground(
          task: () async {
            final remotePage = await _remoteDataSource.getIssueList(
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

    final key =
        '$page|${ordering ?? ''}|${modifiedGt?.toUtc().toIso8601String() ?? ''}|${limit ?? ''}|$forceRefresh';
    try {
      return _coalesce(_issueListInFlight, key, () async {
        final remotePage = await _remoteDataSource.getIssueList(
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

  @override
  Future<SeriesSearchPage> searchSeries(
    String query, {
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
            final remotePage = await _remoteDataSource.searchSeries(
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
          cacheKey: 'search:series:$query:$page',
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
      final remotePage = await _remoteDataSource.searchSeries(
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

  @override
  Future<SeriesListPage> getSeriesList({
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
            final remotePage = await _remoteDataSource.getSeriesList(
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
          cacheKey: 'series_list:$page',
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
      final key = '$page|$forceRefresh';
      return _coalesce(_seriesListInFlight, key, () async {
        final remotePage = await _remoteDataSource.getSeriesList(
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
  @override
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
            final remoteDto =
                await _remoteDataSource.getSeriesDetails(seriesId);
            await _localDataSource.cacheSeriesDetails(remoteDto);
            _indexSeriesName(remoteDto.name);
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
        final remoteDto = await _remoteDataSource.getSeriesDetails(seriesId);
        await _localDataSource.cacheSeriesDetails(remoteDto);
        _indexSeriesName(remoteDto.name);
        return remoteDto.toEntity();
      }, timeout: const Duration(seconds: 30));
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
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  }) async {
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

    if (!forceRefresh && cachedDtos != null && cachedDtos.isNotEmpty) {
      final isFresh =
          cachedAt != null &&
          MetronCachePolicies.seriesIssueList.isFresh(cachedAt, _now());
      if (!isFresh) {
        _refreshInBackground(
          task: () async {
            final remotePage = await _remoteDataSource.getSeriesIssueList(
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
          cacheKey: 'series_issue_list:$seriesId:$page',
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

    try {
      final key = '$seriesId|$page|$forceRefresh';
      return _coalesce(_seriesIssueListInFlight, key, () async {
        final remotePage = await _remoteDataSource.getSeriesIssueList(
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

  @override
  Future<CharacterListPage> searchCharacters(
    String query, {
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  }) async {
    final cachedDtos = await _localDataSource.getCharacterSearchResults(
      query,
      page: page,
      limit: limit,
    );
    final cachedAt = await _localDataSource.getCharacterSearchResultsCachedAt(
      query,
      page: page,
      limit: limit,
    );
    final cachedMeta = await _localDataSource.getCharacterSearchResultsMeta(
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
            final remotePage = await _remoteDataSource.searchCharacters(
              query,
              page: page,
              limit: limit,
              cancelToken: cancelToken,
            );
            await _localDataSource.cacheCharacterSearchResults(
              query,
              remotePage.results,
              page: page,
              limit: limit,
              count: remotePage.count,
              next: remotePage.next,
              previous: remotePage.previous,
            );
          },
          cacheKey: 'search:character:$query:$page',
          cooldown: MetronCachePolicies.searchResults.refreshCooldown,
        );
      }
      if (cachedMeta != null) {
        return CharacterListPage(
          count: cachedMeta.count,
          next: cachedMeta.next,
          previous: cachedMeta.previous,
          results: cachedDtos.map((entry) => entry.toEntity()).toList(),
          currentPage: page,
        );
      }
    }

    try {
      final remotePage = await _remoteDataSource.searchCharacters(
        query,
        page: page,
        limit: limit,
        cancelToken: cancelToken,
      );
      await _localDataSource.cacheCharacterSearchResults(
        query,
        remotePage.results,
        page: page,
        limit: limit,
        count: remotePage.count,
        next: remotePage.next,
        previous: remotePage.previous,
      );
      return CharacterListPage(
        count: remotePage.count,
        next: remotePage.next,
        previous: remotePage.previous,
        results:
            remotePage.results.map((entry) => entry.toEntity()).toList(),
        currentPage: page,
      );
    } catch (error) {
      if (_isCancelled(error)) rethrow;
      if (cachedDtos != null && cachedDtos.isNotEmpty && cachedMeta != null) {
        return CharacterListPage(
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
  Future<CharacterDetails> getCharacterDetails(
    int characterId, {
    bool forceRefresh = false,
  }) async {
    final cachedDto = await _localDataSource.getCharacterDetails(characterId);
    final cachedAt =
        await _localDataSource.getCharacterDetailsCachedAt(characterId);

    if (!forceRefresh && cachedDto != null) {
      final isFresh =
          cachedAt != null &&
          MetronCachePolicies.characterDetails.isFresh(cachedAt, _now());
      if (!isFresh) {
        _refreshInBackground(
          task: () async {
            await _characterDetailsGate.acquire();
            try {
              final remoteDto =
                  await _remoteDataSource.getCharacterDetails(characterId);
              await _localDataSource.cacheCharacterDetails(remoteDto);
            } finally {
              _characterDetailsGate.release();
            }
          },
          cacheKey: 'character_details:$characterId',
          cooldown: MetronCachePolicies.characterDetails.refreshCooldown,
        );
      }
      return cachedDto.toEntity();
    }

    try {
      final key = '$characterId|$forceRefresh';
      return _coalesce(_characterDetailsInFlight, key, () async {
        await _characterDetailsGate.acquire();
        try {
          final remoteDto =
              await _remoteDataSource.getCharacterDetails(characterId);
          await _localDataSource.cacheCharacterDetails(remoteDto);
          return remoteDto.toEntity();
        } finally {
          _characterDetailsGate.release();
        }
      }, timeout: const Duration(seconds: 30));
    } catch (_) {
      if (cachedDto != null) {
        return cachedDto.toEntity();
      }
      rethrow;
    }
  }

  @override
  Future<CharacterIssueListPage> getCharacterIssueList(
    int characterId, {
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  }) async {
    final cachedDtos = await _localDataSource.getCharacterIssueListResults(
      characterId,
      page: page,
      limit: limit,
    );
    final cachedAt =
        await _localDataSource.getCharacterIssueListResultsCachedAt(
      characterId,
      page: page,
      limit: limit,
    );
    final cachedMeta =
        await _localDataSource.getCharacterIssueListResultsMeta(
      characterId,
      page: page,
      limit: limit,
    );

    if (!forceRefresh && cachedDtos != null && cachedDtos.isNotEmpty) {
      final isFresh =
          cachedAt != null &&
          MetronCachePolicies.characterIssueList.isFresh(cachedAt, _now());
      if (!isFresh) {
        _refreshInBackground(
          task: () async {
            final remotePage = await _remoteDataSource.getCharacterIssueList(
              characterId,
              page: page,
              limit: limit,
              cancelToken: cancelToken,
            );
            await _localDataSource.cacheCharacterIssueListResults(
              characterId,
              remotePage.results,
              page: page,
              limit: limit,
              count: remotePage.count,
              next: remotePage.next,
              previous: remotePage.previous,
            );
            _indexSeriesNamesFromIssueList(remotePage.results);
          },
          cacheKey: 'character_issue_list:$characterId:$page',
          cooldown: MetronCachePolicies.characterIssueList.refreshCooldown,
        );
      }
      if (cachedMeta != null) {
        return CharacterIssueListPage(
          count: cachedMeta.count,
          next: cachedMeta.next,
          previous: cachedMeta.previous,
          results: cachedDtos.map((entry) => entry.toEntity()).toList(),
          currentPage: page,
        );
      }
    }

    try {
      final key = '$characterId|$page|$forceRefresh';
      return _coalesce(_characterIssueListInFlight, key, () async {
        final remotePage = await _remoteDataSource.getCharacterIssueList(
          characterId,
          page: page,
          limit: limit,
          cancelToken: cancelToken,
        );
        await _localDataSource.cacheCharacterIssueListResults(
          characterId,
          remotePage.results,
          page: page,
          limit: limit,
          count: remotePage.count,
          next: remotePage.next,
          previous: remotePage.previous,
        );
        _indexSeriesNamesFromIssueList(remotePage.results);
        return CharacterIssueListPage(
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
      if (cachedDtos != null && cachedDtos.isNotEmpty && cachedMeta != null) {
        return CharacterIssueListPage(
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
  Future<CreatorListPage> searchCreators(
    String query, {
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
            final remotePage = await _remoteDataSource.searchCreators(
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
          cacheKey: 'search:creator:$query:$page',
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
      final remotePage = await _remoteDataSource.searchCreators(
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
        results:
            remotePage.results.map((entry) => entry.toEntity()).toList(),
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

  @override
  Future<CreatorDetails> getCreatorDetails(
    int creatorId, {
    bool forceRefresh = false,
  }) async {
    final cachedDto = await _localDataSource.getCreatorDetails(creatorId);
    final cachedAt =
        await _localDataSource.getCreatorDetailsCachedAt(creatorId);

    if (!forceRefresh && cachedDto != null) {
      final isFresh =
          cachedAt != null &&
          MetronCachePolicies.creatorDetails.isFresh(cachedAt, _now());
      if (!isFresh) {
        _refreshInBackground(
          task: () async {
            await _creatorDetailsGate.acquire();
            try {
              final remoteDto =
                  await _remoteDataSource.getCreatorDetails(creatorId);
              await _localDataSource.cacheCreatorDetails(remoteDto);
            } finally {
              _creatorDetailsGate.release();
            }
          },
          cacheKey: 'creator_details:$creatorId',
          cooldown: MetronCachePolicies.creatorDetails.refreshCooldown,
        );
      }
      return cachedDto.toEntity();
    }

    try {
      await _creatorDetailsGate.acquire();
      try {
        final remoteDto =
            await _remoteDataSource.getCreatorDetails(creatorId);
        await _localDataSource.cacheCreatorDetails(remoteDto);
        return remoteDto.toEntity();
      } finally {
        _creatorDetailsGate.release();
      }
    } catch (_) {
      if (cachedDto != null) {
        return cachedDto.toEntity();
      }
      rethrow;
    }
  }

  @override
  Future<UniverseListPage> searchUniverses(
    String query, {
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  }) async {
    final cachedDtos = await _localDataSource.getUniverseSearchResults(
      query,
      page: page,
      limit: limit,
    );
    final cachedAt = await _localDataSource.getUniverseSearchResultsCachedAt(
      query,
      page: page,
      limit: limit,
    );
    final cachedMeta = await _localDataSource.getUniverseSearchResultsMeta(
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
            final remotePage = await _remoteDataSource.searchUniverses(
              query,
              page: page,
              limit: limit,
              cancelToken: cancelToken,
            );
            await _localDataSource.cacheUniverseSearchResults(
              query,
              remotePage.results,
              page: page,
              limit: limit,
              count: remotePage.count,
              next: remotePage.next,
              previous: remotePage.previous,
            );
          },
          cacheKey: 'search:universe:$query:$page',
          cooldown: MetronCachePolicies.universeSearchResults.refreshCooldown,
        );
      }
      if (cachedMeta != null) {
        return UniverseListPage(
          count: cachedMeta.count,
          next: cachedMeta.next,
          previous: cachedMeta.previous,
          results: cachedDtos.map((entry) => entry.toEntity()).toList(),
          currentPage: page,
        );
      }
    }

    try {
      final remotePage = await _remoteDataSource.searchUniverses(
        query,
        page: page,
        limit: limit,
        cancelToken: cancelToken,
      );
      await _localDataSource.cacheUniverseSearchResults(
        query,
        remotePage.results,
        page: page,
        limit: limit,
        count: remotePage.count,
        next: remotePage.next,
        previous: remotePage.previous,
      );
      return UniverseListPage(
        count: remotePage.count,
        next: remotePage.next,
        previous: remotePage.previous,
        results:
            remotePage.results.map((entry) => entry.toEntity()).toList(),
        currentPage: page,
      );
    } catch (error) {
      if (_isCancelled(error)) rethrow;
      if (cachedDtos != null && cachedDtos.isNotEmpty && cachedMeta != null) {
        return UniverseListPage(
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
  Future<UniverseDetails> getUniverseDetails(
    int universeId, {
    bool forceRefresh = false,
  }) async {
    final cachedDto = await _localDataSource.getUniverseDetails(universeId);
    final cachedAt =
        await _localDataSource.getUniverseDetailsCachedAt(universeId);

    if (!forceRefresh && cachedDto != null) {
      final isFresh =
          cachedAt != null &&
          MetronCachePolicies.universeDetails.isFresh(cachedAt, _now());
      if (!isFresh) {
        _refreshInBackground(
          task: () async {
            await _universeDetailsGate.acquire();
            try {
              final remoteDto =
                  await _remoteDataSource.getUniverseDetails(universeId);
              await _localDataSource.cacheUniverseDetails(remoteDto);
            } finally {
              _universeDetailsGate.release();
            }
          },
          cacheKey: 'universe_details:$universeId',
          cooldown: MetronCachePolicies.universeDetails.refreshCooldown,
        );
      }
      return cachedDto.toEntity();
    }

    try {
      await _universeDetailsGate.acquire();
      try {
        final remoteDto =
            await _remoteDataSource.getUniverseDetails(universeId);
        await _localDataSource.cacheUniverseDetails(remoteDto);
        return remoteDto.toEntity();
      } finally {
        _universeDetailsGate.release();
      }
    } catch (_) {
      if (cachedDto != null) {
        return cachedDto.toEntity();
      }
      rethrow;
    }
  }

  @override
  Future<ImprintListPage> searchImprints(
    String query, {
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
            final remotePage = await _remoteDataSource.searchImprints(
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
          cacheKey: 'search:imprint:$query:$page',
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
      final remotePage = await _remoteDataSource.searchImprints(
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
        results:
            remotePage.results.map((entry) => entry.toEntity()).toList(),
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

  @override
  Future<ImprintDetails> getImprintDetails(
    int imprintId, {
    bool forceRefresh = false,
  }) async {
    final cachedDto = await _localDataSource.getImprintDetails(imprintId);
    final cachedAt =
        await _localDataSource.getImprintDetailsCachedAt(imprintId);

    if (!forceRefresh && cachedDto != null) {
      final isFresh =
          cachedAt != null &&
          MetronCachePolicies.universeDetails.isFresh(cachedAt, _now());
      if (!isFresh) {
        _refreshInBackground(
          task: () async {
            await _imprintDetailsGate.acquire();
            try {
              final remoteDto =
                  await _remoteDataSource.getImprintDetails(imprintId);
              await _localDataSource.cacheImprintDetails(remoteDto);
            } finally {
              _imprintDetailsGate.release();
            }
          },
          cacheKey: 'imprint_details:$imprintId',
          cooldown: MetronCachePolicies.universeDetails.refreshCooldown,
        );
      }
      return cachedDto.toEntity();
    }

    try {
      await _imprintDetailsGate.acquire();
      try {
        final remoteDto =
            await _remoteDataSource.getImprintDetails(imprintId);
        await _localDataSource.cacheImprintDetails(remoteDto);
        return remoteDto.toEntity();
      } finally {
        _imprintDetailsGate.release();
      }
    } catch (_) {
      if (cachedDto != null) {
        return cachedDto.toEntity();
      }
      rethrow;
    }
  }

  @override
  Future<TeamListPage> searchTeams(
    String query, {
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  }) async {
    final cachedDtos = await _localDataSource.getTeamSearchResults(
      query,
      page: page,
      limit: limit,
    );
    final cachedAt = await _localDataSource.getTeamSearchResultsCachedAt(
      query,
      page: page,
      limit: limit,
    );
    final cachedMeta = await _localDataSource.getTeamSearchResultsMeta(
      query,
      page: page,
      limit: limit,
    );

    if (!forceRefresh && cachedDtos != null && cachedDtos.isNotEmpty) {
      final isFresh =
          cachedAt != null &&
          MetronCachePolicies.teamSearchResults.isFresh(cachedAt, _now());
      if (!isFresh) {
        _refreshInBackground(
          task: () async {
            final remotePage = await _remoteDataSource.searchTeams(
              query,
              page: page,
              limit: limit,
              cancelToken: cancelToken,
            );
            await _localDataSource.cacheTeamSearchResults(
              query,
              remotePage.results,
              page: page,
              limit: limit,
              count: remotePage.count,
              next: remotePage.next,
              previous: remotePage.previous,
            );
          },
          cacheKey: 'search:team:$query:$page',
          cooldown: MetronCachePolicies.teamSearchResults.refreshCooldown,
        );
      }
      if (cachedMeta != null) {
        return TeamListPage(
          count: cachedMeta.count,
          next: cachedMeta.next,
          previous: cachedMeta.previous,
          results: cachedDtos.map((entry) => entry.toEntity()).toList(),
          currentPage: page,
        );
      }
    }

    try {
      final remotePage = await _remoteDataSource.searchTeams(
        query,
        page: page,
        limit: limit,
        cancelToken: cancelToken,
      );
      await _localDataSource.cacheTeamSearchResults(
        query,
        remotePage.results,
        page: page,
        limit: limit,
        count: remotePage.count,
        next: remotePage.next,
        previous: remotePage.previous,
      );
      return TeamListPage(
        count: remotePage.count,
        next: remotePage.next,
        previous: remotePage.previous,
        results: remotePage.results.map((entry) => entry.toEntity()).toList(),
        currentPage: page,
      );
    } catch (error) {
      if (_isCancelled(error)) rethrow;
      if (cachedDtos != null && cachedDtos.isNotEmpty && cachedMeta != null) {
        return TeamListPage(
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
  Future<TeamDetails> getTeamDetails(
    int teamId, {
    bool forceRefresh = false,
  }) async {
    final cachedDto = await _localDataSource.getTeamDetails(teamId);
    final cachedAt =
        await _localDataSource.getTeamDetailsCachedAt(teamId);

    if (!forceRefresh && cachedDto != null) {
      final isFresh =
          cachedAt != null &&
          MetronCachePolicies.teamDetails.isFresh(cachedAt, _now());
      if (!isFresh) {
        _refreshInBackground(
          task: () async {
            await _teamDetailsGate.acquire();
            try {
              final remoteDto =
                  await _remoteDataSource.getTeamDetails(teamId);
              await _localDataSource.cacheTeamDetails(remoteDto);
            } finally {
              _teamDetailsGate.release();
            }
          },
          cacheKey: 'team_details:$teamId',
          cooldown: MetronCachePolicies.teamDetails.refreshCooldown,
        );
      }
      return cachedDto.toEntity();
    }

    try {
      await _teamDetailsGate.acquire();
      try {
        final remoteDto =
            await _remoteDataSource.getTeamDetails(teamId);
        await _localDataSource.cacheTeamDetails(remoteDto);
        return remoteDto.toEntity();
      } finally {
        _teamDetailsGate.release();
      }
    } catch (_) {
      if (cachedDto != null) {
        return cachedDto.toEntity();
      }
      rethrow;
    }
  }

  @override
  Future<PublisherListPage> searchPublishers(
    String query, {
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
            final remotePage = await _remoteDataSource.searchPublishers(
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
          cacheKey: 'search:publisher:$query:$page',
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
      final remotePage = await _remoteDataSource.searchPublishers(
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
        results:
            remotePage.results.map((entry) => entry.toEntity()).toList(),
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

  @override
  Future<PublisherDetails> getPublisherDetails(
    int publisherId, {
    bool forceRefresh = false,
  }) async {
    final cachedDto = await _localDataSource.getPublisherDetails(publisherId);
    final cachedAt =
        await _localDataSource.getPublisherDetailsCachedAt(publisherId);

    if (!forceRefresh && cachedDto != null) {
      final isFresh =
          cachedAt != null &&
          MetronCachePolicies.universeDetails.isFresh(cachedAt, _now());
      if (!isFresh) {
        _refreshInBackground(
          task: () async {
            await _publisherDetailsGate.acquire();
            try {
              final remoteDto =
                  await _remoteDataSource.getPublisherDetails(publisherId);
              await _localDataSource.cachePublisherDetails(remoteDto);
            } finally {
              _publisherDetailsGate.release();
            }
          },
          cacheKey: 'publisher_details:$publisherId',
          cooldown: MetronCachePolicies.universeDetails.refreshCooldown,
        );
      }
      return cachedDto.toEntity();
    }

    try {
      await _publisherDetailsGate.acquire();
      try {
        final remoteDto =
            await _remoteDataSource.getPublisherDetails(publisherId);
        await _localDataSource.cachePublisherDetails(remoteDto);
        return remoteDto.toEntity();
      } finally {
        _publisherDetailsGate.release();
      }
    } catch (_) {
      if (cachedDto != null) {
        return cachedDto.toEntity();
      }
      rethrow;
    }
  }

  @override
  Future<SeriesListPage> getPublisherSeriesList(
    int publisherId, {
    int page = 1,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  }) async {
    final cachedDtos = await _localDataSource.getPublisherSeriesListResults(
      publisherId,
      page: page,
      limit: metronDefaultPageSize,
    );
    final cachedAt =
        await _localDataSource.getPublisherSeriesListResultsCachedAt(
      publisherId,
      page: page,
      limit: metronDefaultPageSize,
    );
    final cachedMeta =
        await _localDataSource.getPublisherSeriesListResultsMeta(
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
            final remotePage = await _remoteDataSource.getPublisherSeriesList(
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
          },
          cacheKey: 'publisher_series_list:$publisherId:$page',
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
      final remotePage = await _remoteDataSource.getPublisherSeriesList(
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
      return SeriesListPage(
        count: remotePage.count,
        next: remotePage.next,
        previous: remotePage.previous,
        results:
            remotePage.results.map((entry) => entry.toEntity()).toList(),
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
