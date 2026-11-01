import "dart:io";
import "package:drift/drift.dart" show Value;
import "package:drift/native.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:takion/src/core/commands/outbox_constants.dart";
import "package:takion/src/core/network/remote_page.dart";
import "package:takion/src/core/sync/adapters/adapters.dart";
import "package:takion/src/core/sync/outbox/outbox_executor.dart";
import "package:takion/src/core/sync/outbox/outbox_projection_applier.dart";
import "package:takion/src/core/sync/outbox/outbox_remote_dispatcher.dart";
import "package:takion/src/core/sync/sync_cursor.dart";
import "package:takion/src/core/sync/sync_engine.dart";
import "package:takion/src/data/collection/datasources/remote/metron_collection_remote_data_source.dart";
import "package:takion/src/data/collection/dto/collection_item_dto.dart";
import "package:takion/src/data/common/drift/database.dart";
import "package:takion/src/data/pull_list/datasources/remote/metron_pull_list_remote_data_source.dart";
import "package:takion/src/data/pull_list/dto/pull_list_dto.dart";
import "package:takion/src/data/wishlist/datasources/remote/metron_wishlist_remote_data_source.dart";

class MockCollectionRemote extends Mock
    implements MetronCollectionRemoteDataSource {}

class MockPullListRemote extends Mock
    implements MetronPullListRemoteDataSource {}

class MockWishlistRemote extends Mock
    implements MetronWishlistRemoteDataSource {}

