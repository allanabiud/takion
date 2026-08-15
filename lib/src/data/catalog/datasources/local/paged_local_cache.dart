import "dart:convert";

import "package:takion/src/data/common/drift/database.dart";

/// Page metadata (count/next/previous) shared by every cached list page.
class PageCacheMeta {
  const PageCacheMeta({required this.count, this.next, this.previous});

  final int count;
  final String? next;
  final String? previous;
}

/// Generic "cache a JSON list page with pagination meta" storage for the
/// Metron catalog. One instance per resource (issue_search, series_list, ...);
/// the key passed by callers is the resource-specific suffix baked on top of
/// [cacheKeyPrefix].
class PagedLocalCache<T> {
  PagedLocalCache({
    required AppDatabase db,
    required this.cacheKeyPrefix,
    required this.entityType,
    required this.fromJson,
    required this.toJson,
    this.withMeta = true,
  }) : _db = db;

  final AppDatabase _db;
  final String cacheKeyPrefix;
  final String entityType;
  final T Function(Map<String, dynamic>) fromJson;
  final Map<String, dynamic> Function(T) toJson;

  /// Whether [cache] also writes the `meta:` row. Disabled for resources that
  /// only ever store the list (weekly/FOC releases).
  final bool withMeta;

  Future<void> cache(
    String key,
    List<T> items, {
    int count = 0,
    String? next,
    String? previous,
  }) async {
    final listJson = items.map(toJson).toList(growable: false);
    await _db.apiCacheDao.put(
      cacheKey: "$cacheKeyPrefix:$key",
      entityType: entityType,
      payload: jsonEncode(listJson),
    );
    if (withMeta) {
      await _db.apiCacheDao.put(
        cacheKey: "meta:$cacheKeyPrefix:$key",
        entityType: "page_meta",
        payload: jsonEncode({
          "count": count,
          "next": next,
          "previous": previous,
        }),
      );
    }
  }

  Future<List<T>?> get(String key) async {
    final row = await _db.apiCacheDao.get("$cacheKeyPrefix:$key");
    if (row == null) return null;
    try {
      final decoded = jsonDecode(row.payload) as List;
      return decoded
          .map((item) => fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  Future<DateTime?> cachedAt(String key) async {
    final row = await _db.apiCacheDao.get("$cacheKeyPrefix:$key");
    return row?.cachedAt;
  }

  Future<PageCacheMeta?> meta(String key) async {
    final row = await _db.apiCacheDao.get("meta:$cacheKeyPrefix:$key");
    if (row == null) return null;
    try {
      final data = jsonDecode(row.payload) as Map<String, dynamic>;
      final count = (data["count"] as num?)?.toInt();
      if (count == null) return null;
      return PageCacheMeta(
        count: count,
        next: data["next"] as String?,
        previous: data["previous"] as String?,
      );
    } catch (_) {
      return null;
    }
  }
}

/// Generic raw-JSON single-entity cache for detail responses.
class DetailsLocalCache {
  DetailsLocalCache({
    required AppDatabase db,
    required this.cacheKeyPrefix,
    required this.entityType,
  }) : _db = db;

  final AppDatabase _db;
  final String cacheKeyPrefix;
  final String entityType;

  Future<void> cache(String id, Map<String, dynamic> json) async {
    await _db.apiCacheDao.put(
      cacheKey: "$cacheKeyPrefix:$id",
      entityType: entityType,
      payload: jsonEncode(json),
    );
  }

  Future<Map<String, dynamic>?> get(String id) async {
    final row = await _db.apiCacheDao.get("$cacheKeyPrefix:$id");
    if (row == null) return null;
    try {
      return jsonDecode(row.payload) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<DateTime?> cachedAt(String id) async {
    final row = await _db.apiCacheDao.get("$cacheKeyPrefix:$id");
    return row?.cachedAt;
  }
}