import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:takion/src/data/common/drift/database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('upsert*StubsBatch', () {
    test('inserts new stub rows', () async {
      await db.metronEntityDao.upsertCreatorStubsBatch([
        MetronCreatorsCompanion.insert(
          name: 'Grant Morrison',
          id: const Value(1),
          isFullyHydrated: const Value(false),
        ),
      ]);

      final row = await db.metronEntityDao.getCreator(1);
      expect(row, isNotNull);
      expect(row!.name, 'Grant Morrison');
      expect(row.isFullyHydrated, isFalse);
    });

    test('creators stub upsert preserves isFullyHydrated on conflict', () async {
      await db.metronCreators.insertOnConflictUpdate(
        MetronCreatorsCompanion(
          id: const Value(1),
          name: const Value('Grant Morrison'),
          isFullyHydrated: const Value(true),
        ),
      );

      await db.metronEntityDao.upsertCreatorStubsBatch([
        MetronCreatorsCompanion.insert(
          name: 'Grant Morrison',
          id: const Value(1),
          isFullyHydrated: const Value(false),
        ),
      ]);

      final row = await db.metronEntityDao.getCreator(1);
      expect(row, isNotNull);
      expect(row!.isFullyHydrated, isTrue);
    });

    test('characters stub upsert preserves isFullyHydrated on conflict',
        () async {
      await db.metronCharacters.insertOnConflictUpdate(
        MetronCharactersCompanion(
          id: const Value(1),
          name: const Value('Batman'),
          isFullyHydrated: const Value(true),
        ),
      );

      await db.metronEntityDao.upsertCharacterStubsBatch([
        MetronCharactersCompanion.insert(
          name: 'Batman',
          id: const Value(1),
          isFullyHydrated: const Value(false),
        ),
      ]);

      final row = await db.metronEntityDao.getCharacter(1);
      expect(row, isNotNull);
      expect(row!.isFullyHydrated, isTrue);
    });

    test('arcs stub upsert preserves isFullyHydrated on conflict', () async {
      await db.metronArcs.insertOnConflictUpdate(
        MetronArcsCompanion(
          id: const Value(1),
          name: const Value('Knightfall'),
          isFullyHydrated: const Value(true),
        ),
      );

      await db.metronEntityDao.upsertArcStubsBatch([
        MetronArcsCompanion.insert(
          name: 'Knightfall',
          id: const Value(1),
          isFullyHydrated: const Value(false),
        ),
      ]);

      final row = await db.metronEntityDao.getArc(1);
      expect(row, isNotNull);
      expect(row!.isFullyHydrated, isTrue);
    });

    test('teams stub upsert preserves isFullyHydrated on conflict', () async {
      await db.metronTeams.insertOnConflictUpdate(
        MetronTeamsCompanion(
          id: const Value(1),
          name: const Value('Justice League'),
          isFullyHydrated: const Value(true),
        ),
      );

      await db.metronEntityDao.upsertTeamStubsBatch([
        MetronTeamsCompanion.insert(
          name: 'Justice League',
          id: const Value(1),
          isFullyHydrated: const Value(false),
        ),
      ]);

      final row = await db.metronEntityDao.getTeam(1);
      expect(row, isNotNull);
      expect(row!.isFullyHydrated, isTrue);
    });

    test('universes stub upsert preserves isFullyHydrated on conflict',
        () async {
      await db.metronUniverses.insertOnConflictUpdate(
        MetronUniversesCompanion(
          id: const Value(1),
          name: const Value('DC Universe'),
          isFullyHydrated: const Value(true),
        ),
      );

      await db.metronEntityDao.upsertUniverseStubsBatch([
        MetronUniversesCompanion.insert(
          name: 'DC Universe',
          id: const Value(1),
          isFullyHydrated: const Value(false),
        ),
      ]);

      final row = await db.metronEntityDao.getUniverse(1);
      expect(row, isNotNull);
      expect(row!.isFullyHydrated, isTrue);
    });

    test('series stub upsert preserves isFullyHydrated on conflict', () async {
      await db.metronSeries.insertOnConflictUpdate(
        MetronSeriesCompanion(
          id: const Value(1),
          name: const Value('Batman'),
          isFullyHydrated: const Value(true),
        ),
      );

      await db.metronEntityDao.upsertSeriesStubsBatch([
        MetronSeriesCompanion.insert(
          name: 'Batman',
          id: const Value(1),
          isFullyHydrated: const Value(false),
        ),
      ]);

      final row = await db.metronEntityDao.getSeries(1);
      expect(row, isNotNull);
      expect(row!.isFullyHydrated, isTrue);
    });

    test('issues stub upsert preserves isFullyHydrated on conflict', () async {
      await db.metronIssues.insertOnConflictUpdate(
        MetronIssuesCompanion(
          id: const Value(1),
          number: const Value('1'),
          isFullyHydrated: const Value(true),
        ),
      );

      await db.metronEntityDao.upsertIssueStubsBatch([
        MetronIssuesCompanion.insert(
          number: '1',
          id: const Value(1),
          isFullyHydrated: const Value(false),
        ),
      ]);

      final row = await db.metronEntityDao.getIssue(1);
      expect(row, isNotNull);
      expect(row!.isFullyHydrated, isTrue);
    });
  });
}
