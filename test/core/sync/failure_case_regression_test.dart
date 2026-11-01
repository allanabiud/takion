import "package:drift/drift.dart" hide isNull, isNotNull;
import "package:drift/native.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:takion/src/core/cache/cache_mode.dart";
import "package:takion/src/core/commands/outbox_constants.dart";
import "package:takion/src/core/network/conditional_interceptor.dart";
import "package:takion/src/core/network/remote_page.dart";
import "package:takion/src/data/collection/datasources/remote/metron_collection_remote_data_source.dart";
import "package:takion/src/data/collection/sync/collection_sync_manager.dart";
import "package:takion/src/data/common/drift/daos/outbox_dao.dart";
import "package:takion/src/data/common/drift/database.dart";
import "package:takion/src/data/pull_list/datasources/remote/metron_pull_list_remote_data_source.dart";
import "package:takion/src/data/pull_list/sync/pull_list_sync_manager.dart";
import "package:takion/src/data/wishlist/datasources/remote/metron_wishlist_remote_data_source.dart";
import "package:takion/src/domain/collection/entities/collection_item.dart";
import "package:takion/src/domain/collection/repositories/collection_repository.dart";
import "package:takion/src/domain/pull_list/entities/pull_list_item.dart";
import "package:takion/src/domain/pull_list/repositories/pull_list_repository.dart";
import "package:dio/dio.dart";

class MockCollectionRepository extends Mock implements CollectionRepository {}

class MockPullListRepository extends Mock implements MetronPullListRepository {}

class MockCollectionRemoteDataSource extends Mock
    implements MetronCollectionRemoteDataSource {}

class MockPullListRemoteDataSource extends Mock
    implements MetronPullListRemoteDataSource {}

class MockWishlistRemoteDataSource extends Mock
    implements MetronWishlistRemoteDataSource {}

class CapturingRequestHandler extends RequestInterceptorHandler {
  RequestOptions? captured;

  @override
  void next(RequestOptions requestOptions) {
    captured = requestOptions;
  }
}

class CapturingResponseHandler extends ResponseInterceptorHandler {
  Response? captured;

  @override
  void next(Response response) {
    captured = response;
  }

  @override
  void resolve(Response response) {
    captured = response;
  }
}

RemotePage<T> buildPage<T>(List<T> items, {Uri? next}) => RemotePage<T>(
  items: items,
  count: items.length,
  next: next,
  previous: null,
  fetchedAt: DateTime.now().toUtc(),
);

