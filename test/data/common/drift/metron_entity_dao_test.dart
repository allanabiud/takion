import "package:drift/drift.dart" hide isNull, isNotNull;
import "package:drift/native.dart";
import "package:flutter_test/flutter_test.dart";
import "package:takion/src/data/common/drift/database.dart";

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group("upsert*StubsBatch", () {
    test("inserts new stub rows", () async {
      await db.metronEntityDao.upsertCreatorStubsBatch([
        MetronCreatorsCompanion.insert(
          name: "Grant Morrison",
          id: const Value(1),
          isFullyHydrated: const Value(false),
        ),
      ]);

      final row = await db.metronEntityDao.getCreator(1);
      expect(row, isNotNull);
      expect(row!.name, "Grant Morrison");
      expect(row.isFullyHydrated, isFalse);
    });

    test("creators stub upsert preserves isFullyHydrated on conflict", () async {
      await db.metronCreators.insertOnConflictUpdate(
        const MetronCreatorsCompanion(
          id: Value(1),
          name: Value("Grant Morrison"),
          isFullyHydrated: Value(true),
        ),
      );

      await db.metronEntityDao.upsertCreatorStubsBatch([
        MetronCreatorsCompanion.insert(
          name: "Grant Morrison",
          id: const Value(1),
          isFullyHydrated: const Value(false),
        ),
      ]);

      final row = await db.metronEntityDao.getCreator(1);
      expect(row, isNotNull);
      expect(row!.isFullyHydrated, isTrue);
    });

    test("characters stub upsert preserves isFullyHydrated on conflict",
        () async {
      await db.metronCharacters.insertOnConflictUpdate(
        const MetronCharactersCompanion(
          id: Value(1),
          name: Value("Batman"),
          isFullyHydrated: Value(true),
        ),
      );

      await db.metronEntityDao.upsertCharacterStubsBatch([
        MetronCharactersCompanion.insert(
          name: "Batman",
          id: const Value(1),
          isFullyHydrated: const Value(false),
        ),
      ]);

      final row = await db.metronEntityDao.getCharacter(1);
      expect(row, isNotNull);
      expect(row!.isFullyHydrated, isTrue);
    });

    test("arcs stub upsert preserves isFullyHydrated on conflict", () async {
      await db.metronArcs.insertOnConflictUpdate(
        const MetronArcsCompanion(
          id: Value(1),
          name: Value("Knightfall"),
          isFullyHydrated: Value(true),
        ),
      );

      await db.metronEntityDao.upsertArcStubsBatch([
        MetronArcsCompanion.insert(
          name: "Knightfall",
          id: const Value(1),
          isFullyHydrated: const Value(false),
        ),
      ]);

      final row = await db.metronEntityDao.getArc(1);
      expect(row, isNotNull);
      expect(row!.isFullyHydrated, isTrue);
    });

    test("teams stub upsert preserves isFullyHydrated on conflict", () async {
      await db.metronTeams.insertOnConflictUpdate(
        const MetronTeamsCompanion(
          id: Value(1),
          name: Value("Justice League"),
          isFullyHydrated: Value(true),
        ),
      );

      await db.metronEntityDao.upsertTeamStubsBatch([
        MetronTeamsCompanion.insert(
          name: "Justice League",
          id: const Value(1),
          isFullyHydrated: const Value(false),
        ),
      ]);

      final row = await db.metronEntityDao.getTeam(1);
      expect(row, isNotNull);
      expect(row!.isFullyHydrated, isTrue);
    });

    test("universes stub upsert preserves isFullyHydrated on conflict",
        () async {
      await db.metronUniverses.insertOnConflictUpdate(
        const MetronUniversesCompanion(
          id: Value(1),
          name: Value("DC Universe"),
          isFullyHydrated: Value(true),
        ),
      );

      await db.metronEntityDao.upsertUniverseStubsBatch([
        MetronUniversesCompanion.insert(
          name: "DC Universe",
          id: const Value(1),
          isFullyHydrated: const Value(false),
        ),
      ]);

      final row = await db.metronEntityDao.getUniverse(1);
      expect(row, isNotNull);
      expect(row!.isFullyHydrated, isTrue);
    });

    test("series stub upsert preserves isFullyHydrated on conflict", () async {
      await db.metronSeries.insertOnConflictUpdate(
        const MetronSeriesCompanion(
          id: Value(1),
          name: Value("Batman"),
          isFullyHydrated: Value(true),
        ),
      );

      await db.metronEntityDao.upsertSeriesStubsBatch([
        MetronSeriesCompanion.insert(
          name: "Batman",
          id: const Value(1),
          isFullyHydrated: const Value(false),
        ),
      ]);

      final row = await db.metronEntityDao.getSeries(1);
      expect(row, isNotNull);
      expect(row!.isFullyHydrated, isTrue);
    });

    test("issues stub upsert preserves isFullyHydrated on conflict", () async {
      await db.metronIssues.insertOnConflictUpdate(
        const MetronIssuesCompanion(
          id: Value(1),
          number: Value("1"),
          isFullyHydrated: Value(true),
        ),
      );

      await db.metronEntityDao.upsertIssueStubsBatch([
        MetronIssuesCompanion.insert(
          number: "1",
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
