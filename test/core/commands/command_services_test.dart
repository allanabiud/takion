import "dart:convert";

import "package:drift/drift.dart" show Value;
import "package:drift/native.dart";
import "package:flutter_test/flutter_test.dart";
import "package:takion/src/core/commands/collection_command_service.dart";
import "package:takion/src/core/commands/outbox_constants.dart";
import "package:takion/src/core/commands/pull_list_command_service.dart";
import "package:takion/src/core/commands/wishlist_command_service.dart";
import "package:takion/src/data/common/drift/database.dart";

void main() {
  late AppDatabase db;
  late CollectionCommandService collectionService;
  late PullListCommandService pullListService;
  late WishlistCommandService wishlistService;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    collectionService = CollectionCommandService(db);
    pullListService = PullListCommandService(db);
    wishlistService = WishlistCommandService(db);
  });

  tearDown(() async {
    await db.close();
  });

  group("CollectionCommandService & Outbox Coalescing", () {
    test(
      "addToCollection creates local projection and outbox create operation",
      () async {
        final item = await collectionService.addToCollection(
          issueId: 1001,
          seriesId: 50,
          isRead: false,
          rating: 0, // should sanitize to null
          pricePaid: 3.99,
        );

        expect(item.metronIssueId, 1001);
        expect(item.syncStatus, ProjectionSyncState.pending);
        expect(item.rating, isNull);

        final outboxOps = await db.outboxDao.getReady(accountId: "local-user");
        expect(outboxOps.length, 1);
        expect(outboxOps.first.operation, OutboxOperationType.create);
        expect(outboxOps.first.entityType, OutboxEntityType.collection);
        expect(outboxOps.first.coalesceKey, "collection:lib-1001");

        final payload =
            jsonDecode(outboxOps.first.payloadJson) as Map<String, dynamic>;
        expect(payload["issue"], 1001);
        expect(payload["purchase_price"], 3.99);
        expect(payload.containsKey("rating"), isFalse);
      },
    );

    test(
      "patching un-synced create coalesces directly into pending create payload",
      () async {
        await collectionService.addToCollection(
          issueId: 1002,
          seriesId: 50,
          isRead: false,
        );

        // User marks as read and gives rating 5 before remote sync occurs
        await collectionService.setCollectionState(
          issueId: 1002,
          isRead: true,
          rating: 5,
        );

        // Local item updated
        final local = await db.libraryItemDao.requireById("lib-1002");
        expect(local.isRead, isTrue);
        expect(local.rating, 5);

        // Outbox still has ONLY ONE operation: create with merged fields!
        final outboxOps = await db.outboxDao.getReady(accountId: "local-user");
        expect(outboxOps.length, 1);
        expect(outboxOps.first.operation, OutboxOperationType.create);

        final payload =
            jsonDecode(outboxOps.first.payloadJson) as Map<String, dynamic>;
        expect(payload["is_read"], isTrue);
        expect(payload["rating"], 5);
      },
    );

    test(
      "deleting un-synced entity cancels pending outbox completely (0 remote calls)",
      () async {
        await collectionService.addToCollection(issueId: 1003, seriesId: 50);

        var outboxOps = await db.outboxDao.getReady(accountId: "local-user");
        expect(outboxOps.length, 1);

        // User deletes item before reconnect / sync
        await collectionService.removeFromCollection(issueId: 1003);

        final local = await db.libraryItemDao.getById("lib-1003");
        expect(local, isNull);

        outboxOps = await db.outboxDao.getReady(accountId: "local-user");
        expect(outboxOps, isEmpty); // Clean cancellation!
      },
    );

    test(
      "scrobble records read log and coalesces scrobble outbox operation",
      () async {
        final log = await collectionService.scrobble(
          issueId: 2001,
          dateRead: DateTime.utc(2026, 10, 26),
          rating: 4,
          notes: "Great issue!",
        );

        expect(log.collectionItemId, "lib-2001");
        expect(log.notes, "Great issue!");

        final ready = await db.outboxDao.getReady(accountId: "local-user");
        expect(ready.length, 1);
        expect(ready.first.operation, OutboxOperationType.scrobble);
        expect(ready.first.coalesceKey, "scrobble:2001");

        final payload =
            jsonDecode(ready.first.payloadJson) as Map<String, dynamic>;
        expect(payload["issue"], 2001);
        expect(payload["rating"], 4);
        expect(payload["date_read"], "2026-10-26");
      },
    );
  });

  group("PullListCommandService", () {
    test(
      "subscribe creates subscription with pending sync and outbox create",
      () async {
        final sub = await pullListService.subscribe(
          seriesId: 301,
          autoAddToPullList: true,
        );

        expect(sub.metronSeriesId, 301);
        expect(sub.syncStatus, ProjectionSyncState.pending);
        expect(sub.isActive, isTrue);

        final ready = await db.outboxDao.getReady(accountId: "local-user");
        expect(ready.length, 1);
        expect(ready.first.entityType, OutboxEntityType.subscription);
        expect(ready.first.operation, OutboxOperationType.create);
        expect(ready.first.coalesceKey, "subscription:301");
      },
    );

    test(
      "unsubscribe on local-only subscription cancels outbox create cleanly",
      () async {
        await pullListService.subscribe(seriesId: 302);
        expect(
          await db.outboxDao.getReady(accountId: "local-user"),
          hasLength(1),
        );

        await pullListService.unsubscribe(seriesId: 302);
        expect(await db.outboxDao.getReady(accountId: "local-user"), isEmpty);

        final inDb = await db.subscriptionDao.getBySeriesId(302);
        expect(inDb, isNull);
      },
    );
  });

  group("WishlistCommandService & Acquisition", () {
    test(
      "addToWishlist creates item with pending status and outbox intent",
      () async {
        final item = await wishlistService.addToWishlist(
          issueId: 4001,
          seriesId: 10,
          seriesName: "Spider-Man",
          priority: 4,
        );

        expect(item.issueId, 4001);
        expect(item.syncStatus, ProjectionSyncState.pending);

        final ready = await db.outboxDao.getReady(accountId: "local-user");
        expect(ready.length, 1);
        expect(ready.first.entityType, OutboxEntityType.wishlist);
        expect(ready.first.operation, OutboxOperationType.create);
      },
    );

    test(
      "acquireIssue executes atomic tombstone, provisional collection projection, and outbox intent",
      () async {
        // Seed a synced wishlist item with remote ID 999
        await db.wishlistDao.upsert(
          WishlistItemsCompanion.insert(
            id: const Value(999),
            issueId: 4002,
            seriesId: 10,
            seriesName: "Spider-Man",
            issueNumber: "1",
            createdAt: "2026-10-01T00:00:00.000Z",
            updatedAt: "2026-10-01T00:00:00.000Z",
          ),
        );

        await wishlistService.acquireIssue(
          issueId: 4002,
          seriesId: 10,
          purchasePrice: 15.0,
        );

        // 1. Wishlist item is soft deleted (not returned by getByIssueId query)
        final wishItem = await db.wishlistDao.getByIssueId(4002);
        expect(wishItem, isNull);

        final rawWishRow = await (db.select(
          db.wishlistItems,
        )..where((t) => t.id.equals(999))).getSingle();
        expect(rawWishRow.deletedAt, isNotNull);

        // 2. Collection item is provisionally owned and pending
        final libItem = await db.libraryItemDao.requireById("lib-4002");
        expect(libItem.ownershipStatus, "owned");
        expect(libItem.syncStatus, ProjectionSyncState.pending);
        expect(libItem.pricePaid, 15.0);

        // 3. Outbox acquire operation is queued
        final ready = await db.outboxDao.getReady(accountId: "local-user");
        expect(ready.length, 1);
        expect(ready.first.operation, OutboxOperationType.acquire);
        expect(ready.first.entityRemoteId, 999);
      },
    );

    test(
      "adding to collection removes from wishlist enforcing mutual exclusivity",
      () async {
        await wishlistService.addToWishlist(issueId: 4003, seriesId: 10);
        expect(await db.wishlistDao.getByIssueId(4003), isNotNull);

        await collectionService.addToCollection(issueId: 4003, seriesId: 10);

        expect(await db.wishlistDao.getByIssueId(4003), isNull);
        expect(await db.libraryItemDao.getById("lib-4003"), isNotNull);
      },
    );
  });

  group("Outbox Claim and Dependency Resolution", () {
    test(
      "claimNextReady respects dependsOnId and releaseDependents unblocks child",
      () async {
        final parent = await db.outboxDao.coalesceCreate(
          accountId: "local-user",
          entityType: OutboxEntityType.collection,
          entityLocalId: "lib-5001",
          coalesceKey: "collection:lib-5001",
          payload: {"issue": 5001},
        );

        // Child patch operation depends on parent create
        final child = OutboxOperation(
          id: "child-patch-1",
          accountId: "local-user",
          entityType: OutboxEntityType.collection,
          entityLocalId: "lib-5001",
          entityRemoteId: null,
          operation: OutboxOperationType.patch,
          payloadJson: jsonEncode({"rating": 5}),
          coalesceKey: "collection:lib-5001",
          dependsOnId: parent.id,
          state: OutboxState.pending,
          attemptCount: 0,
          createdAt: DateTime.now().toUtc(),
          updatedAt: DateTime.now().toUtc(),
        );
        await db.outboxDao.upsert(child.toCompanion(true));

        // 1. Only parent is claimable, child is blocked by dependsOnId
        final claimed1 = await db.outboxDao.claimNextReady(
          accountId: "local-user",
        );
        expect(claimed1?.id, parent.id);

        // Next ready is null because child still depends on parent
        final claimed2 = await db.outboxDao.claimNextReady(
          accountId: "local-user",
        );
        expect(claimed2, isNull);

        // 2. Parent completes, returns remote ID 8888, release dependents
        await db.outboxDao.markDone(parent.id);
        await db.outboxDao.releaseDependents(parent.id, 8888);

        // 3. Child is now unblocked and has remote ID 8888 injected
        final claimed3 = await db.outboxDao.claimNextReady(
          accountId: "local-user",
        );
        expect(claimed3?.id, child.id);
        expect(claimed3?.entityRemoteId, 8888);
        expect(claimed3?.dependsOnId, isNull);
      },
    );
  });
}
