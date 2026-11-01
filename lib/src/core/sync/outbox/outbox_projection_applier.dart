import "package:drift/drift.dart";
import "package:takion/src/core/commands/outbox_constants.dart";
import "package:takion/src/core/sync/outbox/outbox_action_result.dart";
import "package:takion/src/data/common/drift/database.dart";

class OutboxProjectionApplier {
  const OutboxProjectionApplier(this._db);

  final AppDatabase _db;

  Future<void> applyCanonicalWriteResult(
    OutboxOperation op,
    OutboxActionResult result,
  ) async {
    final now = DateTime.now().toUtc().toIso8601String();

    switch (op.entityType) {
      case OutboxEntityType.collection:
        await _applyCollectionResult(op, result, now);
        break;
      case OutboxEntityType.pullSeries:
        await _applyPullSeriesResult(op, result, now);
        break;
      case OutboxEntityType.wishlist:
        await _applyWishlistResult(op, result, now);
        break;
    }
  }

  Future<void> _applyCollectionResult(
    OutboxOperation op,
    OutboxActionResult result,
    String now,
  ) async {
    if (op.operation == OutboxOperationType.delete) {
      if (op.entityRemoteId != null) {
        await (_db.delete(
          _db.libraryItems,
        )..where((t) => t.metronCollectionId.equals(op.entityRemoteId!))).go();
      }
      await (_db.delete(
        _db.libraryItems,
      )..where((t) => t.id.equals(op.entityLocalId))).go();
      return;
    }

    final query = _db.update(_db.libraryItems);
    if (op.entityRemoteId != null) {
      query.where((t) => t.metronCollectionId.equals(op.entityRemoteId!));
    } else {
      query.where((t) => t.id.equals(op.entityLocalId));
    }

    await query.write(
      LibraryItemsCompanion(
        syncStatus: const Value("synced"),
        metronCollectionId: result.remoteId != null
            ? Value(result.remoteId)
            : const Value.absent(),
        remoteModified: result.remoteModified != null
            ? Value(result.remoteModified)
            : const Value.absent(),
        deletedAt: const Value(null),
        updatedAt: Value(now),
      ),
    );
  }

  Future<void> _applyPullSeriesResult(
    OutboxOperation op,
    OutboxActionResult result,
    String now,
  ) async {
    final seriesId = int.tryParse(op.entityLocalId) ?? op.entityRemoteId;

    if (seriesId == null) return;

    if (op.operation == OutboxOperationType.delete) {
      await (_db.update(
        _db.seriesSubscriptions,
      )..where((t) => t.metronSeriesId.equals(seriesId))).write(
        SeriesSubscriptionsCompanion(
          isActive: const Value(false),
          syncStatus: const Value("synced"),
          deletedAt: Value(now),
          updatedAt: Value(now),
        ),
      );
    } else {
      await (_db.update(
        _db.seriesSubscriptions,
      )..where((t) => t.metronSeriesId.equals(seriesId))).write(
        SeriesSubscriptionsCompanion(
          isActive: const Value(true),
          syncStatus: const Value("synced"),
          deletedAt: const Value(null),
          updatedAt: Value(now),
        ),
      );
    }
  }

  Future<void> _applyWishlistResult(
    OutboxOperation op,
    OutboxActionResult result,
    String now,
  ) async {
    if (op.operation == OutboxOperationType.delete ||
        op.operation == OutboxOperationType.acquire) {
      final remoteId = op.entityRemoteId ?? int.tryParse(op.entityLocalId);
      if (remoteId != null) {
        await (_db.delete(
          _db.wishlistItems,
        )..where((t) => t.id.equals(remoteId))).go();
      }
      return;
    }

    final issueId = int.tryParse(op.entityLocalId);
    if (issueId != null && result.remoteId != null) {
      await (_db.update(
        _db.wishlistItems,
      )..where((t) => t.issueId.equals(issueId))).write(
        WishlistItemsCompanion(
          id: Value(result.remoteId!),
          syncStatus: const Value("synced"),
          deletedAt: const Value(null),
          updatedAt: Value(now),
        ),
      );
    }
  }
}
