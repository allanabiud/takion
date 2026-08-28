import "dart:async";
import "package:dio/dio.dart";
import "package:takion/src/core/cache/cache_policy.dart";
import "package:takion/src/core/logging/app_logger.dart";
import "package:takion/src/core/performance/performance_metrics.dart";
import "package:takion/src/data/catalog/datasources/local/paged_local_cache.dart";

/// Generic orchestrator for paged resource fetching, caching, and coalescing.
class PagedResourceRepository<TDto, TEntity> {
  PagedResourceRepository({
    required this.resourceName,
    required this.cachePolicy,
    required this.getLocalItems,
    required this.getLocalMeta,
    required this.getCachedAt,
    required this.cacheLocal,
    required this.getRemotePage,
    required this.dtoToEntity,
    this.onPersistItems,
    this.now = DateTime.now,
  });

  final String resourceName;
  final CachePolicy cachePolicy;
  final Future<List<TDto>?> Function(String key) getLocalItems;
  final Future<PageCacheMeta?> Function(String key) getLocalMeta;
  final Future<DateTime?> Function(String key) getCachedAt;
  final Future<void> Function(
    String key,
    List<TDto> items, {
    required int count,
    String? next,
    String? previous,
  }) cacheLocal;
  final Future<({List<TDto> items, int count, String? next, String? previous})>
      Function(String key, CancelToken? cancelToken) getRemotePage;
  final TEntity Function(List<TDto> dtos, int count, String? next, String? previous)
      dtoToEntity;
  final Future<void> Function(List<TDto> items)? onPersistItems;
  final DateTime Function() now;

  final Map<String, Future<TEntity>> _inFlight = {};

  Future<TEntity> getPage(
    String cacheKey, {
    bool forceRefresh = false,
    CancelToken? cancelToken,
  }) async {
    // 1. Check local paged cache with TTL
    if (!forceRefresh) {
      final cachedItems = await getLocalItems(cacheKey);
      if (cachedItems != null) {
        final cachedAt = await getCachedAt(cacheKey);
        if (cachedAt != null && cachePolicy.isFresh(cachedAt, now())) {
          AppPerformanceMetrics.instance.recordCacheHit("${resourceName}_paged");
          final meta = await getLocalMeta(cacheKey);
          if (onPersistItems != null) await onPersistItems!(cachedItems);
          return dtoToEntity(
            cachedItems,
            meta?.count ?? cachedItems.length,
            meta?.next,
            meta?.previous,
          );
        }
      }
    }

    AppPerformanceMetrics.instance.recordCacheMiss("${resourceName}_paged");

    final coalescingKey = "$cacheKey|$forceRefresh";
    if (_inFlight.containsKey(coalescingKey)) {
      return _inFlight[coalescingKey]!;
    }

    final future = _fetchAndCache(cacheKey, cancelToken: cancelToken);
    _inFlight[coalescingKey] = future;

    try {
      return await future;
    } finally {
      _inFlight.remove(coalescingKey);
    }
  }

  Future<TEntity> _fetchAndCache(
    String cacheKey, {
    CancelToken? cancelToken,
  }) async {
    try {
      final remote = await getRemotePage(cacheKey, cancelToken);
      await cacheLocal(
        cacheKey,
        remote.items,
        count: remote.count,
        next: remote.next,
        previous: remote.previous,
      );

      if (onPersistItems != null) {
        await onPersistItems!(remote.items);
      }

      return dtoToEntity(
        remote.items,
        remote.count,
        remote.next,
        remote.previous,
      );
    } catch (e) {
      AppLogger.warning("Failed to fetch $resourceName paged remotely: $e");
      // Fallback to stale local cache if present
      final cachedItems = await getLocalItems(cacheKey);
      if (cachedItems != null) {
        final meta = await getLocalMeta(cacheKey);
        if (onPersistItems != null) await onPersistItems!(cachedItems);
        return dtoToEntity(
          cachedItems,
          meta?.count ?? cachedItems.length,
          meta?.next,
          meta?.previous,
        );
      }
      rethrow;
    }
  }
}
