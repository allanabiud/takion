import 'package:dio/dio.dart';
import 'package:takion/src/data/models/issue_details_dto.dart';
import 'package:takion/src/data/models/issue_list_dto.dart';

abstract class MetronRemoteDataSource {
  Future<List<IssueListDto>> getWeeklyReleasesForDate(DateTime date);
  Future<IssueDetailsDto> getIssueDetails(int issueId);
}

class MetronRemoteDataSourceImpl implements MetronRemoteDataSource {
  final Dio _dio;

  MetronRemoteDataSourceImpl(this._dio);

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
}
