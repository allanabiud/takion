import "dart:async";

import "package:drift/drift.dart" hide isNotNull, isNull;
import "package:drift/native.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:takion/src/data/common/drift/database.dart" hide WishlistItem;
import "package:takion/src/data/wishlist/sync/wishlist_sync_manager.dart";
import "package:takion/src/domain/wishlist/entities/wishlist_item.dart";
import "package:takion/src/domain/wishlist/repositories/wishlist_repository.dart";

class MockMetronWishlistRepository extends Mock
    implements MetronWishlistRepository {}

void main() {
  group("WishlistSyncManager", () {
    late AppDatabase database;
    late MockMetronWishlistRepository mockRepository;
    late WishlistSyncManager syncManager;

    setUp(() {
      database = AppDatabase.forTesting(NativeDatabase.memory());
      mockRepository = MockMetronWishlistRepository();
      syncManager = WishlistSyncManager(
        database: database,
        wishlistRepository: mockRepository,
      );
    });

    tearDown(() async {
      await database.close();
    });

    test("syncWishlist ingests remote items into wishlist_items table", () async {
      when(
        () => mockRepository.getWishListItems(page: 1),
      ).thenAnswer(
        (_) async => [
          WishlistItem(
            id: 10,
            issueId: 501,
            seriesId: 100,
            seriesName: "Batman",
            issueNumber: "1",
            priority: 4,
            maxPrice: 25.0,
            addedOn: DateTime.parse("2026-09-01T00:00:00Z"),
          ),
        ],
      );

      final result = await syncManager.syncWishlist();

      expect(result.isSuccess, isTrue);
      expect(result.itemsFetched, 1);
      expect(result.itemsUpdated, 1);

      final inDb = await database.wishlistDao.getByIssueId(501);
      expect(inDb, isNotNull);
      expect(inDb!.seriesId, 100);
      expect(inDb.syncStatus, "synced");
    });

    test("syncWishlist preserves pending local changes in wishlist_items", () async {
      await database.wishlistDao.upsert(
        const WishlistItemsCompanion(
          id: Value(501),
          issueId: Value(501),
          seriesId: Value(100),
          seriesName: Value("Batman"),
          issueNumber: Value("1"),
          syncStatus: Value("pending"),
          createdAt: Value("2026-09-01T00:00:00Z"),
          updatedAt: Value("2026-09-04T00:00:00Z"),
        ),
      );

      when(
        () => mockRepository.getWishListItems(page: 1),
      ).thenAnswer(
        (_) async => [
          const WishlistItem(
            id: 10,
            issueId: 501,
            seriesId: 200,
            seriesName: "Batman",
            issueNumber: "1",
            priority: 2,
          ),
        ],
      );

      final result = await syncManager.syncWishlist();
      expect(result.isSuccess, isTrue);

      final inDb = await database.wishlistDao.getByIssueId(501);
      expect(inDb, isNotNull);
      expect(inDb!.syncStatus, "pending");
      expect(inDb.seriesId, 100);
    });

    test("syncWishlist preserves local synced items when remote returns empty (safety guard)", () async {
      await database.wishlistDao.upsert(
        const WishlistItemsCompanion(
          id: Value(501),
          issueId: Value(501),
          seriesId: Value(100),
          seriesName: Value("Batman"),
          issueNumber: Value("1"),
          syncStatus: Value("synced"),
          createdAt: Value("2026-09-01T00:00:00Z"),
          updatedAt: Value("2026-09-04T00:00:00Z"),
        ),
      );

      when(
        () => mockRepository.getWishListItems(page: 1),
      ).thenAnswer((_) async => []);

      final result = await syncManager.syncWishlist();
      expect(result.isSuccess, isTrue);

      final inDb = await database.wishlistDao.getByIssueId(501);
      expect(inDb, isNotNull);
    });

    test("syncWishlist deletes local synced items absent on remote when remote has data", () async {
      await database.wishlistDao.upsert(
        const WishlistItemsCompanion(
          id: Value(501),
          issueId: Value(501),
          seriesId: Value(100),
          seriesName: Value("Batman"),
          issueNumber: Value("1"),
          syncStatus: Value("synced"),
          createdAt: Value("2026-09-01T00:00:00Z"),
          updatedAt: Value("2026-09-04T00:00:00Z"),
        ),
      );

      when(
        () => mockRepository.getWishListItems(page: 1),
      ).thenAnswer((_) async => [
        const WishlistItem(
          id: 20,
          issueId: 600,
          seriesId: 200,
          seriesName: "X-Men",
          issueNumber: "1",
          priority: 3,
        ),
      ]);

      final result = await syncManager.syncWishlist();
      expect(result.isSuccess, isTrue);

      final deleted = await database.wishlistDao.getByIssueId(501);
      expect(deleted, isNull);

      final kept = await database.wishlistDao.getByIssueId(600);
      expect(kept, isNotNull);
      expect(kept!.syncStatus, "synced");
    });

    test("syncWishlist paginates past full pages and stamps the cursor",
        () async {
      when(
        () => mockRepository.getWishListItems(page: any(named: "page")),
      ).thenAnswer((invocation) async {
        final page = invocation.namedArguments[#page] as int;
        if (page == 1) {
          // Metron page size → the worker must request page 2 as well.
          return List.generate(20, (i) => _wishlistItem(i + 1));
        }
        if (page == 2) {
          return [_wishlistItem(21), _wishlistItem(22), _wishlistItem(23)];
        }
        return const [];
      });

      final result = await syncManager.syncWishlist(forceFullSync: true);

      expect(result.isSuccess, isTrue);
      expect(result.itemsFetched, 23);
      expect(result.itemsUpdated, 23);

      verify(() => mockRepository.getWishListItems(page: 1)).called(1);
      verify(() => mockRepository.getWishListItems(page: 2)).called(1);
      verifyNever(() => mockRepository.getWishListItems(page: 3));

      expect(
        await database.syncMetaDao.get("metron_last_wishlist_sync"),
        isNotNull,
      );
      expect(await database.wishlistDao.getByIssueId(7021), isNotNull);
    });

    test("a failed page must not advance the wishlist cursor", () async {
      const seededCursor = "2026-09-01T00:00:00.000Z";
      await database.syncMetaDao.set("metron_last_wishlist_sync", seededCursor);

      when(
        () => mockRepository.getWishListItems(page: any(named: "page")),
      ).thenAnswer((invocation) async {
        final page = invocation.namedArguments[#page] as int;
        if (page == 1) return List.generate(20, (i) => _wishlistItem(i + 1));
        throw Exception("wishlist page 2 down");
      });

      final result = await syncManager.syncWishlist();

      expect(result.isSuccess, isFalse);
      expect(result.errorMessage, contains("wishlist page 2 down"));
      expect(
        await database.syncMetaDao.get("metron_last_wishlist_sync"),
        seededCursor,
      );
    });

    test("rejects a concurrent run instead of starting a second sync",
        () async {
      final gate = Completer<List<WishlistItem>>();
      var calls = 0;
      when(
        () => mockRepository.getWishListItems(page: any(named: "page")),
      ).thenAnswer((_) {
        calls++;
        return gate.future;
      });

      final first = syncManager.syncWishlist(forceFullSync: true);
      await Future<void>.delayed(Duration.zero);

      final second = await syncManager.syncWishlist();
      expect(second.isSuccess, isFalse);
      expect(second.errorMessage, "Wishlist sync already in progress");

      gate.complete(const []);
      final firstResult = await first;
      expect(firstResult.isSuccess, isTrue);
      expect(calls, 1);
    });
  });
}

WishlistItem _wishlistItem(int n) {
  return WishlistItem(
    id: n,
    issueId: 7000 + n,
    seriesId: 100,
    seriesName: "Series",
    issueNumber: "$n",
  );
}
