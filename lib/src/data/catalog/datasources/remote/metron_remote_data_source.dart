import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:takion/src/data/catalog/dto/dto.dart';
import 'package:takion/src/data/reading_list/dto/dto.dart';

abstract class MetronRemoteDataSource {
  Future<Response> rawGet(
    String path, {
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  });
  Future<Response> getWeeklyReleasesForDate(
    DateTime date, {
    CancelToken? cancelToken,
  });
  Future<Response> getFocReleasesForDate(
    DateTime date, {
    CancelToken? cancelToken,
  });
  Future<Response> getIssueDetails(int issueId);
  Future<IssueSearchResponseDto> searchIssuesByUpc(
    String upc, {
    CancelToken? cancelToken,
  });
  Future<IssueSearchResponseDto> searchIssuesByUpcPrefix(
    String prefix, {
    CancelToken? cancelToken,
  });
  Future<IssueSearchResponseDto> getIssueSearchPage(
    String url, {
    CancelToken? cancelToken,
  });
  Future<IssueSearchResponseDto> searchIssues(
    String query, {
    Uri? nextUrl,
    int page = 1,
    DateTime? modifiedGt,
    CancelToken? cancelToken,
  });
  Future<IssueSearchResponseDto> getIssueList({
    Uri? nextUrl,
    int page = 1,
    String? ordering,
    DateTime? modifiedGt,
    CancelToken? cancelToken,
  });
  Future<SeriesListResponseDto> getSeriesList({
    Uri? nextUrl,
    int page = 1,
    DateTime? modifiedGt,
    CancelToken? cancelToken,
  });
  Future<SeriesSearchResponseDto> searchSeries(
    String query, {
    Uri? nextUrl,
    int page = 1,
    DateTime? modifiedGt,
    CancelToken? cancelToken,
  });
  Future<Response> getSeriesDetails(int seriesId);
  Future<SeriesIssueListResponseDto> getSeriesIssueList(
    int seriesId, {
    Uri? nextUrl,
    int page = 1,
    String? ordering,
    DateTime? storeDateGte,
    DateTime? storeDateLte,
    CancelToken? cancelToken,
  });
  Future<CharacterListResponseDto> getCharacterList({
    Uri? nextUrl,
    int page = 1,
    DateTime? modifiedGt,
    CancelToken? cancelToken,
  });
  Future<CharacterListResponseDto> searchCharacters(
    String query, {
    Uri? nextUrl,
    int page = 1,
    CancelToken? cancelToken,
  });
  Future<Response> getCharacterDetails(int characterId);
  Future<SeriesIssueListResponseDto> getCharacterIssueList(
    int characterId, {
    Uri? nextUrl,
    int page = 1,
    CancelToken? cancelToken,
  });

  Future<CreatorListResponseDto> getCreatorList({
    Uri? nextUrl,
    int page = 1,
    DateTime? modifiedGt,
    CancelToken? cancelToken,
  });

  Future<CreatorListResponseDto> searchCreators(
    String query, {
    Uri? nextUrl,
    int page = 1,
    CancelToken? cancelToken,
  });

  Future<Response> getCreatorDetails(int creatorId);

  Future<UniverseListResponseDto> getUniverseList({
    Uri? nextUrl,
    int page = 1,
    DateTime? modifiedGt,
    CancelToken? cancelToken,
  });

  Future<UniverseListResponseDto> searchUniverses(
    String query, {
    Uri? nextUrl,
    int page = 1,
    CancelToken? cancelToken,
  });

  Future<Response> getUniverseDetails(int universeId);

  Future<ImprintListResponseDto> getImprintList({
    Uri? nextUrl,
    int page = 1,
    DateTime? modifiedGt,
    CancelToken? cancelToken,
  });

  Future<ImprintListResponseDto> searchImprints(
    String query, {
    Uri? nextUrl,
    int page = 1,
    CancelToken? cancelToken,
  });

  Future<Response> getImprintDetails(int imprintId);

  Future<TeamListResponseDto> getTeamList({
    Uri? nextUrl,
    int page = 1,
    DateTime? modifiedGt,
    CancelToken? cancelToken,
  });

  Future<TeamListResponseDto> searchTeams(
    String query, {
    Uri? nextUrl,
    int page = 1,
    CancelToken? cancelToken,
  });

