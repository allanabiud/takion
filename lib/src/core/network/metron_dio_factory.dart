import "dart:math";

import "package:clock/clock.dart";
import "package:dio/dio.dart";
import "package:takion/src/core/cache/cache_header_store.dart";
import "package:takion/src/core/constants/settings_keys.dart";
import "package:takion/src/core/logging/app_logger.dart";
import "package:takion/src/core/network/conditional_interceptor.dart";
import "package:takion/src/core/network/rate_limit_interceptor.dart";
import "package:takion/src/core/network/rate_limit_state_store.dart";
import "package:takion/src/core/performance/performance_metrics.dart";
import "package:takion/src/data/common/drift/database.dart";

/// Builds a fully configured Metron API client.
///
/// This is the single source of truth for the interceptor chain so that the
/// foreground Riverpod client and the Workmanager background sync share the
/// same authentication, rate limiting, conditional-request, and retry
/// behavior.
///
/// - [readToken] supplies the Metron API token for `Authorization` headers.
/// - [db] enables ETag/Conditional requests and 401 token cleanup. It may be
///   omitted in contexts without a database.
/// - [onAuthFailure] is invoked after a 401 invalidates the stored token.
/// - [rateLimitStateStore] persists observed rate-limit state so a 429
///   cooldown survives process death. When omitted and [db] is provided, a
///   store backed by the database's `SyncMetaDao` is wired automatically so
///   the foreground client and the Workmanager isolate behave identically.
Dio buildMetronDio({
  required Future<String?> Function() readToken,
  AppDatabase? db,
  CacheHeaderStore? cacheHeaderStore,
  RateLimitInterceptor? rateLimitInterceptor,
  RateLimitStateStore? rateLimitStateStore,
  void Function()? onAuthFailure,
  Random? random,
  Clock? clock,
}) {
  final rng = random ?? Random();
  final clk = clock ?? const Clock();
  final dio = Dio(
    BaseOptions(
      baseUrl: "https://metron.cloud/api/",
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      validateStatus: (status) =>
          status != null && ((status >= 200 && status < 300) || status == 304),
    ),
  );
  dio.transformer = BackgroundTransformer();

  // Rate limiter early in the chain. A dedicated instance is shared across
  // all requests built from this client so pacing and X-RateLimit-* headers
  // are honored (critical for the background sync worker). When a database
  // is available but no explicit store was given, persist rate state so a
  // 429 cooldown survives app restarts and isolate teardown.
  final effectiveStore = rateLimitInterceptor == null
      ? (rateLimitStateStore ??
            (db != null ? RateLimitStateStore(db.syncMetaDao) : null))
      : rateLimitStateStore;
  final limiter =
      rateLimitInterceptor ?? RateLimitInterceptor(stateStore: effectiveStore);
  dio.interceptors.add(limiter);

  if (db != null) {
    dio.interceptors.add(ConditionalRequestInterceptor(db));
  }

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        options.extra["start_time"] = DateTime.now().millisecondsSinceEpoch;
        final token = await readToken();
        final trimmedToken = token?.trim();
        if (trimmedToken != null && trimmedToken.isNotEmpty) {
          options.headers.putIfAbsent(
            "Authorization",
            () => "Bearer $trimmedToken",
          );
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        final startTime = response.requestOptions.extra["start_time"] as int?;
        if (startTime != null) {
          final duration = Duration(
            milliseconds: DateTime.now().millisecondsSinceEpoch - startTime,
          );
          AppPerformanceMetrics.instance.recordApiCall(
            response.requestOptions.path,
            duration: duration,
            statusCode: response.statusCode,
          );
        }
        handler.next(response);
      },
      onError: (error, handler) async {
        final startTime = error.requestOptions.extra["start_time"] as int?;
        if (startTime != null) {
          final duration = Duration(
            milliseconds: DateTime.now().millisecondsSinceEpoch - startTime,
          );
          AppPerformanceMetrics.instance.recordApiCall(
            error.requestOptions.path,
            duration: duration,
            statusCode: error.response?.statusCode,
          );
        }
        final statusCode = error.response?.statusCode;

        if (statusCode == 400) {
          AppLogger.warning(
            "HTTP 400 validation error for ${error.requestOptions.path} - check request parameters",
          );
          handler.next(error);
          return;
        }

        if (statusCode == 401) {
          AppLogger.warning(
            "HTTP 401 received for ${error.requestOptions.path}",
          );
          final hadToken = error.requestOptions.headers.containsKey(
            "Authorization",
          );
          if (hadToken) {
            if (db != null) {
              await db.settingsDao.deleteByKey(SettingsKeys.metronApiToken);
            }
            onAuthFailure?.call();
          }
          handler.next(error);
          return;
        }

        if (statusCode == 403) {
          AppLogger.warning(
            "HTTP 403 insufficient permissions for ${error.requestOptions.path} - Editor/Admin role required",
          );
          handler.next(error);
          return;
        }

        if (statusCode == 404) {
          AppLogger.warning(
            "HTTP 404 resource not found for ${error.requestOptions.path} - the ID may not exist",
          );
          handler.next(error);
          return;
        }

        if (statusCode == 429) {
          AppLogger.warning(
            "HTTP 429 received for ${error.requestOptions.path}",
          );
          AppPerformanceMetrics.instance.recordHttp429();
        }

        if (statusCode == 429) {
          final retryCount =
              error.requestOptions.extra["retry_429_count"] as int? ?? 0;
          if (retryCount < 2) {
            // 1. Honor standard Retry-After header first (in seconds)
            final retryAfterRaw = error.response?.headers.value("retry-after");
            int? waitSeconds = int.tryParse(retryAfterRaw ?? "");

            // 2. Fall back to X-RateLimit-*-Reset timestamps
            if (waitSeconds == null || waitSeconds <= 0) {
              final sustainedReset = error.response?.headers.value(
                "x-ratelimit-sustained-reset",
              );
              final burstReset = error.response?.headers.value(
                "x-ratelimit-burst-reset",
              );
              final resetTimestamp = int.tryParse(
                sustainedReset ?? burstReset ?? "",
              );
              if (resetTimestamp != null && resetTimestamp > 0) {
                final now = clk.now().millisecondsSinceEpoch ~/ 1000;
                waitSeconds = (resetTimestamp - now).clamp(1, 300);
              } else {
                waitSeconds = 5;
              }
            }

            // Throttle every request through the scheduler for the server's
            // cooldown window (before jitter) so concurrent work queued
            // behind this 429 cannot fire into the same blackout.
            limiter.noteRetryAfter(Duration(seconds: waitSeconds));
            AppPerformanceMetrics.instance.recordThrottleDelay(
              Duration(seconds: waitSeconds),
            );

            // 3. Add randomized jitter (+250ms to +1250ms) to prevent synchronized retry storms
            final jitterMs = rng.nextInt(1000) + 250;
            final totalDelay =
                Duration(seconds: waitSeconds) +
                Duration(milliseconds: jitterMs);

            AppLogger.warning(
              "HTTP 429 waiting ${totalDelay.inMilliseconds}ms (attempt ${retryCount + 1}) for ${error.requestOptions.path}",
            );
            AppPerformanceMetrics.instance.recordRetryAfter429();
            await Future.delayed(totalDelay);

            final retryRequest = error.requestOptions
              ..extra = {
                ...error.requestOptions.extra,
                "retried_after_429": true,
                "retry_429_count": retryCount + 1,
              };

            try {
              AppLogger.info(
                "HTTP 429 retry attempt ${retryCount + 1} for ${error.requestOptions.path}",
              );
              final response = await dio.fetch(retryRequest);
              return handler.resolve(response);
            } on DioException catch (retryError) {
              if (retryCount >= 1) {
                AppLogger.error(
                  "HTTP 429 retry exhausted for ${error.requestOptions.path}",
                  error: retryError,
                );
              }
              return handler.next(retryError);
            }
          }
        }

        if (statusCode != null && statusCode >= 500 && statusCode < 600) {
          final retryCount =
              error.requestOptions.extra["retry_5xx_count"] as int? ?? 0;
          if (retryCount < 3) {
            // Full jitter exponential backoff: base * 2^retry, randomized between 50% and 100%
            final baseMs = 1000 * min(pow(2, retryCount).toInt(), 30);
            final jitteredMs = (baseMs ~/ 2) + rng.nextInt(baseMs ~/ 2 + 1);
            final delay = Duration(milliseconds: jitteredMs);

            AppLogger.info(
              "HTTP $statusCode retry attempt ${retryCount + 1} with jittered backoff (${jitteredMs}ms) for ${error.requestOptions.path}",
            );
            await Future.delayed(delay);

            final retryRequest = error.requestOptions
              ..extra = {
                ...error.requestOptions.extra,
                "retry_5xx_count": retryCount + 1,
              };
            try {
              final response = await dio.fetch(retryRequest);
              return handler.resolve(response);
            } on DioException catch (retryError) {
              if (retryCount >= 2) {
                AppLogger.warning(
                  "Server error after ${retryCount + 1} retries for ${error.requestOptions.path}",
                  error: retryError,
                );
              }
              return handler.next(retryError);
            }
          }
        }

        return handler.next(error);
      },
    ),
  );

  return dio;
}
