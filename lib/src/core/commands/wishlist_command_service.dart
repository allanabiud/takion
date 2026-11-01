import "package:drift/drift.dart";
import "package:takion/src/core/commands/outbox_constants.dart";
import "package:takion/src/data/common/drift/database.dart" as db;

/// Service that executes wishlist mutations atomically against the local database
/// and records an intent in the durable outbox within the same Drift transaction.
class WishlistCommandService {
  WishlistCommandService(
    this._database, {
    this.defaultAccountId = "local-user",
  });

  final db.AppDatabase _database;
  final String defaultAccountId;

  String idForIssue(int issueId) => "lib-$issueId";

  /// Optimistically adds an issue to the wishlist.
  Future<db.WishlistItem> addToWishlist({
    required int issueId,
    int? seriesId,
    String? seriesName,
    String? issueNumber,
    String? imageUrl,
    int priority = 3,
    double? desiredGrade,
    double? maxPrice,
    String maxPriceCurrency = "USD",
    String? notes,
    String? accountId,
  }) async {
    final effectiveAccount = accountId ?? defaultAccountId;
    final now = DateTime.now().toUtc();
    final nowIso = now.toIso8601String();

    return _database.transaction(() async {
      final existing = await _database.wishlistDao.getByIssueId(issueId);

      // Mutual exclusivity: if item was owned in collection, delete it
      final libItem = await _database.libraryItemDao.getByIssueId(issueId);
      if (libItem != null && libItem.ownershipStatus == "owned") {
        await _database.libraryItemDao.deleteByIssueId(issueId);
        if (libItem.metronCollectionId != null) {
          await _database.outboxDao.coalesceDelete(
            accountId: effectiveAccount,
            entityType: OutboxEntityType.collection,
            entityLocalId: libItem.id,
            entityRemoteId: libItem.metronCollectionId,
            coalesceKey: "collection:${libItem.id}",
          );
        }
      }

      final itemId = existing?.id ?? issueId;
      final companion = db.WishlistItemsCompanion(
        id: Value(itemId),
        issueId: Value(issueId),
        seriesId: Value(seriesId ?? existing?.seriesId ?? 0),
        seriesName: Value(
          seriesName ?? existing?.seriesName ?? "Unknown Series",
        ),
        issueNumber: Value(issueNumber ?? existing?.issueNumber ?? ""),
        seriesVolume: Value(existing?.seriesVolume),
        seriesYearBegan: Value(existing?.seriesYearBegan),
        coverDate: Value(existing?.coverDate),
        storeDate: Value(existing?.storeDate),
        imageUrl: Value(imageUrl ?? existing?.imageUrl),
        priority: Value(priority),
        desiredGrade: Value(desiredGrade ?? existing?.desiredGrade),
        maxPrice: Value(maxPrice ?? existing?.maxPrice),
        maxPriceCurrency: Value(maxPriceCurrency),
        notes: Value(notes ?? existing?.notes),
        addedOn: Value(existing?.addedOn ?? now),
        modified: Value(now),
        syncStatus: const Value(ProjectionSyncState.pending),
        localId: Value("wish-$issueId"),
        remoteModified: Value(existing?.remoteModified),
        deletedAt: const Value(null),
        createdAt: Value(existing?.createdAt ?? nowIso),
        updatedAt: Value(nowIso),
      );

      await _database.wishlistDao.upsert(companion);

      final payload = <String, dynamic>{
        "issue": issueId,
        "priority": priority,
        "desired_grade": ?desiredGrade,
        "max_price": ?maxPrice,
        "max_price_currency": maxPriceCurrency,
        "notes": ?notes,
      };

      await _database.outboxDao.coalesceCreate(
        accountId: effectiveAccount,
        entityType: OutboxEntityType.wishlist,
        entityLocalId: "wish-$issueId",
        entityRemoteId: existing?.id != issueId ? existing?.id : null,
        coalesceKey: "wishlist:$issueId",
        payload: payload,
        baseRemoteModified: existing?.remoteModified,
      );

      final result = await _database.wishlistDao.getByIssueId(issueId);
      return result!;
    });
  }

  /// Optimistically removes an issue from the wishlist.
  Future<void> removeFromWishlist({
    required int issueId,
    String? accountId,
  }) async {
    final effectiveAccount = accountId ?? defaultAccountId;

    await _database.transaction(() async {
      final existing = await _database.wishlistDao.getByIssueId(issueId);
      if (existing == null) return;

      final isRemoteSynced = existing.id != issueId;
      if (!isRemoteSynced) {
        // Never synced remotely, delete directly and cancel outbox
        await _database.wishlistDao.deleteByIssueId(issueId);
        await _database.outboxDao.coalesceDelete(
          accountId: effectiveAccount,
          entityType: OutboxEntityType.wishlist,
          entityLocalId: "wish-$issueId",
          coalesceKey: "wishlist:$issueId",
        );
      } else {
        // Exists on remote: tombstone locally and queue remote delete
        await _database.wishlistDao.applyOptimisticDeleteByIssueId(issueId);
        await _database.outboxDao.coalesceDelete(
          accountId: effectiveAccount,
          entityType: OutboxEntityType.wishlist,
          entityLocalId: "wish-$issueId",
          entityRemoteId: existing.id,
          coalesceKey: "wishlist:$issueId",
          baseRemoteModified: existing.remoteModified,
        );
      }
    });
  }

