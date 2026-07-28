import 'dart:convert';
import 'package:takion/src/data/common/drift/database.dart';
import 'package:takion/src/data/catalog/dto/dto.dart';

dynamic _decodeJson(String input) => jsonDecode(input);
String _encodeJson(Map<String, dynamic> input) => jsonEncode(input);
String _encodeJsonList(List<Map<String, dynamic>> input) => jsonEncode(input);

class IssueSearchPageCacheMeta {
  const IssueSearchPageCacheMeta({
    required this.count,
    this.next,
    this.previous,
  });

  final int count;
  final String? next;
  final String? previous;
}

class SeriesSearchPageCacheMeta {
  const SeriesSearchPageCacheMeta({
    required this.count,
    this.next,
    this.previous,
  });

  final int count;
  final String? next;
  final String? previous;
}

class SeriesListPageCacheMeta {
  const SeriesListPageCacheMeta({
    required this.count,
    this.next,
    this.previous,
  });

  final int count;
  final String? next;
  final String? previous;
}

class SeriesIssueListPageCacheMeta {
  const SeriesIssueListPageCacheMeta({
    required this.count,
    this.next,
    this.previous,
  });

  final int count;
  final String? next;
  final String? previous;
}

class CharacterSearchPageCacheMeta {
  const CharacterSearchPageCacheMeta({
    required this.count,
    this.next,
    this.previous,
  });

  final int count;
  final String? next;
  final String? previous;
}

class CreatorSearchPageCacheMeta {
  const CreatorSearchPageCacheMeta({
    required this.count,
    this.next,
    this.previous,
  });

  final int count;
  final String? next;
  final String? previous;
}

class UniverseSearchPageCacheMeta {
  const UniverseSearchPageCacheMeta({
    required this.count,
    this.next,
    this.previous,
  });

  final int count;
  final String? next;
  final String? previous;
}

class ImprintSearchPageCacheMeta {
  const ImprintSearchPageCacheMeta({
    required this.count,
    this.next,
    this.previous,
  });

  final int count;
  final String? next;
  final String? previous;
}

class CharacterIssueListPageCacheMeta {
  const CharacterIssueListPageCacheMeta({
    required this.count,
    this.next,
    this.previous,
  });

  final int count;
  final String? next;
  final String? previous;
}

class TeamSearchPageCacheMeta {
  const TeamSearchPageCacheMeta({
    required this.count,
    this.next,
    this.previous,
  });

  final int count;
  final String? next;
  final String? previous;
}

class TeamIssueListPageCacheMeta {
  const TeamIssueListPageCacheMeta({
    required this.count,
    this.next,
    this.previous,
  });

  final int count;
  final String? next;
  final String? previous;
}

class ArcSearchPageCacheMeta {
  const ArcSearchPageCacheMeta({required this.count, this.next, this.previous});

  final int count;
  final String? next;
  final String? previous;
}

class PublisherSearchPageCacheMeta {
  const PublisherSearchPageCacheMeta({
    required this.count,
    this.next,
    this.previous,
  });

  final int count;
  final String? next;
  final String? previous;
}

