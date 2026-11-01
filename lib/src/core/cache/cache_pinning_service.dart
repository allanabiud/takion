import "package:drift/drift.dart";
import "package:takion/src/data/common/drift/database.dart";

/// Service responsible for identifying and pinning remote cache entries that
/// belong to critical user data (library items, pull list entries, subscriptions,
/// wishlist, and reading lists) and evicting stale or excess LRU cache entries.
class CachePinningService {
  CachePinningService(this._db);

  final AppDatabase _db;

  /// Pins all remote cache entries referenced by the user's library, pull list,
  /// subscriptions, wishlist, favorite series, and reading lists.
  Future<void> pinEssentialEntities({String accountId = "local-user"}) async {
    final pinnedKeys = <String>{};

    // 1. Library Items
    final libraryRows = await _db.select(_db.libraryItems).get();
    for (final row in libraryRows) {
      pinnedKeys.add("details:issue_details:${row.metronIssueId}");
      pinnedKeys.add("/api/issue/${row.metronIssueId}/");
      pinnedKeys.add("details:series_details:${row.metronSeriesId}");
      pinnedKeys.add("/api/series/${row.metronSeriesId}/");
    }

    // 2. Pull List Entries
    final pullRows = await _db.select(_db.pullListEntries).get();
    for (final row in pullRows) {
      pinnedKeys.add("details:issue_details:${row.metronIssueId}");
      pinnedKeys.add("/api/issue/${row.metronIssueId}/");
      pinnedKeys.add("details:series_details:${row.metronSeriesId}");
      pinnedKeys.add("/api/series/${row.metronSeriesId}/");
    }

    // 3. Subscriptions
    final subRows = await _db.select(_db.seriesSubscriptions).get();
    for (final row in subRows) {
      pinnedKeys.add("details:series_details:${row.metronSeriesId}");
      pinnedKeys.add("/api/series/${row.metronSeriesId}/");
    }

    // 4. Wishlist Items
    final wishlistRows = await _db.select(_db.wishlistItems).get();
    for (final row in wishlistRows) {
      pinnedKeys.add("details:issue_details:${row.issueId}");
      pinnedKeys.add("/api/issue/${row.issueId}/");
      pinnedKeys.add("details:series_details:${row.seriesId}");
      pinnedKeys.add("/api/series/${row.seriesId}/");
    }

    // 5. Favorite Series
    final favRows = await _db.select(_db.favoriteSeries).get();
    for (final row in favRows) {
      pinnedKeys.add("details:series_details:${row.metronSeriesId}");
      pinnedKeys.add("/api/series/${row.metronSeriesId}/");
    }

    // 6. Reading List Items
    final readingListItems = await _db.select(_db.readingListItems).get();
    for (final item in readingListItems) {
      final id = int.tryParse(item.targetId);
      if (id != null) {
        if (item.isSeries) {
          pinnedKeys.add("details:series_details:$id");
          pinnedKeys.add("/api/series/$id/");
        } else {
          pinnedKeys.add("details:issue_details:$id");
          pinnedKeys.add("/api/issue/$id/");
        }
      }
    }

    if (pinnedKeys.isNotEmpty) {
      await _db.remoteCacheDao.pinEntries(accountId, pinnedKeys, true);
    }
  }

  /// Evicts expired cache entries and applies LRU eviction to excess unpinned rows.
  Future<int> evictStaleAndLru({
    String accountId = "local-user",
    int maxEntries = 1000,
    Duration staleDuration = const Duration(days: 7),
  }) async {
    // First, pin all essential user entities so they are immune to eviction.
    await pinEssentialEntities(accountId: accountId);

    final cutoff = DateTime.now().toUtc().subtract(staleDuration);

    // Evict stale unpinned cache entries.
    final staleEvicted = await _db.remoteCacheDao.evictStale(
      accountId: accountId,
      before: cutoff,
    );

    // Evict excess unpinned entries by least-recently-accessed.
    final lruEvicted = await _db.remoteCacheDao.evictLru(
      accountId: accountId,
      maxEntries: maxEntries,
    );

    // Clean up stale paged query caches older than cutoff.
    try {
      final cutoffIso = cutoff.toIso8601String();
      final staleQueryCaches = await (_db.select(
        _db.pagedQueryCaches,
      )..where((t) => t.cachedAt.isSmallerThanValue(cutoffIso))).get();

      for (final cache in staleQueryCaches) {
        await (_db.delete(_db.pagedQueryItems)..where(
              (t) =>
                  t.cacheKeyPrefix.equals(cache.cacheKeyPrefix) &
                  t.pageKey.equals(cache.pageKey),
            ))
            .go();
      }
      await (_db.delete(
        _db.pagedQueryCaches,
      )..where((t) => t.cachedAt.isSmallerThanValue(cutoffIso))).go();
    } catch (_) {}

    return staleEvicted + lruEvicted;
  }
}
