import "dart:convert";
import "package:dio/dio.dart";
import "package:drift/drift.dart";
import "package:takion/src/core/logging/app_logger.dart";
import "package:takion/src/data/collection/datasources/remote/metron_collection_remote_data_source.dart";
import "package:takion/src/data/collection/dto/scrobble_dto.dart";
import "package:takion/src/data/common/drift/database.dart";
import "package:takion/src/data/common/drift/daos/offline_queue_dao.dart";
import "package:takion/src/data/pull_list/datasources/remote/metron_pull_list_remote_data_source.dart";
import "package:takion/src/data/wishlist/datasources/remote/metron_wishlist_remote_data_source.dart";
import "package:takion/src/data/wishlist/dto/wishlist_dto.dart";

class OfflineQueueProcessor {
  final OfflineQueueDao _dao;
  final AppDatabase _database;
  final MetronCollectionRemoteDataSource _collectionRemote;
  final MetronPullListRemoteDataSource _pullListRemote;
  final MetronWishlistRemoteDataSource _wishlistRemote;
  final Duration Function()? _rateLimitDelay;

  OfflineQueueProcessor({
    required OfflineQueueDao dao,
    required AppDatabase database,
    required MetronCollectionRemoteDataSource collectionRemote,
    required MetronPullListRemoteDataSource pullListRemote,
    required MetronWishlistRemoteDataSource wishlistRemote,
    Duration Function()? rateLimitDelay,
  })  : _dao = dao,
        _database = database,
        _collectionRemote = collectionRemote,
        _pullListRemote = pullListRemote,
        _wishlistRemote = wishlistRemote,
        _rateLimitDelay = rateLimitDelay;

  Duration get _currentDelay =>
      _rateLimitDelay?.call() ?? const Duration(milliseconds: 3200);

  static int _computeBackoffMs(int retryCount, int baseMs) {
    final ms = baseMs * (1 << retryCount);
    return ms > 51200 ? 51200 : ms;
  }

  Future<int> processPendingEntries({int batchSize = 20}) async {
    final entries = await _dao.getPendingEntries(limit: batchSize);
    final now = DateTime.now().millisecondsSinceEpoch;
    var processedCount = 0;

    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];

      if (i > 0) {
        await Future<void>.delayed(_currentDelay);
      }

      if (entry.lastAttemptAt != null) {
        final backoffMs = _computeBackoffMs(
          entry.retryCount,
          _currentDelay.inMilliseconds,
        );
        final elapsed = now - entry.lastAttemptAt!;
        if (elapsed < backoffMs) {
          continue;
        }
      }

