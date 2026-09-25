import "package:takion/src/data/common/drift/database.dart";

class CacheHeaderStore {
  final Map<String, String> _cache = {};

  Future<void> init(AppDatabase db) async {
    final entries = await db.syncMetaDao.getByPrefix("cache_headers:");
    _cache.addAll(entries);
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
      await db.syncMetaDao.set(_etagKey(url), etag);
    }
    if (lastModified != null) {
      _cache[_lmKey(url)] = lastModified;
      await db.syncMetaDao.set(_lmKey(url), lastModified);
    }
  }

  String? getEtag(String url) => _cache[_etagKey(url)];

  String? getLastModified(String url) => _cache[_lmKey(url)];

  Future<void> remove(AppDatabase db, String url) async {
    _cache.remove(_etagKey(url));
    _cache.remove(_lmKey(url));
    await db.syncMetaDao.deleteByKey(_etagKey(url));
    await db.syncMetaDao.deleteByKey(_lmKey(url));
  }

  Future<void> clear(AppDatabase db) async {
    _cache.clear();
    await db.syncMetaDao.deleteByPrefix("cache_headers:");
  }
}
