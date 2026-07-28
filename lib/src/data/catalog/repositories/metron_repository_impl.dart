import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:takion/src/core/constants/pagination.dart';
import 'package:takion/src/core/cache/cache_policy.dart';
import 'package:takion/src/core/logging/app_logger.dart';
import 'package:takion/src/core/performance/performance_metrics.dart';
import 'package:takion/src/data/catalog/datasources/local/metron_local_data_source.dart';
import 'package:takion/src/data/catalog/datasources/remote/metron_remote_data_source.dart';
import 'package:takion/src/data/catalog/datasources/local/series_name_index.dart';
import 'package:takion/src/data/common/drift/database.dart'
    hide MetronReadingListItem, SeriesNameIndex;
import 'package:takion/src/data/common/drift/daos/junction_dao.dart';
import 'package:takion/src/data/common/drift/daos/metron_entity_dao.dart';
import 'package:takion/src/data/catalog/dto/dto.dart';
import 'package:takion/src/domain/entities.dart';
import 'package:takion/src/domain/repositories.dart';

part 'metron_repository_impl_releases.dart';
part 'metron_repository_impl_issues.dart';
part 'metron_repository_impl_series.dart';
part 'metron_repository_impl_characters.dart';
part 'metron_repository_impl_creators.dart';
part 'metron_repository_impl_universes.dart';
part 'metron_repository_impl_imprints.dart';
part 'metron_repository_impl_teams.dart';
part 'metron_repository_impl_publishers.dart';
part 'metron_repository_impl_arcs.dart';
part 'metron_repository_impl_reading_lists.dart';

// ignore_for_file: unused_element

mixin _RepositoryState {
  MetronRemoteDataSource get _remoteDataSource;
  MetronLocalDataSource get _localDataSource;
  MetronEntityDao get _metronEntityDao;
  JunctionDao get _junctionDao;
  DateTime Function() get _now;
  Map<String, Future<List<IssueList>>> get _weeklyInFlight;
  Map<String, Future<IssueDetails>> get _issueDetailsInFlight;
  Map<String, Future<IssueSearchPage>> get _issueListInFlight;
  Map<String, Future<SeriesListPage>> get _seriesListInFlight;
  Map<String, Future<SeriesIssueListPage>> get _seriesIssueListInFlight;
  Map<String, Future<CharacterIssueListPage>> get _characterIssueListInFlight;
  Map<String, Future<SeriesDetails>> get _seriesDetailsInFlight;
  Map<String, Future<List<IssueList>>> get _focReleasesInFlight;
  _AsyncConcurrencyGate get _issueDetailsGate;
  Map<String, Future<ArcListPage>> get _arcSearchInFlight;
  Map<String, Future<ArcIssueListPage>> get _arcIssueListInFlight;
  Map<String, Future<CharacterIssueListPage>> get _teamIssueListInFlight;
  Map<String, DateTime> get _lastBackgroundRefresh;
  int get _backgroundRefreshCount;
  set _backgroundRefreshCount(int value);
  SeriesNameIndex get _seriesNameIndex;

  Future<T> _coalesce<T>(
    Map<String, Future<T>> inFlight,
    String key,
    Future<T> Function() loader, {
    Duration timeout = const Duration(seconds: 30),
  });
  bool _isCancelled(Object error);
  void _refreshInBackground({
    required Future<void> Function() task,
    required String cacheKey,
    required Duration cooldown,
  });
  void _indexSeriesName(String name);
  void _indexSeriesNamesFromIssueList(Iterable<IssueListDto> issues);
  void _indexSeriesNamesFromIssueDetails(IssueDetailsDto issue);
  Future<String> _correctSearchQuery(String query);
  Future<T> _fetchWithConditional<T>({
    required Future<Response> fetch,
    required Future<T> Function() cached,
    required Future<void> Function(Response response) cache,
    required Future<void> Function() updateTtl,
  });

  void _upsertIssueListStubs(Iterable<IssueListDto> dtos) {
    final issueStubs = <MetronIssuesCompanion>[];
    final seriesStubs = <MetronSeriesCompanion>[];

    for (final dto in dtos) {
      issueStubs.add(
        MetronIssuesCompanion(
          id: Value(dto.id),
          number: Value(dto.number),
          seriesId: Value(dto.series?.id),
          imageUrl: Value(dto.image),
          storeDate: Value(
            dto.storeDate != null
                ? DateTime.tryParse(dto.storeDate!)?.toIso8601String()
                : null,
          ),
          coverDate: Value(
            dto.coverDate != null
                ? DateTime.tryParse(dto.coverDate!)?.toIso8601String()
                : null,
          ),
          coverHash: Value(dto.coverHash),
          isFullyHydrated: const Value(false),
        ),
      );
      final series = dto.series;
      if (series != null) {
        seriesStubs.add(
          MetronSeriesCompanion(
            id: Value(series.id ?? 0),
            name: Value(series.name),
            yearBegan: Value(series.yearBegan),
            volume: Value(series.volume),
            isFullyHydrated: const Value(false),
          ),
        );
      }
    }

    if (issueStubs.isNotEmpty) {
      unawaited(_metronEntityDao.upsertIssueStubsBatch(issueStubs));
    }
    if (seriesStubs.isNotEmpty) {
      unawaited(_metronEntityDao.upsertSeriesStubsBatch(seriesStubs));
    }
  }

  void _upsertSeriesListStubs(Iterable<SeriesListDto> dtos) {
    final seriesStubs = <MetronSeriesCompanion>[];
    for (final dto in dtos) {
      seriesStubs.add(
        MetronSeriesCompanion(
          id: Value(dto.id),
          name: Value(dto.series),
          yearBegan: Value(dto.yearBegan),
          yearEnd: Value(dto.yearEnd),
          volume: Value(dto.volume),
          issueCount: Value(dto.issueCount),
          modified: Value(dto.modified),
          isFullyHydrated: const Value(false),
        ),
      );
    }
    if (seriesStubs.isNotEmpty) {
      unawaited(_metronEntityDao.upsertSeriesStubsBatch(seriesStubs));
    }
  }
}