  Future<Response> getTeamDetails(int teamId);
  Future<SeriesIssueListResponseDto> getTeamIssueList(
    int teamId, {
    Uri? nextUrl,
    int page = 1,
    CancelToken? cancelToken,
  });
  Future<ArcListResponseDto> getArcList({
    Uri? nextUrl,
    int page = 1,
    DateTime? modifiedGt,
    CancelToken? cancelToken,
  });

  Future<ArcListResponseDto> searchArcs(
    String query, {
    Uri? nextUrl,
    int page = 1,
    CancelToken? cancelToken,
  });
  Future<Response> getArcDetails(int arcId);
  Future<SeriesIssueListResponseDto> getArcIssueList(
    int arcId, {
    Uri? nextUrl,
    int page = 1,
    CancelToken? cancelToken,
    bool bypassConditional = false,
  });

  Future<PublisherListResponseDto> getPublisherList({
    Uri? nextUrl,
    int page = 1,
    DateTime? modifiedGt,
    CancelToken? cancelToken,
  });

  Future<PublisherListResponseDto> searchPublishers(
    String query, {
    Uri? nextUrl,
    int page = 1,
    CancelToken? cancelToken,
  });

  Future<Response> getPublisherDetails(int publisherId);

  Future<SeriesListResponseDto> getPublisherSeriesList(
    int publisherId, {
    Uri? nextUrl,
    int page = 1,
    CancelToken? cancelToken,
  });

  Future<ReadingListResponseDto> getReadingLists({
    Uri? nextUrl,
    int page = 1,
    String? name,
    String? listType,
    String? attributionSource,
    String? publisher,
    DateTime? modifiedGt,
    CancelToken? cancelToken,
  });

  Future<Response> getReadingListDetail(int id);

  Future<ReadingListItemResponseDto> getReadingListItems(
    int id, {
    Uri? nextUrl,
    int page = 1,
    CancelToken? cancelToken,
  });
}

class MetronRemoteDataSourceImpl implements MetronRemoteDataSource {
  final Dio _dio;

  MetronRemoteDataSourceImpl(this._dio);

