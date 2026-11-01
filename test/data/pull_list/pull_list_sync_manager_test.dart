import "dart:async";

import "package:dio/dio.dart";
import "package:drift/drift.dart" hide isNotNull, isNull;
import "package:drift/native.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:takion/src/core/network/remote_page.dart";
import "package:takion/src/data/common/drift/database.dart";
import "package:takion/src/data/pull_list/sync/pull_list_sync_manager.dart";
import "package:takion/src/domain/pull_list/entities/pull_list_item.dart";
import "package:takion/src/domain/pull_list/repositories/pull_list_repository.dart";

class MockPullListRepository extends Mock implements MetronPullListRepository {}

RemotePage<T> testPage<T>(List<T> items, {Uri? next, int? count}) =>
    RemotePage<T>(
      items: items,
      count: count ?? items.length,
      next: next,
      previous: null,
      fetchedAt: DateTime.now(),
    );

DioException notFound(String path) {
  final req = RequestOptions(path: path);
  return DioException(
    requestOptions: req,
    response: Response(statusCode: 404, requestOptions: req),
    type: DioExceptionType.badResponse,
  );
}

void main() {
  group("PullListSyncManager", () {
    late AppDatabase database;
    late MockPullListRepository mockRepository;
    late PullListSyncManager syncManager;

    setUp(() {
      database = AppDatabase.forTesting(NativeDatabase.memory());
      mockRepository = MockPullListRepository();
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
        when(
          () => mockRepository.getPullListSeriesPage(
            pageUrl: any(named: "pageUrl"),
          ),
        ).thenAnswer(
          (_) async => testPage([
            PullListSeriesItem(
              id: 10,
              seriesId: 100,
              seriesName: "Batman",
              addedOn: DateTime.parse("2026-09-01T00:00:00Z"),
            ),
          ]),
        );

        when(
          () => mockRepository.getPullListIssuesPage(
            pageUrl: any(named: "pageUrl"),
            storeDateAfter: any(named: "storeDateAfter"),
            storeDateBefore: any(named: "storeDateBefore"),
          ),
        ).thenAnswer(
          (_) async => testPage([
            PullListIssueItem(
              id: 20,
              issueId: 501,
              seriesId: 100,
              seriesName: "Batman",
              issueNumber: "1",
              storeDate: DateTime.parse("2026-09-10T00:00:00Z"),
            ),
          ]),
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

        verify(
          () => mockRepository.getPullListSeriesPage(pageUrl: null),
        ).called(1);
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

      when(
        () => mockRepository.getPullListSeriesPage(
          pageUrl: any(named: "pageUrl"),
        ),
      ).thenAnswer(
        (_) async => testPage([
          PullListSeriesItem(
            id: 10,
            seriesId: 100,
            seriesName: "Batman",
            addedOn: DateTime.parse("2026-09-01T00:00:00Z"),
          ),
        ]),
      );

      when(
        () => mockRepository.getPullListIssuesPage(
          pageUrl: any(named: "pageUrl"),
          storeDateAfter: any(named: "storeDateAfter"),
          storeDateBefore: any(named: "storeDateBefore"),
        ),
      ).thenAnswer((_) async => testPage(const []));

      final result = await syncManager.syncPullList();

      expect(result.isSuccess, isTrue);

      final sub = await database.subscriptionDao.getBySeriesId(100);
      expect(sub!.isActive, isFalse);
      expect(sub.syncStatus, "pending");
    });

    test(
      "syncPullList paginates series and issues past full pages and stamps the cursor",
      () async {
        final seriesPage2 = Uri.parse(
          "https://metron.cloud/api/pull_list/series/?page=2",
        );
        when(
          () => mockRepository.getPullListSeriesPage(pageUrl: null),
        ).thenAnswer(
          (_) async => testPage(
            List.generate(
              20,
              (i) => PullListSeriesItem(
                id: 100 + i,
                seriesId: 1000 + i,
                seriesName: "Series $i",
              ),
            ),
            next: seriesPage2,
          ),
        );
        when(
          () => mockRepository.getPullListSeriesPage(pageUrl: seriesPage2),
        ).thenAnswer(
          (_) async => testPage(const [
            PullListSeriesItem(id: 999, seriesId: 1999, seriesName: "Last"),
          ]),
        );

        final issuesPage2 = Uri.parse(
          "https://metron.cloud/api/pull_list/issue/?page=2",
        );
        when(
          () => mockRepository.getPullListIssuesPage(
            pageUrl: null,
            storeDateAfter: any(named: "storeDateAfter"),
            storeDateBefore: any(named: "storeDateBefore"),
          ),
        ).thenAnswer(
          (_) async => testPage(
            List.generate(
              20,
              (i) => PullListIssueItem(
                id: 500 + i,
                issueId: 9000 + i,
                seriesId: 1000,
                seriesName: "Series 0",
                issueNumber: "$i",
              ),
            ),
            next: issuesPage2,
          ),
        );
        when(
          () => mockRepository.getPullListIssuesPage(
            pageUrl: issuesPage2,
            storeDateAfter: any(named: "storeDateAfter"),
            storeDateBefore: any(named: "storeDateBefore"),
          ),
        ).thenAnswer(
          (_) async => testPage(
            List.generate(
              3,
              (i) => PullListIssueItem(
                id: 900 + i,
                issueId: 9500 + i,
                seriesId: 1000,
                seriesName: "Series 0",
                issueNumber: "$i",
              ),
            ),
          ),
        );

        final result = await syncManager.syncPullList(forceFullSync: true);

        expect(result.isSuccess, isTrue);
        expect(result.seriesFetched, 21);
        expect(result.issuesFetched, 23);

        verify(
          () => mockRepository.getPullListSeriesPage(pageUrl: seriesPage2),
        ).called(1);
        verify(
          () => mockRepository.getPullListIssuesPage(
            pageUrl: issuesPage2,
            storeDateAfter: any(named: "storeDateAfter"),
            storeDateBefore: any(named: "storeDateBefore"),
          ),
        ).called(1);

        expect(
          await database.syncMetaDao.get("metron_last_pull_list_sync"),
          isNotNull,
        );
      },
    );

    test(
      "a failed issues phase must not advance the pull list cursor",
      () async {
        const seededCursor = "2026-09-01T00:00:00.000Z";
        await database.syncMetaDao.set(
          "metron_last_pull_list_sync",
          seededCursor,
        );

        when(
          () => mockRepository.getPullListSeriesPage(
            pageUrl: any(named: "pageUrl"),
          ),
        ).thenAnswer(
          (_) async => testPage([
            PullListSeriesItem(
              id: 10,
              seriesId: 100,
              seriesName: "Batman",
              addedOn: DateTime.parse("2026-09-01T00:00:00Z"),
            ),
          ]),
        );
        when(
          () => mockRepository.getPullListIssuesPage(
            pageUrl: any(named: "pageUrl"),
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
      },
    );

    test(
      "a 404 (no remote pull list) succeeds and stamps the cursor",
      () async {
        when(
          () => mockRepository.getPullListSeriesPage(
            pageUrl: any(named: "pageUrl"),
          ),
        ).thenThrow(notFound("/api/pull_list/series/"));

        final result = await syncManager.syncPullList();

        expect(result.isSuccess, isTrue);
        expect(result.isFullSync, isTrue);
        expect(await syncManager.getLastSyncTime(), isNotNull);
      },
    );

    test(
      "rejects a concurrent run instead of starting a second sync",
      () async {
        final seriesGate = Completer<RemotePage<PullListSeriesItem>>();
        var seriesCalls = 0;
        when(
          () => mockRepository.getPullListSeriesPage(
            pageUrl: any(named: "pageUrl"),
          ),
        ).thenAnswer((_) {
          seriesCalls++;
          return seriesGate.future;
        });
        when(
          () => mockRepository.getPullListIssuesPage(
            pageUrl: any(named: "pageUrl"),
            storeDateAfter: any(named: "storeDateAfter"),
            storeDateBefore: any(named: "storeDateBefore"),
          ),
        ).thenAnswer((_) async => testPage(const []));

        final first = syncManager.syncPullList();
        await Future<void>.delayed(Duration.zero);

        final second = await syncManager.syncPullList();
        expect(second.isSuccess, isFalse);
        expect(second.errorMessage, "Pull list sync already in progress");

        seriesGate.complete(testPage(const []));
        final firstResult = await first;
        expect(firstResult.isSuccess, isTrue);
        expect(seriesCalls, 1);
      },
    );

    test(
      "multi-page full sync keeps subscriptions from all pages active",
      () async {
        final page1Series = List.generate(
          20,
          (i) => PullListSeriesItem(
            id: i + 1,
            seriesId: 100 + i,
            seriesName: "Series $i",
            addedOn: DateTime.parse("2026-09-01T00:00:00Z"),
          ),
        );
        final page2Series = <PullListSeriesItem>[
          PullListSeriesItem(
            id: 21,
            seriesId: 121,
            seriesName: "Series 21",
            addedOn: DateTime.parse("2026-09-01T00:00:00Z"),
          ),
        ];

        final page2Uri = Uri.parse(
          "https://metron.cloud/api/pull_list/series/?page=2",
        );
        when(
          () => mockRepository.getPullListSeriesPage(pageUrl: null),
        ).thenAnswer((_) async => testPage(page1Series, next: page2Uri));
        when(
          () => mockRepository.getPullListSeriesPage(pageUrl: page2Uri),
        ).thenAnswer((_) async => testPage(page2Series));
        when(
          () => mockRepository.getPullListIssuesPage(
            pageUrl: any(named: "pageUrl"),
            storeDateAfter: any(named: "storeDateAfter"),
            storeDateBefore: any(named: "storeDateBefore"),
          ),
        ).thenAnswer((_) async => testPage(const []));

        final result = await syncManager.syncPullList(forceFullSync: true);

        expect(result.isSuccess, isTrue);
        expect(result.seriesFetched, 21);

        // Verify page 1 series are active
        final sub0 = await database.subscriptionDao.getBySeriesId(100);
        expect(sub0, isNotNull);
        expect(sub0!.isActive, isTrue);

        final sub19 = await database.subscriptionDao.getBySeriesId(119);
        expect(sub19, isNotNull);
        expect(sub19!.isActive, isTrue);

        // Verify page 2 series is also active
        final sub21 = await database.subscriptionDao.getBySeriesId(121);
        expect(sub21, isNotNull);
        expect(sub21!.isActive, isTrue);
      },
    );
  });
}