      try {
        await _processEntry(
          operation: entry.operation,
          entityType: entry.entityType,
          entityId: entry.entityId,
          payloadJson: entry.payload,
        );
        await _dao.markCompleted(entry.id);
        processedCount++;
      } on DioException catch (e, st) {
        final statusCode = e.response?.statusCode;
        final responseData = e.response?.data?.toString().toLowerCase() ?? "";
        final isAlreadyPresent = (statusCode == 400 || statusCode == 409) &&
            (responseData.contains("already") ||
                responseData.contains("duplicate") ||
                responseData.contains("exists"));
        final isAlreadyDeleted = statusCode == 404 && entry.operation == "delete";

        if (isAlreadyPresent || isAlreadyDeleted) {
          AppLogger.info(
            "Offline queue entry #${entry.id} (${entry.entityType}/${entry.operation}) already synced on remote: $responseData",
          );
          await _markEntitySynced(
            entityType: entry.entityType,
            operation: entry.operation,
            entityId: entry.entityId,
          );
          await _dao.markCompleted(entry.id);
          processedCount++;
        } else {
          final cleanError = _extractCleanErrorMessage(e);
          AppLogger.warning(
            "Failed to process offline queue entry #${entry.id} (${entry.entityType}/${entry.operation}): $cleanError",
            error: e,
            stackTrace: st,
          );
          await _dao.markFailed(
            entry.id,
            error: cleanError,
            retryCount: entry.retryCount + 1,
          );
        }
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

  String _extractCleanErrorMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      if (data["detail"] != null) return data["detail"].toString();
      if (data["error"] != null) return data["error"].toString();
      final firstKey = data.keys.firstOrNull;
      if (firstKey != null) {
        final val = data[firstKey];
        if (val is List && val.isNotEmpty) {
          return "$firstKey: ${val.first}";
        }
        return "$firstKey: $val";
      }
    } else if (data is String && data.isNotEmpty) {
      return data;
    }
    final statusCode = e.response?.statusCode;
    if (statusCode == 429) return "Rate limit exceeded (HTTP 429)";
    if (statusCode == 401) return "Unauthorized: Invalid or expired token";
    if (statusCode == 403) return "Forbidden: Missing permissions on Metron";
    if (statusCode == 404) return "Resource not found on Metron (HTTP 404)";
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return "Connection timed out";
    }
    return e.message ?? e.toString();
  }

  Future<void> _markEntitySynced({
    required String entityType,
    required String operation,
    String? entityId,
    int? remoteId,
  }) async {
    if (entityId == null) return;

    final nowIso = DateTime.now().toUtc().toIso8601String();

    switch (entityType) {
      case "collection":
        await _markCollectionSynced(operation, entityId, nowIso, remoteId);
      case "pull_list":
        await _markPullListSynced(operation, entityId, nowIso);
      case "wish_list":
        await _markWishlistSynced(operation, entityId, nowIso);
    }
  }

  Future<void> _markCollectionSynced(
    String operation,
    String entityId,
    String nowIso, [
    int? remoteId,
  ]) async {
    switch (operation) {
      case "create":
        final issueId = int.tryParse(entityId);
        if (issueId != null) {
          final updates = LibraryItemsCompanion(
            syncStatus: const Value("synced"),
            updatedAt: Value(nowIso),
          );
          await (_database.update(_database.libraryItems)
                ..where((t) => t.metronIssueId.equals(issueId)))
              .write(updates);
          if (remoteId != null) {
            await (_database.update(_database.libraryItems)
                  ..where((t) => t.metronIssueId.equals(issueId)))
                .write(
              LibraryItemsCompanion(metronCollectionId: Value(remoteId)),
            );
            final item = await _database.libraryItemDao.getByIssueId(issueId);
            if (item != null && item.rating != null && item.rating! > 0) {
              await _database.offlineQueueDao.enqueue(
                operation: "update",
                entityType: "collection",
                entityId: remoteId.toString(),
                payload: jsonEncode({"rating": item.rating}),
              );
            }
          }
        }
      case "update":
        final collectionId = int.tryParse(entityId);
        if (collectionId != null) {
          await (_database.update(_database.libraryItems)
                ..where((t) => t.metronCollectionId.equals(collectionId)))
              .write(
            LibraryItemsCompanion(
              syncStatus: const Value("synced"),
              updatedAt: Value(nowIso),
            ),
          );
        }
      case "delete":
        final collectionId = int.tryParse(entityId);
        if (collectionId != null) {
          await (_database.delete(_database.libraryItems)
                ..where((t) => t.metronCollectionId.equals(collectionId)))
              .go();
        }
      case "scrobble":
        break;
    }
  }

  Future<void> _markPullListSynced(
    String operation,
    String entityId,
    String nowIso,
  ) async {
    final seriesId = int.tryParse(entityId);
    if (seriesId == null) return;

    switch (operation) {
      case "create":
        await (_database.update(_database.seriesSubscriptions)
              ..where((t) => t.metronSeriesId.equals(seriesId)))
            .write(
          SeriesSubscriptionsCompanion(
            syncStatus: const Value("synced"),
            updatedAt: Value(nowIso),
          ),
        );
      case "delete":
        await (_database.update(_database.seriesSubscriptions)
              ..where((t) => t.metronSeriesId.equals(seriesId)))
            .write(
          SeriesSubscriptionsCompanion(
            syncStatus: const Value("synced"),
            isActive: const Value(false),
            metronPullListId: const Value(null),
            updatedAt: Value(nowIso),
          ),
        );
    }
  }

  Future<void> _markWishlistSynced(
    String operation,
    String entityId,
    String nowIso,
  ) async {
    switch (operation) {
      case "create":
        final issueId = int.tryParse(entityId);
        if (issueId != null) {
          await _database.wishlistDao.updateSyncStatusByIssueId(
            issueId,
            "synced",
          );
        }
      case "acquire":
        final itemId = int.tryParse(entityId);
        if (itemId != null) {
          final item = await _database.wishlistDao.getById(itemId);
          if (item != null) {
            await _database.wishlistDao.upsert(
              WishlistItemsCompanion(
                id: Value(itemId),
                syncStatus: const Value("synced"),
                updatedAt: Value(nowIso),
              ),
            );
          }
        }
      case "delete":
        final itemId = int.tryParse(entityId);
        if (itemId != null) {
          await _database.wishlistDao.deleteById(itemId);
        }
    }
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

    int? remoteId;

    switch (entityType) {
      case "collection":
        remoteId = await _processCollection(operation, entityId, payload);
      case "pull_list":
        await _processPullList(operation, entityId, payload);
      case "wish_list":
        await _processWishlist(operation, entityId, payload);
      default:
        throw ArgumentError("Unknown entityType: $entityType");
    }

    await _markEntitySynced(
      entityType: entityType,
      operation: operation,
      entityId: entityId,
      remoteId: remoteId,
    );
  }

  Future<int?> _processCollection(
    String operation,
    String? entityId,
    Map<String, dynamic> payload,
  ) async {
    switch (operation) {
      case "create":
        final issueId = payload["issue_id"] as int? ??
            int.tryParse(entityId ?? "") ??
            0;
        final result = await _collectionRemote.addToCollection(
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
        return result.id;
      case "update":
        final id = int.parse(entityId!);
        await _collectionRemote.updateCollectionItem(id, payload);
        return null;
      case "delete":
        final id = int.parse(entityId!);
        await _collectionRemote.removeFromCollection(id);
        return null;
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
        return null;
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
