import "package:drift/native.dart";
import "package:flutter_test/flutter_test.dart";
import "package:takion/src/core/commands/outbox_constants.dart";
import "package:takion/src/data/common/drift/database.dart" hide WishlistItem;
import "package:takion/src/data/wishlist/repositories/local_wishlist_repository.dart";

void main() {
  group("LocalWishlistRepository", () {
    late AppDatabase database;
    late LocalWishlistRepository repository;

    setUp(() {
      database = AppDatabase.forTesting(NativeDatabase.memory());
      repository = LocalWishlistRepository(database);
    });

    tearDown(() async {
      await database.close();
    });

    test(
      "addToWishList inserts into database and records a durable outbox intent",
      () async {
        final item = await repository.addToWishList(
          issueId: 101,
          seriesId: 20,
          seriesName: "Batman",
          issueNumber: "1",
          priority: 4,
          maxPrice: 30.0,
        );

        expect(item.issueId, 101);
        expect(item.seriesName, "Batman");
        expect(item.syncStatus, "pending");

        final inDb = await repository.getItemByIssueId(101);
        expect(inDb, isNotNull);
        expect(inDb!.seriesId, 20);
        expect(inDb.priority, 4);

        // Local projection and outbox intent change in one transaction.
        final pending = await database.outboxDao.getPendingEntries();
        expect(pending.length, 1);
        final op = pending.first;
        expect(op.operation, OutboxOperationType.create);
        expect(op.entityType, OutboxEntityType.wishlist);
        expect(op.coalesceKey, "wishlist:101");
        expect(op.payloadJson, contains('"issue":101'));
      },
    );

    test(
      "acquireWishListItem deletes from database and queues a collection create",
      () async {
        await repository.addToWishList(
          issueId: 101,
          seriesId: 20,
          seriesName: "Batman",
          issueNumber: "1",
        );

        await repository.acquireWishListItem(
          itemId: 101,
          purchasePrice: 15.0,
          purchaseStore: "Midtown Comics",
        );

        final inDb = await repository.getItemByIssueId(101);
        expect(inDb, isNull);

        final libItem = await database.libraryItemDao.getByIssueId(101);
        expect(libItem, isNotNull);
        expect(libItem!.ownershipStatus, "owned");
        expect(libItem.metronIssueId, 101);
        expect(libItem.metronSeriesId, 20);

        // Never-synced wishlist item converts directly to a collection create;
        // the cancelled wishlist create leaves no dangling outbox rows.
        final pending = await database.outboxDao.getPendingEntries();
        expect(pending.length, 1);
        final op = pending.first;
        expect(op.operation, OutboxOperationType.create);
        expect(op.entityType, OutboxEntityType.collection);
        expect(op.payloadJson, contains('"issue":101'));
        expect(
          pending.any((o) => o.entityType == OutboxEntityType.wishlist),
          isFalse,
        );
      },
    );

    test(
      "removeFromWishList deletes from database and cancels the pending outbox intent",
      () async {
        await repository.addToWishList(
          issueId: 101,
          seriesId: 20,
          seriesName: "Batman",
          issueNumber: "1",
        );

        await repository.removeFromWishList(101);

        final inDb = await repository.getItemByIssueId(101);
        expect(inDb, isNull);

        // Add then remove of a never-synced item cancels both sides: no
        // remote work is left queued.
        final pending = await database.outboxDao.getPendingEntries();
        expect(pending, isEmpty);
      },
    );

    test("watchWishListItems emits list of wishlist items", () async {
      await repository.addToWishList(
        issueId: 101,
        seriesId: 20,
        seriesName: "Batman",
        issueNumber: "1",
      );

      final items = await repository.watchWishListItems().first;
      expect(items.length, 1);
      expect(items.first.seriesName, "Batman");
    });
  });
}
