import "dart:convert";

import "package:drift/drift.dart";
import "package:takion/src/data/catalog/datasources/local/paged_cache_codec.dart";
import "package:takion/src/data/common/drift/database.dart";

class PageCacheMeta {
  const PageCacheMeta({required this.count, this.next, this.previous});

  final int count;
  final String? next;
  final String? previous;
}

/// Caches one page of list-DTO results per query key on normalized tables.
///
/// [cache] upserts every item into the shared `metron_*` catalog tables (see
/// [PagedCacheCodec]) and records only the query state: pagination metadata
/// plus freshness in `paged_query_caches` and the ordered entity ids in
/// `paged_query_items`. [get] re-hydrates the DTOs from the catalog tables
/// by id, so a cached page reflects the latest stored entity rows and no
/// JSON page payloads remain in the settings key-value store.
class PagedLocalCache<T> {
  PagedLocalCache({
    required AppDatabase db,
    required this.cacheKeyPrefix,
    required this.entityType,
    required this.fromJson,
    required this.toJson,
    this.withMeta = true,
  }) : _db = db,
       _codec = resolvePagedCacheCodec<T>(cacheKeyPrefix);

  final AppDatabase _db;
  final PagedCacheCodec<T> _codec;

  final String cacheKeyPrefix;
  final String entityType;
  final T Function(Map<String, dynamic>) fromJson;
  final Map<String, dynamic> Function(T) toJson;

  final bool withMeta;

  Future<void> cache(
    String key,
    List<T> items, {
    int count = 0,
    String? next,
    String? previous,
  }) async {
    await _db.transaction(() async {
      await _codec.upsertEntities(_db, items);
      await _db
          .into(_db.pagedQueryCaches)
          .insertOnConflictUpdate(
            PagedQueryCachesCompanion(
              cacheKeyPrefix: Value(cacheKeyPrefix),
              pageKey: Value(key),
              count: Value(withMeta ? count : null),
              next: Value(withMeta ? next : null),
              previous: Value(withMeta ? previous : null),
              cachedAt: Value(DateTime.now().toUtc().toIso8601String()),
            ),
          );
      final removePreviousItems = _db.delete(_db.pagedQueryItems)
        ..where(
          (table) =>
              table.cacheKeyPrefix.equals(cacheKeyPrefix) &
              table.pageKey.equals(key),
        );
      await removePreviousItems.go();
      if (items.isEmpty) return;
      final ids = [for (final item in items) _codec.entityId(item)];
      await _db.batch((batch) {
        batch.insertAll(_db.pagedQueryItems, [
          for (var position = 0; position < ids.length; position++)
            PagedQueryItemsCompanion.insert(
              cacheKeyPrefix: cacheKeyPrefix,
              pageKey: key,
              position: position,
              entityId: ids[position],
            ),
        ]);
      });
    });
  }

  Future<List<T>?> get(String key) async {
    if (await _cacheRow(key) == null) return null;
    final itemRows =
        await (_db.select(_db.pagedQueryItems)
              ..where(
                (table) =>
                    table.cacheKeyPrefix.equals(cacheKeyPrefix) &
                    table.pageKey.equals(key),
              )
              ..orderBy([(table) => OrderingTerm.asc(table.position)]))
            .get();
    if (itemRows.isEmpty) return <T>[];
    return _codec.loadByIds(_db, [for (final row in itemRows) row.entityId]);
  }

  Future<DateTime?> cachedAt(String key) async {
    final row = await _cacheRow(key);
    if (row == null) return null;
    return DateTime.tryParse(row.cachedAt);
  }

  Future<PageCacheMeta?> meta(String key) async {
    final row = await _cacheRow(key);
    if (row == null) return null;
    final count = row.count;
    if (count == null) return null;
    return PageCacheMeta(count: count, next: row.next, previous: row.previous);
  }

  Future<PagedQueryCache?> _cacheRow(String key) =>
      (_db.select(_db.pagedQueryCaches)..where(
            (table) =>
                table.cacheKeyPrefix.equals(cacheKeyPrefix) &
                table.pageKey.equals(key),
          ))
          .getSingleOrNull();
}

class DetailsLocalCache {
  DetailsLocalCache({
    required AppDatabase db,
    required this.cacheKeyPrefix,
    required this.entityType,
    this.accountId = "local-user",
    this.defaultTtl = const Duration(days: 3),
  }) : _db = db;

  final AppDatabase _db;
  final String cacheKeyPrefix;
  final String entityType;
  final String accountId;
  final Duration defaultTtl;

  String _cacheKey(String id) => "details:$cacheKeyPrefix:$id";

  Future<void> cache(
    String id,
    Map<String, dynamic> json, {
    Duration? ttl,
    String? etag,
    String? lastModified,
    bool isPinned = false,
  }) async {
    final now = DateTime.now().toUtc();
    final effectiveTtl = ttl ?? defaultTtl;
    await _db.remoteCacheDao.upsertEntry(
      accountId: accountId,
      cacheKey: _cacheKey(id),
      etag: etag,
      lastModified: lastModified,
      payloadJson: jsonEncode(json),
      fetchedAt: now,
      staleAt: now.add(effectiveTtl),
      lastAccessedAt: now,
      isPinned: isPinned,
    );
  }

  Future<Map<String, dynamic>?> get(String id) async {
    final key = _cacheKey(id);
    final entry = await _db.remoteCacheDao.getEntry(
      accountId,
      key,
      touch: true,
    );
    if (entry != null && entry.payloadJson != null) {
      try {
        return jsonDecode(entry.payloadJson!) as Map<String, dynamic>;
      } catch (_) {
        return null;
      }
    }

    // Migrate from legacy settings table if present
    final legacyPayload = await _db.settingsDao.getString(
      "details_cache:$cacheKeyPrefix:$id",
    );
    if (legacyPayload != null) {
      try {
        final map = jsonDecode(legacyPayload) as Map<String, dynamic>;
        final legacyAtRaw = await _db.settingsDao.getString(
          "details_cache_at:$cacheKeyPrefix:$id",
        );
        final legacyAt = legacyAtRaw != null
            ? DateTime.tryParse(legacyAtRaw)
            : null;
        final fetchedAt = legacyAt ?? DateTime.now().toUtc();

        await _db.remoteCacheDao.upsertEntry(
          accountId: accountId,
          cacheKey: key,
          payloadJson: legacyPayload,
          fetchedAt: fetchedAt,
          staleAt: fetchedAt.add(defaultTtl),
          lastAccessedAt: DateTime.now().toUtc(),
        );

        // Clean up legacy settings keys
        await _db.settingsDao.deleteByKey("details_cache:$cacheKeyPrefix:$id");
        await _db.settingsDao.deleteByKey(
          "details_cache_at:$cacheKeyPrefix:$id",
        );

        return map;
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  Future<DateTime?> cachedAt(String id) async {
    final entry = await _db.remoteCacheDao.getEntry(accountId, _cacheKey(id));
    if (entry != null) {
      return entry.fetchedAt;
    }
    final raw = await _db.settingsDao.getString(
      "details_cache_at:$cacheKeyPrefix:$id",
    );
    return raw == null ? null : DateTime.tryParse(raw);
  }
}
