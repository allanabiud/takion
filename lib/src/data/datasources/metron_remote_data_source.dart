import 'package:dio/dio.dart';
import 'package:takion/src/core/constants/pagination.dart';
import 'package:takion/src/data/dto/dto.dart';

abstract class MetronRemoteDataSource {
  Future<Response> rawGet(
    String path, {
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  });
  Future<Response> getWeeklyReleasesForDate(DateTime date);
  Future<Response> getFocReleasesForDate(DateTime date);
  Future<Response> getIssueDetails(int issueId);
  Future<IssueSearchResponseDto> searchIssues(
    String query, {
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
  });
  Future<IssueSearchResponseDto> getIssueList({
    int page = 1,
    String? ordering,
    DateTime? modifiedGt,
    int? limit,
    CancelToken? cancelToken,
  });
  Future<SeriesListResponseDto> getSeriesList({
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
  });
  Future<SeriesSearchResponseDto> searchSeries(
    String query, {
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
  });
  Future<Response> getSeriesDetails(int seriesId);
  Future<SeriesIssueListResponseDto> getSeriesIssueList(
    int seriesId, {
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
  });
  Future<CharacterListResponseDto> getCharacterList({
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
  });
  Future<CharacterListResponseDto> searchCharacters(
    String query, {
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
  });
  Future<CharacterDetailsDto> getCharacterDetails(int characterId);
  Future<SeriesIssueListResponseDto> getCharacterIssueList(
    int characterId, {
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
  });

  Future<CreatorListResponseDto> getCreatorList({
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
  });

  Future<CreatorListResponseDto> searchCreators(
    String query, {
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
  });

  Future<CreatorDetailsDto> getCreatorDetails(int creatorId);

  Future<UniverseListResponseDto> getUniverseList({
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
  });

  Future<UniverseListResponseDto> searchUniverses(
    String query, {
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
  });

  Future<UniverseDetailsDto> getUniverseDetails(int universeId);

  Future<ImprintListResponseDto> getImprintList({
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
  });

  Future<ImprintListResponseDto> searchImprints(
    String query, {
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
  });

  Future<ImprintDetailsDto> getImprintDetails(int imprintId);

  Future<TeamListResponseDto> getTeamList({
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
  });

  Future<TeamListResponseDto> searchTeams(
    String query, {
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
  });

  Future<TeamDetailsDto> getTeamDetails(int teamId);
  Future<ArcListResponseDto> getArcList({
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
  });

  Future<ArcListResponseDto> searchArcs(
    String query, {
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
  });
  Future<ArcDetailsDto> getArcDetails(int arcId);
  Future<SeriesIssueListResponseDto> getArcIssueList(
    int arcId, {
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
  });

  Future<PublisherListResponseDto> getPublisherList({
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
  });

  Future<PublisherListResponseDto> searchPublishers(
    String query, {
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
  });

  Future<PublisherDetailsDto> getPublisherDetails(int publisherId);

  Future<SeriesListResponseDto> getPublisherSeriesList(
    int publisherId, {
    int page = 1,
    CancelToken? cancelToken,
  });

  Future<ReadingListResponseDto> getReadingLists({
    int page = 1,
    String? name,
    String? listType,
    String? attributionSource,
    String? publisher,
    CancelToken? cancelToken,
  });

  Future<ReadingListDetailDto> getReadingListDetail(int id);

  Future<ReadingListItemResponseDto> getReadingListItems(
    int id, {
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

  String _normalizeQuery(String query) {
    return query
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'[^\w\s#-]'), ' ')
        .trim();
  }

