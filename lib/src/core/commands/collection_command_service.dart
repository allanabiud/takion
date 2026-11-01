import "package:drift/drift.dart";
import "package:takion/src/core/commands/outbox_constants.dart";
import "package:takion/src/data/common/drift/database.dart" as db;
import "package:takion/src/domain/collection/entities/library_item.dart";

/// Service that executes collection mutations atomically against the local database
/// and records an intent in the durable outbox within the same Drift transaction.
class CollectionCommandService {
  CollectionCommandService(
    this._database, {
    this.defaultAccountId = "local-user",
  });

  final db.AppDatabase _database;
  final String defaultAccountId;

  String idForIssue(int issueId) => "lib-$issueId";
  String readLogId(int issueId) =>
      "read-$issueId-${DateTime.now().microsecondsSinceEpoch}";

  /// Optimistically adds or updates an issue in the collection.
  Future<db.LibraryItem> addToCollection({
    required int issueId,
    required int seriesId,
    String? accountId,
    LibraryOwnershipStatus ownershipStatus = LibraryOwnershipStatus.owned,
    bool isRead = false,
    int? rating,
    DateTime? purchaseDate,
    double? pricePaid,
    int quantityOwned = 1,
    LibraryItemFormat format = LibraryItemFormat.print,
    DateTime? firstReadAt,
    String? conditionGrade,
    DateTime? acquiredOn,
    String? notes,
  }) async {
    final effectiveAccount = accountId ?? defaultAccountId;
    final now = DateTime.now().toUtc();
    final nowIso = now.toIso8601String();
    final localId = idForIssue(issueId);
    final sanitizedRating = (rating != null && rating > 0) ? rating : null;

    final formatRaw = switch (format) {
      LibraryItemFormat.digital => "digital",
      LibraryItemFormat.both => "both",
      LibraryItemFormat.print => "print",
    };

    return _database.transaction(() async {
      final existing = await _database.libraryItemDao.getById(localId);

      // Mutual exclusivity: if added to collection, delete from wishlist
      final wishItem = await _database.wishlistDao.getByIssueId(issueId);
      if (wishItem != null) {
        await _database.wishlistDao.deleteByIssueId(issueId);
        await _database.outboxDao.coalesceDelete(
          accountId: effectiveAccount,
          entityType: OutboxEntityType.wishlist,
          entityLocalId: "wish-${wishItem.id}",
          entityRemoteId: wishItem.id,
          coalesceKey: "wishlist:${wishItem.id}",
        );
      }

      final companion = db.LibraryItemsCompanion(
        id: Value(localId),
        userId: Value(effectiveAccount),
        metronIssueId: Value(issueId),
        metronSeriesId: Value(seriesId),
        ownershipStatus: const Value("owned"),
        isRead: Value(isRead),
        metronCollectionId: Value(existing?.metronCollectionId),
        syncStatus: const Value(ProjectionSyncState.pending),
        rating: Value(sanitizedRating),
        purchaseDate: Value(
          purchaseDate?.toIso8601String() ?? existing?.purchaseDate,
        ),
        pricePaid: Value(pricePaid ?? existing?.pricePaid),
        quantityOwned: Value(quantityOwned),
        format: Value(formatRaw),
        firstReadAt: Value(
          firstReadAt?.toIso8601String() ?? existing?.firstReadAt,
        ),
        conditionGrade: Value(conditionGrade ?? existing?.conditionGrade),
        acquiredOn: Value(
          acquiredOn?.toIso8601String() ??
              purchaseDate?.toIso8601String() ??
              existing?.acquiredOn ??
              nowIso,
        ),
        notes: Value(notes ?? existing?.notes),
        remoteModified: Value(existing?.remoteModified),
        deletedAt: const Value(null),
        createdAt: Value(existing?.createdAt ?? nowIso),
        updatedAt: Value(nowIso),
      );

      await _database.libraryItemDao.upsert(companion);

      final payload = <String, dynamic>{
        "issue": issueId,
        "quantity": quantityOwned,
        "book_format": formatRaw.toUpperCase(),
        "grade": ?(conditionGrade != null
            ? double.tryParse(conditionGrade)
            : null),
        "purchase_date": ?purchaseDate?.toIso8601String().split("T").first,
        "purchase_price": ?pricePaid,
        "notes": ?notes,
        "is_read": isRead,
        "rating": ?sanitizedRating,
      };

      if (existing?.metronCollectionId != null) {
        await _database.outboxDao.coalescePatch(
          accountId: effectiveAccount,
          entityType: OutboxEntityType.collection,
          entityLocalId: localId,
          entityRemoteId: existing!.metronCollectionId,
          coalesceKey: "collection:$localId",
          payload: payload,
          baseRemoteModified: existing.remoteModified,
        );
      } else {
        await _database.outboxDao.coalesceCreate(
          accountId: effectiveAccount,
          entityType: OutboxEntityType.collection,
          entityLocalId: localId,
          coalesceKey: "collection:$localId",
          payload: payload,
          baseRemoteModified: existing?.remoteModified,
        );
      }

      return _database.libraryItemDao.requireById(localId);
    });
  }

