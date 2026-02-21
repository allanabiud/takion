import 'package:dio/dio.dart';
import 'package:takion/src/data/models/issue_dto.dart';
import 'package:takion/src/data/models/series_dto.dart';

abstract class MetronRemoteDataSource {
  Future<List<IssueDto>> getWeeklyReleases();
  Future<List<IssueDto>> getWeeklyReleasesForDate(DateTime date);
  Future<List<IssueDto>> searchIssues(String query);
  Future<List<SeriesDto>> searchSeries(String query);
  Future<IssueDto> getIssueDetails(int id);
}

class MetronRemoteDataSourceImpl implements MetronRemoteDataSource {
  final Dio _dio;

  MetronRemoteDataSourceImpl(this._dio);

  @override
  Future<List<IssueDto>> getWeeklyReleases() async {
    return getWeeklyReleasesForDate(DateTime.now());
  }

  @override
  Future<List<IssueDto>> getWeeklyReleasesForDate(DateTime date) async {
    // Week starts on Sunday. 
    // In Dart weekday is 1 (Mon) to 7 (Sun).
    // If it's Sunday (7), subtract 0. If Monday (1), subtract 1.
    final offset = date.weekday % 7;
    final startOfWeek = DateTime(date.year, date.month, date.day).subtract(Duration(days: offset));
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
    return results.map((e) => IssueDto.fromJson(e)).toList();
  }

  @override
  Future<List<IssueDto>> searchIssues(String query) async {
    final response = await _dio.get(
      'issue/',
      queryParameters: {'series_name': query},
    );
    final List results = response.data['results'];
    return results.map((e) => IssueDto.fromJson(e)).toList();
  }

  @override
  Future<List<SeriesDto>> searchSeries(String query) async {
    final response = await _dio.get(
      'series/',
      queryParameters: {'name': query},
    );
    final List results = response.data['results'];
    return results.map((e) => SeriesDto.fromJson(e)).toList();
  }

  @override
  Future<IssueDto> getIssueDetails(int id) async {
    final response = await _dio.get('issue/$id/');
    return IssueDto.fromJson(response.data);
  }
}
