import "dart:async";
import "package:dio/dio.dart";
import "package:takion/src/core/cache/cache_mode.dart";
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
    CacheMode? cacheMode,
  }) async {
    final effectiveMode =
        cacheMode ??
        (forceRefresh ? CacheMode.validate : CacheMode.staleWhileRevalidate);

    // 1. If offlineOnly or cacheFirst or staleWhileRevalidate, check local normalized entity first
    if (effectiveMode != CacheMode.networkOnly &&
        effectiveMode != CacheMode.validate &&
        getLocalEntity != null) {
      final local = await getLocalEntity!(id);
      if (local != null) {
        AppPerformanceMetrics.instance.recordCacheHit(resourceName);
        return local;
      }
    }

    // 2. Check local JSON cache with TTL
    if (effectiveMode != CacheMode.networkOnly &&
        effectiveMode != CacheMode.validate) {
      final cachedJson = await getLocalCachedJson(id);
      if (cachedJson != null) {
        final cachedAt = await getCachedAt(id);
        if (effectiveMode == CacheMode.offlineOnly ||
            effectiveMode == CacheMode.cacheFirst ||
            (cachedAt != null && cachePolicy.isFresh(cachedAt, now()))) {
          AppPerformanceMetrics.instance.recordCacheHit(
            "${resourceName}_response",
          );
          final dto = dtoFromJson(cachedJson);
          if (onPersist != null) await onPersist!(dto);
          return dtoToEntity(dto);
        }
      }
    }

    if (effectiveMode == CacheMode.offlineOnly) {
      if (getLocalEntity != null) {
        final local = await getLocalEntity!(id);
        if (local != null) return local;
      }
      throw StateError("Offline only and no cached data for $resourceName $id");
    }

    AppPerformanceMetrics.instance.recordCacheMiss(resourceName);

    final key = "$id|$effectiveMode";
    if (_inFlight.containsKey(key)) {
      return _inFlight[key]!;
    }

    final future = _fetchAndCache(id, mode: effectiveMode);
    _inFlight[key] = future;

    try {
      return await future;
    } finally {
      _inFlight.remove(key);
    }
  }

  Future<TEntity> _fetchAndCache(int id, {required CacheMode mode}) async {
    try {
      final response = await getRemote(id);

      // On 304, the central ConditionalRequestInterceptor restores response.data
      // from the cached body. If response.data is available, use it directly.
      if (response.data != null &&
          (response.data is Map || response.data is String)) {
        final data = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : (response.data is Map
                  ? Map<String, dynamic>.from(response.data as Map)
                  : jsonToMap(response.data));
        final dto = dtoFromJson(data);
        await cacheLocalJson(id, data);
        if (onPersist != null) await onPersist!(dto);
        return dtoToEntity(dto);
      }

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

  Map<String, dynamic> jsonToMap(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return const {};
  }
}
