import "package:drift/drift.dart" hide isNull, isNotNull;
import "package:drift/native.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:takion/src/core/migration/wish_list_migrator.dart";
import "package:takion/src/data/common/drift/database.dart";
import "package:takion/src/data/wishlist/datasources/remote/metron_wishlist_remote_data_source.dart";
import "package:takion/src/data/wishlist/dto/wishlist_dto.dart";

class MockMetronWishlistRemoteDataSource extends Mock
    implements MetronWishlistRemoteDataSource {}

void main() {
  setUpAll(() {
    registerFallbackValue(const WishListAddItemDto(issueId: 1));
  });

  group("WishListMigrator", () {
    late AppDatabase database;
    late MockMetronWishlistRemoteDataSource remoteDataSource;
    late WishListMigrator migrator;

    setUp(() {
      database = AppDatabase.forTesting(NativeDatabase.memory());
      remoteDataSource = MockMetronWishlistRemoteDataSource();
      migrator = WishListMigrator(
        database: database,
        remoteDataSource: remoteDataSource,
      );
    });

    tearDown(() async {
      await database.close();
    });

    test("migrate moves legacy library wishlist rows into WishlistItems",
        () async {
      await database.libraryItemDao.upsert(
        const LibraryItemsCompanion(
          id: Value("lib-202"),
          userId: Value("local-user"),
          metronIssueId: Value(202),
          metronSeriesId: Value(50),
          ownershipStatus: Value("wishlist"),
          isRead: Value(false),
          syncStatus: Value("pending"),
          format: Value("print"),
          createdAt: Value("2026-09-01T00:00:00Z"),
          updatedAt: Value("2026-09-01T00:00:00Z"),
        ),
      );

      when(
        () => remoteDataSource.addToWishList(any()),
      ).thenAnswer(
        (_) async => const WishListItemDto(
          id: 777,
          issueId: 202,
          seriesId: 50,
          seriesName: "Spider-Man",
          issueNumber: "2",
          priority: 3,
        ),
      );

      final count = await migrator.countUnmigrated();
      expect(count, 1);

      final migrated = await migrator.migrate();
      expect(migrated.migrated, 1);
      expect(migrated.failed, 0);

      // Verify removed from legacy libraryItems
      final legacy = await database.libraryItemDao.getByIssueId(202);
      expect(legacy, isNull);

      // Verify created in wishlistItems
      final inWishlist = await database.wishlistDao.getByIssueId(202);
      expect(inWishlist, isNotNull);
      expect(inWishlist!.id, 777);
      expect(inWishlist.syncStatus, "synced");
    });
  });
}
