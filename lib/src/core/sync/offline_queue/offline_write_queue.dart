import "dart:convert";
import "package:takion/src/core/sync/offline_queue/offline_queue_processor.dart";
import "package:takion/src/data/common/drift/daos/offline_queue_dao.dart";

class OfflineWriteQueue {
  final OfflineQueueDao _dao;
  final OfflineQueueProcessor _processor;

  OfflineWriteQueue({
    required OfflineQueueDao dao,
    required OfflineQueueProcessor processor,
  })  : _dao = dao,
        _processor = processor;

  Stream<int> watchPendingCount() => _dao.watchPendingCount();

  Stream<int> watchFailedCount() => _dao.watchFailedCount();

  Future<void> retryFailedEntries() => _dao.resetFailedEntries();

  Future<int> enqueueCollectionAdd({
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
  }) {
    final payload = <String, dynamic>{
      "issue_id": issueId,
      "quantity": quantity,
      "book_format": bookFormat,
      "grade": ?grade,
      "grading_company": ?gradingCompany,
      if (purchaseDate != null)
        "purchase_date": purchaseDate.toIso8601String().split("T").first,
      "purchase_price": ?purchasePrice,
      "purchase_price_currency": purchasePriceCurrency,
      "purchase_store": ?purchaseStore,
      "storage_location": ?storageLocation,
      "notes": ?notes,
    };

    return _dao.enqueue(
      operation: "create",
      entityType: "collection",
      entityId: issueId.toString(),
      payload: jsonEncode(payload),
    );
  }

  Future<int> enqueueCollectionUpdate({
    required int metronCollectionId,
    Map<String, dynamic> updates = const {},
  }) {
    return _dao.enqueue(
      operation: "update",
      entityType: "collection",
      entityId: metronCollectionId.toString(),
      payload: jsonEncode(updates),
    );
  }

  Future<int> enqueueCollectionDelete({required int metronCollectionId}) {
    return _dao.enqueue(
      operation: "delete",
      entityType: "collection",
      entityId: metronCollectionId.toString(),
      payload: "{}",
    );
  }

  Future<int> enqueueScrobble({
    required int issueId,
    DateTime? dateRead,
    int? rating,
  }) {
    final payload = <String, dynamic>{
      "issue_id": issueId,
      if (dateRead != null) "date_read": dateRead.toUtc().toIso8601String(),
      "rating": ?rating,
    };

    return _dao.enqueue(
      operation: "scrobble",
      entityType: "collection",
      entityId: issueId.toString(),
      payload: jsonEncode(payload),
    );
  }

  Future<int> enqueuePullListAdd({required int seriesId}) {
    return _dao.enqueue(
      operation: "create",
      entityType: "pull_list",
      entityId: seriesId.toString(),
      payload: jsonEncode({"series_id": seriesId}),
    );
  }

  Future<int> enqueuePullListRemove({required int seriesId}) {
    return _dao.enqueue(
      operation: "delete",
      entityType: "pull_list",
      entityId: seriesId.toString(),
      payload: jsonEncode({"series_id": seriesId}),
    );
  }

  Future<int> enqueueWishlistAdd({
    required int issueId,
    int priority = 3,
    double? desiredGrade,
    double? maxPrice,
    String maxPriceCurrency = "USD",
    String? notes,
  }) {
    final payload = <String, dynamic>{
      "issue_id": issueId,
      "priority": priority,
      "desired_grade": ?desiredGrade,
      "max_price": ?maxPrice,
      "max_price_currency": maxPriceCurrency,
      "notes": ?notes,
    };

    return _dao.enqueue(
      operation: "create",
      entityType: "wish_list",
      entityId: issueId.toString(),
      payload: jsonEncode(payload),
    );
  }

  Future<int> enqueueWishlistAcquire({
    required int itemId,
    DateTime? purchaseDate,
    double? purchasePrice,
    String purchasePriceCurrency = "USD",
    String? purchaseStore,
    String? notes,
  }) {
    final payload = <String, dynamic>{
      if (purchaseDate != null)
        "purchase_date": purchaseDate.toIso8601String().split("T").first,
      "purchase_price": ?purchasePrice,
      "purchase_price_currency": purchasePriceCurrency,
      "purchase_store": ?purchaseStore,
      "notes": ?notes,
    };

    return _dao.enqueue(
      operation: "acquire",
      entityType: "wish_list",
      entityId: itemId.toString(),
      payload: jsonEncode(payload),
    );
  }

  Future<int> enqueueWishlistRemove({required int itemId}) {
    return _dao.enqueue(
      operation: "delete",
      entityType: "wish_list",
      entityId: itemId.toString(),
      payload: "{}",
    );
  }

  Future<int> processQueue({int batchSize = 20}) {
    return _processor.processPendingEntries(batchSize: batchSize);
  }
}
