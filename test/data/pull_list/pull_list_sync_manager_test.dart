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

    test("syncPullList syncs remote series and issues into local database", () async {
      when(
        () => mockRepository.getPullListSeries(page: 1),
      ).thenAnswer(
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
    });

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
        () => mockRepository.getPullListSeries(page: 1),
      ).thenAnswer(
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
  });
}
