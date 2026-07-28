import 'package:drift/drift.dart';
import 'package:takion/src/data/common/drift/database.dart';

class SyncMetaDao extends DatabaseAccessor<AppDatabase> {
  SyncMetaDao(super.db);

  Future<String?> get(String key) async {
    final row = await (select(
      attachedDatabase.syncMeta,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> set(String key, String value) async {
    await into(
      attachedDatabase.syncMeta,
    ).insertOnConflictUpdate(SyncMetaCompanion.insert(key: key, value: value));
  }

  Future<Map<String, String>> getAll() async {
    final rows = await select(attachedDatabase.syncMeta).get();
    return {for (final row in rows) row.key: row.value};
  }

  Future<void> deleteByKey(String key) async {
    await (delete(
      attachedDatabase.syncMeta,
    )..where((t) => t.key.equals(key))).go();
  }
}
