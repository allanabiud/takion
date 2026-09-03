import "package:takion/src/data/collection/datasources/remote/metron_collection_remote_data_source.dart";
import "package:takion/src/data/collection/dto/scrobble_dto.dart";
import "package:takion/src/domain/collection/entities/collection_item.dart";
import "package:takion/src/domain/collection/entities/collection_stats.dart";
import "package:takion/src/domain/collection/entities/missing_issue.dart";
import "package:takion/src/domain/collection/entities/scrobble_result.dart";
import "package:takion/src/domain/collection/repositories/collection_repository.dart";

class MetronCollectionRepositoryImpl implements CollectionRepository {
  MetronCollectionRepositoryImpl(this._remoteDataSource);

  final MetronCollectionRemoteDataSource _remoteDataSource;

  @override
  Future<List<CollectionItem>> getCollection({
    int page = 1,
    String? bookFormat,
    DateTime? dateRead,
    double? grade,
    String? gradingCompany,
    bool? isRead,
    DateTime? modifiedGt,
    int? rating,
  }) async {
    final dtos = await _remoteDataSource.getCollection(
      page: page,
      bookFormat: bookFormat,
      dateRead: dateRead,
      grade: grade,
      gradingCompany: gradingCompany,
      isRead: isRead,
      modifiedGt: modifiedGt,
      rating: rating,
    );
    return dtos.map((dto) => dto.toEntity()).toList();
  }

  @override
  Future<CollectionItem> getCollectionItem(int id) async {
    final dto = await _remoteDataSource.getCollectionItem(id);
    return dto.toEntity();
  }

  @override
  Future<CollectionItem> addToCollection({
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
  }) async {
    final dto = await _remoteDataSource.addToCollection(
      issueId: issueId,
      quantity: quantity,
      bookFormat: bookFormat,
      grade: grade,
      gradingCompany: gradingCompany,
      purchaseDate: purchaseDate,
      purchasePrice: purchasePrice,
      purchasePriceCurrency: purchasePriceCurrency,
      purchaseStore: purchaseStore,
      storageLocation: storageLocation,
      notes: notes,
    );
    return dto.toEntity();
  }

  @override
  Future<CollectionItem> updateCollectionItem({
    required int id,
    int? rating,
    int? quantity,
    String? bookFormat,
    double? grade,
    String? gradingCompany,
    DateTime? purchaseDate,
    double? purchasePrice,
    String? purchaseStore,
    String? storageLocation,
    String? notes,
    bool? isRead,
  }) async {
    final data = <String, dynamic>{
      "rating": ?rating,
      "quantity": ?quantity,
      "book_format": ?bookFormat,
      "grade": ?grade,
      "grading_company": ?gradingCompany,
      "purchase_date": ?purchaseDate?.toIso8601String().split("T").first,
      "purchase_price": ?purchasePrice,
      "purchase_store": ?purchaseStore,
      "storage_location": ?storageLocation,
      "notes": ?notes,
      "is_read": ?isRead,
    };

    final dto = await _remoteDataSource.updateCollectionItem(id, data);
    return dto.toEntity();
  }

  @override
  Future<void> removeFromCollection(int id) {
    return _remoteDataSource.removeFromCollection(id);
  }

  @override
  Future<ScrobbleResult> scrobble({
    required int issueId,
    DateTime? dateRead,
    int? rating,
  }) async {
    final request = ScrobbleRequestDto(
      issueId: issueId,
      dateRead: dateRead?.toUtc().toIso8601String(),
      rating: rating,
    );
    final dto = await _remoteDataSource.scrobble(request);
    return dto.toEntity();
  }

  @override
  Future<CollectionStats> getCollectionStats() async {
    final dto = await _remoteDataSource.getCollectionStats();
    return dto.toEntity();
  }

  @override
  Future<List<MissingIssue>> getMissingIssues(
    int seriesId, {
    int page = 1,
  }) async {
    final dtos = await _remoteDataSource.getMissingIssues(seriesId, page: page);
    return dtos.map((dto) => dto.toEntity()).toList();
  }

  @override
  Future<List<MissingSeries>> getMissingSeries({int page = 1}) async {
    final dtos = await _remoteDataSource.getMissingSeries(page: page);
    return dtos.map((dto) => dto.toEntity()).toList();
  }
}
