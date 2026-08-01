import 'package:drift/drift.dart';
import 'package:takion/src/data/common/drift/database.dart';

class ImageCacheDao extends DatabaseAccessor<AppDatabase> {
  ImageCacheDao(super.db);

  Future<ImageCacheData?> get(String key) async {
    return (select(
      attachedDatabase.imageCache,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
  }

  Future<Map<String, ImageCacheData>> getByKeys(List<String> keys) async {
    if (keys.isEmpty) return {};
    final rows = await (select(
      attachedDatabase.imageCache,
    )..where((t) => t.key.isIn(keys))).get();
    return {for (final r in rows) r.key: r};
  }

  Future<void> put(
    String key,
    String imageUrl, {
    required String entityType,
    required int entityId,
  }) async {
    await into(attachedDatabase.imageCache).insertOnConflictUpdate(
      ImageCacheCompanion.insert(
        key: key,
        entityType: entityType,
        entityId: entityId,
        imageUrl: imageUrl,
        cachedAt: DateTime.now().toUtc(),
      ),
    );
  }

  Future<void> deleteByKey(String key) async {
    await (delete(
      attachedDatabase.imageCache,
    )..where((t) => t.key.equals(key))).go();
  }

  Future<void> putMany(
    Map<String, String> entries, {
    required String entityType,
    required int entityId,
  }) async {
    final now = DateTime.now().toUtc();
    await batch((batch) {
      for (final entry in entries.entries) {
        batch.insert(
          attachedDatabase.imageCache,
          ImageCacheCompanion.insert(
            key: entry.key,
            entityType: entityType,
            entityId: entityId,
            imageUrl: entry.value,
            cachedAt: now,
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  Future<void> clearAll() async {
    await delete(attachedDatabase.imageCache).go();
  }

  Future<List<ImageCacheData>> getAll() async {
    return select(attachedDatabase.imageCache).get();
  }
}