  @override
  Future<Response> getWeeklyReleasesForDate(DateTime date) async {
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
    );
  }

  @override
  Future<Response> getFocReleasesForDate(DateTime date) async {
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
    );
  }

  @override
  Future<Response> getIssueDetails(int issueId) async {
    return _dio.get('issue/$issueId/');
  }

  @override
  Future<IssueSearchResponseDto> searchIssues(
    String query, {
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
  }) async {
    final normalized = _normalizeQuery(query);
    if (normalized.isEmpty) {
      return const IssueSearchResponseDto(count: 0, results: []);
    }

    final response = await _dio.get(
      'issue/',
      queryParameters: {
        'series_name': normalized,
        'page': page,
      },
      cancelToken: cancelToken,
    );

    return IssueSearchResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<IssueSearchResponseDto> getIssueList({
    int page = 1,
    String? ordering,
    DateTime? modifiedGt,
    int? limit,
    CancelToken? cancelToken,
  }) async {
    final queryParameters = <String, dynamic>{'page': page};
    if (ordering != null && ordering.trim().isNotEmpty) {
      queryParameters['ordering'] = ordering.trim();
    }
    if (modifiedGt != null) {
      queryParameters['modified_gt'] = modifiedGt.toUtc().toIso8601String();
    }
    final response = await _dio.get(
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
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.get(
      'series/',
      queryParameters: {'page': page},
      cancelToken: cancelToken,
    );

    return SeriesListResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<SeriesSearchResponseDto> searchSeries(
    String query, {
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
  }) async {
    final normalized = _normalizeQuery(query);
    if (normalized.isEmpty) {
      return const SeriesSearchResponseDto(count: 0, results: []);
    }

    final response = await _dio.get(
      'series/',
      queryParameters: {'name': normalized, 'page': page},
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
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.get(
      'series/$seriesId/issue_list/',
      queryParameters: {'page': page},
      cancelToken: cancelToken,
    );

    return SeriesIssueListResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<CharacterListResponseDto> getCharacterList({
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.get(
      'character/',
      queryParameters: {'page': page},
      cancelToken: cancelToken,
    );

    return CharacterListResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<CharacterListResponseDto> searchCharacters(
    String query, {
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
  }) async {
    final normalized = _normalizeQuery(query);
    if (normalized.isEmpty) {
      return const CharacterListResponseDto(count: 0, results: []);
    }

    final response = await _dio.get(
      'character/',
      queryParameters: {'name': normalized, 'page': page},
      cancelToken: cancelToken,
    );

    return CharacterListResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<CharacterDetailsDto> getCharacterDetails(int characterId) async {
    final response = await _dio.get('character/$characterId/');
    return CharacterDetailsDto.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<SeriesIssueListResponseDto> getCharacterIssueList(
    int characterId, {
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.get(
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
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.get(
      'creator/',
      queryParameters: {'page': page},
      cancelToken: cancelToken,
    );
    return CreatorListResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<CreatorListResponseDto> searchCreators(
    String query, {
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
  }) async {
    final normalized = _normalizeQuery(query);
    if (normalized.isEmpty) {
      return const CreatorListResponseDto(count: 0, results: []);
    }

    final response = await _dio.get(
      'creator/',
      queryParameters: {'name': normalized, 'page': page},
      cancelToken: cancelToken,
    );

    return CreatorListResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<CreatorDetailsDto> getCreatorDetails(int creatorId) async {
    final response = await _dio.get('creator/$creatorId/');
    return CreatorDetailsDto.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<UniverseListResponseDto> getUniverseList({
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.get(
      'universe/',
      queryParameters: {'page': page},
      cancelToken: cancelToken,
    );
    return UniverseListResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<UniverseListResponseDto> searchUniverses(
    String query, {
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
  }) async {
    final normalized = _normalizeQuery(query);
    if (normalized.isEmpty) {
      return const UniverseListResponseDto(count: 0, results: []);
    }

    final response = await _dio.get(
      'universe/',
      queryParameters: {'name': normalized, 'page': page},
      cancelToken: cancelToken,
    );

    return UniverseListResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<UniverseDetailsDto> getUniverseDetails(int universeId) async {
    final response = await _dio.get('universe/$universeId/');
    return UniverseDetailsDto.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<ImprintListResponseDto> getImprintList({
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.get(
      'imprint/',
      queryParameters: {'page': page},
      cancelToken: cancelToken,
    );
    return ImprintListResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<ImprintListResponseDto> searchImprints(
    String query, {
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
  }) async {
    final normalized = _normalizeQuery(query);
    if (normalized.isEmpty) {
      return const ImprintListResponseDto(count: 0, results: []);
    }

    final response = await _dio.get(
      'imprint/',
      queryParameters: {'name': normalized, 'page': page},
      cancelToken: cancelToken,
    );

    return ImprintListResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<ImprintDetailsDto> getImprintDetails(int imprintId) async {
    final response = await _dio.get('imprint/$imprintId/');
    return ImprintDetailsDto.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<TeamListResponseDto> searchTeams(
    String query, {
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
  }) async {
    final normalized = _normalizeQuery(query);
    if (normalized.isEmpty) {
      return const TeamListResponseDto(count: 0, results: []);
    }

    final response = await _dio.get(
      'team/',
      queryParameters: {'name': normalized, 'page': page},
      cancelToken: cancelToken,
    );

    return TeamListResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<TeamListResponseDto> getTeamList({
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.get(
      'team/',
      queryParameters: {'page': page},
      cancelToken: cancelToken,
    );
    return TeamListResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<TeamDetailsDto> getTeamDetails(int teamId) async {
    final response = await _dio.get('team/$teamId/');
    return TeamDetailsDto.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<ArcListResponseDto> searchArcs(
    String query, {
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
  }) async {
    final normalized = _normalizeQuery(query);
    if (normalized.isEmpty) {
      return const ArcListResponseDto(count: 0, results: []);
    }

    final response = await _dio.get(
      'arc/',
      queryParameters: {'name': normalized, 'page': page},
      cancelToken: cancelToken,
    );

    return ArcListResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<ArcListResponseDto> getArcList({
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.get(
      'arc/',
      queryParameters: {'page': page},
      cancelToken: cancelToken,
    );
    return ArcListResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<ArcDetailsDto> getArcDetails(int arcId) async {
    final response = await _dio.get('arc/$arcId/');
    return ArcDetailsDto.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<SeriesIssueListResponseDto> getArcIssueList(
    int arcId, {
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.get(
      'arc/$arcId/issue_list/',
      queryParameters: {'page': page},
      cancelToken: cancelToken,
    );

    return SeriesIssueListResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<PublisherListResponseDto> getPublisherList({
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.get(
      'publisher/',
      queryParameters: {'page': page},
      cancelToken: cancelToken,
    );
    return PublisherListResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<PublisherListResponseDto> searchPublishers(
    String query, {
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
  }) async {
    final normalized = _normalizeQuery(query);
    if (normalized.isEmpty) {
      return const PublisherListResponseDto(count: 0, results: []);
    }

    final response = await _dio.get(
      'publisher/',
      queryParameters: {'name': normalized, 'page': page},
      cancelToken: cancelToken,
    );

    return PublisherListResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<PublisherDetailsDto> getPublisherDetails(int publisherId) async {
    final response = await _dio.get('publisher/$publisherId/');
    return PublisherDetailsDto.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<SeriesListResponseDto> getPublisherSeriesList(
    int publisherId, {
    int page = 1,
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.get(
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
    int page = 1,
    String? name,
    String? listType,
    String? attributionSource,
    String? publisher,
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

    final response = await _dio.get(
      'reading_list/',
      queryParameters: queryParameters,
      cancelToken: cancelToken,
    );

    return ReadingListResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<ReadingListDetailDto> getReadingListDetail(int id) async {
    final response = await _dio.get('reading_list/$id/');
    return ReadingListDetailDto.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<ReadingListItemResponseDto> getReadingListItems(
    int id, {
    int page = 1,
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.get(
      'reading_list/$id/items/',
      queryParameters: {'page': page},
      cancelToken: cancelToken,
    );

    return ReadingListItemResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}