  /// Optimistically updates read status and/or rating.
  Future<void> setCollectionState({
    required int issueId,
    required bool isRead,
    int? rating,
    String? accountId,
  }) async {
    final effectiveAccount = accountId ?? defaultAccountId;
    final localId = idForIssue(issueId);
    final sanitizedRating = (rating != null && rating > 0) ? rating : null;

    await _database.transaction(() async {
      final existing = await _database.libraryItemDao.getById(localId);
      if (existing == null) {
        throw StateError(
          "Cannot setCollectionState: issue $issueId is not in collection",
        );
      }

      await _database.libraryItemDao.applyOptimisticPatch(
        localId,
        isRead: Value(isRead),
        rating: Value(sanitizedRating),
        syncStatus: const Value(ProjectionSyncState.pending),
      );

      final patch = <String, dynamic>{
        "is_read": isRead,
        "rating": sanitizedRating,
      };

      await _database.outboxDao.coalescePatch(
        accountId: effectiveAccount,
        entityType: OutboxEntityType.collection,
        entityLocalId: localId,
        entityRemoteId: existing.metronCollectionId,
        coalesceKey: "collection:$localId",
        payload: patch,
        baseRemoteModified: existing.remoteModified,
      );
    });
  }

  /// Optimistically removes an issue from the collection.
  Future<void> removeFromCollection({
    required int issueId,
    String? accountId,
  }) async {
    final effectiveAccount = accountId ?? defaultAccountId;
    final localId = idForIssue(issueId);

    await _database.transaction(() async {
      final existing = await _database.libraryItemDao.getById(localId);
      if (existing == null) return;

      if (existing.metronCollectionId == null) {
        // Created locally and never synced remotely: delete directly and cancel outbox
        await _database.libraryItemDao.deleteById(localId);
        await _database.outboxDao.coalesceDelete(
          accountId: effectiveAccount,
          entityType: OutboxEntityType.collection,
          entityLocalId: localId,
          coalesceKey: "collection:$localId",
        );
      } else {
        // Exists on remote: mark soft deleted locally and queue remote delete
        await _database.libraryItemDao.applyOptimisticDelete(localId);
        await _database.outboxDao.coalesceDelete(
          accountId: effectiveAccount,
          entityType: OutboxEntityType.collection,
          entityLocalId: localId,
          entityRemoteId: existing.metronCollectionId,
          coalesceKey: "collection:$localId",
          baseRemoteModified: existing.remoteModified,
        );
      }
    });
  }

  /// Optimistically records a reading session and enqueues a scrobble.
  Future<db.LibraryReadLog> scrobble({
    required int issueId,
    required DateTime dateRead,
    int? rating,
    String? notes,
    String? accountId,
  }) async {
    final effectiveAccount = accountId ?? defaultAccountId;
    final localId = idForIssue(issueId);
    final now = DateTime.now().toUtc();
    final logId = readLogId(issueId);
    final sanitizedRating = (rating != null && rating > 0) ? rating : null;

    return _database.transaction(() async {
      final existing = await _database.libraryItemDao.getById(localId);
      if (existing != null) {
        await _database.libraryItemDao.applyOptimisticPatch(
          localId,
          isRead: const Value(true),
          rating: sanitizedRating != null ? Value(sanitizedRating) : null,
          syncStatus: const Value(ProjectionSyncState.pending),
        );
      }

      final log = db.LibraryReadLogsCompanion(
        id: Value(logId),
        userId: Value(effectiveAccount),
        collectionItemId: Value(existing?.id ?? localId),
        readAt: Value(dateRead.toIso8601String()),
        notes: Value(notes),
        createdAt: Value(now.toIso8601String()),
      );

      await _database.libraryItemDao.insertReadLog(log);

      await _database.outboxDao.coalesceScrobble(
        accountId: effectiveAccount,
        issueId: issueId,
        rating: sanitizedRating,
        dateRead: dateRead,
      );

      return db.LibraryReadLog(
        id: logId,
        userId: effectiveAccount,
        collectionItemId: existing?.id ?? localId,
        readAt: dateRead.toIso8601String(),
        notes: notes,
        createdAt: now.toIso8601String(),
      );
    });
  }
}
