import "package:dio/dio.dart";
import "package:takion/src/data/collection/dto/collection_item_dto.dart";
import "package:takion/src/data/collection/dto/collection_stats_dto.dart";
import "package:takion/src/data/collection/dto/missing_issues_dto.dart";
import "package:takion/src/data/collection/dto/scrobble_dto.dart";

abstract class MetronCollectionRemoteDataSource {
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
  });

  Future<CollectionItemDto> getCollectionItem(
    int id, {
    CancelToken? cancelToken,
  });

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
  });

  Future<CollectionItemDto> updateCollectionItem(
    int id,
    Map<String, dynamic> data, {
    CancelToken? cancelToken,
  });

  Future<void> removeFromCollection(
    int id, {
    CancelToken? cancelToken,
  });

  Future<ScrobbleResponseDto> scrobble(
    ScrobbleRequestDto request, {
    CancelToken? cancelToken,
  });

  Future<CollectionStatsDto> getCollectionStats({
    CancelToken? cancelToken,
  });

  Future<List<MissingIssueDto>> getMissingIssues(
    int seriesId, {
    int page = 1,
    CancelToken? cancelToken,
  });

  Future<List<MissingSeriesDto>> getMissingSeries({
    int page = 1,
    CancelToken? cancelToken,
  });
}
