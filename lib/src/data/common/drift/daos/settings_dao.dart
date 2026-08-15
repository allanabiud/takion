import "package:drift/drift.dart";
import "package:takion/src/data/common/drift/database.dart";

class SettingsDao extends DatabaseAccessor<AppDatabase> {
  SettingsDao(super.db);

  Future<bool> getBool(String key, {bool defaultValue = false}) async {
    final row = await (select(
      attachedDatabase.appSettings,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
    if (row == null) return defaultValue;
    return row.value.toLowerCase() == "true";
  }

  Future<String?> getString(String key) async {
    final row = await (select(
      attachedDatabase.appSettings,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<int> getInt(String key, {int defaultValue = 0}) async {
    final row = await (select(
      attachedDatabase.appSettings,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
    if (row == null) return defaultValue;
    return int.tryParse(row.value) ?? defaultValue;
  }

  Future<void> setBool(String key, bool value) async {
    await into(attachedDatabase.appSettings).insertOnConflictUpdate(
      AppSettingsCompanion.insert(key: key, value: value.toString()),
    );
  }

  Future<void> setString(String key, String value) async {
    await into(attachedDatabase.appSettings).insertOnConflictUpdate(
      AppSettingsCompanion.insert(key: key, value: value),
    );
  }

  Future<void> setInt(String key, int value) async {
    await into(attachedDatabase.appSettings).insertOnConflictUpdate(
      AppSettingsCompanion.insert(key: key, value: value.toString()),
    );
  }

  Future<void> deleteByKey(String key) async {
    await (delete(
      attachedDatabase.appSettings,
    )..where((t) => t.key.equals(key))).go();
  }
}
