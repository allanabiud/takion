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

    test("syncWishlist ingests remote items into local database", () async {
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
      expect(inDb!.id, 10);
      expect(inDb.seriesName, "Batman");
      expect(inDb.priority, 4);
      expect(inDb.syncStatus, "synced");
    });

    test("syncWishlist preserves pending local changes", () async {
      await database.wishlistDao.upsert(
        const WishlistItemsCompanion(
          id: Value(10),
          issueId: Value(501),
          seriesId: Value(100),
          seriesName: Value("Batman"),
          issueNumber: Value("1"),
          priority: Value(5),
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
            seriesId: 100,
            seriesName: "Batman",
            issueNumber: "1",
            priority: 2,
          ),
        ],
      );

      final result = await syncManager.syncWishlist();
      expect(result.isSuccess, isTrue);

      final inDb = await database.wishlistDao.getByIssueId(501);
      expect(inDb!.priority, 5);
      expect(inDb.syncStatus, "pending");
    });

    test("syncWishlist deletes local synced items absent on remote", () async {
      await database.wishlistDao.upsert(
        const WishlistItemsCompanion(
          id: Value(10),
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
      expect(inDb, isNull);
    });
  });
}
