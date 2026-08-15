import "package:takion/src/data/common/drift/database.dart";

class CacheHeaderStore {
  final Map<String, String> _cache = {};

  Future<void> init(AppDatabase db) async {
    final rows = await db.apiCacheDao.getByPrefix("cache_headers:");
    for (final row in rows) {
      _cache[row.cacheKey] = row.payload;
    }
  }

  String _etagKey(String url) => "cache_headers:$url:etag";
  String _lmKey(String url) => "cache_headers:$url:lm";

  Future<void> store(
    AppDatabase db,
    String url, {
    String? etag,
    String? lastModified,
  }) async {
    if (etag != null) {
      _cache[_etagKey(url)] = etag;
      await db.apiCacheDao.put(
        cacheKey: _etagKey(url),
        entityType: "cache_header",
        payload: etag,
      );
    }
    if (lastModified != null) {
      _cache[_lmKey(url)] = lastModified;
      await db.apiCacheDao.put(
        cacheKey: _lmKey(url),
        entityType: "cache_header",
        payload: lastModified,
      );
    }
  }

  String? getEtag(String url) => _cache[_etagKey(url)];

  String? getLastModified(String url) => _cache[_lmKey(url)];

  Future<void> remove(AppDatabase db, String url) async {
    _cache.remove(_etagKey(url));
    _cache.remove(_lmKey(url));
    await db.apiCacheDao.deleteByKey(_etagKey(url));
    await db.apiCacheDao.deleteByKey(_lmKey(url));
  }

  Future<void> clear(AppDatabase db) async {
    _cache.clear();
    final rows = await db.apiCacheDao.getByPrefix("cache_headers:");
    for (final row in rows) {
      await db.apiCacheDao.deleteByKey(row.cacheKey);
    }
  }
}