  /// Acquires a wishlist item into the collection.
  /// Executes atomic wishlist tombstone + provisional collection projection + dependent outbox intent.
  Future<void> acquireIssue({
    required int issueId,
    int? seriesId,
    DateTime? purchaseDate,
    double? purchasePrice,
    String purchasePriceCurrency = "USD",
    String? purchaseStore,
    String? notes,
    String? accountId,
  }) async {
    final effectiveAccount = accountId ?? defaultAccountId;
    final now = DateTime.now().toUtc();
    final nowIso = now.toIso8601String();
    final purchaseDateIso = (purchaseDate ?? now).toIso8601String();
    final localCollectionId = idForIssue(issueId);

    await _database.transaction(() async {
      final wishItem = await _database.wishlistDao.getByIssueId(issueId);
      final libItem = await _database.libraryItemDao.getByIssueId(issueId);
      final isRemoteSynced = wishItem != null && wishItem.id != issueId;

      // 1. Wishlist tombstone / deletion
      if (isRemoteSynced) {
        await _database.wishlistDao.applyOptimisticDeleteByIssueId(issueId);
      } else {
        await _database.wishlistDao.deleteByIssueId(issueId);
      }

      // 2. Provisional collection projection
      final effectiveSeriesId =
          seriesId ?? wishItem?.seriesId ?? libItem?.metronSeriesId ?? 0;

      await _database.libraryItemDao.upsert(
        db.LibraryItemsCompanion(
          id: Value(localCollectionId),
          userId: Value(effectiveAccount),
          metronIssueId: Value(issueId),
          metronSeriesId: Value(effectiveSeriesId),
          ownershipStatus: const Value("owned"),
          isRead: Value(libItem?.isRead ?? false),
          rating: Value(libItem?.rating),
          quantityOwned: Value(libItem?.quantityOwned ?? 1),
          format: Value(libItem?.format ?? "print"),
          purchaseDate: Value(purchaseDateIso),
          pricePaid: purchasePrice != null
              ? Value(purchasePrice)
              : (libItem?.pricePaid != null
                    ? Value(libItem!.pricePaid)
                    : const Value.absent()),
          acquiredOn: Value(purchaseDateIso),
          notes: notes != null
              ? Value(notes)
              : (libItem?.notes != null
                    ? Value(libItem!.notes)
                    : const Value.absent()),
          syncStatus: const Value(ProjectionSyncState.pending),
          deletedAt: const Value(null),
          createdAt: Value(libItem?.createdAt ?? nowIso),
          updatedAt: Value(nowIso),
        ),
      );

      // 3. Outbox operation
      if (isRemoteSynced) {
        // Enqueue acquire operation against Metron wishlist item
        final payload = <String, dynamic>{
          "purchase_date": ?purchaseDate?.toIso8601String().split("T").first,
          "purchase_price": ?purchasePrice,
          "purchase_price_currency": purchasePriceCurrency,
          "purchase_store": ?purchaseStore,
          "notes": ?notes,
        };

        await _database.outboxDao.coalesceAcquire(
          accountId: effectiveAccount,
          wishlistRemoteId: wishItem.id,
          issueId: issueId,
          payload: payload,
        );
      } else {
        // Wishlist item was never synced to Metron; convert directly to collection create!
        await _database.outboxDao.coalesceDelete(
          accountId: effectiveAccount,
          entityType: OutboxEntityType.wishlist,
          entityLocalId: "wish-$issueId",
          coalesceKey: "wishlist:$issueId",
        );

        final collectionPayload = <String, dynamic>{
          "issue": issueId,
          "quantity": libItem?.quantityOwned ?? 1,
          "book_format": (libItem?.format ?? "print").toUpperCase(),
          "purchase_date": ?purchaseDate?.toIso8601String().split("T").first,
          "purchase_price": ?purchasePrice,
          "notes": ?notes,
          "is_read": libItem?.isRead ?? false,
          if (libItem?.rating != null && libItem!.rating! > 0)
            "rating": libItem.rating,
        };

        await _database.outboxDao.coalesceCreate(
          accountId: effectiveAccount,
          entityType: OutboxEntityType.collection,
          entityLocalId: localCollectionId,
          coalesceKey: "collection:$localCollectionId",
          payload: collectionPayload,
        );
      }
    });
  }
}