abstract class MetronLocalDataSource {
  Future<void> cacheWeeklyReleases(
    DateTime weekStart,
    List<IssueListDto> issues,
  );
  Future<List<IssueListDto>?> getWeeklyReleases(DateTime weekStart);
  Future<DateTime?> getWeeklyReleasesCachedAt(DateTime weekStart);
  Future<void> cacheFocReleases(DateTime weekStart, List<IssueListDto> issues);
  Future<List<IssueListDto>?> getFocReleases(DateTime weekStart);
  Future<DateTime?> getFocReleasesCachedAt(DateTime weekStart);
  Future<void> cacheIssueSearchResults(
    String query,
    List<IssueListDto> issues, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  });
  Future<List<IssueListDto>?> getIssueSearchResults(
    String query, {
    required int page,
    required int limit,
  });
  Future<DateTime?> getIssueSearchResultsCachedAt(
    String query, {
    required int page,
    required int limit,
  });
  Future<IssueSearchPageCacheMeta?> getIssueSearchResultsMeta(
    String query, {
    required int page,
    required int limit,
  });
  Future<void> cacheIssueListResults(
    List<IssueListDto> issues, {
    required int page,
    String? ordering,
    DateTime? modifiedGt,
    int? limit,
    required int count,
    String? next,
    String? previous,
  });
  Future<List<IssueListDto>?> getIssueListResults({
    required int page,
    String? ordering,
    DateTime? modifiedGt,
    int? limit,
  });
  Future<DateTime?> getIssueListResultsCachedAt({
    required int page,
    String? ordering,
    DateTime? modifiedGt,
    int? limit,
  });
  Future<IssueSearchPageCacheMeta?> getIssueListResultsMeta({
    required int page,
    String? ordering,
    DateTime? modifiedGt,
    int? limit,
  });
  Future<void> cacheSeriesSearchResults(
    String query,
    List<SeriesListDto> series, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  });
  Future<List<SeriesListDto>?> getSeriesSearchResults(
    String query, {
    required int page,
    required int limit,
  });
  Future<DateTime?> getSeriesSearchResultsCachedAt(
    String query, {
    required int page,
    required int limit,
  });
  Future<SeriesSearchPageCacheMeta?> getSeriesSearchResultsMeta(
    String query, {
    required int page,
    required int limit,
  });
  Future<void> cacheSeriesListResults(
    List<SeriesListDto> series, {
    required int page,
    required int limit,
    DateTime? modifiedGt,
    required int count,
    String? next,
    String? previous,
  });
  Future<List<SeriesListDto>?> getSeriesListResults({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  });
  Future<DateTime?> getSeriesListResultsCachedAt({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  });
  Future<SeriesListPageCacheMeta?> getSeriesListResultsMeta({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  });
  Future<void> cacheSeriesIssueListResults(
    int seriesId,
    List<IssueListDto> issues, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  });
  Future<List<IssueListDto>?> getSeriesIssueListResults(
    int seriesId, {
    required int page,
    required int limit,
  });
  Future<DateTime?> getSeriesIssueListResultsCachedAt(
    int seriesId, {
    required int page,
    required int limit,
  });
  Future<SeriesIssueListPageCacheMeta?> getSeriesIssueListResultsMeta(
    int seriesId, {
    required int page,
    required int limit,
  });
  Future<void> cacheCharacterSearchResults(
    String query,
    List<CharacterListDto> characters, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  });
  Future<List<CharacterListDto>?> getCharacterSearchResults(
    String query, {
    required int page,
    required int limit,
  });
  Future<DateTime?> getCharacterSearchResultsCachedAt(
    String query, {
    required int page,
    required int limit,
  });
  Future<CharacterSearchPageCacheMeta?> getCharacterSearchResultsMeta(
    String query, {
    required int page,
    required int limit,
  });
  Future<void> cacheCharacterIssueListResults(
    int characterId,
    List<IssueListDto> issues, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  });
  Future<List<IssueListDto>?> getCharacterIssueListResults(
    int characterId, {
    required int page,
    required int limit,
  });
  Future<DateTime?> getCharacterIssueListResultsCachedAt(
    int characterId, {
    required int page,
    required int limit,
  });
  Future<CharacterIssueListPageCacheMeta?> getCharacterIssueListResultsMeta(
    int characterId, {
    required int page,
    required int limit,
  });

  Future<void> cacheTeamIssueListResults(
    int teamId,
    List<IssueListDto> issues, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  });
  Future<List<IssueListDto>?> getTeamIssueListResults(
    int teamId, {
    required int page,
    required int limit,
  });
  Future<DateTime?> getTeamIssueListResultsCachedAt(
    int teamId, {
    required int page,
    required int limit,
  });
  Future<TeamIssueListPageCacheMeta?> getTeamIssueListResultsMeta(
    int teamId, {
    required int page,
    required int limit,
  });

  Future<void> cacheCreatorSearchResults(
    String query,
    List<CreatorListDto> creators, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  });

  Future<List<CreatorListDto>?> getCreatorSearchResults(
    String query, {
    required int page,
    required int limit,
  });

  Future<DateTime?> getCreatorSearchResultsCachedAt(
    String query, {
    required int page,
    required int limit,
  });

  Future<CreatorSearchPageCacheMeta?> getCreatorSearchResultsMeta(
    String query, {
    required int page,
    required int limit,
  });

  Future<void> cacheUniverseSearchResults(
    String query,
    List<UniverseListDto> universes, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  });

  Future<List<UniverseListDto>?> getUniverseSearchResults(
    String query, {
    required int page,
    required int limit,
  });

  Future<DateTime?> getUniverseSearchResultsCachedAt(
    String query, {
    required int page,
    required int limit,
  });

  Future<UniverseSearchPageCacheMeta?> getUniverseSearchResultsMeta(
    String query, {
    required int page,
    required int limit,
  });

  Future<void> cacheImprintSearchResults(
    String query,
    List<ImprintListDto> imprints, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  });

  Future<List<ImprintListDto>?> getImprintSearchResults(
    String query, {
    required int page,
    required int limit,
  });

  Future<DateTime?> getImprintSearchResultsCachedAt(
    String query, {
    required int page,
    required int limit,
  });

  Future<ImprintSearchPageCacheMeta?> getImprintSearchResultsMeta(
    String query, {
    required int page,
    required int limit,
  });

  Future<void> cacheTeamSearchResults(
    String query,
    List<TeamListDto> teams, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  });

  Future<List<TeamListDto>?> getTeamSearchResults(
    String query, {
    required int page,
    required int limit,
  });

  Future<DateTime?> getTeamSearchResultsCachedAt(
    String query, {
    required int page,
    required int limit,
  });

  Future<TeamSearchPageCacheMeta?> getTeamSearchResultsMeta(
    String query, {
    required int page,
    required int limit,
  });

  Future<void> cacheArcSearchResults(
    String query,
    List<ArcListDto> arcs, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  });

  Future<List<ArcListDto>?> getArcSearchResults(
    String query, {
    required int page,
    required int limit,
  });

  Future<DateTime?> getArcSearchResultsCachedAt(
    String query, {
    required int page,
    required int limit,
  });

  Future<ArcSearchPageCacheMeta?> getArcSearchResultsMeta(
    String query, {
    required int page,
    required int limit,
  });

  Future<void> cacheArcIssueListResults(
    int arcId,
    List<IssueListDto> issues, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  });

  Future<List<IssueListDto>?> getArcIssueListResults(
    int arcId, {
    required int page,
    required int limit,
  });

  Future<DateTime?> getArcIssueListResultsCachedAt(
    int arcId, {
    required int page,
    required int limit,
  });

  Future<SeriesIssueListPageCacheMeta?> getArcIssueListResultsMeta(
    int arcId, {
    required int page,
    required int limit,
  });

  Future<void> cachePublisherSearchResults(
    String query,
    List<PublisherListDto> publishers, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  });

  Future<List<PublisherListDto>?> getPublisherSearchResults(
    String query, {
    required int page,
    required int limit,
  });

  Future<DateTime?> getPublisherSearchResultsCachedAt(
    String query, {
    required int page,
    required int limit,
  });

  Future<PublisherSearchPageCacheMeta?> getPublisherSearchResultsMeta(
    String query, {
    required int page,
    required int limit,
  });

  Future<void> cachePublisherSeriesListResults(
    int publisherId,
    List<SeriesListDto> series, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  });

  Future<List<SeriesListDto>?> getPublisherSeriesListResults(
    int publisherId, {
    required int page,
    required int limit,
  });

  Future<DateTime?> getPublisherSeriesListResultsCachedAt(
    int publisherId, {
    required int page,
    required int limit,
  });

  Future<SeriesIssueListPageCacheMeta?> getPublisherSeriesListResultsMeta(
    int publisherId, {
    required int page,
    required int limit,
  });

  Future<void> cacheIssueDetailsResponse(
    int issueId,
    Map<String, dynamic> json,
  );
  Future<Map<String, dynamic>?> getCachedIssueDetailsResponse(int issueId);
  Future<DateTime?> getCachedIssueDetailsCachedAt(int issueId);

  Future<void> cacheSeriesDetailsResponse(
    int seriesId,
    Map<String, dynamic> json,
  );
  Future<Map<String, dynamic>?> getCachedSeriesDetailsResponse(int seriesId);
  Future<DateTime?> getCachedSeriesDetailsCachedAt(int seriesId);
}

