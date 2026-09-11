import "package:drift/drift.dart" hide isNull, isNotNull;
import "package:drift/native.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:takion/src/core/migration/wishlist_migrator.dart";
import "package:takion/src/data/common/drift/database.dart";
import "package:takion/src/data/wishlist/datasources/remote/metron_wishlist_remote_data_source.dart";
import "package:takion/src/data/wishlist/dto/wishlist_dto.dart";

class MockMetronWishlistRemoteDataSource extends Mock
    implements MetronWishlistRemoteDataSource {}

void main() {
  setUpAll(() {
    registerFallbackValue(const WishListAddItemDto(issueId: 0));
  });

  group("WishlistMigrator", () {
    late AppDatabase database;
    late MockMetronWishlistRemoteDataSource remoteDataSource;
    late WishlistMigrator migrator;

    setUp(() {
      database = AppDatabase.forTesting(NativeDatabase.memory());
      remoteDataSource = MockMetronWishlistRemoteDataSource();
      migrator = WishlistMigrator(
        database: database,
        remoteDataSource: remoteDataSource,
      );
    });

    tearDown(() async {
      await database.close();
    });

    test("migrate pushes unmigrated wishlist items to Metron", () async {
      await database.wishlistDao.upsert(
        const WishlistItemsCompanion(
          id: Value(-1),
          issueId: Value(1234),
          seriesId: Value(99),
          seriesName: Value("Spider-Man"),
          issueNumber: Value("1"),
          createdAt: Value("2026-09-01T00:00:00Z"),
          updatedAt: Value("2026-09-01T00:00:00Z"),
          syncStatus: Value("pending"),
        ),
      );

      when(
        () => remoteDataSource.addToWishList(any()),
      ).thenAnswer(
        (_) async => const WishListItemDto(
          id: 5678,
          issueId: 1234,
          seriesId: 99,
          seriesName: "Spider-Man",
          issueNumber: "1",
        ),
      );

      final count = await migrator.countUnmigrated();
      expect(count, 1);

      final result = await migrator.migrate();
      expect(result.migrated, 1);
      expect(result.failed, 0);

      final updated = await database.wishlistDao.getByIssueId(1234);
      expect(updated!.id, 5678);
      expect(updated.syncStatus, "synced");
    });
  });
}
