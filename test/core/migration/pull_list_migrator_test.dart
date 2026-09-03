import "package:drift/drift.dart" hide isNull, isNotNull;
import "package:drift/native.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:takion/src/core/migration/pull_list_migrator.dart";
import "package:takion/src/data/common/drift/database.dart";
import "package:takion/src/data/pull_list/datasources/remote/metron_pull_list_remote_data_source.dart";
import "package:takion/src/data/pull_list/dto/pull_list_dto.dart";

class MockMetronPullListRemoteDataSource extends Mock
    implements MetronPullListRemoteDataSource {}

void main() {
  group("PullListMigrator", () {
    late AppDatabase database;
    late MockMetronPullListRemoteDataSource remoteDataSource;
    late PullListMigrator migrator;

    setUp(() {
      database = AppDatabase.forTesting(NativeDatabase.memory());
      remoteDataSource = MockMetronPullListRemoteDataSource();
      migrator = PullListMigrator(
        database: database,
        remoteDataSource: remoteDataSource,
      );
    });

    tearDown(() async {
      await database.close();
    });

    test("migrate pushes active subscriptions without Metron ID", () async {
      await database.subscriptionDao.upsert(
        const SeriesSubscriptionsCompanion(
          id: Value("sub-50"),
          userId: Value("local-user"),
          metronSeriesId: Value(50),
          metronPullListId: Value(null),
          syncStatus: Value("pending"),
          isActive: Value(true),
          autoAddPull: Value(true),
          subscribedAt: Value("2026-09-01T00:00:00Z"),
          createdAt: Value("2026-09-01T00:00:00Z"),
          updatedAt: Value("2026-09-01T00:00:00Z"),
        ),
      );

      when(
        () => remoteDataSource.addSeriesToPullList(50),
      ).thenAnswer(
        (_) async => const PullListSeriesDto(
          id: 888,
          seriesId: 50,
          seriesName: "Spider-Man",
        ),
      );

      final count = await migrator.countUnmigrated();
      expect(count, 1);

      final migrated = await migrator.migrate();
      expect(migrated, 1);

      final updated = await database.subscriptionDao.getBySeriesId(50);
      expect(updated!.metronPullListId, 888);
      expect(updated.syncStatus, "synced");
    });
  });
}
