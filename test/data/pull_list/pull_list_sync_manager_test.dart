import "dart:async";

import "package:dio/dio.dart";
import "package:drift/drift.dart" hide isNotNull, isNull;
import "package:drift/native.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:takion/src/data/common/drift/database.dart";
import "package:takion/src/data/pull_list/sync/pull_list_sync_manager.dart";
import "package:takion/src/domain/pull_list/entities/pull_list_item.dart";
import "package:takion/src/domain/pull_list/repositories/pull_list_repository.dart";

class MockMetronPullListRepository extends Mock
    implements MetronPullListRepository {}

DioException notFound(String path) {
  final options = RequestOptions(path: path);
  return DioException(
    requestOptions: options,
    response: Response(requestOptions: options, statusCode: 404),
    type: DioExceptionType.badResponse,
  );
}

void main() {
  group("PullListSyncManager", () {
    late AppDatabase database;
    late MockMetronPullListRepository mockRepository;
    late PullListSyncManager syncManager;

    setUp(() {
      database = AppDatabase.forTesting(NativeDatabase.memory());
      mockRepository = MockMetronPullListRepository();
      syncManager = PullListSyncManager(
        database: database,
        pullListRepository: mockRepository,
      );
    });

    tearDown(() async {
      await database.close();
    });

    test(
      "syncPullList syncs remote series and issues into local database",
      () async {
        when(() => mockRepository.getPullListSeries(page: 1)).thenAnswer(
          (_) async => [
            PullListSeriesItem(
              id: 10,
              seriesId: 100,
              seriesName: "Batman",
              addedOn: DateTime.parse("2026-09-01T00:00:00Z"),
            ),
          ],
        );

        when(
          () => mockRepository.getPullListIssues(
            page: 1,
            storeDateAfter: any(named: "storeDateAfter"),
            storeDateBefore: any(named: "storeDateBefore"),
          ),
        ).thenAnswer(
          (_) async => [
            PullListIssueItem(
              id: 20,
              issueId: 501,
              seriesId: 100,
              seriesName: "Batman",
              issueNumber: "1",
              storeDate: DateTime.parse("2026-09-10T00:00:00Z"),
            ),
          ],
        );

        final result = await syncManager.syncPullList();

        expect(result.isSuccess, isTrue);
        expect(result.seriesFetched, 1);
        expect(result.issuesFetched, 1);

        // Verify subscription row
        final sub = await database.subscriptionDao.getBySeriesId(100);
        expect(sub, isNotNull);
        expect(sub!.isActive, isTrue);
        expect(sub.metronPullListId, 10);
        expect(sub.syncStatus, "synced");

        // Verify pull list entry row
        final pull = await database.pullListDao.getByIssueId(501);
        expect(pull, isNotNull);
        expect(pull!.metronSeriesId, 100);
        expect(pull.metronPullListId, 20);
        expect(pull.syncStatus, "synced");
        expect(pull.entryStatus, "upcoming");

        // Full sync reconciliation occurs during the initial pagination pass.
        // Do not re-fetch the same series page after it has been ingested.
        verify(() => mockRepository.getPullListSeries(page: 1)).called(1);
      },
    );

    test("syncPullList preserves pending local subscriptions", () async {
      // Setup local subscription pending removal
      await database.subscriptionDao.upsert(
        const SeriesSubscriptionsCompanion(
          id: Value("sub-100"),
          userId: Value("local-user"),
          metronSeriesId: Value(100),
          metronPullListId: Value(10),
          syncStatus: Value("pending"),
          isActive: Value(false),
          autoAddPull: Value(true),
          subscribedAt: Value("2026-09-01T00:00:00Z"),
          createdAt: Value("2026-09-01T00:00:00Z"),
          updatedAt: Value("2026-09-04T00:00:00Z"),
        ),
      );

      when(() => mockRepository.getPullListSeries(page: 1)).thenAnswer(
        (_) async => [
          PullListSeriesItem(
            id: 10,
            seriesId: 100,
            seriesName: "Batman",
            addedOn: DateTime.parse("2026-09-01T00:00:00Z"),
          ),
        ],
      );

      when(
        () => mockRepository.getPullListIssues(
          page: 1,
          storeDateAfter: any(named: "storeDateAfter"),
          storeDateBefore: any(named: "storeDateBefore"),
        ),
      ).thenAnswer((_) async => []);

      final result = await syncManager.syncPullList();

      expect(result.isSuccess, isTrue);

      final sub = await database.subscriptionDao.getBySeriesId(100);
      expect(sub!.isActive, isFalse);
      expect(sub.syncStatus, "pending");
    });

    test(
      "syncPullList paginates series and issues past full pages and stamps the cursor",
      () async {
        when(
          () => mockRepository.getPullListSeries(
            page: any(named: "page"),
            modifiedGt: any(named: "modifiedGt"),
          ),
        ).thenAnswer((invocation) async {
          final page = invocation.namedArguments[#page] as int;
          if (page == 1) {
            return List.generate(
              20, // Metron page size
              (i) => PullListSeriesItem(
                id: 100 + i,
                seriesId: 1000 + i,
                seriesName: "Series $i",
              ),
            );
          }
          if (page == 2) {
            return const [
              PullListSeriesItem(id: 999, seriesId: 1999, seriesName: "Last"),
            ];
          }
          return const [];
        });

        when(
          () => mockRepository.getPullListIssues(
            page: any(named: "page"),
            storeDateAfter: any(named: "storeDateAfter"),
            storeDateBefore: any(named: "storeDateBefore"),
          ),
        ).thenAnswer((invocation) async {
          final page = invocation.namedArguments[#page] as int;
          if (page == 1) {
            return List.generate(
              20,
              (i) => PullListIssueItem(
                id: 500 + i,
                issueId: 9000 + i,
                seriesId: 1000,
                seriesName: "Series 0",
                issueNumber: "$i",
              ),
            );
          }
          if (page == 2) {
            return List.generate(
              3,
              (i) => PullListIssueItem(
                id: 900 + i,
                issueId: 9500 + i,
                seriesId: 1000,
                seriesName: "Series 0",
                issueNumber: "$i",
              ),
            );
          }
          return const [];
        });

        final result = await syncManager.syncPullList(forceFullSync: true);

        expect(result.isSuccess, isTrue);
        expect(result.seriesFetched, 21);
        expect(result.issuesFetched, 23);

        verify(
          () => mockRepository.getPullListSeries(
            page: 2,
            modifiedGt: any(named: "modifiedGt"),
          ),
        ).called(1);
        verify(
          () => mockRepository.getPullListIssues(
            page: 2,
            storeDateAfter: any(named: "storeDateAfter"),
            storeDateBefore: any(named: "storeDateBefore"),
          ),
        ).called(1);
        verifyNever(
          () => mockRepository.getPullListSeries(
            page: 3,
            modifiedGt: any(named: "modifiedGt"),
          ),
        );
        verifyNever(
          () => mockRepository.getPullListIssues(
            page: 3,
            storeDateAfter: any(named: "storeDateAfter"),
            storeDateBefore: any(named: "storeDateBefore"),
          ),
        );

        expect(
          await database.syncMetaDao.get("metron_last_pull_list_sync"),
          isNotNull,
        );
      },
    );

    test("a failed issues phase must not advance the pull list cursor",
        () async {
      const seededCursor = "2026-09-01T00:00:00.000Z";
      await database.syncMetaDao.set(
        "metron_last_pull_list_sync",
        seededCursor,
      );

      when(() => mockRepository.getPullListSeries(
            page: any(named: "page"),
            modifiedGt: any(named: "modifiedGt"),
          )).thenAnswer(
        (_) async => [
          PullListSeriesItem(
            id: 10,
            seriesId: 100,
            seriesName: "Batman",
            addedOn: DateTime.parse("2026-09-01T00:00:00Z"),
          ),
        ],
      );
      when(
        () => mockRepository.getPullListIssues(
          page: any(named: "page"),
          storeDateAfter: any(named: "storeDateAfter"),
          storeDateBefore: any(named: "storeDateBefore"),
        ),
      ).thenThrow(Exception("issues endpoint down"));

      final result = await syncManager.syncPullList();

      expect(result.isSuccess, isFalse);
      expect(result.errorMessage, contains("issues endpoint down"));

      // Cursor stays put even though the earlier series phase succeeded.
      expect(
        await database.syncMetaDao.get("metron_last_pull_list_sync"),
        seededCursor,
      );
      // Progress made by the completed phase is retained.
      expect(
        (await database.subscriptionDao.getBySeriesId(100))?.syncStatus,
        "synced",
      );
    });

    test("a 404 (no remote pull list) succeeds and stamps the cursor",
        () async {
      when(() => mockRepository.getPullListSeries(
            page: any(named: "page"),
            modifiedGt: any(named: "modifiedGt"),
          )).thenThrow(notFound("/api/pull_list/series/"));

      final result = await syncManager.syncPullList();

      expect(result.isSuccess, isTrue);
      expect(result.isFullSync, isTrue);
      expect(await syncManager.getLastSyncTime(), isNotNull);
    });

    test("rejects a concurrent run instead of starting a second sync",
        () async {
      final seriesGate = Completer<List<PullListSeriesItem>>();
      var seriesCalls = 0;
      when(() => mockRepository.getPullListSeries(
            page: any(named: "page"),
            modifiedGt: any(named: "modifiedGt"),
          )).thenAnswer((_) {
        seriesCalls++;
        return seriesGate.future;
      });
      when(
        () => mockRepository.getPullListIssues(
          page: any(named: "page"),
          storeDateAfter: any(named: "storeDateAfter"),
          storeDateBefore: any(named: "storeDateBefore"),
        ),
      ).thenAnswer((_) async => const []);

      final first = syncManager.syncPullList();
      await Future<void>.delayed(Duration.zero);

      final second = await syncManager.syncPullList();
      expect(second.isSuccess, isFalse);
      expect(second.errorMessage, "Pull list sync already in progress");

      seriesGate.complete(const []);
      final firstResult = await first;
      expect(firstResult.isSuccess, isTrue);
      expect(seriesCalls, 1);
    });
  });
}