  @override
  Future<Response> rawGet(
    String path, {
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) {
    return _dio.get(
      path,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
    );
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    if (data is String) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map<String, dynamic>) return decoded;
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      } catch (_) {}
    }
    return <String, dynamic>{};
  }

  String _normalizeQuery(String query) {
    return query
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'[^\w\s#-]'), ' ')
        .trim();
  }

  @override
  Future<Response> getWeeklyReleasesForDate(
    DateTime date, {
    CancelToken? cancelToken,
  }) async {
    final offset = date.weekday % 7;
    final startOfWeek = DateTime(
      date.year,
      date.month,
      date.day,
    ).subtract(Duration(days: offset));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    String formatDate(DateTime d) =>
        "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

    return _dio.get(
      'issue/',
      queryParameters: {
        'store_date_range_after': formatDate(startOfWeek),
        'store_date_range_before': formatDate(endOfWeek),
      },
      cancelToken: cancelToken,
    );
  }

  @override
  Future<Response> getFocReleasesForDate(
    DateTime date, {
    CancelToken? cancelToken,
  }) async {
    final offset = date.weekday % 7;
    final startOfWeek = DateTime(
      date.year,
      date.month,
      date.day,
    ).subtract(Duration(days: offset));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    String formatDate(DateTime d) =>
        "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

    return _dio.get(
      'issue/',
      queryParameters: {
        'foc_date_range_after': formatDate(startOfWeek),
        'foc_date_range_before': formatDate(endOfWeek),
      },
      cancelToken: cancelToken,
    );
  }

  @override
  Future<Response> getIssueDetails(int issueId) async {
    return _dio.get('issue/$issueId/');
  }

  @override
  Future<IssueSearchResponseDto> searchIssuesByUpc(
    String upc, {
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.get(
      'issue/',
      queryParameters: {'upc': upc},
      cancelToken: cancelToken,
    );
    return IssueSearchResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<IssueSearchResponseDto> searchIssuesByUpcPrefix(
    String prefix, {
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.get(
      'issue/',
      queryParameters: {'upc_starts_with': prefix},
      cancelToken: cancelToken,
    );
    return IssueSearchResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<IssueSearchResponseDto> getIssueSearchPage(
    String url, {
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.getUri(
      Uri.parse(url),
      cancelToken: cancelToken,
    );
    return IssueSearchResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<IssueSearchResponseDto> searchIssues(
    String query, {
    Uri? nextUrl,
    int page = 1,
    DateTime? modifiedGt,
    CancelToken? cancelToken,
  }) async {
    final normalized = _normalizeQuery(query);
    if (normalized.isEmpty) {
      return const IssueSearchResponseDto(count: 0, results: []);
    }

    final queryParameters = <String, dynamic>{'series_name': normalized, 'page': page};
    if (modifiedGt != null) {
      queryParameters['modified_gt'] = modifiedGt.toUtc().toIso8601String();
    }

    final response = nextUrl != null
        ? await _dio.getUri(nextUrl)
        : await _dio.get(
            'issue/',
            queryParameters: queryParameters,
            cancelToken: cancelToken,
          );

    return IssueSearchResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<IssueSearchResponseDto> getIssueList({
    Uri? nextUrl,
    int page = 1,
    String? ordering,
    DateTime? modifiedGt,
    CancelToken? cancelToken,
  }) async {
    final queryParameters = <String, dynamic>{'page': page};
    if (ordering != null && ordering.trim().isNotEmpty) {
      queryParameters['ordering'] = ordering.trim();
    }
    if (modifiedGt != null) {
      queryParameters['modified_gt'] = modifiedGt.toUtc().toIso8601String();
    }
    final response = nextUrl != null
        ? await _dio.getUri(nextUrl)
        : await _dio.get(
            'issue/',
            queryParameters: queryParameters,
            cancelToken: cancelToken,
          );
    return IssueSearchResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<SeriesListResponseDto> getSeriesList({
    Uri? nextUrl,
    int page = 1,
    DateTime? modifiedGt,
    CancelToken? cancelToken,
  }) async {
    final queryParameters = <String, dynamic>{'page': page};
    if (modifiedGt != null) {
      queryParameters['modified_gt'] = modifiedGt.toUtc().toIso8601String();
    }
    final response = nextUrl != null
        ? await _dio.getUri(nextUrl)
        : await _dio.get(
            'series/',
            queryParameters: queryParameters,
            cancelToken: cancelToken,
          );

    return SeriesListResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<SeriesSearchResponseDto> searchSeries(
    String query, {
    Uri? nextUrl,
    int page = 1,
    DateTime? modifiedGt,
    CancelToken? cancelToken,
  }) async {
    final normalized = _normalizeQuery(query);
    if (normalized.isEmpty) {
      return const SeriesSearchResponseDto(count: 0, results: []);
    }

    final queryParameters = <String, dynamic>{'name': normalized, 'page': page};
    if (modifiedGt != null) {
      queryParameters['modified_gt'] = modifiedGt.toUtc().toIso8601String();
    }

    final response = nextUrl != null
        ? await _dio.getUri(nextUrl)
        : await _dio.get(
            'series/',
            queryParameters: queryParameters,
            cancelToken: cancelToken,
          );

    return SeriesSearchResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<Response> getSeriesDetails(int seriesId) async {
    return _dio.get('series/$seriesId/');
  }

  @override
  Future<SeriesIssueListResponseDto> getSeriesIssueList(
    int seriesId, {
    Uri? nextUrl,
    int page = 1,
    String? ordering,
    DateTime? storeDateGte,
    DateTime? storeDateLte,
    CancelToken? cancelToken,
  }) async {
    String formatDate(DateTime d) =>
        "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

    final response = nextUrl != null
        ? await _dio.getUri(nextUrl)
        : (storeDateGte != null || storeDateLte != null)
        ? await _dio.get(
            'issue/',
            queryParameters: {
              'series_id': seriesId,
              'page': page,
              if (ordering != null && ordering.trim().isNotEmpty)
                'ordering': ordering.trim(),
              if (storeDateGte != null)
                'store_date_range_after': formatDate(storeDateGte),
              if (storeDateLte != null)
                'store_date_range_before': formatDate(storeDateLte),
            },
            cancelToken: cancelToken,
          )
        : await _dio.get(
            'series/$seriesId/issue_list/',
            queryParameters: {
              'page': page,
              if (ordering != null && ordering.trim().isNotEmpty)
                'ordering': ordering.trim(),
            },
            cancelToken: cancelToken,
          );

    return SeriesIssueListResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<CharacterListResponseDto> getCharacterList({
    Uri? nextUrl,
    int page = 1,
    DateTime? modifiedGt,
    CancelToken? cancelToken,
  }) async {
    final queryParameters = <String, dynamic>{'page': page};
    if (modifiedGt != null) {
      queryParameters['modified_gt'] = modifiedGt.toUtc().toIso8601String();
    }
    final response = nextUrl != null
        ? await _dio.getUri(nextUrl)
        : await _dio.get(
            'character/',
            queryParameters: queryParameters,
            cancelToken: cancelToken,
          );

    return CharacterListResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<CharacterListResponseDto> searchCharacters(
    String query, {
    Uri? nextUrl,
    int page = 1,
    CancelToken? cancelToken,
  }) async {
    final normalized = _normalizeQuery(query);
    if (normalized.isEmpty) {
      return const CharacterListResponseDto(count: 0, results: []);
    }

    final response = nextUrl != null
        ? await _dio.getUri(nextUrl)
        : await _dio.get(
            'character/',
            queryParameters: {'name': normalized, 'page': page},
            cancelToken: cancelToken,
          );

    return CharacterListResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<Response> getCharacterDetails(int characterId) async {
    return _dio.get('character/$characterId/');
  }

  @override
  Future<SeriesIssueListResponseDto> getCharacterIssueList(
    int characterId, {
    Uri? nextUrl,
    int page = 1,
    CancelToken? cancelToken,
  }) async {
    final response = nextUrl != null
        ? await _dio.getUri(nextUrl)
        : await _dio.get(
            'character/$characterId/issue_list/',
            queryParameters: {'page': page},
            cancelToken: cancelToken,
          );

    return SeriesIssueListResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<CreatorListResponseDto> getCreatorList({
    Uri? nextUrl,
    int page = 1,
    DateTime? modifiedGt,
    CancelToken? cancelToken,
  }) async {
    final queryParameters = <String, dynamic>{'page': page};
    if (modifiedGt != null) {
      queryParameters['modified_gt'] = modifiedGt.toUtc().toIso8601String();
    }
    final response = nextUrl != null
        ? await _dio.getUri(nextUrl)
        : await _dio.get(
            'creator/',
            queryParameters: queryParameters,
            cancelToken: cancelToken,
          );
    return CreatorListResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<CreatorListResponseDto> searchCreators(
    String query, {
    Uri? nextUrl,
    int page = 1,
    CancelToken? cancelToken,
  }) async {
    final normalized = _normalizeQuery(query);
    if (normalized.isEmpty) {
      return const CreatorListResponseDto(count: 0, results: []);
    }

    final response = nextUrl != null
        ? await _dio.getUri(nextUrl)
        : await _dio.get(
            'creator/',
            queryParameters: {'name': normalized, 'page': page},
            cancelToken: cancelToken,
          );

    return CreatorListResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<Response> getCreatorDetails(int creatorId) async {
    return _dio.get('creator/$creatorId/');
  }

  @override
  Future<UniverseListResponseDto> getUniverseList({
    Uri? nextUrl,
    int page = 1,
    DateTime? modifiedGt,
    CancelToken? cancelToken,
  }) async {
    final queryParameters = <String, dynamic>{'page': page};
    if (modifiedGt != null) {
      queryParameters['modified_gt'] = modifiedGt.toUtc().toIso8601String();
    }
    final response = nextUrl != null
        ? await _dio.getUri(nextUrl)
        : await _dio.get(
            'universe/',
            queryParameters: queryParameters,
            cancelToken: cancelToken,
          );
    return UniverseListResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<UniverseListResponseDto> searchUniverses(
    String query, {
    Uri? nextUrl,
    int page = 1,
    CancelToken? cancelToken,
  }) async {
    final normalized = _normalizeQuery(query);
    if (normalized.isEmpty) {
      return const UniverseListResponseDto(count: 0, results: []);
    }

    final response = nextUrl != null
        ? await _dio.getUri(nextUrl)
        : await _dio.get(
            'universe/',
            queryParameters: {'name': normalized, 'page': page},
            cancelToken: cancelToken,
          );

    return UniverseListResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<Response> getUniverseDetails(int universeId) async {
    return _dio.get('universe/$universeId/');
  }

  @override
  Future<ImprintListResponseDto> getImprintList({
    Uri? nextUrl,
    int page = 1,
    DateTime? modifiedGt,
    CancelToken? cancelToken,
  }) async {
    final queryParameters = <String, dynamic>{'page': page};
    if (modifiedGt != null) {
      queryParameters['modified_gt'] = modifiedGt.toUtc().toIso8601String();
    }
    final response = nextUrl != null
        ? await _dio.getUri(nextUrl)
        : await _dio.get(
            'imprint/',
            queryParameters: queryParameters,
            cancelToken: cancelToken,
          );
    return ImprintListResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<ImprintListResponseDto> searchImprints(
    String query, {
    Uri? nextUrl,
    int page = 1,
    CancelToken? cancelToken,
  }) async {
    final normalized = _normalizeQuery(query);
    if (normalized.isEmpty) {
      return const ImprintListResponseDto(count: 0, results: []);
    }

    final response = nextUrl != null
        ? await _dio.getUri(nextUrl)
        : await _dio.get(
            'imprint/',
            queryParameters: {'name': normalized, 'page': page},
            cancelToken: cancelToken,
          );

    return ImprintListResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<Response> getImprintDetails(int imprintId) async {
    return _dio.get('imprint/$imprintId/');
  }

  @override
  Future<TeamListResponseDto> searchTeams(
    String query, {
    Uri? nextUrl,
    int page = 1,
    CancelToken? cancelToken,
  }) async {
    final normalized = _normalizeQuery(query);
    if (normalized.isEmpty) {
      return const TeamListResponseDto(count: 0, results: []);
    }

    final response = nextUrl != null
        ? await _dio.getUri(nextUrl)
        : await _dio.get(
            'team/',
            queryParameters: {'name': normalized, 'page': page},
            cancelToken: cancelToken,
          );

    return TeamListResponseDto.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<TeamListResponseDto> getTeamList({
    Uri? nextUrl,
    int page = 1,
    DateTime? modifiedGt,
    CancelToken? cancelToken,
  }) async {
    final queryParameters = <String, dynamic>{'page': page};
    if (modifiedGt != null) {
      queryParameters['modified_gt'] = modifiedGt.toUtc().toIso8601String();
    }
    final response = nextUrl != null
        ? await _dio.getUri(nextUrl)
        : await _dio.get(
            'team/',
            queryParameters: queryParameters,
            cancelToken: cancelToken,
          );
    return TeamListResponseDto.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<Response> getTeamDetails(int teamId) async {
    return _dio.get('team/$teamId/');
  }

  @override
  Future<SeriesIssueListResponseDto> getTeamIssueList(
    int teamId, {
    Uri? nextUrl,
    int page = 1,
    CancelToken? cancelToken,
  }) async {
    final response = nextUrl != null
        ? await _dio.getUri(nextUrl)
        : await _dio.get(
            'team/$teamId/issue_list/',
            queryParameters: {'page': page},
            cancelToken: cancelToken,
          );

    return SeriesIssueListResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<ArcListResponseDto> searchArcs(
    String query, {
    Uri? nextUrl,
    int page = 1,
    CancelToken? cancelToken,
  }) async {
    final normalized = _normalizeQuery(query);
    if (normalized.isEmpty) {
      return const ArcListResponseDto(count: 0, results: []);
    }

    final response = nextUrl != null
        ? await _dio.getUri(nextUrl)
        : await _dio.get(
            'arc/',
            queryParameters: {'name': normalized, 'page': page},
            cancelToken: cancelToken,
          );

    return ArcListResponseDto.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<ArcListResponseDto> getArcList({
    Uri? nextUrl,
    int page = 1,
    DateTime? modifiedGt,
    CancelToken? cancelToken,
  }) async {
    final queryParameters = <String, dynamic>{'page': page};
    if (modifiedGt != null) {
      queryParameters['modified_gt'] = modifiedGt.toUtc().toIso8601String();
    }
    final response = nextUrl != null
        ? await _dio.getUri(nextUrl)
        : await _dio.get(
            'arc/',
            queryParameters: queryParameters,
            cancelToken: cancelToken,
          );
    return ArcListResponseDto.fromJson(_asMap(response.data));
  }

  @override
  Future<Response> getArcDetails(int arcId) async {
    return _dio.get('arc/$arcId/');
  }

  @override
  Future<SeriesIssueListResponseDto> getArcIssueList(
    int arcId, {
    Uri? nextUrl,
    int page = 1,
    CancelToken? cancelToken,
    bool bypassConditional = false,
  }) async {
    final options = bypassConditional
        ? Options(extra: {'bypass_conditional': true})
        : Options();
    final response = nextUrl != null
        ? await _dio.getUri(nextUrl, options: options)
        : await _dio.get(
            'arc/$arcId/issue_list/',
            queryParameters: {'page': page},
            cancelToken: cancelToken,
            options: options,
          );

    return SeriesIssueListResponseDto.fromJson(
      _asMap(response.data),
    );
  }

  @override
  Future<PublisherListResponseDto> getPublisherList({
    Uri? nextUrl,
    int page = 1,
    DateTime? modifiedGt,
    CancelToken? cancelToken,
  }) async {
    final queryParameters = <String, dynamic>{'page': page};
    if (modifiedGt != null) {
      queryParameters['modified_gt'] = modifiedGt.toUtc().toIso8601String();
    }
    final response = nextUrl != null
        ? await _dio.getUri(nextUrl)
        : await _dio.get(
            'publisher/',
            queryParameters: queryParameters,
            cancelToken: cancelToken,
          );
    return PublisherListResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<PublisherListResponseDto> searchPublishers(
    String query, {
    Uri? nextUrl,
    int page = 1,
    CancelToken? cancelToken,
  }) async {
    final normalized = _normalizeQuery(query);
    if (normalized.isEmpty) {
      return const PublisherListResponseDto(count: 0, results: []);
    }

    final response = nextUrl != null
        ? await _dio.getUri(nextUrl)
        : await _dio.get(
            'publisher/',
            queryParameters: {'name': normalized, 'page': page},
            cancelToken: cancelToken,
          );

    return PublisherListResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<Response> getPublisherDetails(int publisherId) async {
    return _dio.get('publisher/$publisherId/');
  }

  @override
  Future<SeriesListResponseDto> getPublisherSeriesList(
    int publisherId, {
    Uri? nextUrl,
    int page = 1,
    CancelToken? cancelToken,
  }) async {
    final response = nextUrl != null
        ? await _dio.getUri(nextUrl)
        : await _dio.get(
            'publisher/$publisherId/series_list/',
            queryParameters: {'page': page},
            cancelToken: cancelToken,
          );

    return SeriesListResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<ReadingListResponseDto> getReadingLists({
    Uri? nextUrl,
    int page = 1,
    String? name,
    String? listType,
    String? attributionSource,
    String? publisher,
    DateTime? modifiedGt,
    CancelToken? cancelToken,
  }) async {
    final queryParameters = <String, dynamic>{'page': page};
    if (name != null && name.trim().isNotEmpty) {
      queryParameters['name'] = name.trim();
    }
    if (listType != null && listType.trim().isNotEmpty) {
      queryParameters['list_type'] = listType.trim();
    }
    if (attributionSource != null && attributionSource.trim().isNotEmpty) {
      queryParameters['attribution_source'] = attributionSource.trim();
    }
    if (publisher != null && publisher.trim().isNotEmpty) {
      queryParameters['publisher'] = publisher.trim();
    }
    if (modifiedGt != null) {
      queryParameters['modified_gt'] = modifiedGt.toUtc().toIso8601String();
    }

    final response = nextUrl != null
        ? await _dio.getUri(nextUrl)
        : await _dio.get(
            'reading_list/',
            queryParameters: queryParameters,
            cancelToken: cancelToken,
          );

    return ReadingListResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<Response> getReadingListDetail(int id) async {
    return _dio.get('reading_list/$id/');
  }

  @override
  Future<ReadingListItemResponseDto> getReadingListItems(
    int id, {
    Uri? nextUrl,
    int page = 1,
    CancelToken? cancelToken,
  }) async {
    final response = nextUrl != null
        ? await _dio.getUri(nextUrl)
        : await _dio.get(
            'reading_list/$id/items/',
            queryParameters: {'page': page},
            cancelToken: cancelToken,
          );

    return ReadingListItemResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}
