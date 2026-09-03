import "package:drift/drift.dart" hide isNotNull, isNull;
import "package:drift/native.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:takion/src/data/collection/sync/collection_sync_manager.dart";
import "package:takion/src/data/common/drift/database.dart";
import "package:takion/src/domain/collection/entities/collection_item.dart";
import "package:takion/src/domain/collection/repositories/collection_repository.dart";

class MockCollectionRepository extends Mock implements CollectionRepository {}

void main() {
  group("CollectionSyncManager", () {
    late AppDatabase database;
    late MockCollectionRepository mockRepository;
    late CollectionSyncManager syncManager;

    setUp(() {
      database = AppDatabase.forTesting(NativeDatabase.memory());
      mockRepository = MockCollectionRepository();
      syncManager = CollectionSyncManager(
        database: database,
        collectionRepository: mockRepository,
      );
    });

    tearDown(() async {
      await database.close();
    });

    test("syncCollection pulls remote items and writes them to local DB", () async {
      when(
        () => mockRepository.getCollection(
          page: 1,
          modifiedGt: any(named: "modifiedGt"),
        ),
      ).thenAnswer(
        (_) async => [
          const CollectionItem(
            id: 101,
            issue: CollectionIssueRef(
              id: 42,
              number: "1",
              series: CollectionIssueSeriesRef(id: 10, name: "Batman"),
            ),
            quantity: 1,
            isRead: true,
            rating: 5,
          ),
        ],
      );

      final result = await syncManager.syncCollection(forceFullSync: true);

      expect(result.isSuccess, isTrue);
      expect(result.itemsFetched, 1);
      expect(result.itemsUpdated, 1);

      final localItem = await database.libraryItemDao.getByIssueId(42);
      expect(localItem, isNotNull);
      expect(localItem!.metronIssueId, 42);
      expect(localItem.metronCollectionId, 101);
      expect(localItem.isRead, isTrue);
      expect(localItem.rating, 5);
      expect(localItem.syncStatus, "synced");
    });

    test("syncCollection preserves items with pending local modifications", () async {
      // First insert an item with pending local changes
      await database.libraryItemDao.upsert(
        const LibraryItemsCompanion(
          id: Value("lib-42"),
          userId: Value("local-user"),
          metronIssueId: Value(42),
          metronSeriesId: Value(10),
          ownershipStatus: Value("owned"),
          isRead: Value(false),
          metronCollectionId: Value(101),
          syncStatus: Value("pending"),
          format: Value("print"),
          createdAt: Value("2026-09-01T00:00:00Z"),
          updatedAt: Value("2026-09-04T00:00:00Z"),
        ),
      );

      // Mock remote returns isRead: true
      when(
        () => mockRepository.getCollection(
          page: 1,
          modifiedGt: any(named: "modifiedGt"),
        ),
      ).thenAnswer(
        (_) async => [
          const CollectionItem(
            id: 101,
            issue: CollectionIssueRef(
              id: 42,
              number: "1",
              series: CollectionIssueSeriesRef(id: 10, name: "Batman"),
            ),
            quantity: 1,
            isRead: true,
          ),
        ],
      );

      final result = await syncManager.syncCollection(forceFullSync: true);

      expect(result.isSuccess, isTrue);
      expect(result.itemsUpdated, 0); // Not updated because of pending status

      final localItem = await database.libraryItemDao.getByIssueId(42);
      expect(localItem!.isRead, isFalse);
      expect(localItem.syncStatus, "pending");
    });
  });
}
