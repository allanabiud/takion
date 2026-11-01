import "package:dio/dio.dart";
import "package:takion/src/core/constants/date_formatter.dart";
import "package:takion/src/core/network/remote_page.dart";
import "package:takion/src/core/network/request_priority.dart";
import "package:takion/src/data/pull_list/datasources/remote/metron_pull_list_remote_data_source.dart";
import "package:takion/src/data/pull_list/dto/pull_list_dto.dart";

class MetronPullListRemoteDataSourceImpl
    implements MetronPullListRemoteDataSource {
  final Dio _dio;

  MetronPullListRemoteDataSourceImpl(this._dio);

  @override
  Future<RemotePage<PullListSeriesDto>> getPullListSeriesPage({
    Uri? pageUrl,
    CancelToken? cancelToken,
  }) async {
    try {
      // Sequential pagination is capped at one in-flight scan by the
      // request scheduler (Phase 5 Step 2).
      final scanOptions = Options(extra: const {paginationScanExtraKey: true});
      final Response<dynamic> response;
      if (pageUrl != null) {
        response = await _dio.getUri(
          pageUrl,
          cancelToken: cancelToken,
          options: scanOptions,
        );
      } else {
        response = await _dio.get(
          "pull_list/series/",
          cancelToken: cancelToken,
          options: scanOptions,
        );
      }

      final data = response.data as Map<String, dynamic>;
      final results = data["results"] as List<dynamic>? ?? const [];
      final items = results
          .whereType<Map<String, dynamic>>()
          .map(PullListSeriesDto.fromJson)
          .toList();
      final count = data["count"] as int? ?? items.length;
      final nextRaw = data["next"] as String?;
      final prevRaw = data["previous"] as String?;

      return RemotePage<PullListSeriesDto>(
        items: items,
        count: count,
        next: nextRaw != null && nextRaw.isNotEmpty
            ? Uri.tryParse(nextRaw)
            : null,
        previous: prevRaw != null && prevRaw.isNotEmpty
            ? Uri.tryParse(prevRaw)
            : null,
        fetchedAt: DateTime.now().toUtc(),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return RemotePage<PullListSeriesDto>(
          items: const [],
          count: 0,
          next: null,
          previous: null,
          fetchedAt: DateTime.now().toUtc(),
        );
      }
      rethrow;
    }
  }

  @override
  Future<RemotePage<PullListIssueDto>> getPullListIssuesPage({
    Uri? pageUrl,
    DateTime? storeDateAfter,
    DateTime? storeDateBefore,
    CancelToken? cancelToken,
  }) async {
    try {
      // Sequential pagination is capped at one in-flight scan by the
      // request scheduler (Phase 5 Step 2).
      final scanOptions = Options(extra: const {paginationScanExtraKey: true});
      final Response<dynamic> response;
      if (pageUrl != null) {
        response = await _dio.getUri(
          pageUrl,
          cancelToken: cancelToken,
          options: scanOptions,
        );
      } else {
        final queryParameters = <String, dynamic>{
          if (storeDateAfter != null)
            "store_date_range_after": DateFormatter.isoDate(storeDateAfter),
          if (storeDateBefore != null)
            "store_date_range_before": DateFormatter.isoDate(storeDateBefore),
        };
        response = await _dio.get(
          "pull_list/issue/",
          queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
          cancelToken: cancelToken,
          options: scanOptions,
        );
      }

      final data = response.data as Map<String, dynamic>;
      final results = data["results"] as List<dynamic>? ?? const [];
      final items = results
          .whereType<Map<String, dynamic>>()
          .map(PullListIssueDto.fromJson)
          .toList();
      final count = data["count"] as int? ?? items.length;
      final nextRaw = data["next"] as String?;
      final prevRaw = data["previous"] as String?;

      return RemotePage<PullListIssueDto>(
        items: items,
        count: count,
        next: nextRaw != null && nextRaw.isNotEmpty
            ? Uri.tryParse(nextRaw)
            : null,
        previous: prevRaw != null && prevRaw.isNotEmpty
            ? Uri.tryParse(prevRaw)
            : null,
        fetchedAt: DateTime.now().toUtc(),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return RemotePage<PullListIssueDto>(
          items: const [],
          count: 0,
          next: null,
          previous: null,
          fetchedAt: DateTime.now().toUtc(),
        );
      }
      rethrow;
    }
  }

  @override
  Future<List<PullListReadDto>> getPullLists({
    int page = 1,
    CancelToken? cancelToken,
  }) async {
    try {
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
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return const [];
      }
      rethrow;
    }
  }

  @override
  Future<PullListReadDto> getPullList(
    int id, {
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.get("pull_list/$id/", cancelToken: cancelToken);
    return PullListReadDto.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<PullListSeriesDto>> getPullListSeries({
    int page = 1,
    DateTime? modifiedGt,
    CancelToken? cancelToken,
  }) async {
    try {
      final queryParameters = <String, dynamic>{"page": page};
      if (modifiedGt != null) {
        queryParameters["modified_gt"] = modifiedGt.toUtc().toIso8601String();
      }
      final response = await _dio.get(
        "pull_list/series/",
        queryParameters: queryParameters,
        cancelToken: cancelToken,
      );
      final data = response.data as Map<String, dynamic>;
      final results = data["results"] as List<dynamic>? ?? [];
      return results
          .whereType<Map<String, dynamic>>()
          .map(PullListSeriesDto.fromJson)
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return const [];
      }
      rethrow;
    }
  }

  @override
  Future<PullListSeriesDto> addSeriesToPullList(
    int seriesId, {
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.post(
      "pull_list/series/add/",
      data: {"series_id": seriesId},
      cancelToken: cancelToken,
    );
    return PullListSeriesDto.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> removeSeriesFromPullList(
    int seriesId, {
    CancelToken? cancelToken,
  }) async {
    try {
      await _dio.delete(
        "pull_list/series/$seriesId/remove/",
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return;
      }
      rethrow;
    }
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

    try {
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
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return const [];
      }
      rethrow;
    }
  }
}
