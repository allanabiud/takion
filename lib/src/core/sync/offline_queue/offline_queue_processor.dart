import "dart:convert";
import "package:takion/src/core/logging/app_logger.dart";
import "package:takion/src/data/collection/datasources/remote/metron_collection_remote_data_source.dart";
import "package:takion/src/data/collection/dto/scrobble_dto.dart";
import "package:takion/src/data/common/drift/daos/offline_queue_dao.dart";
import "package:takion/src/data/pull_list/datasources/remote/metron_pull_list_remote_data_source.dart";
import "package:takion/src/data/wishlist/datasources/remote/metron_wishlist_remote_data_source.dart";
import "package:takion/src/data/wishlist/dto/wishlist_dto.dart";

class OfflineQueueProcessor {
  final OfflineQueueDao _dao;
  final MetronCollectionRemoteDataSource _collectionRemote;
  final MetronPullListRemoteDataSource _pullListRemote;
  final MetronWishlistRemoteDataSource _wishlistRemote;

  OfflineQueueProcessor({
    required OfflineQueueDao dao,
    required MetronCollectionRemoteDataSource collectionRemote,
    required MetronPullListRemoteDataSource pullListRemote,
    required MetronWishlistRemoteDataSource wishlistRemote,
  })  : _dao = dao,
        _collectionRemote = collectionRemote,
        _pullListRemote = pullListRemote,
        _wishlistRemote = wishlistRemote;

  Future<int> processPendingEntries({int batchSize = 20}) async {
    final entries = await _dao.getPendingEntries(limit: batchSize);
    var processedCount = 0;

    for (final entry in entries) {
      try {
        await _processEntry(
          operation: entry.operation,
          entityType: entry.entityType,
          entityId: entry.entityId,
          payloadJson: entry.payload,
        );
        await _dao.markCompleted(entry.id);
        processedCount++;
      } catch (e, st) {
        AppLogger.warning(
          "Failed to process offline queue entry #${entry.id} (${entry.entityType}/${entry.operation})",
          error: e,
          stackTrace: st,
        );
        await _dao.markFailed(
          entry.id,
          error: e.toString(),
          retryCount: entry.retryCount + 1,
        );
      }
    }

    return processedCount;
  }

  Future<void> _processEntry({
    required String operation,
    required String entityType,
    String? entityId,
    required String payloadJson,
  }) async {
    final payload = payloadJson.isNotEmpty
        ? jsonDecode(payloadJson) as Map<String, dynamic>
        : <String, dynamic>{};

    switch (entityType) {
      case "collection":
        await _processCollection(operation, entityId, payload);
      case "pull_list":
        await _processPullList(operation, entityId, payload);
      case "wish_list":
        await _processWishlist(operation, entityId, payload);
      default:
        throw ArgumentError("Unknown entityType: $entityType");
    }
  }

  Future<void> _processCollection(
    String operation,
    String? entityId,
    Map<String, dynamic> payload,
  ) async {
    switch (operation) {
      case "create":
        final issueId = payload["issue_id"] as int? ??
            int.tryParse(entityId ?? "") ??
            0;
        await _collectionRemote.addToCollection(
          issueId: issueId,
          quantity: payload["quantity"] as int? ?? 1,
          bookFormat: payload["book_format"] as String? ?? "PRINT",
          grade: (payload["grade"] as num?)?.toDouble(),
          gradingCompany: payload["grading_company"] as String?,
          purchaseDate: payload["purchase_date"] != null
              ? DateTime.tryParse(payload["purchase_date"] as String)
              : null,
          purchasePrice: (payload["purchase_price"] as num?)?.toDouble(),
          purchasePriceCurrency:
              payload["purchase_price_currency"] as String? ?? "USD",
          purchaseStore: payload["purchase_store"] as String?,
          storageLocation: payload["storage_location"] as String?,
          notes: payload["notes"] as String?,
        );
      case "update":
        final id = int.parse(entityId!);
        await _collectionRemote.updateCollectionItem(id, payload);
      case "delete":
        final id = int.parse(entityId!);
        await _collectionRemote.removeFromCollection(id);
      case "scrobble":
        final issueId = payload["issue_id"] as int? ??
            int.tryParse(entityId ?? "") ??
            0;
        await _collectionRemote.scrobble(
          ScrobbleRequestDto(
            issueId: issueId,
            dateRead: payload["date_read"] as String?,
            rating: payload["rating"] as int?,
          ),
        );
      default:
        throw ArgumentError("Unknown collection operation: $operation");
    }
  }

  Future<void> _processPullList(
    String operation,
    String? entityId,
    Map<String, dynamic> payload,
  ) async {
    switch (operation) {
      case "create":
        final seriesId = payload["series_id"] as int? ??
            int.tryParse(entityId ?? "") ??
            0;
        await _pullListRemote.addSeriesToPullList(seriesId);
      case "delete":
        final seriesId = payload["series_id"] as int? ??
            int.tryParse(entityId ?? "") ??
            0;
        await _pullListRemote.removeSeriesFromPullList(seriesId);
      default:
        throw ArgumentError("Unknown pull_list operation: $operation");
    }
  }

  Future<void> _processWishlist(
    String operation,
    String? entityId,
    Map<String, dynamic> payload,
  ) async {
    switch (operation) {
      case "create":
        final issueId = payload["issue_id"] as int? ??
            int.tryParse(entityId ?? "") ??
            0;
        await _wishlistRemote.addToWishList(
          WishListAddItemDto(
            issueId: issueId,
            priority: payload["priority"] as int? ?? 3,
            desiredGrade: (payload["desired_grade"] as num?)?.toDouble(),
            maxPrice: (payload["max_price"] as num?)?.toDouble(),
            maxPriceCurrency:
                payload["max_price_currency"] as String? ?? "USD",
            notes: payload["notes"] as String?,
          ),
        );
      case "acquire":
        final itemId = int.parse(entityId!);
        await _wishlistRemote.acquireWishListItem(
          itemId,
          AcquireWishListItemDto(
            purchaseDate: payload["purchase_date"] as String?,
            purchasePrice: (payload["purchase_price"] as num?)?.toDouble(),
            purchasePriceCurrency:
                payload["purchase_price_currency"] as String? ?? "USD",
            purchaseStore: payload["purchase_store"] as String?,
            notes: payload["notes"] as String?,
          ),
        );
      case "delete":
        final itemId = int.parse(entityId!);
        await _wishlistRemote.removeFromWishList(itemId);
      default:
        throw ArgumentError("Unknown wishlist operation: $operation");
    }
  }
}
