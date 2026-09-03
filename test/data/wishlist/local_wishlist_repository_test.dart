import "package:drift/native.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:takion/src/core/sync/offline_queue/offline_write_queue.dart";
import "package:takion/src/data/common/drift/database.dart"
    hide OfflineWriteQueue, WishlistItem;
import "package:takion/src/data/wishlist/repositories/local_wishlist_repository.dart";

class MockOfflineWriteQueue extends Mock implements OfflineWriteQueue {}

void main() {
  group("LocalWishlistRepository", () {
    late AppDatabase database;
    late MockOfflineWriteQueue offlineQueue;
    late LocalWishlistRepository repository;

    setUp(() {
      database = AppDatabase.forTesting(NativeDatabase.memory());
      offlineQueue = MockOfflineWriteQueue();
      when(
        () => offlineQueue.enqueueWishlistAdd(
          issueId: any(named: "issueId"),
          priority: any(named: "priority"),
          desiredGrade: any(named: "desiredGrade"),
          maxPrice: any(named: "maxPrice"),
          maxPriceCurrency: any(named: "maxPriceCurrency"),
          notes: any(named: "notes"),
        ),
      ).thenAnswer((_) async => 1);

      when(
        () => offlineQueue.enqueueWishlistAcquire(
          itemId: any(named: "itemId"),
          purchaseDate: any(named: "purchaseDate"),
          purchasePrice: any(named: "purchasePrice"),
          purchasePriceCurrency: any(named: "purchasePriceCurrency"),
          purchaseStore: any(named: "purchaseStore"),
          notes: any(named: "notes"),
        ),
      ).thenAnswer((_) async => 1);

      when(
        () => offlineQueue.enqueueWishlistRemove(
          itemId: any(named: "itemId"),
        ),
      ).thenAnswer((_) async => 1);

      repository = LocalWishlistRepository(
        database,
        offlineQueue: offlineQueue,
      );
    });

    tearDown(() async {
      await database.close();
    });

    test("addToWishList inserts into database and enqueues offline write",
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

      verify(
        () => offlineQueue.enqueueWishlistAdd(
          issueId: 101,
          priority: 4,
          desiredGrade: null,
          maxPrice: 30.0,
          maxPriceCurrency: "USD",
          notes: null,
        ),
      ).called(1);
    });

    test("acquireWishListItem deletes from database and enqueues offline acquire",
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

      verify(
        () => offlineQueue.enqueueWishlistAcquire(
          itemId: 101,
          purchaseDate: null,
          purchasePrice: 15.0,
          purchasePriceCurrency: "USD",
          purchaseStore: "Midtown Comics",
          notes: null,
        ),
      ).called(1);
    });

    test("removeFromWishList deletes from database and enqueues offline remove",
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

      verify(() => offlineQueue.enqueueWishlistRemove(itemId: 101)).called(1);
    });

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
