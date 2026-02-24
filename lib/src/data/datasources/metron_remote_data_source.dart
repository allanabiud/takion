import 'package:dio/dio.dart';
import 'package:takion/src/data/models/issue_details_dto.dart';
import 'package:takion/src/data/models/issue_list_dto.dart';
import 'package:takion/src/data/models/issue_search_response_dto.dart';
import 'package:takion/src/data/models/series_list_response_dto.dart';
import 'package:takion/src/data/models/series_search_response_dto.dart';

abstract class MetronRemoteDataSource {
  Future<List<IssueListDto>> getWeeklyReleasesForDate(DateTime date);
  Future<IssueDetailsDto> getIssueDetails(int issueId);
  Future<IssueSearchResponseDto> searchIssues(String query, {int page = 1});
  Future<SeriesListResponseDto> getSeriesList({int page = 1});
  Future<SeriesSearchResponseDto> searchSeries(String query, {int page = 1});
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

    final cleaned = normalized.replaceAll(RegExp(r'[^\w\s#-]'), ' ').replaceAll(
      RegExp(r'\s+'),
      ' ',
    ).trim();
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
        queryParameters: {
          'series_name': candidate,
          'page': page,
        },
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
    final response = await _dio.get(
      'series/',
      queryParameters: {
        'page': page,
      },
    );

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
        queryParameters: {
          'name': candidate,
          'page': page,
        },
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
}
