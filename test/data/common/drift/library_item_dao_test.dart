import "package:drift/drift.dart";
import "package:drift/native.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_test/flutter_test.dart";
import "package:takion/src/core/storage/drift_database_provider.dart";
import "package:takion/src/data/common/drift/database.dart";
import "package:takion/src/data/common/drift/daos/library_item_dao.dart";
import "package:takion/src/presentation/features/issues/providers/issue_collection_status_model.dart";
import "package:takion/src/presentation/features/library/providers/collection_status_cache_provider.dart";

LibraryItemsCompanion _item({
  required int issueId,
  String ownershipStatus = "not_owned",
  bool isRead = false,
}) {
  final now = DateTime.now().toUtc().toIso8601String();
  return LibraryItemsCompanion(
    id: Value("lib-$issueId"),
    userId: const Value("local-user"),
    metronIssueId: Value(issueId),
    metronSeriesId: const Value(1),
    ownershipStatus: Value(ownershipStatus),
    isRead: Value(isRead),
    format: const Value("print"),
    createdAt: Value(now),
    updatedAt: Value(now),
  );
}

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group("watchStatusRows", () {
    test(
      "emits initial rows and re-emits when a library item changes",
      () async {
        final emissions = <List<LibraryItemStatusRow>>[];
        final sub = db.libraryItemDao.watchStatusRows().listen(emissions.add);

        await db.libraryItemDao.batchUpsert([_item(issueId: 42)]);
        await db.libraryItemDao.batchUpsert([
          _item(issueId: 42, ownershipStatus: "owned", isRead: true),
        ]);

        await pumpEventQueue();
        await sub.cancel();

        expect(emissions, isNotEmpty);
        final latest = emissions.last;
        expect(latest, hasLength(1));
        expect(latest.first.metronIssueId, 42);
        expect(latest.first.ownershipStatus, "owned");
        expect(latest.first.isRead, isTrue);
      },
    );
  });

  group("collectionStatusCacheProvider", () {
    test("reflects library mutations without manual invalidation", () async {
      final container = ProviderContainer(
        overrides: [driftDatabaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);

      final statuses = <Map<int, IssueCollectionStatus>?>[];
      final sub = container.listen(collectionStatusCacheProvider, (_, next) {
        statuses.add(next.value);
      });

      await db.libraryItemDao.batchUpsert([_item(issueId: 7)]);

      final before = await container.read(collectionStatusCacheProvider.future);
      expect(before[7]?.isCollected, isFalse);

      await db.libraryItemDao.batchUpsert([
        _item(issueId: 7, ownershipStatus: "owned"),
      ]);

      final deadline = DateTime.now().add(const Duration(seconds: 5));
      while (DateTime.now().isBefore(deadline)) {
        await pumpEventQueue();
        final current = container.read(collectionStatusCacheProvider).value;
        if (current?[7]?.isCollected == true) break;
      }

      final after = container.read(collectionStatusCacheProvider).value;
      expect(after?[7]?.isCollected, isTrue);

      final lastEmission = statuses.lastWhere((s) => s != null);
      expect(lastEmission?[7]?.isCollected, isTrue);

      sub.close();
    });
  });

  group("watchHydratedItems and getHydratedItems", () {
    test("returns joined items with issue and series metadata", () async {
      final now = DateTime.now().toUtc().toIso8601String();
      await db.metronEntityDao.upsertSeriesStubsBatch([
        MetronSeriesCompanion.insert(
          id: const Value(100),
          name: "Batman",
          volume: const Value(1),
          yearBegan: const Value(1940),
          issueCount: const Value(713),
          computedCoverUrl: const Value(
            "https://metron.cloud/media/batman.jpg",
          ),
        ),
      ]);

      await db.metronEntityDao.upsertIssueStubsBatch([
        MetronIssuesCompanion.insert(
          id: const Value(500),
          seriesId: const Value(100),
          number: "1",
          imageUrl: const Value("https://metron.cloud/media/issue1.jpg"),
        ),
      ]);

      await db.libraryItemDao.batchUpsert([
        LibraryItemsCompanion(
          id: const Value("lib-500"),
          userId: const Value("local-user"),
          metronIssueId: const Value(500),
          metronSeriesId: const Value(100),
          ownershipStatus: const Value("owned"),
          isRead: const Value(true),
          rating: const Value(5),
          format: const Value("print"),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      ]);

      final hydrated = await db.libraryItemDao.getHydratedItems(
        ownershipStatus: "owned",
      );
      expect(hydrated, hasLength(1));
      expect(hydrated.first.libraryItem.metronIssueId, 500);
      expect(hydrated.first.issue?.number, "1");
      expect(
        hydrated.first.issue?.imageUrl,
        "https://metron.cloud/media/issue1.jpg",
      );
      expect(hydrated.first.series?.name, "Batman");
      expect(
        hydrated.first.series?.computedCoverUrl,
        "https://metron.cloud/media/batman.jpg",
      );

      final seriesSummaries = await db.libraryItemDao
          .getSeriesSummariesByCategory(ownershipStatus: "owned");
      expect(seriesSummaries, hasLength(1));
      expect(seriesSummaries.first.seriesId, 100);
      expect(seriesSummaries.first.seriesName, "Batman");
      expect(
        seriesSummaries.first.computedCoverUrl,
        "https://metron.cloud/media/batman.jpg",
      );
    });
  });
}
