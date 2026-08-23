import "package:drift/drift.dart";
import "package:takion/src/data/common/drift/database.dart";

class SuperheroCharacterCacheDao extends DatabaseAccessor<AppDatabase> {
  SuperheroCharacterCacheDao(super.db);

  Future<SuperheroCharacterCacheData?> getByMetronCharacterId(
    int metronCharacterId,
  ) async {
    return (select(attachedDatabase.superheroCharacterCache)
          ..where((t) => t.metronCharacterId.equals(metronCharacterId)))
        .getSingleOrNull();
  }

  Future<void> upsert(SuperheroCharacterCacheCompanion entry) async {
    await into(
      attachedDatabase.superheroCharacterCache,
    ).insertOnConflictUpdate(entry);
  }

  Future<void> deleteByMetronCharacterId(int metronCharacterId) async {
    await (delete(
      attachedDatabase.superheroCharacterCache,
    )..where((t) => t.metronCharacterId.equals(metronCharacterId))).go();
  }

  Future<void> clearAll() async {
    await delete(attachedDatabase.superheroCharacterCache).go();
  }
}