void main() {
  group("Core Failure Cases & Safety Rail Regression Tests", () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    // -------------------------------------------------------------------------
    // 1. Page-size termination is unsafe
    // -------------------------------------------------------------------------
    test(
      "Failure Case 1: Page-size termination is unsafe; pagination must follow 'next' link even when count is below nominal page size",
      () async {
        final mockRepo = MockCollectionRepository();
        final syncManager = CollectionSyncManager(
          database: db,
          collectionRepository: mockRepo,
        );

        // Server returns page 1 with only 12 items (e.g. filtered), but has next link!
        final page2Url = Uri.parse(
          "https://metron.cloud/api/collection/issue/?page=2",
        );
        when(
          () => mockRepo.getCollectionPage(
            pageUrl: null,
            modifiedGt: any(named: "modifiedGt"),
          ),
        ).thenAnswer(
          (_) async => buildPage(
            List.generate(
              12,
              (i) => CollectionItem(
                id: i + 1,
                issue: CollectionIssueRef(
                  id: 100 + i,
                  number: "$i",
                  series: const CollectionIssueSeriesRef(id: 1, name: "S"),
                ),
                quantity: 1,
              ),
            ),
            next: page2Url,
          ),
        );

        when(
          () => mockRepo.getCollectionPage(
            pageUrl: page2Url,
            modifiedGt: any(named: "modifiedGt"),
          ),
        ).thenAnswer(
          (_) async => buildPage([
            const CollectionItem(
              id: 13,
              issue: CollectionIssueRef(
                id: 200,
                number: "13",
                series: CollectionIssueSeriesRef(id: 1, name: "S"),
              ),
              quantity: 1,
            ),
          ], next: null),
        );

        final result = await syncManager.syncCollection(forceFullSync: true);

        // A naive `items.length < 20` check would have stopped after page 1 (12 items).
        // With next-URL pagination, it correctly fetches all 13 items.
        expect(result.itemsFetched, 13);
        verify(
          () => mockRepo.getCollectionPage(
            pageUrl: page2Url,
            modifiedGt: any(named: "modifiedGt"),
          ),
        ).called(1);
      },
    );

    // -------------------------------------------------------------------------
    // 2. 304 list decoding
    // -------------------------------------------------------------------------
    test(
      "Failure Case 2: 304 response restores cached body so JSON decoders never encounter empty body",
      () async {
        const cacheKey = "/api/collection/";
        const cachedJson = '{"count": 1, "results": [{"id": 42}]}';

        await db.remoteCacheDao.upsertEntry(
          accountId: "default",
          cacheKey: cacheKey,
          etag: '"etag-123"',
          payloadJson: cachedJson,
          fetchedAt: DateTime.now().toUtc(),
          staleAt: DateTime.now().toUtc().add(const Duration(hours: 1)),
        );

        final interceptor = ConditionalRequestInterceptor(
          db,
          defaultAccountId: "default",
        );
        final requestOptions = RequestOptions(
          method: "GET",
          path: "https://metron.cloud$cacheKey",
          extra: const CacheRequestOptions(
            cacheKey: cacheKey,
            accountId: "default",
          ).toExtra(),
        );

        final reqHandler = CapturingRequestHandler();
        await interceptor.onRequest(requestOptions, reqHandler);

        // Simulate 304 Not Modified response with empty body from server
        final response304 = Response<dynamic>(
          requestOptions: reqHandler.captured ?? requestOptions,
          statusCode: 304,
          data: "",
          headers: Headers.fromMap({
            "etag": ['"etag-123"'],
          }),
        );

        final handler = CapturingResponseHandler();
        await interceptor.onResponse(response304, handler);

        expect(handler.captured, isNotNull);
        // Body was transparently restored from cached entry rather than returning empty ""
        expect(handler.captured!.data, isA<Map<String, dynamic>>());
        expect((handler.captured!.data as Map)["count"], 1);
      },
    );

    // -------------------------------------------------------------------------
    // 3. Interrupted delta run must not advance cursor
    // -------------------------------------------------------------------------
    test(
      "Failure Case 3: Interrupted delta run preserves existing watermark and does not advance cursor",
      () async {
        const initialWatermark = "2026-10-01T00:00:00.000Z";
        await db.syncMetaDao.set(
          "metron_last_collection_sync",
          initialWatermark,
        );

        final mockRepo = MockCollectionRepository();
        final syncManager = CollectionSyncManager(
          database: db,
          collectionRepository: mockRepo,
        );

        // Page 1 succeeds with next link; page 2 throws network error
        final page2Url = Uri.parse(
          "https://metron.cloud/api/collection/issue/?page=2",
        );
        when(
          () => mockRepo.getCollectionPage(
            pageUrl: null,
            modifiedGt: DateTime.parse(initialWatermark),
          ),
        ).thenAnswer(
          (_) async => buildPage([
            const CollectionItem(
              id: 1,
              issue: CollectionIssueRef(
                id: 101,
                number: "1",
                series: CollectionIssueSeriesRef(id: 1, name: "Batman"),
              ),
              quantity: 1,
            ),
          ], next: page2Url),
        );

        when(
          () => mockRepo.getCollectionPage(
            pageUrl: page2Url,
            modifiedGt: any(named: "modifiedGt"),
          ),
        ).thenThrow(Exception("Process interrupted / connection reset"));

        final result = await syncManager.syncCollection();
        expect(result.isSuccess, isFalse);

        // Cursor must remain at initialWatermark so un-fetched pages are not skipped on retry
        final storedCursor = await db.syncMetaDao.get(
          "metron_last_collection_sync",
        );
        expect(storedCursor, initialWatermark);
      },
    );

    // -------------------------------------------------------------------------
    // 4. Unsupported pull/wish modified_gt safety
    // -------------------------------------------------------------------------
    test(
      "Failure Case 4: Pull list sync does not pass modified_gt to Metron pull endpoints and requires complete scan before deletion",
      () async {
        final mockRepo = MockPullListRepository();
        final syncManager = PullListSyncManager(
          database: db,
          pullListRepository: mockRepo,
        );

        // Seed an existing local subscription
        await db.subscriptionDao.upsert(
          const SeriesSubscriptionsCompanion(
            id: Value("sub-1"),
            userId: Value("user"),
            metronSeriesId: Value(999),
            metronPullListId: Value(10),
            syncStatus: Value("synced"),
            isActive: Value(true),
            autoAddPull: Value(true),
            subscribedAt: Value("2026-01-01T00:00:00Z"),
            createdAt: Value("2026-01-01T00:00:00Z"),
            updatedAt: Value("2026-01-01T00:00:00Z"),
          ),
        );

        // Simulate page 1 succeeds with 20 items, but page 2 fails
        final page2Url = Uri.parse(
          "https://metron.cloud/api/pull_list/series/?page=2",
        );
        when(() => mockRepo.getPullListSeriesPage(pageUrl: null)).thenAnswer(
          (_) async => buildPage([
            PullListSeriesItem(
              id: 1,
              seriesId: 101,
              seriesName: "Series 101",
              addedOn: DateTime.parse("2026-01-01T00:00:00Z"),
            ),
          ], next: page2Url),
        );

        when(
          () => mockRepo.getPullListSeriesPage(pageUrl: page2Url),
        ).thenThrow(Exception("Failed on page 2"));

        final result = await syncManager.syncPullList(forceFullSync: true);
        expect(result.isSuccess, isFalse);

        // Subscription 999 must NOT be deleted or deactivated because the scan did not complete!
        final sub = await db.subscriptionDao.getBySeriesId(999);
        expect(sub, isNotNull);
        expect(sub!.isActive, isTrue);
      },
    );

    // -------------------------------------------------------------------------
    // 5. Create -> Edit identity dependency
    // -------------------------------------------------------------------------
    test(
      "Failure Case 5: Dependent edit operation waits for create operation and inherits remote ID",
      () async {
        final outboxDao = OutboxDao(db);

        // 1. Enqueue create operation
        const createOpId = "op-create-1";
        const editOpId = "op-edit-2";
        const localIssueId = "local-uuid-42";

        await outboxDao.upsert(
          OutboxOperationsCompanion(
            id: const Value(createOpId),
            accountId: const Value("default"),
            entityType: const Value("collection"),
            entityLocalId: const Value(localIssueId),
            operation: const Value(OutboxOperationType.create),
            payloadJson: const Value('{"issue_id": 5001}'),
            coalesceKey: const Value("collection:$localIssueId"),
            state: const Value(OutboxState.pending),
            createdAt: Value(DateTime.utc(2026, 1, 1, 10, 0)),
            updatedAt: Value(DateTime.utc(2026, 1, 1, 10, 0)),
          ),
        );

        // 2. Enqueue edit operation depending on create operation
        await outboxDao.upsert(
          OutboxOperationsCompanion(
            id: const Value(editOpId),
            accountId: const Value("default"),
            entityType: const Value("collection"),
            entityLocalId: const Value(localIssueId),
            operation: const Value(OutboxOperationType.patch),
            payloadJson: const Value('{"is_read": true}'),
            coalesceKey: const Value("collection:$localIssueId"),
            dependsOnId: const Value(createOpId), // Dependent!
            state: const Value(OutboxState.pending),
            createdAt: Value(DateTime.utc(2026, 1, 1, 10, 1)),
            updatedAt: Value(DateTime.utc(2026, 1, 1, 10, 1)),
          ),
        );

        // Before create completes, edit is blocked and cannot be dispatched independently
        final readyBefore = await outboxDao.getReady(accountId: "default");
        expect(readyBefore.map((e) => e.id), contains(createOpId));
        expect(readyBefore.map((e) => e.id), isNot(contains(editOpId)));

        // When create completes and releases dependents with remote ID 999:
        await outboxDao.releaseDependents(createOpId, 999);
        final readyAfter = await outboxDao.getReady(accountId: "default");
        expect(readyAfter.map((e) => e.id), contains(editOpId));
        final unblockedEdit = await outboxDao.getById(editOpId);
        expect(unblockedEdit?.entityRemoteId, 999);
      },
    );
  });
}
