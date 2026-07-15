import 'package:dio/dio.dart';
import 'dart:async';
import 'dart:collection';
import 'package:takion/src/core/constants/pagination.dart';
import 'package:takion/src/core/cache/cache_policy.dart';
import 'package:takion/src/core/performance/performance_metrics.dart';
import 'package:takion/src/data/datasources/metron_local_data_source.dart';
import 'package:takion/src/data/datasources/metron_remote_data_source.dart';
import 'package:takion/src/data/datasources/series_name_index.dart';
import 'package:takion/src/data/dto/dto.dart';
import 'package:takion/src/domain/entities/entities.dart';
import 'package:takion/src/domain/repositories/repositories.dart';

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
  DateTime Function() get _now;
  Map<String, Future<List<IssueList>>> get _weeklyInFlight;
  Map<String, Future<IssueDetails>> get _issueDetailsInFlight;
  Map<String, Future<IssueSearchPage>> get _issueListInFlight;
  Map<String, Future<SeriesListPage>> get _seriesListInFlight;
  Map<String, Future<SeriesIssueListPage>> get _seriesIssueListInFlight;
  Map<String, Future<CharacterIssueListPage>> get _characterIssueListInFlight;
  Map<String, Future<SeriesDetails>> get _seriesDetailsInFlight;
  Map<String, Future<List<IssueList>>> get _focReleasesInFlight;
  Map<String, Future<CharacterDetails>> get _characterDetailsInFlight;
  _AsyncConcurrencyGate get _issueDetailsGate;
  _AsyncConcurrencyGate get _characterDetailsGate;
  _AsyncConcurrencyGate get _creatorDetailsGate;
  _AsyncConcurrencyGate get _universeDetailsGate;
  _AsyncConcurrencyGate get _imprintDetailsGate;
  _AsyncConcurrencyGate get _teamDetailsGate;
  _AsyncConcurrencyGate get _publisherDetailsGate;
  _AsyncConcurrencyGate get _arcDetailsGate;
  Map<String, Future<ArcListPage>> get _arcSearchInFlight;
  Map<String, Future<ArcIssueListPage>> get _arcIssueListInFlight;
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
}

class MetronRepositoryImpl with
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
    implements MetronRepository {
  @override
  final MetronRemoteDataSource _remoteDataSource;
  @override
  final MetronLocalDataSource _localDataSource;
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
      _characterIssueListInFlight =
      <String, Future<CharacterIssueListPage>>{};
  @override
  final Map<String, Future<SeriesDetails>> _seriesDetailsInFlight =
      <String, Future<SeriesDetails>>{};
  @override
  final Map<String, Future<List<IssueList>>> _focReleasesInFlight =
      <String, Future<List<IssueList>>>{};
  @override
  final Map<String, Future<CharacterDetails>> _characterDetailsInFlight =
      <String, Future<CharacterDetails>>{};
  @override
  final _AsyncConcurrencyGate _issueDetailsGate = _AsyncConcurrencyGate(4);
  @override
  final _AsyncConcurrencyGate _characterDetailsGate = _AsyncConcurrencyGate(3);
  @override
  final _AsyncConcurrencyGate _creatorDetailsGate = _AsyncConcurrencyGate(3);
  @override
  final _AsyncConcurrencyGate _universeDetailsGate = _AsyncConcurrencyGate(3);
  @override
  final _AsyncConcurrencyGate _imprintDetailsGate = _AsyncConcurrencyGate(3);
  @override
  final _AsyncConcurrencyGate _teamDetailsGate = _AsyncConcurrencyGate(3);
  @override
  final _AsyncConcurrencyGate _publisherDetailsGate = _AsyncConcurrencyGate(3);
  @override
  final _AsyncConcurrencyGate _arcDetailsGate = _AsyncConcurrencyGate(3);
  @override
  final Map<String, Future<ArcListPage>> _arcSearchInFlight =
      <String, Future<ArcListPage>>{};
  @override
  final Map<String, Future<ArcIssueListPage>> _arcIssueListInFlight =
      <String, Future<ArcIssueListPage>>{};
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
        () => task().catchError((_) {}).whenComplete(() {
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