class MetronLocalDataSourceImpl implements MetronLocalDataSource {
  final AppDatabase _db;

  MetronLocalDataSourceImpl(this._db);

  Future<void> _cacheList<T>(
    String cacheKey,
    String entityType,
    List<T> list,
    Map<String, dynamic> Function(T) toJson,
  ) async {
    final listJson = list.map((item) => toJson(item)).toList(growable: false);
    final payload = _encodeJsonList(listJson);
    await _db.apiCacheDao.put(
      cacheKey: cacheKey,
      entityType: entityType,
      payload: payload,
    );
  }

  Future<List<T>?> _getList<T>(
    String cacheKey,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final row = await _db.apiCacheDao.get(cacheKey);
    if (row == null) return null;
    try {
      final decoded = _decodeJson(row.payload) as List;
      return decoded
          .map((item) => fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  Future<DateTime?> _getCachedAt(String cacheKey) async {
    final row = await _db.apiCacheDao.get(cacheKey);
    return row?.cachedAt;
  }

  Future<void> _cacheMeta(
    String cacheKey,
    int count,
    String? next,
    String? previous,
  ) async {
    final payload = _encodeJson({
      'count': count,
      'next': next,
      'previous': previous,
    });
    await _db.apiCacheDao.put(
      cacheKey: 'meta:$cacheKey',
      entityType: 'page_meta',
      payload: payload,
    );
  }

  Future<Map<String, dynamic>?> _getMeta(String cacheKey) async {
    final row = await _db.apiCacheDao.get('meta:$cacheKey');
    if (row == null) return null;
    try {
      return _decodeJson(row.payload) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> _cacheSingle(
    String cacheKey,
    String entityType,
    Map<String, dynamic> json,
  ) async {
    final payload = _encodeJson(json);
    await _db.apiCacheDao.put(
      cacheKey: cacheKey,
      entityType: entityType,
      payload: payload,
    );
  }

  Future<Map<String, dynamic>?> _getSingle(String cacheKey) async {
    final row = await _db.apiCacheDao.get(cacheKey);
    if (row == null) return null;
    try {
      return _decodeJson(row.payload) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  // Key normalization helpers
  String _getWeekKey(DateTime date) {
    final offset = date.weekday % 7;
    final sunday = DateTime(
      date.year,
      date.month,
      date.day,
    ).subtract(Duration(days: offset));
    return "${sunday.year}-${sunday.month}-${sunday.day}";
  }

  String _normalizeSearchQuery(String query) => query.trim().toLowerCase();
  String _normalizeLimit(int? limit) =>
      limit != null && limit > 0 ? '$limit' : '';
  String _normalizeOrdering(String? ordering) => ordering?.trim() ?? '';
  String _normalizeModifiedGt(DateTime? modifiedGt) =>
      modifiedGt?.toUtc().toIso8601String() ?? '';

  String _getIssueSearchKey(String query, int page, int limit) =>
      '${_normalizeSearchQuery(query)}::p$page:l${_normalizeLimit(limit)}';

  String _getIssueListKey({
    required int page,
    String? ordering,
    DateTime? modifiedGt,
    int? limit,
  }) =>
      'issue_list:p$page:o${_normalizeOrdering(ordering)}:m${_normalizeModifiedGt(modifiedGt)}:l${_normalizeLimit(limit)}';

  String _getSeriesSearchKey(String query, int page, int limit) =>
      '${_normalizeSearchQuery(query)}::p$page:l${_normalizeLimit(limit)}';

  String _getSeriesListKey(int page, int limit, {DateTime? modifiedGt}) =>
      'series_list:p$page:l${_normalizeLimit(limit)}:m${_normalizeModifiedGt(modifiedGt)}';

  String _getSeriesIssueListKey(int seriesId, int page, int limit) =>
      'series_issue_list:$seriesId:p$page:l${_normalizeLimit(limit)}';

  String _getCharacterSearchKey(String query, int page, int limit) =>
      '${_normalizeSearchQuery(query)}::p$page:l${_normalizeLimit(limit)}';

  String _getCharacterIssueListKey(int characterId, int page, int limit) =>
      'character_issue_list:$characterId:p$page:l${_normalizeLimit(limit)}';

  String _getCreatorSearchKey(String query, int page, int limit) =>
      '${_normalizeSearchQuery(query)}::p$page:l${_normalizeLimit(limit)}';

  String _getUniverseSearchKey(String query, int page, int limit) =>
      '${_normalizeSearchQuery(query)}::p$page:l${_normalizeLimit(limit)}';

  String _getImprintSearchKey(String query, int page, int limit) =>
      '${_normalizeSearchQuery(query)}::p$page:l${_normalizeLimit(limit)}';

  String _getTeamSearchKey(String query, int page, int limit) =>
      '${_normalizeSearchQuery(query)}::p$page:l${_normalizeLimit(limit)}';

  String _getTeamIssueListKey(int teamId, int page, int limit) =>
      'team_issue_list:$teamId:p$page:l${_normalizeLimit(limit)}';

  String _getPublisherSearchKey(String query, int page, int limit) =>
      '${_normalizeSearchQuery(query)}::p$page:l${_normalizeLimit(limit)}';

  String _getPublisherSeriesListKey(int publisherId, int page, int limit) =>
      'publisher_series_list:$publisherId:p$page:l${_normalizeLimit(limit)}';

  String _getArcSearchKey(String query, int page, int limit) =>
      '${_normalizeSearchQuery(query)}::p$page:l${_normalizeLimit(limit)}';

  String _getArcIssueListKey(int arcId, int page, int limit) =>
      'arc_issue_list:$arcId:p$page:l${_normalizeLimit(limit)}';

  // --- Implementations ---

  // Releases
  @override
  Future<void> cacheWeeklyReleases(
    DateTime weekStart,
    List<IssueListDto> issues,
  ) async {
    final key = _getWeekKey(weekStart);
    await _cacheList(
      'weekly_releases:$key',
      'weekly_releases',
      issues,
      (i) => i.toJson(),
    );
  }

  @override
  Future<List<IssueListDto>?> getWeeklyReleases(DateTime weekStart) async {
    final key = _getWeekKey(weekStart);
    return _getList('weekly_releases:$key', IssueListDto.fromJson);
  }

  @override
  Future<DateTime?> getWeeklyReleasesCachedAt(DateTime weekStart) async {
    final key = _getWeekKey(weekStart);
    return _getCachedAt('weekly_releases:$key');
  }

  @override
  Future<void> cacheFocReleases(
    DateTime weekStart,
    List<IssueListDto> issues,
  ) async {
    final key = _getWeekKey(weekStart);
    await _cacheList(
      'foc_releases:$key',
      'foc_releases',
      issues,
      (i) => i.toJson(),
    );
  }

  @override
  Future<List<IssueListDto>?> getFocReleases(DateTime weekStart) async {
    final key = _getWeekKey(weekStart);
    return _getList('foc_releases:$key', IssueListDto.fromJson);
  }

  @override
  Future<DateTime?> getFocReleasesCachedAt(DateTime weekStart) async {
    final key = _getWeekKey(weekStart);
    return _getCachedAt('foc_releases:$key');
  }

  // Issue Search Results
  @override
  Future<void> cacheIssueSearchResults(
    String query,
    List<IssueListDto> issues, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  }) async {
    final key = _getIssueSearchKey(query, page, limit);
    await _cacheList(
      'issue_search:$key',
      'issue_search',
      issues,
      (i) => i.toJson(),
    );
    await _cacheMeta('issue_search:$key', count, next, previous);
  }

  @override
  Future<List<IssueListDto>?> getIssueSearchResults(
    String query, {
    required int page,
    required int limit,
  }) async {
    final key = _getIssueSearchKey(query, page, limit);
    return _getList('issue_search:$key', IssueListDto.fromJson);
  }

  @override
  Future<DateTime?> getIssueSearchResultsCachedAt(
    String query, {
    required int page,
    required int limit,
  }) async {
    final key = _getIssueSearchKey(query, page, limit);
    return _getCachedAt('issue_search:$key');
  }

  @override
  Future<IssueSearchPageCacheMeta?> getIssueSearchResultsMeta(
    String query, {
    required int page,
    required int limit,
  }) async {
    final key = _getIssueSearchKey(query, page, limit);
    final data = await _getMeta('issue_search:$key');
    if (data == null) return null;
    final count = (data['count'] as num?)?.toInt();
    if (count == null) return null;
    return IssueSearchPageCacheMeta(
      count: count,
      next: data['next'] as String?,
      previous: data['previous'] as String?,
    );
  }

  // Issue List Results
  @override
  Future<void> cacheIssueListResults(
    List<IssueListDto> issues, {
    required int page,
    String? ordering,
    DateTime? modifiedGt,
    int? limit,
    required int count,
    String? next,
    String? previous,
  }) async {
    final key = _getIssueListKey(
      page: page,
      ordering: ordering,
      modifiedGt: modifiedGt,
      limit: limit,
    );
    await _cacheList(
      'issue_list:$key',
      'issue_list',
      issues,
      (i) => i.toJson(),
    );
    await _cacheMeta('issue_list:$key', count, next, previous);
  }

  @override
  Future<List<IssueListDto>?> getIssueListResults({
    required int page,
    String? ordering,
    DateTime? modifiedGt,
    int? limit,
  }) async {
    final key = _getIssueListKey(
      page: page,
      ordering: ordering,
      modifiedGt: modifiedGt,
      limit: limit,
    );
    return _getList('issue_list:$key', IssueListDto.fromJson);
  }

  @override
  Future<DateTime?> getIssueListResultsCachedAt({
    required int page,
    String? ordering,
    DateTime? modifiedGt,
    int? limit,
  }) async {
    final key = _getIssueListKey(
      page: page,
      ordering: ordering,
      modifiedGt: modifiedGt,
      limit: limit,
    );
    return _getCachedAt('issue_list:$key');
  }

  @override
  Future<IssueSearchPageCacheMeta?> getIssueListResultsMeta({
    required int page,
    String? ordering,
    DateTime? modifiedGt,
    int? limit,
  }) async {
    final key = _getIssueListKey(
      page: page,
      ordering: ordering,
      modifiedGt: modifiedGt,
      limit: limit,
    );
    final data = await _getMeta('issue_list:$key');
    if (data == null) return null;
    final count = (data['count'] as num?)?.toInt();
    if (count == null) return null;
    return IssueSearchPageCacheMeta(
      count: count,
      next: data['next'] as String?,
      previous: data['previous'] as String?,
    );
  }

  // Series Search Results
  @override
  Future<void> cacheSeriesSearchResults(
    String query,
    List<SeriesListDto> series, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  }) async {
    final key = _getSeriesSearchKey(query, page, limit);
    await _cacheList(
      'series_search:$key',
      'series_search',
      series,
      (s) => s.toJson(),
    );
    await _cacheMeta('series_search:$key', count, next, previous);
  }

  @override
  Future<List<SeriesListDto>?> getSeriesSearchResults(
    String query, {
    required int page,
    required int limit,
  }) async {
    final key = _getSeriesSearchKey(query, page, limit);
    return _getList('series_search:$key', SeriesListDto.fromJson);
  }

  @override
  Future<DateTime?> getSeriesSearchResultsCachedAt(
    String query, {
    required int page,
    required int limit,
  }) async {
    final key = _getSeriesSearchKey(query, page, limit);
    return _getCachedAt('series_search:$key');
  }

  @override
  Future<SeriesSearchPageCacheMeta?> getSeriesSearchResultsMeta(
    String query, {
    required int page,
    required int limit,
  }) async {
    final key = _getSeriesSearchKey(query, page, limit);
    final data = await _getMeta('series_search:$key');
    if (data == null) return null;
    final count = (data['count'] as num?)?.toInt();
    if (count == null) return null;
    return SeriesSearchPageCacheMeta(
      count: count,
      next: data['next'] as String?,
      previous: data['previous'] as String?,
    );
  }

  // Series List Results
  @override
  Future<void> cacheSeriesListResults(
    List<SeriesListDto> series, {
    required int page,
    required int limit,
    DateTime? modifiedGt,
    required int count,
    String? next,
    String? previous,
  }) async {
    final key = _getSeriesListKey(page, limit, modifiedGt: modifiedGt);
    await _cacheList(
      'series_list:$key',
      'series_list',
      series,
      (s) => s.toJson(),
    );
    await _cacheMeta('series_list:$key', count, next, previous);
  }

  @override
  Future<List<SeriesListDto>?> getSeriesListResults({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  }) async {
    final key = _getSeriesListKey(page, limit, modifiedGt: modifiedGt);
    return _getList('series_list:$key', SeriesListDto.fromJson);
  }

  @override
  Future<DateTime?> getSeriesListResultsCachedAt({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  }) async {
    final key = _getSeriesListKey(page, limit, modifiedGt: modifiedGt);
    return _getCachedAt('series_list:$key');
  }

  @override
  Future<SeriesListPageCacheMeta?> getSeriesListResultsMeta({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  }) async {
    final key = _getSeriesListKey(page, limit, modifiedGt: modifiedGt);
    final data = await _getMeta('series_list:$key');
    if (data == null) return null;
    final count = (data['count'] as num?)?.toInt();
    if (count == null) return null;
    return SeriesListPageCacheMeta(
      count: count,
      next: data['next'] as String?,
      previous: data['previous'] as String?,
    );
  }

  // Series Issue List Results
  @override
  Future<void> cacheSeriesIssueListResults(
    int seriesId,
    List<IssueListDto> issues, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  }) async {
    final key = _getSeriesIssueListKey(seriesId, page, limit);
    await _cacheList(
      'series_issue_list:$key',
      'series_issue_list',
      issues,
      (i) => i.toJson(),
    );
    await _cacheMeta('series_issue_list:$key', count, next, previous);
  }

  @override
  Future<List<IssueListDto>?> getSeriesIssueListResults(
    int seriesId, {
    required int page,
    required int limit,
  }) async {
    final key = _getSeriesIssueListKey(seriesId, page, limit);
    return _getList('series_issue_list:$key', IssueListDto.fromJson);
  }

  @override
  Future<DateTime?> getSeriesIssueListResultsCachedAt(
    int seriesId, {
    required int page,
    required int limit,
  }) async {
    final key = _getSeriesIssueListKey(seriesId, page, limit);
    return _getCachedAt('series_issue_list:$key');
  }

  @override
  Future<SeriesIssueListPageCacheMeta?> getSeriesIssueListResultsMeta(
    int seriesId, {
    required int page,
    required int limit,
  }) async {
    final key = _getSeriesIssueListKey(seriesId, page, limit);
    final data = await _getMeta('series_issue_list:$key');
    if (data == null) return null;
    final count = (data['count'] as num?)?.toInt();
    if (count == null) return null;
    return SeriesIssueListPageCacheMeta(
      count: count,
      next: data['next'] as String?,
      previous: data['previous'] as String?,
    );
  }

  // Character Search Results
  @override
  Future<void> cacheCharacterSearchResults(
    String query,
    List<CharacterListDto> characters, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  }) async {
    final key = _getCharacterSearchKey(query, page, limit);
    await _cacheList(
      'character_search:$key',
      'character_search',
      characters,
      (c) => c.toJson(),
    );
    await _cacheMeta('character_search:$key', count, next, previous);
  }

  @override
  Future<List<CharacterListDto>?> getCharacterSearchResults(
    String query, {
    required int page,
    required int limit,
  }) async {
    final key = _getCharacterSearchKey(query, page, limit);
    return _getList('character_search:$key', CharacterListDto.fromJson);
  }

  @override
  Future<DateTime?> getCharacterSearchResultsCachedAt(
    String query, {
    required int page,
    required int limit,
  }) async {
    final key = _getCharacterSearchKey(query, page, limit);
    return _getCachedAt('character_search:$key');
  }

  @override
  Future<CharacterSearchPageCacheMeta?> getCharacterSearchResultsMeta(
    String query, {
    required int page,
    required int limit,
  }) async {
    final key = _getCharacterSearchKey(query, page, limit);
    final data = await _getMeta('character_search:$key');
    if (data == null) return null;
    final count = (data['count'] as num?)?.toInt();
    if (count == null) return null;
    return CharacterSearchPageCacheMeta(
      count: count,
      next: data['next'] as String?,
      previous: data['previous'] as String?,
    );
  }

  // Character Issue List Results
  @override
  Future<void> cacheCharacterIssueListResults(
    int characterId,
    List<IssueListDto> issues, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  }) async {
    final key = _getCharacterIssueListKey(characterId, page, limit);
    await _cacheList(
      'character_issue_list:$key',
      'character_issue_list',
      issues,
      (i) => i.toJson(),
    );
    await _cacheMeta('character_issue_list:$key', count, next, previous);
  }

  @override
  Future<List<IssueListDto>?> getCharacterIssueListResults(
    int characterId, {
    required int page,
    required int limit,
  }) async {
    final key = _getCharacterIssueListKey(characterId, page, limit);
    return _getList('character_issue_list:$key', IssueListDto.fromJson);
  }

  @override
  Future<DateTime?> getCharacterIssueListResultsCachedAt(
    int characterId, {
    required int page,
    required int limit,
  }) async {
    final key = _getCharacterIssueListKey(characterId, page, limit);
    return _getCachedAt('character_issue_list:$key');
  }

  @override
  Future<CharacterIssueListPageCacheMeta?> getCharacterIssueListResultsMeta(
    int characterId, {
    required int page,
    required int limit,
  }) async {
    final key = _getCharacterIssueListKey(characterId, page, limit);
    final data = await _getMeta('character_issue_list:$key');
    if (data == null) return null;
    final count = (data['count'] as num?)?.toInt();
    if (count == null) return null;
    return CharacterIssueListPageCacheMeta(
      count: count,
      next: data['next'] as String?,
      previous: data['previous'] as String?,
    );
  }

  // Team Issue List Results
  @override
  Future<void> cacheTeamIssueListResults(
    int teamId,
    List<IssueListDto> issues, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  }) async {
    final key = _getTeamIssueListKey(teamId, page, limit);
    await _cacheList(
      'team_issue_list:$key',
      'team_issue_list',
      issues,
      (i) => i.toJson(),
    );
    await _cacheMeta('team_issue_list:$key', count, next, previous);
  }

  @override
  Future<List<IssueListDto>?> getTeamIssueListResults(
    int teamId, {
    required int page,
    required int limit,
  }) async {
    final key = _getTeamIssueListKey(teamId, page, limit);
    return _getList('team_issue_list:$key', IssueListDto.fromJson);
  }

  @override
  Future<DateTime?> getTeamIssueListResultsCachedAt(
    int teamId, {
    required int page,
    required int limit,
  }) async {
    final key = _getTeamIssueListKey(teamId, page, limit);
    return _getCachedAt('team_issue_list:$key');
  }

  @override
  Future<TeamIssueListPageCacheMeta?> getTeamIssueListResultsMeta(
    int teamId, {
    required int page,
    required int limit,
  }) async {
    final key = _getTeamIssueListKey(teamId, page, limit);
    final data = await _getMeta('team_issue_list:$key');
    if (data == null) return null;
    final count = (data['count'] as num?)?.toInt();
    if (count == null) return null;
    return TeamIssueListPageCacheMeta(
      count: count,
      next: data['next'] as String?,
      previous: data['previous'] as String?,
    );
  }

  // Creator Search Results
  @override
  Future<void> cacheCreatorSearchResults(
    String query,
    List<CreatorListDto> creators, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  }) async {
    final key = _getCreatorSearchKey(query, page, limit);
    await _cacheList(
      'creator_search:$key',
      'creator_search',
      creators,
      (c) => c.toJson(),
    );
    await _cacheMeta('creator_search:$key', count, next, previous);
  }

