import "dart:convert";
import "package:takion/src/core/commands/outbox_constants.dart";
import "package:takion/src/core/sync/outbox/outbox_action_result.dart";
import "package:takion/src/data/collection/datasources/remote/metron_collection_remote_data_source.dart";
import "package:takion/src/data/collection/dto/scrobble_dto.dart";
import "package:takion/src/data/common/drift/database.dart";
import "package:takion/src/data/pull_list/datasources/remote/metron_pull_list_remote_data_source.dart";
import "package:takion/src/data/wishlist/datasources/remote/metron_wishlist_remote_data_source.dart";
import "package:takion/src/data/wishlist/dto/wishlist_dto.dart";

class OutboxRemoteDispatcher {
  const OutboxRemoteDispatcher({
    required MetronCollectionRemoteDataSource collectionRemote,
    required MetronPullListRemoteDataSource pullListRemote,
    required MetronWishlistRemoteDataSource wishlistRemote,
  }) : _collectionRemote = collectionRemote,
       _pullListRemote = pullListRemote,
       _wishlistRemote = wishlistRemote;

  final MetronCollectionRemoteDataSource _collectionRemote;
  final MetronPullListRemoteDataSource _pullListRemote;
  final MetronWishlistRemoteDataSource _wishlistRemote;

  Future<OutboxActionResult> execute(OutboxOperation op) async {
    final payload = op.payloadJson.isNotEmpty
        ? (jsonDecode(op.payloadJson) as Map<String, dynamic>)
        : const <String, dynamic>{};

    switch (op.entityType) {
      case OutboxEntityType.collection:
      case OutboxEntityType.scrobble:
        return _executeCollection(op, payload);
      case OutboxEntityType.pullSeries:
        return _executePullSeries(op, payload);
      case OutboxEntityType.wishlist:
        return _executeWishlist(op, payload);
      default:
        throw UnsupportedError("Unsupported entityType: ${op.entityType}");
    }
  }

  Future<OutboxActionResult> _executeCollection(
    OutboxOperation op,
    Map<String, dynamic> payload,
  ) async {
    switch (op.operation) {
      case OutboxOperationType.create:
        final issueId =
            (payload["issue_id"] as num?)?.toInt() ??
            (payload["issue"] as num?)?.toInt() ??
            0;
        final res = await _collectionRemote.addToCollection(
          issueId: issueId,
          quantity: (payload["quantity"] as num?)?.toInt() ?? 1,
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
        return OutboxActionResult(
          remoteId: res.id,
          remoteModified: res.modified,
        );

      case OutboxOperationType.patch:
        final remoteId = op.entityRemoteId ?? (payload["id"] as num?)?.toInt();
        if (remoteId == null) {
          throw StateError(
            "Cannot patch collection item without entityRemoteId (op: ${op.id})",
          );
        }
        final cleanPayload = Map<String, dynamic>.from(payload);
        if (cleanPayload.containsKey("rating")) {
          final r = cleanPayload["rating"];
          if (r == null || (r is num && r <= 0)) {
            cleanPayload["rating"] = null;
          }
        }
        final res = await _collectionRemote.updateCollectionItem(
          remoteId,
          cleanPayload,
        );
        return OutboxActionResult(
          remoteId: res.id,
          remoteModified: res.modified,
        );

      case OutboxOperationType.delete:
        final remoteId = op.entityRemoteId ?? (payload["id"] as num?)?.toInt();
        if (remoteId != null) {
          await _collectionRemote.removeFromCollection(remoteId);
        }
        return OutboxActionResult(remoteId: remoteId);

      case OutboxOperationType.scrobble:
        final issueId = (payload["issue_id"] as num?)?.toInt() ?? 0;
        final rawRating = (payload["rating"] as num?)?.toInt();
        final sanitizedRating = (rawRating != null && rawRating > 0)
            ? rawRating
            : null;
        final res = await _collectionRemote.scrobble(
          ScrobbleRequestDto(
            issueId: issueId,
            dateRead: payload["date_read"] as String?,
            rating: sanitizedRating,
          ),
        );
        return OutboxActionResult(remoteId: res.id);

      default:
        throw UnsupportedError(
          "Unsupported collection operation: ${op.operation}",
        );
    }
  }

  Future<OutboxActionResult> _executePullSeries(
    OutboxOperation op,
    Map<String, dynamic> payload,
  ) async {
    final seriesId =
        (payload["series_id"] as num?)?.toInt() ??
        int.tryParse(op.entityLocalId) ??
        0;

    switch (op.operation) {
      case OutboxOperationType.create:
        final res = await _pullListRemote.addSeriesToPullList(seriesId);
        return OutboxActionResult(remoteId: res.id);

      case OutboxOperationType.delete:
        await _pullListRemote.removeSeriesFromPullList(seriesId);
        return const OutboxActionResult();

      default:
        throw UnsupportedError(
          "Unsupported pullSeries operation: ${op.operation}",
        );
    }
  }

  Future<OutboxActionResult> _executeWishlist(
    OutboxOperation op,
    Map<String, dynamic> payload,
  ) async {
    switch (op.operation) {
      case OutboxOperationType.create:
        final issueId = (payload["issue_id"] as num?)?.toInt() ?? 0;
        final item = WishListAddItemDto(
          issueId: issueId,
          priority: (payload["priority"] as num?)?.toInt() ?? 3,
          desiredGrade: (payload["desired_grade"] as num?)?.toDouble(),
          maxPrice: (payload["max_price"] as num?)?.toDouble(),
          maxPriceCurrency: payload["max_price_currency"] as String? ?? "USD",
          notes: payload["notes"] as String?,
        );
        final res = await _wishlistRemote.addToWishList(item);
        return OutboxActionResult(remoteId: res.id);

      case OutboxOperationType.delete:
        final remoteId =
            op.entityRemoteId ??
            (payload["id"] as num?)?.toInt() ??
            int.tryParse(op.entityLocalId);
        if (remoteId != null) {
          await _wishlistRemote.removeFromWishList(remoteId);
        }
        return OutboxActionResult(remoteId: remoteId);

      case OutboxOperationType.acquire:
        final remoteId =
            op.entityRemoteId ??
            (payload["id"] as num?)?.toInt() ??
            int.tryParse(op.entityLocalId);
        if (remoteId == null) {
          throw StateError(
            "Cannot acquire wishlist item without remoteId (op: ${op.id})",
          );
        }
        final request = AcquireWishListItemDto(
          purchaseDate: payload["purchase_date"] as String?,
          purchasePrice: (payload["purchase_price"] as num?)?.toDouble(),
          purchasePriceCurrency:
              payload["purchase_price_currency"] as String? ?? "USD",
          purchaseStore: payload["purchase_store"] as String?,
          notes: payload["notes"] as String?,
        );
        await _wishlistRemote.acquireWishListItem(remoteId, request);
        return OutboxActionResult(remoteId: remoteId);

      default:
        throw UnsupportedError(
          "Unsupported wishlist operation: ${op.operation}",
        );
    }
  }
}
