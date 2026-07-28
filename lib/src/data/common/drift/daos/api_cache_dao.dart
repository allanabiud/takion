import 'package:drift/drift.dart';
import 'package:takion/src/data/common/drift/database.dart';

class ApiCacheDao extends DatabaseAccessor<AppDatabase> {
  ApiCacheDao(super.db);

  Future<ApiCacheData?> get(String cacheKey) async {
    return (select(
      attachedDatabase.apiCache,
    )..where((t) => t.cacheKey.equals(cacheKey))).getSingleOrNull();
  }

  Future<void> put({
    required String cacheKey,
    required String entityType,
    required String payload,
    String? etag,
  }) async {
    await into(attachedDatabase.apiCache).insertOnConflictUpdate(
      ApiCacheCompanion.insert(
        cacheKey: cacheKey,
        entityType: entityType,
        payload: payload,
        etag: Value(etag),
        cachedAt: DateTime.now().toUtc(),
      ),
    );
  }

  Future<void> deleteByKey(String cacheKey) async {
    await (delete(
      attachedDatabase.apiCache,
    )..where((t) => t.cacheKey.equals(cacheKey))).go();
  }

  Future<void> deleteOlderThan(DateTime cutoff) async {
    await (delete(
      attachedDatabase.apiCache,
    )..where((t) => t.cachedAt.isSmallerThan(Constant(cutoff)))).go();
  }

  Future<int> deleteStaleEntries() async {
    final now = DateTime.now().toUtc();
    final deleted =
        await (delete(attachedDatabase.apiCache)..where(
              (t) =>
                  t.cacheKey.like('weekly_releases:%') &
                      t.cachedAt.isSmallerThan(
                        Constant(now.subtract(const Duration(hours: 24))),
                      ) |
                  t.cacheKey.like('search_results:%') &
                      t.cachedAt.isSmallerThan(
                        Constant(now.subtract(const Duration(hours: 3))),
                      ) |
                  t.cacheKey.like('issue_details:%') &
                      t.cachedAt.isSmallerThan(
                        Constant(now.subtract(const Duration(hours: 24))),
                      ) |
                  t.cacheKey.like('series_details:%') &
                      t.cachedAt.isSmallerThan(
                        Constant(now.subtract(const Duration(hours: 48))),
                      ) |
                  t.cachedAt.isSmallerThan(
                    Constant(now.subtract(const Duration(days: 7))),
                  ),
            ))
            .go();
    return deleted;
  }

  Future<void> clearAll() async {
    await delete(attachedDatabase.apiCache).go();
  }

  Future<List<ApiCacheData>> getByPrefix(String prefix) async {
    return (select(
      attachedDatabase.apiCache,
    )..where((t) => t.cacheKey.like('$prefix%'))).get();
  }
}