  @override
  Future<List<CreatorListDto>?> getCreatorSearchResults(
    String query, {
    required int page,
    required int limit,
  }) async {
    final key = _getCreatorSearchKey(query, page, limit);
    return _getList('creator_search:$key', CreatorListDto.fromJson);
  }

  @override
  Future<DateTime?> getCreatorSearchResultsCachedAt(
    String query, {
    required int page,
    required int limit,
  }) async {
    final key = _getCreatorSearchKey(query, page, limit);
    return _getCachedAt('creator_search:$key');
  }

  @override
  Future<CreatorSearchPageCacheMeta?> getCreatorSearchResultsMeta(
    String query, {
    required int page,
    required int limit,
  }) async {
    final key = _getCreatorSearchKey(query, page, limit);
    final data = await _getMeta('creator_search:$key');
    if (data == null) return null;
    final count = (data['count'] as num?)?.toInt();
    if (count == null) return null;
    return CreatorSearchPageCacheMeta(
      count: count,
      next: data['next'] as String?,
      previous: data['previous'] as String?,
    );
  }

  // Universe Search Results
  @override
  Future<void> cacheUniverseSearchResults(
    String query,
    List<UniverseListDto> universes, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  }) async {
    final key = _getUniverseSearchKey(query, page, limit);
    await _cacheList(
      'universe_search:$key',
      'universe_search',
      universes,
      (u) => u.toJson(),
    );
    await _cacheMeta('universe_search:$key', count, next, previous);
  }

  @override
  Future<List<UniverseListDto>?> getUniverseSearchResults(
    String query, {
    required int page,
    required int limit,
  }) async {
    final key = _getUniverseSearchKey(query, page, limit);
    return _getList('universe_search:$key', UniverseListDto.fromJson);
  }

  @override
  Future<DateTime?> getUniverseSearchResultsCachedAt(
    String query, {
    required int page,
    required int limit,
  }) async {
    final key = _getUniverseSearchKey(query, page, limit);
    return _getCachedAt('universe_search:$key');
  }

  @override
  Future<UniverseSearchPageCacheMeta?> getUniverseSearchResultsMeta(
    String query, {
    required int page,
    required int limit,
  }) async {
    final key = _getUniverseSearchKey(query, page, limit);
    final data = await _getMeta('universe_search:$key');
    if (data == null) return null;
    final count = (data['count'] as num?)?.toInt();
    if (count == null) return null;
    return UniverseSearchPageCacheMeta(
      count: count,
      next: data['next'] as String?,
      previous: data['previous'] as String?,
    );
  }

  // Imprint Search Results
  @override
  Future<void> cacheImprintSearchResults(
    String query,
    List<ImprintListDto> imprints, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  }) async {
    final key = _getImprintSearchKey(query, page, limit);
    await _cacheList(
      'imprint_search:$key',
      'imprint_search',
      imprints,
      (i) => i.toJson(),
    );
    await _cacheMeta('imprint_search:$key', count, next, previous);
  }

  @override
  Future<List<ImprintListDto>?> getImprintSearchResults(
    String query, {
    required int page,
    required int limit,
  }) async {
    final key = _getImprintSearchKey(query, page, limit);
    return _getList('imprint_search:$key', ImprintListDto.fromJson);
  }

  @override
  Future<DateTime?> getImprintSearchResultsCachedAt(
    String query, {
    required int page,
    required int limit,
  }) async {
    final key = _getImprintSearchKey(query, page, limit);
    return _getCachedAt('imprint_search:$key');
  }

  @override
  Future<ImprintSearchPageCacheMeta?> getImprintSearchResultsMeta(
    String query, {
    required int page,
    required int limit,
  }) async {
    final key = _getImprintSearchKey(query, page, limit);
    final data = await _getMeta('imprint_search:$key');
    if (data == null) return null;
    final count = (data['count'] as num?)?.toInt();
    if (count == null) return null;
    return ImprintSearchPageCacheMeta(
      count: count,
      next: data['next'] as String?,
      previous: data['previous'] as String?,
    );
  }

  // Team Search Results
  @override
  Future<void> cacheTeamSearchResults(
    String query,
    List<TeamListDto> teams, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  }) async {
    final key = _getTeamSearchKey(query, page, limit);
    await _cacheList(
      'team_search:$key',
      'team_search',
      teams,
      (t) => t.toJson(),
    );
    await _cacheMeta('team_search:$key', count, next, previous);
  }

  @override
  Future<List<TeamListDto>?> getTeamSearchResults(
    String query, {
    required int page,
    required int limit,
  }) async {
    final key = _getTeamSearchKey(query, page, limit);
    return _getList('team_search:$key', TeamListDto.fromJson);
  }

  @override
  Future<DateTime?> getTeamSearchResultsCachedAt(
    String query, {
    required int page,
    required int limit,
  }) async {
    final key = _getTeamSearchKey(query, page, limit);
    return _getCachedAt('team_search:$key');
  }

  @override
  Future<TeamSearchPageCacheMeta?> getTeamSearchResultsMeta(
    String query, {
    required int page,
    required int limit,
  }) async {
    final key = _getTeamSearchKey(query, page, limit);
    final data = await _getMeta('team_search:$key');
    if (data == null) return null;
    final count = (data['count'] as num?)?.toInt();
    if (count == null) return null;
    return TeamSearchPageCacheMeta(
      count: count,
      next: data['next'] as String?,
      previous: data['previous'] as String?,
    );
  }

  // Arc Search Results
  @override
  Future<void> cacheArcSearchResults(
    String query,
    List<ArcListDto> arcs, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  }) async {
    final key = _getArcSearchKey(query, page, limit);
    await _cacheList('arc_search:$key', 'arc_search', arcs, (a) => a.toJson());
    await _cacheMeta('arc_search:$key', count, next, previous);
  }

  @override
  Future<List<ArcListDto>?> getArcSearchResults(
    String query, {
    required int page,
    required int limit,
  }) async {
    final key = _getArcSearchKey(query, page, limit);
    return _getList('arc_search:$key', ArcListDto.fromJson);
  }

  @override
  Future<DateTime?> getArcSearchResultsCachedAt(
    String query, {
    required int page,
    required int limit,
  }) async {
    final key = _getArcSearchKey(query, page, limit);
    return _getCachedAt('arc_search:$key');
  }

  @override
  Future<ArcSearchPageCacheMeta?> getArcSearchResultsMeta(
    String query, {
    required int page,
    required int limit,
  }) async {
    final key = _getArcSearchKey(query, page, limit);
    final data = await _getMeta('arc_search:$key');
    if (data == null) return null;
    final count = (data['count'] as num?)?.toInt();
    if (count == null) return null;
    return ArcSearchPageCacheMeta(
      count: count,
      next: data['next'] as String?,
      previous: data['previous'] as String?,
    );
  }

  // Arc Issue List Results
  @override
  Future<void> cacheArcIssueListResults(
    int arcId,
    List<IssueListDto> issues, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  }) async {
    final key = _getArcIssueListKey(arcId, page, limit);
    await _cacheList(
      'arc_issue_list:$key',
      'arc_issue_list',
      issues,
      (i) => i.toJson(),
    );
    await _cacheMeta('arc_issue_list:$key', count, next, previous);
  }

  @override
  Future<List<IssueListDto>?> getArcIssueListResults(
    int arcId, {
    required int page,
    required int limit,
  }) async {
    final key = _getArcIssueListKey(arcId, page, limit);
    return _getList('arc_issue_list:$key', IssueListDto.fromJson);
  }

  @override
  Future<DateTime?> getArcIssueListResultsCachedAt(
    int arcId, {
    required int page,
    required int limit,
  }) async {
    final key = _getArcIssueListKey(arcId, page, limit);
    return _getCachedAt('arc_issue_list:$key');
  }

  @override
  Future<SeriesIssueListPageCacheMeta?> getArcIssueListResultsMeta(
    int arcId, {
    required int page,
    required int limit,
  }) async {
    final key = _getArcIssueListKey(arcId, page, limit);
    final data = await _getMeta('arc_issue_list:$key');
    if (data == null) return null;
    final count = (data['count'] as num?)?.toInt();
    if (count == null) return null;
    return SeriesIssueListPageCacheMeta(
      count: count,
      next: data['next'] as String?,
      previous: data['previous'] as String?,
    );
  }

  // Publisher Search Results
  @override
  Future<void> cachePublisherSearchResults(
    String query,
    List<PublisherListDto> publishers, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  }) async {
    final key = _getPublisherSearchKey(query, page, limit);
    await _cacheList(
      'publisher_search:$key',
      'publisher_search',
      publishers,
      (p) => p.toJson(),
    );
    await _cacheMeta('publisher_search:$key', count, next, previous);
  }

  @override
  Future<List<PublisherListDto>?> getPublisherSearchResults(
    String query, {
    required int page,
    required int limit,
  }) async {
    final key = _getPublisherSearchKey(query, page, limit);
    return _getList('publisher_search:$key', PublisherListDto.fromJson);
  }

  @override
  Future<DateTime?> getPublisherSearchResultsCachedAt(
    String query, {
    required int page,
    required int limit,
  }) async {
    final key = _getPublisherSearchKey(query, page, limit);
    return _getCachedAt('publisher_search:$key');
  }

  @override
  Future<PublisherSearchPageCacheMeta?> getPublisherSearchResultsMeta(
    String query, {
    required int page,
    required int limit,
  }) async {
    final key = _getPublisherSearchKey(query, page, limit);
    final data = await _getMeta('publisher_search:$key');
    if (data == null) return null;
    final count = (data['count'] as num?)?.toInt();
    if (count == null) return null;
    return PublisherSearchPageCacheMeta(
      count: count,
      next: data['next'] as String?,
      previous: data['previous'] as String?,
    );
  }

  // Publisher Series List Results
  @override
  Future<void> cachePublisherSeriesListResults(
    int publisherId,
    List<SeriesListDto> series, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  }) async {
    final key = _getPublisherSeriesListKey(publisherId, page, limit);
    await _cacheList(
      'publisher_series_list:$key',
      'publisher_series_list',
      series,
      (s) => s.toJson(),
    );
    await _cacheMeta('publisher_series_list:$key', count, next, previous);
  }

  @override
  Future<List<SeriesListDto>?> getPublisherSeriesListResults(
    int publisherId, {
    required int page,
    required int limit,
  }) async {
    final key = _getPublisherSeriesListKey(publisherId, page, limit);
    return _getList('publisher_series_list:$key', SeriesListDto.fromJson);
  }

  @override
  Future<DateTime?> getPublisherSeriesListResultsCachedAt(
    int publisherId, {
    required int page,
    required int limit,
  }) async {
    final key = _getPublisherSeriesListKey(publisherId, page, limit);
    return _getCachedAt('publisher_series_list:$key');
  }

  @override
  Future<SeriesIssueListPageCacheMeta?> getPublisherSeriesListResultsMeta(
    int publisherId, {
    required int page,
    required int limit,
  }) async {
    final key = _getPublisherSeriesListKey(publisherId, page, limit);
    final data = await _getMeta('publisher_series_list:$key');
    if (data == null) return null;
    final count = (data['count'] as num?)?.toInt();
    if (count == null) return null;
    return SeriesIssueListPageCacheMeta(
      count: count,
      next: data['next'] as String?,
      previous: data['previous'] as String?,
    );
  }

  @override
  Future<void> cacheIssueDetailsResponse(
    int issueId,
    Map<String, dynamic> json,
  ) async {
    await _cacheSingle('issue_details:$issueId', 'issue_details', json);
  }

  @override
  Future<Map<String, dynamic>?> getCachedIssueDetailsResponse(
    int issueId,
  ) async {
    return _getSingle('issue_details:$issueId');
  }

  @override
  Future<DateTime?> getCachedIssueDetailsCachedAt(int issueId) async {
    return _getCachedAt('issue_details:$issueId');
  }

  @override
  Future<void> cacheSeriesDetailsResponse(
    int seriesId,
    Map<String, dynamic> json,
  ) async {
    await _cacheSingle('series_details:$seriesId', 'series_details', json);
  }

  @override
  Future<Map<String, dynamic>?> getCachedSeriesDetailsResponse(
    int seriesId,
  ) async {
    return _getSingle('series_details:$seriesId');
  }

  @override
  Future<DateTime?> getCachedSeriesDetailsCachedAt(int seriesId) async {
    return _getCachedAt('series_details:$seriesId');
  }
}
