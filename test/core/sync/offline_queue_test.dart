import "package:drift/native.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:takion/src/core/sync/offline_queue/offline_queue_processor.dart";
import "package:takion/src/core/sync/offline_queue/offline_write_queue.dart";
import "package:takion/src/data/collection/datasources/remote/metron_collection_remote_data_source.dart";
import "package:takion/src/data/collection/dto/collection_item_dto.dart";
import "package:takion/src/data/collection/dto/scrobble_dto.dart";
import "package:takion/src/data/common/drift/database.dart"
    hide OfflineWriteQueue;
import "package:takion/src/data/pull_list/datasources/remote/metron_pull_list_remote_data_source.dart";
import "package:takion/src/data/pull_list/dto/pull_list_dto.dart";
import "package:takion/src/data/wishlist/datasources/remote/metron_wishlist_remote_data_source.dart";
import "package:takion/src/data/wishlist/dto/wishlist_dto.dart";

class MockCollectionRemoteDataSource extends Mock
    implements MetronCollectionRemoteDataSource {}

class MockPullListRemoteDataSource extends Mock
    implements MetronPullListRemoteDataSource {}

class MockWishlistRemoteDataSource extends Mock
    implements MetronWishlistRemoteDataSource {}

void main() {
  late AppDatabase db;
  late MockCollectionRemoteDataSource mockCollectionRemote;
  late MockPullListRemoteDataSource mockPullListRemote;
  late MockWishlistRemoteDataSource mockWishlistRemote;
  late OfflineQueueProcessor processor;
  late OfflineWriteQueue queue;

  setUpAll(() {
    registerFallbackValue(const ScrobbleRequestDto(issueId: 1));
    registerFallbackValue(const WishListAddItemDto(issueId: 1));
    registerFallbackValue(const AcquireWishListItemDto());
  });

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    mockCollectionRemote = MockCollectionRemoteDataSource();
    mockPullListRemote = MockPullListRemoteDataSource();
    mockWishlistRemote = MockWishlistRemoteDataSource();

    processor = OfflineQueueProcessor(
      dao: db.offlineQueueDao,
      database: db,
      collectionRemote: mockCollectionRemote,
      pullListRemote: mockPullListRemote,
      wishlistRemote: mockWishlistRemote,
    );

    queue = OfflineWriteQueue(dao: db.offlineQueueDao, processor: processor);
  });

  tearDown(() async {
    await db.close();
  });

  group("OfflineWriteQueue and OfflineQueueProcessor", () {
    test("enqueueCollectionAdd and process successfully", () async {
      when(
        () => mockCollectionRemote.addToCollection(
          issueId: 100,
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
          id: 1,
          issueId: 100,
          seriesId: 10,
          seriesName: "Batman",
          issueNumber: "1",
        ),
      );

      final id = await queue.enqueueCollectionAdd(
        issueId: 100,
        notes: "Mint condition",
      );
      expect(id, isPositive);

      final processed = await queue.processQueue();
      expect(processed, 1);

      final pending = await db.offlineQueueDao.getPendingEntries();
      expect(pending, isEmpty);

      verify(
        () => mockCollectionRemote.addToCollection(
          issueId: 100,
          quantity: 1,
          bookFormat: "PRINT",
          notes: "Mint condition",
          purchasePriceCurrency: "USD",
        ),
      ).called(1);
    });

    test("enqueueScrobble and process successfully", () async {
      when(
        () => mockCollectionRemote.scrobble(any()),
      ).thenAnswer((_) async => const ScrobbleResponseDto(id: 1, isRead: true));

      await queue.enqueueScrobble(issueId: 200, rating: 5);

      final processed = await queue.processQueue();
      expect(processed, 1);

      verify(() => mockCollectionRemote.scrobble(any())).called(1);
    });

    test(
      "enqueueScrobble sanitizes rating of 0 to null (never sends 0 to Metron)",
      () async {
        ScrobbleRequestDto? capturedRequest;
        when(() => mockCollectionRemote.scrobble(any())).thenAnswer((
          invocation,
        ) async {
          capturedRequest =
              invocation.positionalArguments.first as ScrobbleRequestDto;
          return const ScrobbleResponseDto(id: 1, isRead: true);
        });

        await queue.enqueueScrobble(issueId: 205, rating: 0);

        final processed = await queue.processQueue();
        expect(processed, 1);

        expect(capturedRequest, isNotNull);
        expect(capturedRequest!.issueId, 205);
        expect(capturedRequest!.rating, isNull);
        expect(capturedRequest!.toJson().containsKey("rating"), isFalse);
      },
    );

    test(
      "enqueueCollectionUpdate sanitizes rating of 0 to null to clear rating cleanly",
      () async {
        Map<String, dynamic>? capturedUpdates;
        when(
          () => mockCollectionRemote.updateCollectionItem(any(), any()),
        ).thenAnswer((invocation) async {
          capturedUpdates =
              invocation.positionalArguments[1] as Map<String, dynamic>;
          return const CollectionItemDto(
            id: 50,
            issueId: 210,
            seriesId: 10,
            seriesName: "Batman",
            issueNumber: "2",
          );
        });

        await queue.enqueueCollectionUpdate(
          metronCollectionId: 50,
          updates: {"rating": 0, "notes": "Read it"},
        );

        final processed = await queue.processQueue();
        expect(processed, 1);

        expect(capturedUpdates, isNotNull);
        expect(capturedUpdates!["rating"], isNull);
        expect(capturedUpdates!["notes"], "Read it");
      },
    );

    test("enqueuePullListAdd and process successfully", () async {
      when(() => mockPullListRemote.addSeriesToPullList(300)).thenAnswer(
        (_) async => const PullListSeriesDto(
          id: 1,
          seriesId: 300,
          seriesName: "Spider-Man",
        ),
      );

      await queue.enqueuePullListAdd(seriesId: 300);

      final processed = await queue.processQueue();
      expect(processed, 1);

      verify(() => mockPullListRemote.addSeriesToPullList(300)).called(1);
    });

    test("enqueueWishlistAdd and process successfully", () async {
      when(() => mockWishlistRemote.addToWishList(any())).thenAnswer(
        (_) async => const WishListItemDto(
          id: 1,
          issueId: 400,
          seriesId: 50,
          seriesName: "X-Men",
          issueNumber: "1",
        ),
      );

      await queue.enqueueWishlistAdd(issueId: 400, priority: 5);

      final processed = await queue.processQueue();
      expect(processed, 1);

      verify(() => mockWishlistRemote.addToWishList(any())).called(1);
    });

    test(
      "handles failure by incrementing retry count and storing error",
      () async {
        when(
          () => mockPullListRemote.removeSeriesFromPullList(999),
        ).thenThrow(Exception("Network unreachable"));

        await queue.enqueuePullListRemove(seriesId: 999);

        final processed = await queue.processQueue();
        expect(processed, 0);

        final pending = await db.offlineQueueDao.getPendingEntries();
        expect(pending.length, 1);
        expect(pending.first.retryCount, 1);
        expect(pending.first.lastError, contains("Network unreachable"));
      },
    );
  });
}
