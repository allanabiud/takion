import "dart:convert";
import "package:dio/dio.dart";
import "package:takion/src/core/cache/cache_mode.dart";
import "package:takion/src/core/logging/app_logger.dart";
import "package:takion/src/core/performance/performance_metrics.dart";
import "package:takion/src/data/common/drift/database.dart";

/// Interceptor that handles conditional HTTP requests, 304 response body
/// restoration from local cache, and caching of 200 responses.
///
/// Invariants:
/// 1. Only attaches `If-None-Match` and `If-Modified-Since` when a cached
///    representation exists locally that can satisfy a 304 response.
/// 2. Resolves 304 Not Modified by restoring the cached JSON payload into
///    `response.data` so callers never see an empty body.
/// 3. If an unexpected 304 is received without a local representation,
///    retries once network-only without conditional headers.
/// 4. Provides offline fallback if the network fails and cached data is available.
class ConditionalRequestInterceptor extends Interceptor {
  ConditionalRequestInterceptor(
    this._db, {
    this.defaultAccountId = "local-user",
  });

  final AppDatabase _db;
  final String defaultAccountId;

  static String canonicalCacheKey(Uri uri) {
    final path = uri.path;
    if (!uri.hasQuery) return path;
    final sortedParams = uri.queryParametersAll.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final queryString = sortedParams
        .expand(
          (e) => e.value.map(
            (v) =>
                "${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(v)}",
          ),
        )
        .join("&");
    return queryString.isEmpty ? path : "$path?$queryString";
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Only GET requests are eligible for conditional requests and body caching.
    if (options.method.toUpperCase() != "GET") {
      handler.next(options);
      return;
    }

    if (options.extra["bypass_conditional"] == true) {
      handler.next(options);
      return;
    }

    final cacheOptions = CacheRequestOptions.fromExtra(options.extra);
    if (cacheOptions?.mode == CacheMode.networkOnly) {
      handler.next(options);
      return;
    }

    options.extra = Map<String, dynamic>.from(options.extra);
    options.headers = Map<String, dynamic>.from(options.headers);

    final cacheKey = cacheOptions?.cacheKey ?? canonicalCacheKey(options.uri);
    final accountId = cacheOptions?.accountId ?? defaultAccountId;

    options.extra["_cache_key"] = cacheKey;
    options.extra["_account_id"] = accountId;

    try {
      final entry = await _db.remoteCacheDao.getEntry(accountId, cacheKey);
      if (entry != null &&
          entry.payloadJson != null &&
          entry.payloadJson!.isNotEmpty) {
        // Offline-only: return cached representation immediately without network
        if (cacheOptions?.mode == CacheMode.offlineOnly) {
          try {
            final decoded = jsonDecode(entry.payloadJson!);
            await _db.remoteCacheDao.touchEntry(accountId, cacheKey);
            handler.resolve(
              Response(
                requestOptions: options,
                data: decoded,
                statusCode: 200,
                headers: Headers.fromMap({
                  "x-from-cache": ["offline-only"],
                }),
              ),
            );
            return;
          } catch (_) {}
        }

        // Cache-first: return cached representation if fresh
        if (cacheOptions?.mode == CacheMode.cacheFirst) {
          final now = DateTime.now().toUtc();
          if (entry.staleAt.isAfter(now)) {
            try {
              final decoded = jsonDecode(entry.payloadJson!);
              await _db.remoteCacheDao.touchEntry(accountId, cacheKey);
              handler.resolve(
                Response(
                  requestOptions: options,
                  data: decoded,
                  statusCode: 200,
                  headers: Headers.fromMap({
                    "x-from-cache": ["cache-first"],
                  }),
                ),
              );
              return;
            } catch (_) {}
          }
        }

        // Local body exists to satisfy a 304 response. Safe to send conditional headers.
        options.extra["_cached_entry"] = entry;
        if (entry.etag != null && entry.etag!.isNotEmpty) {
          options.headers["If-None-Match"] = entry.etag;
        }
        if (entry.lastModified != null && entry.lastModified!.isNotEmpty) {
          options.headers["If-Modified-Since"] = entry.lastModified;
        }
      } else {
        // No local cached payload exists.
        if (cacheOptions?.mode == CacheMode.offlineOnly) {
          handler.reject(
            DioException(
              requestOptions: options,
              type: DioExceptionType.cancel,
              error: "Offline mode: No cached data available for $cacheKey",
            ),
          );
          return;
        }
        // Do NOT attach conditional headers since 304 cannot be satisfied.
      }
    } catch (e) {
      AppLogger.debug("Error checking cache entry for $cacheKey: $e");
    }

    handler.next(options);
  }