class MetronRepositoryImpl
    with
        _RepositoryState,
        _ReleasesRepositoryMixin,
        _IssuesRepositoryMixin,
        _SeriesRepositoryMixin,
        _CharactersRepositoryMixin,
        _CreatorsRepositoryMixin,
        _UniversesRepositoryMixin,
        _ImprintsRepositoryMixin,
        _TeamsRepositoryMixin,
        _PublishersRepositoryMixin,
        _ArcsRepositoryMixin,
        _ReadingListsRepositoryMixin
    implements CatalogRepository {
  @override
  final MetronRemoteDataSource _remoteDataSource;
  @override
  final MetronLocalDataSource _localDataSource;
  @override
  final MetronEntityDao _metronEntityDao;
  @override
  final JunctionDao _junctionDao;
  @override
  final DateTime Function() _now;
  @override
  final Map<String, Future<List<IssueList>>> _weeklyInFlight =
      <String, Future<List<IssueList>>>{};
  @override
  final Map<String, Future<IssueDetails>> _issueDetailsInFlight =
      <String, Future<IssueDetails>>{};
  @override
  final Map<String, Future<IssueSearchPage>> _issueListInFlight =
      <String, Future<IssueSearchPage>>{};
  @override
  final Map<String, Future<SeriesListPage>> _seriesListInFlight =
      <String, Future<SeriesListPage>>{};
  @override
  final Map<String, Future<SeriesIssueListPage>> _seriesIssueListInFlight =
      <String, Future<SeriesIssueListPage>>{};
  @override
  final Map<String, Future<CharacterIssueListPage>>
  _characterIssueListInFlight = <String, Future<CharacterIssueListPage>>{};
  @override
  final Map<String, Future<SeriesDetails>> _seriesDetailsInFlight =
      <String, Future<SeriesDetails>>{};
  @override
  final Map<String, Future<List<IssueList>>> _focReleasesInFlight =
      <String, Future<List<IssueList>>>{};
  @override
  final _AsyncConcurrencyGate _issueDetailsGate = _AsyncConcurrencyGate(4);
  @override
  final Map<String, Future<ArcListPage>> _arcSearchInFlight =
      <String, Future<ArcListPage>>{};
  @override
  final Map<String, Future<ArcIssueListPage>> _arcIssueListInFlight =
      <String, Future<ArcIssueListPage>>{};
  @override
  final Map<String, Future<CharacterIssueListPage>> _teamIssueListInFlight =
      <String, Future<CharacterIssueListPage>>{};
  @override
  final Map<String, DateTime> _lastBackgroundRefresh = {};
  @override
  int _backgroundRefreshCount = 0;
  static const int _maxConcurrentBackgroundRefreshes = 3;
  @override
  final SeriesNameIndex _seriesNameIndex;

  MetronRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._metronEntityDao,
    this._junctionDao,
    this._seriesNameIndex, {
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  @override
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

  @override
  bool _isCancelled(Object error) =>
      error is DioException && error.type == DioExceptionType.cancel;

  @override
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
        () => task()
            .catchError((e) {
              AppLogger.debug(
                'Background refresh failed for $cacheKey',
                error: e,
              );
            })
            .whenComplete(() {
              _backgroundRefreshCount--;
            }),
        zoneValues: {#opencode_background: true},
      ),
    );
  }

  @override
  void _indexSeriesName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    unawaited(_seriesNameIndex.add(trimmed));
  }

  @override
  void _indexSeriesNamesFromIssueList(Iterable<IssueListDto> issues) {
    for (final issue in issues) {
      final series = issue.series;
      if (series != null && series.name.trim().isNotEmpty) {
        _indexSeriesName(series.name);
      }
    }
  }

  @override
  void _indexSeriesNamesFromIssueDetails(IssueDetailsDto issue) {
    final series = issue.series;
    if (series != null && series.name.trim().isNotEmpty) {
      _indexSeriesName(series.name);
    }
  }

  @override
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
  Future<T> _fetchWithConditional<T>({
    required Future<Response> fetch,
    required Future<T> Function() cached,
    required Future<void> Function(Response response) cache,
    required Future<void> Function() updateTtl,
  }) async {
    try {
      final response = await fetch;
      if (response.statusCode == 304) {
        await updateTtl();
        return cached();
      }
      await cache(response);
      return cached();
    } on DioException catch (e) {
      if (e.response?.statusCode == 304) {
        await updateTtl();
        return cached();
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
