import "dart:async";

import "package:drift/drift.dart" hide isNotNull, isNull;
import "package:drift/native.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:takion/src/data/collection/sync/collection_sync_manager.dart";
import "package:takion/src/data/common/drift/database.dart";
import "package:takion/src/domain/collection/entities/collection_item.dart";
import "package:takion/src/domain/collection/repositories/collection_repository.dart";

class MockCollectionRepository extends Mock implements CollectionRepository {}

/// Builds [count] remote collection items whose issue/page ids do not
/// collide, so multi-page fixtures can be assembled with an [offset].
List<CollectionItem> collectionPage(int count, {int offset = 0}) {
  return List.generate(count, (i) {
    final n = offset + i + 1;
    return CollectionItem(
      id: n,
      issue: CollectionIssueRef(
        id: 10000 + n,
        number: "$n",
        series: const CollectionIssueSeriesRef(id: 10, name: "Batman"),
      ),
      quantity: 1,
    );
  });
}

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

    test("syncCollection paginates past full pages and stamps the cursor",
        () async {
      when(
        () => mockRepository.getCollection(
          page: any(named: "page"),
          modifiedGt: any(named: "modifiedGt"),
        ),
      ).thenAnswer((invocation) async {
        final page = invocation.namedArguments[#page] as int;
        if (page == 1) return collectionPage(20); // Metron page size
        if (page == 2) return collectionPage(5, offset: 20);
        return const [];
      });

      final result = await syncManager.syncCollection(forceFullSync: true);

      expect(result.isSuccess, isTrue);
      expect(result.itemsFetched, 25);
      expect(result.itemsUpdated, 25);

      verify(
        () => mockRepository.getCollection(
          page: 1,
          modifiedGt: any(named: "modifiedGt"),
        ),
      ).called(1);
      verify(
        () => mockRepository.getCollection(
          page: 2,
          modifiedGt: any(named: "modifiedGt"),
        ),
      ).called(1);
      verifyNever(
        () => mockRepository.getCollection(
          page: 3,
          modifiedGt: any(named: "modifiedGt"),
        ),
      );

      expect(
        await database.syncMetaDao.get("metron_last_collection_sync"),
        isNotNull,
      );
    });

    test("a failed page must not advance the sync cursor", () async {
      const seededCursor = "2026-09-01T00:00:00.000Z";
      await database.syncMetaDao.set(
        "metron_last_collection_sync",
        seededCursor,
      );

      when(
        () => mockRepository.getCollection(
          page: any(named: "page"),
          modifiedGt: any(named: "modifiedGt"),
        ),
      ).thenAnswer((invocation) async {
        final page = invocation.namedArguments[#page] as int;
        if (page == 1) return collectionPage(20); // full page → page 2
        throw Exception("network exploded on page 2");
      });

      final result = await syncManager.syncCollection();

      expect(result.isSuccess, isFalse);
      expect(result.errorMessage, contains("network exploded on page 2"));

      // The failed phase must not overwrite the previous cursor, otherwise
      // the un-fetched remainder would be skipped on the next incremental run.
      expect(
        await database.syncMetaDao.get("metron_last_collection_sync"),
        seededCursor,
      );
    });

    test("rejects a concurrent run instead of starting a second sync",
        () async {
      final gate = Completer<List<CollectionItem>>();
      var calls = 0;
      when(
        () => mockRepository.getCollection(
          page: any(named: "page"),
          modifiedGt: any(named: "modifiedGt"),
        ),
      ).thenAnswer((_) {
        calls++;
        return gate.future;
      });

      final first = syncManager.syncCollection(forceFullSync: true);
      await Future<void>.delayed(Duration.zero);

      final second = await syncManager.syncCollection();
      expect(second.isSuccess, isFalse);
      expect(second.errorMessage, "Sync already in progress");

      gate.complete(const []);
      final firstResult = await first;
      expect(firstResult.isSuccess, isTrue);
      expect(calls, 1);
    });
  });
}