  @override
  Future<void> onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    final cacheKey =
        response.requestOptions.extra["_cache_key"] as String? ??
        canonicalCacheKey(response.requestOptions.uri);
    final accountId =
        response.requestOptions.extra["_account_id"] as String? ??
        defaultAccountId;
    final cachedEntry =
        response.requestOptions.extra["_cached_entry"] as RemoteCacheEntry?;
    final cacheOptions = CacheRequestOptions.fromExtra(
      response.requestOptions.extra,
    );

    if (response.statusCode == 304) {
      if (cachedEntry != null &&
          cachedEntry.payloadJson != null &&
          cachedEntry.payloadJson!.isNotEmpty) {
        try {
          final decoded = jsonDecode(cachedEntry.payloadJson!);
          Response<dynamic> resolvedResponse = response;
          try {
            response.data = decoded;
          } catch (_) {
            resolvedResponse = Response<dynamic>(
              requestOptions: response.requestOptions,
              data: decoded,
              statusCode: response.statusCode,
              headers: response.headers,
              isRedirect: response.isRedirect,
              redirects: response.redirects,
              statusMessage: response.statusMessage,
              extra: response.extra,
            );
          }
          resolvedResponse.headers.set("x-from-cache", "304-restored");
          AppPerformanceMetrics.instance.recordCacheOutcome(
            CacheOutcome.validation304Restored,
          );

          final now = DateTime.now().toUtc();
          final ttl = cacheOptions?.ttl ?? const Duration(hours: 24);
          await _db.remoteCacheDao.touchEntry(
            accountId,
            cacheKey,
            fetchedAt: now,
            staleAt: now.add(ttl),
          );

          AppLogger.debug(
            "Cache: 304 Not Modified for $cacheKey - restored cached payload",
          );
          handler.next(resolvedResponse);
          return;
        } catch (e) {
          AppLogger.warning("Failed to decode cached payload for 304: $e");
        }
      }

      // Unexpected 304 without cached body available: retry once network-only
      AppLogger.warning(
        "Cache: 304 received without valid local payload for $cacheKey. Retrying network-only.",
      );
      try {
        final retryHeaders =
            Map<String, dynamic>.from(response.requestOptions.headers)
              ..remove("If-None-Match")
              ..remove("If-Modified-Since");

        final retryOptions = response.requestOptions.copyWith(
          headers: retryHeaders,
          extra: Map<String, dynamic>.from(response.requestOptions.extra)
            ..["bypass_conditional"] = true,
        );

        final retryDio = Dio(
          BaseOptions(
            baseUrl: response.requestOptions.baseUrl,
            headers: retryHeaders,
          ),
        );
        final freshResponse = await retryDio.fetch(retryOptions);
        handler.resolve(freshResponse);
        return;
      } catch (retryError) {
        AppLogger.error(
          "Retry after unexpected 304 failed for $cacheKey",
          error: retryError,
        );
      }
    } else if (response.statusCode == 200 && response.data != null) {
      if (response.data is Map || response.data is List) {
        final etag = response.headers.value("etag");
        final lastModified = response.headers.value("last-modified");
        final now = DateTime.now().toUtc();
        final ttl = cacheOptions?.ttl ?? const Duration(hours: 24);

        try {
          final payloadJson = jsonEncode(response.data);
          await _db.remoteCacheDao.upsertEntry(
            accountId: accountId,
            cacheKey: cacheKey,
            etag: etag,
            lastModified: lastModified,
            payloadJson: payloadJson,
            fetchedAt: now,
            staleAt: now.add(ttl),
            lastAccessedAt: now,
            isPinned: cacheOptions?.isPinned ?? false,
          );
          AppLogger.debug(
            "Cache: 200 OK stored payload and ETag for $cacheKey",
          );
          AppPerformanceMetrics.instance.recordCacheOutcome(
            CacheOutcome.network200Fresh,
          );
        } catch (e) {
          AppLogger.debug(
            "Cache: failed to persist response for $cacheKey: $e",
          );
        }
      }
    }

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final isNetworkError =
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError;

    if (isNetworkError) {
      final cachedEntry =
          err.requestOptions.extra["_cached_entry"] as RemoteCacheEntry?;
      if (cachedEntry != null &&
          cachedEntry.payloadJson != null &&
          cachedEntry.payloadJson!.isNotEmpty) {
        try {
          final decoded = jsonDecode(cachedEntry.payloadJson!);
          AppLogger.info(
            "Cache: network error, falling back to cached representation for ${err.requestOptions.path}",
          );
          handler.resolve(
            Response(
              requestOptions: err.requestOptions,
              data: decoded,
              statusCode: 200,
              headers: Headers.fromMap({
                "x-from-cache": ["offline-fallback"],
              }),
            ),
          );
          return;
        } catch (_) {}
      }
    }

    handler.next(err);
  }
}
