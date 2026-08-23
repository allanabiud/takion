import "dart:async";
import "dart:collection";
import "dart:convert";
import "package:dio/dio.dart";
import "package:drift/drift.dart";
import "package:takion/src/core/constants/pagination.dart";
import "package:takion/src/core/cache/cache_policy.dart";
import "package:takion/src/core/logging/app_logger.dart";
import "package:takion/src/core/network/rate_limit_interceptor.dart"
    show backgroundZoneKey;
import "package:takion/src/core/performance/performance_metrics.dart";
import "package:takion/src/core/utils/json_utils.dart";
import "package:takion/src/data/catalog/datasources/local/metron_local_data_source.dart";
import "package:takion/src/data/catalog/datasources/remote/metron_remote_data_source.dart";
import "package:takion/src/data/catalog/datasources/local/series_name_index.dart";
import "package:takion/src/data/common/drift/database.dart"
    hide MetronReadingListItem, SeriesNameIndex;
import "package:takion/src/data/common/drift/daos/junction_dao.dart";
import "package:takion/src/data/common/drift/daos/metron_entity_dao.dart";
import "package:takion/src/core/cache/metron_metadata_cache.dart";
import "package:takion/src/data/catalog/dto/dto.dart";
import "package:takion/src/data/reading_list/dto/dto.dart";
import "package:takion/src/domain/entities.dart";
import "package:takion/src/domain/repositories.dart";

part "metron_repository_impl_releases.dart";
part "metron_repository_impl_issues.dart";
part "metron_repository_impl_series.dart";
part "metron_repository_impl_characters.dart";
part "metron_repository_impl_creators.dart";
part "metron_repository_impl_universes.dart";
part "metron_repository_impl_imprints.dart";
part "metron_repository_impl_teams.dart";
part "metron_repository_impl_publishers.dart";
part "metron_repository_impl_arcs.dart";
part "metron_repository_impl_reading_lists.dart";

