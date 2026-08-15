import "package:drift/drift.dart" hide isNull, isNotNull;
import "package:drift/native.dart";
import "package:flutter_test/flutter_test.dart";
import "package:takion/src/data/common/drift/database.dart";
import "package:takion/src/data/common/drift/daos/superhero_character_cache_dao.dart";

void main() {
  late AppDatabase db;
  late SuperheroCharacterCacheDao dao;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = db.superheroCharacterCacheDao;
  });

  tearDown(() async {
    await db.close();
  });

  test("upsert then get round-trip preserves values", () async {
    final now = DateTime.now().toUtc();
    await dao.upsert(
      SuperheroCharacterCacheCompanion.insert(
        metronCharacterId: const Value(42),
        superheroId: 70,
        superheroName: "Batman",
        imageUrl: const Value("https://example.com/batman.jpg"),
        powerstatsJson: const Value('{"combat":100}'),
        updatedAt: now,
      ),
    );

    final cached = await dao.getByMetronCharacterId(42);
    expect(cached, isNotNull);
    expect(cached!.superheroId, 70);
    expect(cached.superheroName, "Batman");
    expect(cached.imageUrl, "https://example.com/batman.jpg");
    expect(cached.powerstatsJson, '{"combat":100}');
    expect(
      cached.updatedAt.toUtc().difference(now.toUtc()).inSeconds,
      lessThan(2),
    );
  });

  test("upsert on existing key overwrites", () async {
    await dao.upsert(
      SuperheroCharacterCacheCompanion.insert(
        metronCharacterId: const Value(42),
        superheroId: 70,
        superheroName: "Batman",
        updatedAt: DateTime.now().toUtc(),
      ),
    );
    await dao.upsert(
      SuperheroCharacterCacheCompanion.insert(
        metronCharacterId: const Value(42),
        superheroId: 620,
        superheroName: "Spider-Man",
        imageUrl: const Value("https://example.com/spidey.jpg"),
        updatedAt: DateTime.now().toUtc(),
      ),
    );

    final cached = await dao.getByMetronCharacterId(42);
    expect(cached!.superheroId, 620);
    expect(cached.superheroName, "Spider-Man");
  });

  test("get returns null for unknown metron character", () async {
    final cached = await dao.getByMetronCharacterId(999);
    expect(cached, isNull);
  });

  test("delete removes the cached match", () async {
    await dao.upsert(
      SuperheroCharacterCacheCompanion.insert(
        metronCharacterId: const Value(1),
        superheroId: 70,
        superheroName: "Batman",
        updatedAt: DateTime.now().toUtc(),
      ),
    );

    await dao.deleteByMetronCharacterId(1);
    expect(await dao.getByMetronCharacterId(1), isNull);
  });

  test("clearAll removes every cached match", () async {
    for (var i = 1; i <= 3; i++) {
      await dao.upsert(
        SuperheroCharacterCacheCompanion.insert(
          metronCharacterId: Value(i),
          superheroId: 70,
          superheroName: "Batman",
          updatedAt: DateTime.now().toUtc(),
        ),
      );
    }

    await dao.clearAll();
    for (var i = 1; i <= 3; i++) {
      expect(await dao.getByMetronCharacterId(i), isNull);
    }
  });
}
