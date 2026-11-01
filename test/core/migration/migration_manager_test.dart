import "package:drift/native.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:takion/src/core/migration/collection_migrator.dart";
import "package:takion/src/core/migration/migration_manager.dart";
import "package:takion/src/core/migration/migration_state.dart";
import "package:takion/src/core/migration/pull_list_migrator.dart";
import "package:takion/src/data/common/drift/database.dart";

class MockCollectionMigrator extends Mock implements CollectionMigrator {}

class MockPullListMigrator extends Mock implements PullListMigrator {}

void main() {
  group("MigrationManager", () {
    late AppDatabase database;
    late MockCollectionMigrator colMigrator;
    late MockPullListMigrator pullMigrator;
    late MigrationManager manager;

    setUp(() {
      database = AppDatabase.forTesting(NativeDatabase.memory());
      colMigrator = MockCollectionMigrator();
      pullMigrator = MockPullListMigrator();

      manager = MigrationManager(
        database: database,
        collectionMigrator: colMigrator,
        pullListMigrator: pullMigrator,
      );
    });

    tearDown(() async {
      manager.dispose();
      await database.close();
    });

    test(
      "isMigrationNeeded returns true when unmigrated items exist",
      () async {
        when(() => colMigrator.countUnmigrated()).thenAnswer((_) async => 5);
        when(() => pullMigrator.countUnmigrated()).thenAnswer((_) async => 0);

        final needed = await manager.isMigrationNeeded();
        expect(needed, isTrue);
      },
    );

    test(
      "runMigration coordinates all migrators and marks completed",
      () async {
        when(() => colMigrator.countUnmigrated()).thenAnswer((_) async => 2);
        when(() => pullMigrator.countUnmigrated()).thenAnswer((_) async => 1);

        when(
          () => colMigrator.migrate(
            onProgress: any(named: "onProgress"),
            isCancelled: any(named: "isCancelled"),
          ),
        ).thenAnswer(
          (_) async => const MigrationResult(migrated: 2, failed: 0),
        );
        when(
          () => pullMigrator.migrate(
            onProgress: any(named: "onProgress"),
            isCancelled: any(named: "isCancelled"),
          ),
        ).thenAnswer(
          (_) async => const MigrationResult(migrated: 1, failed: 0),
        );

        final progress = await manager.runMigration();

        expect(progress.status, MigrationStatus.completed);
        expect(progress.migratedCollection, 2);
        expect(progress.migratedSubscriptions, 1);
        expect(progress.progressFraction, 1.0);

        final completed = await manager.isMigrationCompleted();
        expect(completed, isTrue);
      },
    );

    test("skipMigration marks completed in settings", () async {
      await manager.skipMigration();

      final completed = await manager.isMigrationCompleted();
      expect(completed, isTrue);
      expect(manager.currentProgress.status, MigrationStatus.skipped);
    });
  });
}