mixin _RepositoryState {
  MetronRemoteDataSource get _remoteDataSource;
  MetronLocalDataSource get _localDataSource;
  MetronEntityDao get _metronEntityDao;
  JunctionDao get _junctionDao;
  MetronMetadataCache? get _metadataCache;
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
  Map<String, Future<IssueSearchPage>> get _issueSearchInFlight;
  Map<String, Future<SeriesSearchPage>> get _seriesSearchInFlight;
  Map<String, Future<CharacterListPage>> get _characterSearchInFlight;
  Map<String, Future<CreatorListPage>> get _creatorSearchInFlight;
  Map<String, Future<UniverseListPage>> get _universeSearchInFlight;
  Map<String, Future<ImprintListPage>> get _imprintSearchInFlight;
  Map<String, Future<TeamListPage>> get _teamSearchInFlight;
  Map<String, Future<PublisherListPage>> get _publisherSearchInFlight;
  Map<String, Future<ArcIssueListPage>> get _arcIssueListInFlight;
  Map<String, Future<CharacterIssueListPage>> get _teamIssueListInFlight;
  Map<String, Future<ArcListPage>> get _arcListInFlight;
  Map<String, Future<CharacterListPage>> get _characterListInFlight;
  Map<String, Future<CreatorListPage>> get _creatorListInFlight;
  Map<String, Future<ImprintListPage>> get _imprintListInFlight;
  Map<String, Future<PublisherListPage>> get _publisherListInFlight;
  Map<String, Future<TeamListPage>> get _teamListInFlight;
  Map<String, Future<UniverseListPage>> get _universeListInFlight;
  Map<String, Future<MetronReadingListPage>> get _readingListInFlight;

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
  Future<T> _fetchWithConditional<T>({
    required Future<Response> fetch,
    required Future<T> Function() cached,
    required Future<void> Function(Response response) cache,
    required Future<void> Function() updateTtl,
  });

  /// A page with no results but a non-zero total count is a page that does not
  /// exist (e.g. requested past the last page). Caching it would poison the
  /// cache and make the empty state persist across sessions.
  bool _isValidIssueListPage({required int count, required int resultCount}) {
    return resultCount > 0 || count == 0;
  }

  /// The real per-page size reported by the API, when the response indicates
  /// more than one page. Null when only one page exists or size is unknown.
  int? _issuePageSize({required int resultCount, required bool hasNext}) {
    return hasNext && resultCount > 0 ? resultCount : null;
  }

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
      if (series != null && series.id != null) {
        seriesStubs.add(
          MetronSeriesCompanion(
            id: Value(series.id!),
            name: Value(series.name),
            yearBegan: Value(series.yearBegan),
            volume: Value(series.volume),
            isFullyHydrated: const Value(false),
          ),
        );
        if (series.name.trim().isNotEmpty) {
          _metadataCache?.indexSeries(series.id!, series.name.trim());
        }
      }
    }

    if (issueStubs.isNotEmpty) {
      unawaited(_metronEntityDao.upsertIssueStubsBatch(issueStubs));
    }
    if (seriesStubs.isNotEmpty) {
      unawaited(_metronEntityDao.upsertSeriesStubsBatch(seriesStubs));
    }
    _autoAddPullListEntries(dtos);
  }

  /// Automatically adds pull list entries for issues belonging to a series the
  /// user is subscribed to with auto-add-to-pull-list enabled. Runs whenever
  /// issue data is ingested from Metron so new issues appear as "pulled" across
  /// the app without waiting for the throttled reconciler.
  void _autoAddPullListEntries(Iterable<IssueListDto> dtos) {
    final seriesIds = dtos.map((d) => d.series?.id).whereType<int>().toSet();
    if (seriesIds.isEmpty) return;
    unawaited(_autoAddPullListEntriesAsync(dtos, seriesIds));
  }

  Future<void> _autoAddPullListEntriesAsync(
    Iterable<IssueListDto> dtos,
    Set<int> seriesIds,
  ) async {
    try {
      final database = _metronEntityDao.attachedDatabase;
      final subscriptions = await database.subscriptionDao.getBySeriesIds(
        seriesIds.toList(),
      );
      if (subscriptions.isEmpty) return;
      final autoAddSeriesIds = subscriptions
          .where((s) => s.isActive && s.autoAddPull)
          .map((s) => s.metronSeriesId)
          .toSet();
      if (autoAddSeriesIds.isEmpty) return;

      final entries =
          <({int metronSeriesId, int metronIssueId, DateTime? releaseDate})>[];
      for (final dto in dtos) {
        final seriesId = dto.series?.id;
        if (seriesId == null) continue;
        if (!autoAddSeriesIds.contains(seriesId)) continue;
        final rawRelease = dto.storeDate ?? dto.coverDate;
        final releaseDate = rawRelease != null
            ? DateTime.tryParse(rawRelease)
            : null;
        entries.add((
          metronSeriesId: seriesId,
          metronIssueId: dto.id,
          releaseDate: releaseDate,
        ));
      }
      if (entries.isEmpty) return;
      await database.pullListDao.upsertSubscriptionEntries(entries);
    } catch (e) {
      AppLogger.debug("Auto-add pull list entries failed", error: e);
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
      if (dto.series.trim().isNotEmpty) {
        _metadataCache?.indexSeries(dto.id, dto.series.trim());
      }
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
  final MetronMetadataCache? _metadataCache;
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
  final Map<String, Future<IssueSearchPage>> _issueSearchInFlight =
      <String, Future<IssueSearchPage>>{};
  @override
  final Map<String, Future<SeriesSearchPage>> _seriesSearchInFlight =
      <String, Future<SeriesSearchPage>>{};
  @override
  final Map<String, Future<CharacterListPage>> _characterSearchInFlight =
      <String, Future<CharacterListPage>>{};
  @override
  final Map<String, Future<CreatorListPage>> _creatorSearchInFlight =
      <String, Future<CreatorListPage>>{};
  @override
  final Map<String, Future<UniverseListPage>> _universeSearchInFlight =
      <String, Future<UniverseListPage>>{};
  @override
  final Map<String, Future<ImprintListPage>> _imprintSearchInFlight =
      <String, Future<ImprintListPage>>{};
  @override
  final Map<String, Future<TeamListPage>> _teamSearchInFlight =
      <String, Future<TeamListPage>>{};
  @override
  final Map<String, Future<PublisherListPage>> _publisherSearchInFlight =
      <String, Future<PublisherListPage>>{};
  @override
  final Map<String, Future<ArcIssueListPage>> _arcIssueListInFlight =
      <String, Future<ArcIssueListPage>>{};
  @override
  final Map<String, Future<CharacterIssueListPage>> _teamIssueListInFlight =
      <String, Future<CharacterIssueListPage>>{};
  @override
  final Map<String, Future<ArcListPage>> _arcListInFlight =
      <String, Future<ArcListPage>>{};
  @override
  final Map<String, Future<CharacterListPage>> _characterListInFlight =
      <String, Future<CharacterListPage>>{};
  @override
  final Map<String, Future<CreatorListPage>> _creatorListInFlight =
      <String, Future<CreatorListPage>>{};
  @override
  final Map<String, Future<ImprintListPage>> _imprintListInFlight =
      <String, Future<ImprintListPage>>{};
  @override
  final Map<String, Future<PublisherListPage>> _publisherListInFlight =
      <String, Future<PublisherListPage>>{};
  @override
  final Map<String, Future<TeamListPage>> _teamListInFlight =
      <String, Future<TeamListPage>>{};
  @override
  final Map<String, Future<UniverseListPage>> _universeListInFlight =
      <String, Future<UniverseListPage>>{};
  @override
  final Map<String, Future<MetronReadingListPage>> _readingListInFlight =
      <String, Future<MetronReadingListPage>>{};
  final Map<String, DateTime> _lastBackgroundRefresh = {};
  int _backgroundRefreshCount = 0;
  static const int _maxConcurrentBackgroundRefreshes = 2;
  final SeriesNameIndex _seriesNameIndex;

  MetronRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._metronEntityDao,
    this._junctionDao,
    this._seriesNameIndex, {
    MetronMetadataCache? metadataCache,
    DateTime Function()? now,
  }) : _metadataCache = metadataCache,
       _now = now ?? DateTime.now;

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
                "Background refresh failed for $cacheKey",
                error: e,
              );
            })
            .whenComplete(() {
              _backgroundRefreshCount--;
            }),
        zoneValues: {backgroundZoneKey: true},
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
