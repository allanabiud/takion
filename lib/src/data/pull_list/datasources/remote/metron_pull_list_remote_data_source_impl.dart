import "package:dio/dio.dart";
import "package:takion/src/core/constants/date_formatter.dart";
import "package:takion/src/data/pull_list/datasources/remote/metron_pull_list_remote_data_source.dart";
import "package:takion/src/data/pull_list/dto/pull_list_dto.dart";

class MetronPullListRemoteDataSourceImpl
    implements MetronPullListRemoteDataSource {
  final Dio _dio;

  MetronPullListRemoteDataSourceImpl(this._dio);

  @override
  Future<List<PullListReadDto>> getPullLists({
    int page = 1,
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.get(
      "pull_list/",
      queryParameters: {"page": page},
      cancelToken: cancelToken,
    );
    final data = response.data as Map<String, dynamic>;
    final results = data["results"] as List<dynamic>? ?? [];
    return results
        .whereType<Map<String, dynamic>>()
        .map(PullListReadDto.fromJson)
        .toList();
  }

  @override
  Future<PullListReadDto> getPullList(
    int id, {
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.get(
      "pull_list/$id/",
      cancelToken: cancelToken,
    );
    return PullListReadDto.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<PullListSeriesDto>> getPullListSeries({
    int page = 1,
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.get(
      "pull_list/series/",
      queryParameters: {"page": page},
      cancelToken: cancelToken,
    );
    final data = response.data as Map<String, dynamic>;
    final results = data["results"] as List<dynamic>? ?? [];
    return results
        .whereType<Map<String, dynamic>>()
        .map(PullListSeriesDto.fromJson)
        .toList();
  }

  @override
  Future<PullListSeriesDto> addSeriesToPullList(
    int seriesId, {
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.post(
      "pull_list/series/add/",
      queryParameters: {"series_id": seriesId},
      cancelToken: cancelToken,
    );
    return PullListSeriesDto.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> removeSeriesFromPullList(
    int seriesId, {
    CancelToken? cancelToken,
  }) async {
    await _dio.delete(
      "pull_list/series/$seriesId/remove/",
      cancelToken: cancelToken,
    );
  }

  @override
  Future<List<PullListIssueDto>> getPullListIssues({
    int page = 1,
    DateTime? storeDateAfter,
    DateTime? storeDateBefore,
    CancelToken? cancelToken,
  }) async {
    final queryParameters = <String, dynamic>{
      "page": page,
      if (storeDateAfter != null)
        "store_date_after": DateFormatter.isoDate(storeDateAfter),
      if (storeDateBefore != null)
        "store_date_before": DateFormatter.isoDate(storeDateBefore),
    };

    final response = await _dio.get(
      "pull_list/issues/",
      queryParameters: queryParameters,
      cancelToken: cancelToken,
    );
    final data = response.data as Map<String, dynamic>;
    final results = data["results"] as List<dynamic>? ?? [];
    return results
        .whereType<Map<String, dynamic>>()
        .map(PullListIssueDto.fromJson)
        .toList();
  }
}
