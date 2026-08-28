import "dart:async";
import "package:dio/dio.dart";
import "package:takion/src/core/cache/cache_policy.dart";
import "package:takion/src/core/logging/app_logger.dart";
import "package:takion/src/core/performance/performance_metrics.dart";

/// Generic orchestrator for entity detail lookups.
/// Handles: local-first cached reading, TTL validation, request coalescing,
/// remote fetching, 304 conditional updates, local caching, and fallback.
class EntityDetailRepository<TDto, TEntity> {
  EntityDetailRepository({
    required this.resourceName,
    required this.cachePolicy,
    required this.getRemote,
    required this.getLocalCachedJson,
    required this.getCachedAt,
    required this.cacheLocalJson,
    required this.dtoFromJson,
    required this.dtoToEntity,
    this.getLocalEntity,
    this.onPersist,
    this.now = DateTime.now,
  });

  final String resourceName;
  final CachePolicy cachePolicy;
  final Future<Response<dynamic>> Function(int id) getRemote;
  final Future<Map<String, dynamic>?> Function(int id) getLocalCachedJson;
  final Future<DateTime?> Function(int id) getCachedAt;
  final Future<void> Function(int id, Map<String, dynamic> json) cacheLocalJson;
  final TDto Function(Map<String, dynamic> json) dtoFromJson;
  final TEntity Function(TDto dto) dtoToEntity;
  final Future<TEntity?> Function(int id)? getLocalEntity;
  final Future<void> Function(TDto dto)? onPersist;
  final DateTime Function() now;

  final Map<String, Future<TEntity>> _inFlight = {};

  Future<TEntity> getDetails(
    int id, {
    bool forceRefresh = false,
  }) async {
    // 1. Check local normalized entity if available
    if (!forceRefresh && getLocalEntity != null) {
      final local = await getLocalEntity!(id);
      if (local != null) {
        AppPerformanceMetrics.instance.recordCacheHit(resourceName);
        return local;
      }
    }

    // 2. Check local JSON cache with TTL
    if (!forceRefresh) {
      final cachedJson = await getLocalCachedJson(id);
      if (cachedJson != null) {
        final cachedAt = await getCachedAt(id);
        if (cachedAt != null && cachePolicy.isFresh(cachedAt, now())) {
          AppPerformanceMetrics.instance.recordCacheHit("${resourceName}_response");
          final dto = dtoFromJson(cachedJson);
          if (onPersist != null) await onPersist!(dto);
          return dtoToEntity(dto);
        }
      }
    }

    AppPerformanceMetrics.instance.recordCacheMiss(resourceName);

    final key = "$id|$forceRefresh";
    if (_inFlight.containsKey(key)) {
      return _inFlight[key]!;
    }

    final future = _fetchAndCache(id, forceRefresh: forceRefresh);
    _inFlight[key] = future;

    try {
      return await future;
    } finally {
      _inFlight.remove(key);
    }
  }

  Future<TEntity> _fetchAndCache(int id, {required bool forceRefresh}) async {
    try {
      final response = await getRemote(id);
      if (response.statusCode == 304) {
        final cachedJson = await getLocalCachedJson(id);
        if (cachedJson != null) {
          await cacheLocalJson(id, cachedJson);
          final dto = dtoFromJson(cachedJson);
          if (onPersist != null) await onPersist!(dto);
          return dtoToEntity(dto);
        }
        if (getLocalEntity != null) {
          final local = await getLocalEntity!(id);
          if (local != null) return local;
        }
      }

      final data = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : Map<String, dynamic>.from(response.data as Map);

      final dto = dtoFromJson(data);
      await cacheLocalJson(id, data);
      if (onPersist != null) await onPersist!(dto);
      return dtoToEntity(dto);
    } catch (e) {
      AppLogger.warning("Failed to fetch $resourceName $id remotely: $e");
      // Fallback to local cache if present
      final cachedJson = await getLocalCachedJson(id);
      if (cachedJson != null) {
        final dto = dtoFromJson(cachedJson);
        if (onPersist != null) await onPersist!(dto);
        return dtoToEntity(dto);
      }
      if (getLocalEntity != null) {
        final local = await getLocalEntity!(id);
        if (local != null) return local;
      }
      rethrow;
    }
  }
}