void main() {
  late Directory tempDir;
  late File dbFile;
  late AppDatabase db;
  late MockCollectionRemote mockCollectionRemote;
  late MockPullListRemote mockPullListRemote;
  late MockWishlistRemote mockWishlistRemote;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp("sync_engine_phase3_test");
    dbFile = File("${tempDir.path}/test.db");
    db = AppDatabase.forTesting(NativeDatabase(dbFile));
    mockCollectionRemote = MockCollectionRemote();
    mockPullListRemote = MockPullListRemote();
    mockWishlistRemote = MockWishlistRemote();
  });

  tearDown(() async {
    await db.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group("SyncLeaseDao Mutual Exclusion", () {
    test(
      "second runner cannot acquire lease while active runner holds it",
      () async {
        final leaseDao = db.syncLeaseDao;
        final now = DateTime.utc(2026, 10, 26, 12, 0, 0);

        // Runner 1 acquires lease for 5 minutes
        final acquired1 = await leaseDao.tryAcquire(
          name: "metron:local-user",
          ownerId: "foreground-runner",
          ttl: const Duration(minutes: 5),
          now: now,
        );
        expect(acquired1, isTrue);

        // Runner 2 tries to acquire lease at the same time
        final acquired2 = await leaseDao.tryAcquire(
          name: "metron:local-user",
          ownerId: "background-worker",
          ttl: const Duration(minutes: 5),
          now: now,
        );
        expect(acquired2, isFalse);

        // After 6 minutes, Runner 1 lease is expired -> Runner 2 can acquire
        final acquired2AfterExpiry = await leaseDao.tryAcquire(
          name: "metron:local-user",
          ownerId: "background-worker",
          ttl: const Duration(minutes: 5),
          now: now.add(const Duration(minutes: 6)),
        );
        expect(acquired2AfterExpiry, isTrue);

        // Runner 2 releases lease
        await leaseDao.release("metron:local-user", "background-worker");

        // Runner 1 can reacquire
        final reacquired1 = await leaseDao.tryAcquire(
          name: "metron:local-user",
          ownerId: "foreground-runner",
          ttl: const Duration(minutes: 5),
          now: now.add(const Duration(minutes: 7)),
        );
        expect(reacquired1, isTrue);
      },
    );
  });

  group("CollectionDeltaAdapter safe pagination and resume", () {
    test("resumes from saved nextUrl without restarting from page 1", () async {
      final cursorDao = db.syncCursorDao;
      final libraryDao = db.libraryItemDao;

      // Seed an existing cursor that was interrupted on page 2
      final page2Uri = Uri.parse("https://metron.cloud/api/collection/?page=2");
      await cursorDao.saveCursor(
        accountId: "local-user",
        resource: "collection",
        cursor: SyncCursorState(
          scanId: "scan-prev",
          scanStartedAt: DateTime.utc(2026, 10, 26, 10, 0, 0),
          nextUrl: page2Uri,
        ),
        isComplete: false,
      );

      final adapter = CollectionDeltaAdapter(
        db: db,
        remoteDataSource: mockCollectionRemote,
        libraryItemDao: libraryDao,
        cursorDao: cursorDao,
      );

      // Mock only page 2 returning next: null
      when(
        () => mockCollectionRemote.getCollectionPage(
          pageUrl: page2Uri,
          modifiedGt: any(named: "modifiedGt"),
        ),
      ).thenAnswer(
        (_) async => RemotePage<CollectionItemDto>(
          items: const [
            CollectionItemDto(
              id: 999,
              issueId: 101,
              seriesId: 10,
              seriesName: "Spider-Man",
              issueNumber: "1",
              isRead: true,
              modified: "2026-10-26T10:05:00.000Z",
            ),
          ],
          count: 1,
          next: null,
          previous: null,
          fetchedAt: DateTime.utc(2026, 10, 26, 10, 05, 0),
        ),
      );

      final result = await adapter.sync(
        accountId: "local-user",
        budget: SyncBudget(maxRequests: 10),
      );

      expect(result.isSuccess, isTrue);
      expect(result.isComplete, isTrue);
      expect(result.itemsFetched, 1);

      // Verify pageUrl requested was exactly page2Uri, not page 1
      verify(
        () => mockCollectionRemote.getCollectionPage(
          pageUrl: page2Uri,
          modifiedGt: null,
        ),
      ).called(1);

      // Verify item was ingested locally
      final item = await libraryDao.getByIssueId(101);
      expect(item, isNotNull);
      expect(item!.metronCollectionId, 999);
      expect(item.syncStatus, "synced");

      // Verify cursor is marked complete and watermark is saved
      final updatedCursor = await cursorDao.loadCursor(
        "local-user",
        "collection",
      );
      expect(updatedCursor.nextUrl, isNull);
      expect(updatedCursor.watermark, isNotNull);
    });
  });

  group("PullSeriesSnapshotAdapter Complete-Scan Deletion Safety", () {
    test(
      "incomplete/interrupted scan NEVER deletes or deactivates local subscriptions",
      () async {
        final subscriptionDao = db.subscriptionDao;
        final cursorDao = db.syncCursorDao;

        // Seed existing local subscription
        await subscriptionDao.upsert(
          SeriesSubscriptionsCompanion.insert(
            id: "sub-10",
            userId: "local-user",
            metronSeriesId: 10,
            isActive: true,
            syncStatus: const Value("synced"),
            subscribedAt: "2026-10-20T00:00:00.000Z",
            createdAt: "2026-10-20T00:00:00.000Z",
            updatedAt: "2026-10-20T00:00:00.000Z",
          ),
        );

        final adapter = PullSeriesSnapshotAdapter(
          db: db,
          remoteDataSource: mockPullListRemote,
          subscriptionDao: subscriptionDao,
          cursorDao: cursorDao,
        );

        // Mock page 1 returning series 20, but with nextUrl pointing to page 2
        final page2Uri = Uri.parse(
          "https://metron.cloud/api/pull_list/series/?page=2",
        );
        when(
          () => mockPullListRemote.getPullListSeriesPage(pageUrl: null),
        ).thenAnswer(
          (_) async => RemotePage<PullListSeriesDto>(
            items: const [
              PullListSeriesDto(id: 200, seriesId: 20, seriesName: "Batman"),
            ],
            count: 2,
            next: page2Uri,
            previous: null,
            fetchedAt: DateTime.now().toUtc(),
          ),
        );

        // Run sync with budget of only 1 request, so it stops after page 1 (incomplete)
        final budget = SyncBudget(maxRequests: 1);
        final result = await adapter.sync(
          accountId: "local-user",
          budget: budget,
        );

        expect(result.isSuccess, isTrue);
        expect(result.isComplete, isFalse);

        // INVARIANT CHECK: Series 10 must NOT be deactivated because scan was incomplete
        final sub10 = await subscriptionDao.getBySeriesId(10);
        expect(sub10, isNotNull);
        expect(sub10!.isActive, isTrue);
        expect(sub10.deletedAt, isNull);

        // Now complete the scan (page 2 with next: null, only containing series 20)
        when(
          () => mockPullListRemote.getPullListSeriesPage(pageUrl: page2Uri),
        ).thenAnswer(
          (_) async => RemotePage<PullListSeriesDto>(
            items: const [],
            count: 2,
            next: null,
            previous: null,
            fetchedAt: DateTime.now().toUtc(),
          ),
        );

        final completeBudget = SyncBudget(maxRequests: 5);
        final completeResult = await adapter.sync(
          accountId: "local-user",
          budget: completeBudget,
        );

        expect(completeResult.isSuccess, isTrue);
        expect(completeResult.isComplete, isTrue);

        // AFTER full authoritative scan completion, Series 10 was missing from remote -> deactivated
        final sub10Reconciled = await subscriptionDao.getBySeriesId(10);
        expect(sub10Reconciled!.isActive, isFalse);
        expect(sub10Reconciled.deletedAt, isNotNull);
      },
    );
  });

  group("SyncEngine concurrency and outbox integration", () {
    test("outbox drainage releases dependent operations", () async {
      final outboxDao = db.outboxDao;
      final dispatcher = OutboxRemoteDispatcher(
        collectionRemote: mockCollectionRemote,
        pullListRemote: mockPullListRemote,
        wishlistRemote: mockWishlistRemote,
      );
      final projectionApplier = OutboxProjectionApplier(db);
      final executor = OutboxExecutor(
        db: db,
        outboxDao: outboxDao,
        dispatcher: dispatcher,
        projectionApplier: projectionApplier,
      );

      // 1. Create collection item in outbox
      final createOp = await outboxDao.coalesceCreate(
        accountId: "local-user",
        entityType: OutboxEntityType.collection,
        entityLocalId: "lib-500",
        coalesceKey: "collection:lib-500",
        payload: {"issue_id": 500, "quantity": 1},
      );

      // Claim create so it enters 'running' state (in-flight network call)
      final claimedCreate = await outboxDao.claimNextReady(
        accountId: "local-user",
      );
      expect(claimedCreate, isNotNull);
      expect(claimedCreate!.id, createOp.id);

      // 2. User edits/patches while create is in-flight
      final patchOp = await outboxDao.coalescePatch(
        accountId: "local-user",
        entityType: OutboxEntityType.collection,
        entityLocalId: "lib-500",
        entityRemoteId: null, // Still unsynced
        coalesceKey: "collection:lib-500",
        payload: {"rating": 5},
      );

      // Verify patch depends on in-flight create
      expect(patchOp!.dependsOnId, createOp.id);

      // At this point, patch cannot be claimed because it is dependent on create
      final nextReadyBeforeCreateDone = await outboxDao.claimNextReady(
        accountId: "local-user",
      );
      expect(nextReadyBeforeCreateDone, isNull);

      // Reset createOp to retry/pending for executor drainage test
      await outboxDao.updateState(createOp.id, state: OutboxState.pending);

      // Mock remote create returning remoteId: 777
      when(
        () => mockCollectionRemote.addToCollection(
          issueId: 500,
          quantity: 1,
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
          id: 777,
          issueId: 500,
          seriesId: 50,
          seriesName: "Hulk",
          issueNumber: "1",
          modified: "2026-10-26T12:00:00.000Z",
        ),
      );

      // Mock remote patch on 777
      when(
        () => mockCollectionRemote.updateCollectionItem(777, {"rating": 5}),
      ).thenAnswer(
        (_) async => const CollectionItemDto(
          id: 777,
          issueId: 500,
          seriesId: 50,
          seriesName: "Hulk",
          issueNumber: "1",
          rating: 5,
          modified: "2026-10-26T12:01:00.000Z",
        ),
      );

      // Drain outbox
      final drainResult = await executor.drain(accountId: "local-user");
      expect(drainResult.completedCount, 2);
      expect(drainResult.blockedCount, 0);
      expect(drainResult.retryCount, 0);

      // Verify both ops marked done
      final remaining = await outboxDao.getReady(accountId: "local-user");
      expect(remaining, isEmpty);
    });

    test(
      "SyncEngine rejects second concurrent engine run with alreadyRunning",
      () async {
        final engine1 = SyncEngine(
          leaseDao: db.syncLeaseDao,
          jobDao: db.syncJobDao,
          outboxDao: db.outboxDao,
          outboxExecutor: OutboxExecutor(
            db: db,
            outboxDao: db.outboxDao,
            dispatcher: OutboxRemoteDispatcher(
              collectionRemote: mockCollectionRemote,
              pullListRemote: mockPullListRemote,
              wishlistRemote: mockWishlistRemote,
            ),
            projectionApplier: OutboxProjectionApplier(db),
          ),
          adapters: const [],
          runnerId: "runner-1",
        );

        final engine2 = SyncEngine(
          leaseDao: db.syncLeaseDao,
          jobDao: db.syncJobDao,
          outboxDao: db.outboxDao,
          outboxExecutor: OutboxExecutor(
            db: db,
            outboxDao: db.outboxDao,
            dispatcher: OutboxRemoteDispatcher(
              collectionRemote: mockCollectionRemote,
              pullListRemote: mockPullListRemote,
              wishlistRemote: mockWishlistRemote,
            ),
            projectionApplier: OutboxProjectionApplier(db),
          ),
          adapters: const [],
          runnerId: "runner-2",
        );

        // Acquire lease manually for runner 1
        await db.syncLeaseDao.tryAcquire(
          name: "metron:local-user",
          ownerId: "runner-1",
          ttl: const Duration(minutes: 5),
        );

        // Engine 2 attempts to run work
        final result2 = await engine2.runDueWork(trigger: "worker");
        expect(result2.wasAlreadyRunning, isTrue);

        engine1.dispose();
        engine2.dispose();
      },
    );
  });
}
