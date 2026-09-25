import "package:dio/dio.dart";
import "package:takion/src/core/constants/date_formatter.dart";
import "package:takion/src/data/collection/datasources/remote/metron_collection_remote_data_source.dart";
import "package:takion/src/data/collection/dto/collection_item_dto.dart";
import "package:takion/src/data/collection/dto/collection_stats_dto.dart";
import "package:takion/src/data/collection/dto/missing_issues_dto.dart";
import "package:takion/src/data/collection/dto/scrobble_dto.dart";

class MetronCollectionRemoteDataSourceImpl
    implements MetronCollectionRemoteDataSource {
  final Dio _dio;

  MetronCollectionRemoteDataSourceImpl(this._dio);

  @override
  Future<List<CollectionItemDto>> getCollection({
    int page = 1,
    String? bookFormat,
    DateTime? dateRead,
    double? grade,
    String? gradingCompany,
    bool? isRead,
    DateTime? modifiedGt,
    int? rating,
    CancelToken? cancelToken,
  }) async {
    final queryParameters = <String, dynamic>{
      "page": page,
      if (bookFormat != null && bookFormat.isNotEmpty)
        "book_format": bookFormat,
      if (dateRead != null)
        "date_read": DateFormatter.isoDate(dateRead),
      "grade": ?grade,
      if (gradingCompany != null && gradingCompany.isNotEmpty)
        "grading_company": gradingCompany,
      "is_read": ?isRead,
      if (modifiedGt != null)
        "modified_gt": modifiedGt.toUtc().toIso8601String(),
      "rating": ?rating,
    };

    try {
      final response = await _dio.get(
        "collection/",
        queryParameters: queryParameters,
        cancelToken: cancelToken,
      );

      final data = response.data as Map<String, dynamic>;
      final results = data["results"] as List<dynamic>? ?? [];
      return results
          .whereType<Map<String, dynamic>>()
          .map(CollectionItemDto.fromJson)
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return const [];
      }
      rethrow;
    }
  }

  @override
  Future<CollectionItemDto> getCollectionItem(
    int id, {
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.get(
      "collection/$id/",
      cancelToken: cancelToken,
    );
    return CollectionItemDto.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<CollectionItemDto> addToCollection({
    required int issueId,
    int quantity = 1,
    String bookFormat = "PRINT",
    double? grade,
    String? gradingCompany,
    DateTime? purchaseDate,
    double? purchasePrice,
    String purchasePriceCurrency = "USD",
    String? purchaseStore,
    String? storageLocation,
    String? notes,
    CancelToken? cancelToken,
  }) async {
    final payload = <String, dynamic>{
      "issue_id": issueId,
      "quantity": quantity,
      "book_format": bookFormat,
      "grade": ?grade,
      "grading_company": ?gradingCompany,
      if (purchaseDate != null)
        "purchase_date": DateFormatter.isoDate(purchaseDate),
      "purchase_price": ?purchasePrice,
      "purchase_price_currency": purchasePriceCurrency,
      "purchase_store": ?purchaseStore,
      "storage_location": ?storageLocation,
      "notes": ?notes,
    };

    final response = await _dio.post(
      "collection/add/",
      data: payload,
      cancelToken: cancelToken,
    );
    return CollectionItemDto.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<CollectionItemDto> updateCollectionItem(
    int id,
    Map<String, dynamic> data, {
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.patch(
      "collection/$id/",
      data: data,
      cancelToken: cancelToken,
    );
    return CollectionItemDto.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> removeFromCollection(
    int id, {
    CancelToken? cancelToken,
  }) async {
    try {
      await _dio.delete(
        "collection/$id/",
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
  Future<ScrobbleResponseDto> scrobble(
    ScrobbleRequestDto request, {
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.post(
      "collection/scrobble/",
      data: request.toJson(),
      cancelToken: cancelToken,
    );
    return ScrobbleResponseDto.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<CollectionStatsDto> getCollectionStats({
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.get(
      "collection/stats/",
      cancelToken: cancelToken,
    );
    return CollectionStatsDto.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<MissingIssuesPageDto> getMissingIssues(
    int seriesId, {
    int page = 1,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get(
        "collection/missing_issues/$seriesId/",
        queryParameters: {"page": page},
        cancelToken: cancelToken,
      );
      final data = response.data as Map<String, dynamic>;
      return MissingIssuesPageDto.fromJson(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return const MissingIssuesPageDto(count: 0, results: []);
      }
      rethrow;
    }
  }

  @override
  Future<List<MissingSeriesDto>> getMissingSeries({
    int page = 1,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get(
        "collection/missing_series/",
        queryParameters: {"page": page},
        cancelToken: cancelToken,
      );
      final data = response.data as Map<String, dynamic>;
      final results = data["results"] as List<dynamic>? ?? [];
      return results
          .whereType<Map<String, dynamic>>()
          .map(MissingSeriesDto.fromJson)
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return const [];
      }
      rethrow;
    }
  }
}
