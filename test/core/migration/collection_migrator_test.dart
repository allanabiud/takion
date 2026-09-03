import "package:drift/drift.dart" hide isNull, isNotNull;
import "package:drift/native.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:takion/src/core/migration/collection_migrator.dart";
import "package:takion/src/data/collection/datasources/remote/metron_collection_remote_data_source.dart";
import "package:takion/src/data/collection/dto/collection_item_dto.dart";
import "package:takion/src/data/common/drift/database.dart";

class MockMetronCollectionRemoteDataSource extends Mock
    implements MetronCollectionRemoteDataSource {}

void main() {
  group("CollectionMigrator", () {
    late AppDatabase database;
    late MockMetronCollectionRemoteDataSource remoteDataSource;
    late CollectionMigrator migrator;

    setUp(() {
      database = AppDatabase.forTesting(NativeDatabase.memory());
      remoteDataSource = MockMetronCollectionRemoteDataSource();
      migrator = CollectionMigrator(
        database: database,
        remoteDataSource: remoteDataSource,
      );
    });

    tearDown(() async {
      await database.close();
    });

    test("migrate pushes unmigrated collection items to Metron", () async {
      await database.libraryItemDao.upsert(
        const LibraryItemsCompanion(
          id: Value("lib-101"),
          userId: Value("local-user"),
          metronIssueId: Value(101),
          metronSeriesId: Value(50),
          ownershipStatus: Value("owned"),
          isRead: Value(false),
          metronCollectionId: Value(null),
          syncStatus: Value("pending"),
          format: Value("print"),
          createdAt: Value("2026-09-01T00:00:00Z"),
          updatedAt: Value("2026-09-01T00:00:00Z"),
        ),
      );

      when(
        () => remoteDataSource.addToCollection(
          issueId: 101,
          quantity: any(named: "quantity"),
          bookFormat: any(named: "bookFormat"),
          grade: any(named: "grade"),
          gradingCompany: any(named: "gradingCompany"),
          purchaseDate: any(named: "purchaseDate"),
          purchasePrice: any(named: "purchasePrice"),
          purchasePriceCurrency: any(named: "purchasePriceCurrency"),
          purchaseStore: any(named: "purchaseStore"),
          storageLocation: any(named: "storageLocation"),
          notes: any(named: "notes"),
        ),
      ).thenAnswer(
        (_) async => const CollectionItemDto(
          id: 999,
          issueId: 101,
          seriesId: 50,
          seriesName: "Spider-Man",
          issueNumber: "1",
        ),
      );

      final count = await migrator.countUnmigrated();
      expect(count, 1);

      final migrated = await migrator.migrate();
      expect(migrated, 1);

      final updated = await database.libraryItemDao.getByIssueId(101);
      expect(updated!.metronCollectionId, 999);
      expect(updated.syncStatus, "synced");
    });
  });
}
