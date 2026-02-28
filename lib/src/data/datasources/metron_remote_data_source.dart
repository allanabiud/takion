import 'package:dio/dio.dart';
import 'package:takion/src/data/models/collection_item_details_dto.dart';
import 'package:takion/src/data/models/collection_stats_dto.dart';
import 'package:takion/src/data/models/collection_items_response_dto.dart';
import 'package:takion/src/data/models/collection_scrobble_response_dto.dart';
import 'package:takion/src/data/models/issue_details_dto.dart';
import 'package:takion/src/data/models/issue_list_dto.dart';
import 'package:takion/src/data/models/issue_search_response_dto.dart';
import 'package:takion/src/data/models/missing_series_response_dto.dart';
import 'package:takion/src/data/models/series_details_dto.dart';
import 'package:takion/src/data/models/series_issue_list_response_dto.dart';
import 'package:takion/src/data/models/series_list_response_dto.dart';
import 'package:takion/src/data/models/series_search_response_dto.dart';

abstract class MetronRemoteDataSource {
  Future<CollectionStatsDto> getCollectionStats();
  Future<CollectionScrobbleResponseDto> scrobbleIssueRead({
    required int issueId,
    DateTime? dateRead,
    int? rating,
  });
  Future<CollectionItemsResponseDto> getCollectionItems({int page = 1});
  Future<CollectionItemDetailsDto> getCollectionItemDetails(int collectionId);
  Future<MissingSeriesResponseDto> getMissingSeries({int page = 1});
  Future<List<IssueListDto>> getWeeklyReleasesForDate(DateTime date);
  Future<IssueDetailsDto> getIssueDetails(int issueId);
  Future<IssueSearchResponseDto> searchIssues(String query, {int page = 1});
  Future<SeriesListResponseDto> getSeriesList({int page = 1});
  Future<SeriesSearchResponseDto> searchSeries(String query, {int page = 1});
  Future<SeriesDetailsDto> getSeriesDetails(int seriesId);
  Future<SeriesIssueListResponseDto> getSeriesIssueList(
    int seriesId, {
    int page = 1,
  });
}

class MetronRemoteDataSourceImpl implements MetronRemoteDataSource {
  final Dio _dio;

  MetronRemoteDataSourceImpl(this._dio);

  String _normalizeQuery(String query) {
    final collapsed = query.trim().replaceAll(RegExp(r'\s+'), ' ');
    return collapsed;
  }

  List<String> _queryCandidates(String query) {
    final normalized = _normalizeQuery(query);
    if (normalized.isEmpty) return const [];

    final cleaned = normalized
        .replaceAll(RegExp(r'[^\w\s#-]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    final tokens = cleaned
        .split(' ')
        .map((token) => token.trim())
        .where((token) => token.length >= 3)
        .toList();

    final candidates = <String>{normalized};
    if (cleaned.isNotEmpty) {
      candidates.add(cleaned);
    }
    candidates.addAll(tokens);

    return candidates.toList(growable: false);
  }

  @override
  Future<CollectionStatsDto> getCollectionStats() async {
    final response = await _dio.get('collection/stats/');
    return CollectionStatsDto.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<CollectionScrobbleResponseDto> scrobbleIssueRead({
    required int issueId,
    DateTime? dateRead,
    int? rating,
  }) async {
    final payload = <String, dynamic>{'issue_id': issueId};

    if (dateRead != null) {
      payload['date_read'] = dateRead.toUtc().toIso8601String();
    }
    if (rating != null) {
      payload['rating'] = rating;
    }

    final response = await _dio.post('collection/scrobble/', data: payload);

    return CollectionScrobbleResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<CollectionItemsResponseDto> getCollectionItems({int page = 1}) async {
    final response = await _dio.get(
      'collection/',
      queryParameters: {'page': page},
    );
    return CollectionItemsResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<CollectionItemDetailsDto> getCollectionItemDetails(
    int collectionId,
  ) async {
    final response = await _dio.get('collection/$collectionId/');
    return CollectionItemDetailsDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<MissingSeriesResponseDto> getMissingSeries({int page = 1}) async {
    final response = await _dio.get(
      'collection/missing_series/',
      queryParameters: {'page': page},
    );
    return MissingSeriesResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<List<IssueListDto>> getWeeklyReleasesForDate(DateTime date) async {
    final offset = date.weekday % 7;
    final startOfWeek = DateTime(
      date.year,
      date.month,
      date.day,
    ).subtract(Duration(days: offset));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    String formatDate(DateTime d) =>
        "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

    final response = await _dio.get(
      'issue/',
      queryParameters: {
        'store_date_range_after': formatDate(startOfWeek),
        'store_date_range_before': formatDate(endOfWeek),
      },
    );

    final List results = response.data['results'];
    return results.map((e) => IssueListDto.fromJson(e)).toList();
  }

  @override
  Future<IssueDetailsDto> getIssueDetails(int issueId) async {
    final response = await _dio.get('issue/$issueId/');
    return IssueDetailsDto.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<IssueSearchResponseDto> searchIssues(
    String query, {
    int page = 1,
  }) async {
    final candidates = _queryCandidates(query);
    if (candidates.isEmpty) {
      return const IssueSearchResponseDto(count: 0, results: []);
    }

    IssueSearchResponseDto? lastResponse;
    for (final candidate in candidates) {
      final response = await _dio.get(
        'issue/',
        queryParameters: {'series_name': candidate, 'page': page},
      );

      final parsed = IssueSearchResponseDto.fromJson(
        response.data as Map<String, dynamic>,
      );
      lastResponse = parsed;

      if (parsed.results.isNotEmpty) {
        return parsed;
      }
    }

    return lastResponse ?? const IssueSearchResponseDto(count: 0, results: []);
  }

  @override
  Future<SeriesListResponseDto> getSeriesList({int page = 1}) async {
    final response = await _dio.get('series/', queryParameters: {'page': page});

    return SeriesListResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<SeriesSearchResponseDto> searchSeries(
    String query, {
    int page = 1,
  }) async {
    final candidates = _queryCandidates(query);
    if (candidates.isEmpty) {
      return const SeriesSearchResponseDto(count: 0, results: []);
    }

    SeriesSearchResponseDto? lastResponse;
    for (final candidate in candidates) {
      final response = await _dio.get(
        'series/',
        queryParameters: {'name': candidate, 'page': page},
      );

      final parsed = SeriesSearchResponseDto.fromJson(
        response.data as Map<String, dynamic>,
      );
      lastResponse = parsed;

      if (parsed.results.isNotEmpty) {
        return parsed;
      }
    }

    return lastResponse ?? const SeriesSearchResponseDto(count: 0, results: []);
  }

  @override
  Future<SeriesDetailsDto> getSeriesDetails(int seriesId) async {
    final response = await _dio.get('series/$seriesId/');
    return SeriesDetailsDto.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<SeriesIssueListResponseDto> getSeriesIssueList(
    int seriesId, {
    int page = 1,
  }) async {
    final response = await _dio.get(
      'series/$seriesId/issue_list/',
      queryParameters: {'page': page},
    );

    return SeriesIssueListResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}
