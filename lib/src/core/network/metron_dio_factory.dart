import "dart:math";

import "package:dio/dio.dart";
import "package:takion/src/core/cache/cache_header_store.dart";
import "package:takion/src/core/constants/settings_keys.dart";
import "package:takion/src/core/logging/app_logger.dart";
import "package:takion/src/core/network/conditional_interceptor.dart";
import "package:takion/src/core/network/rate_limit_interceptor.dart";
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
Dio buildMetronDio({
  required Future<String?> Function() readToken,
  AppDatabase? db,
  CacheHeaderStore? cacheHeaderStore,
  RateLimitInterceptor? rateLimitInterceptor,
  void Function()? onAuthFailure,
}) {
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
  // are honored (critical for the background sync worker).
  dio.interceptors.add(rateLimitInterceptor ?? RateLimitInterceptor());

  final headerStore = cacheHeaderStore;
  if (db != null && headerStore != null) {
    dio.interceptors.add(ConditionalRequestInterceptor(headerStore, db));
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
            "HTTP 400 validation error for ${error.requestOptions.path} — check request parameters",
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
            "HTTP 403 insufficient permissions for ${error.requestOptions.path} — Editor/Admin role required",
          );
          handler.next(error);
          return;
        }

        if (statusCode == 404) {
          AppLogger.warning(
            "HTTP 404 resource not found for ${error.requestOptions.path} — the ID may not exist",
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

        if (statusCode == 429 &&
            error.requestOptions.extra["retried_after_429"] != true) {
          final sustainedReset = error.response?.headers.value(
            "x-ratelimit-sustained-reset",
          );
          final burstReset = error.response?.headers.value(
            "x-ratelimit-burst-reset",
          );
          final resetValue = sustainedReset ?? burstReset;
          final resetTimestamp = int.tryParse(resetValue ?? "");

          int waitSeconds;
          if (resetTimestamp != null && resetTimestamp > 0) {
            final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
            waitSeconds = (resetTimestamp - now).clamp(1, 300);
          } else {
            waitSeconds = 5;
          }

          AppLogger.warning(
            "HTTP 429 waiting ${waitSeconds}s for ${error.requestOptions.path}",
          );
          AppPerformanceMetrics.instance.recordRetryAfter429();
          await Future.delayed(Duration(seconds: waitSeconds + 1));
          final retryRequest = error.requestOptions
            ..extra = {
              ...error.requestOptions.extra,
              "retried_after_429": true,
            };

          try {
            AppLogger.info("HTTP 429 retry for ${error.requestOptions.path}");
            final response = await dio.fetch(retryRequest);
            return handler.resolve(response);
          } on DioException catch (retryError) {
            AppLogger.error(
              "HTTP 429 retry failed for ${error.requestOptions.path}",
              error: retryError,
            );
            return handler.next(retryError);
          }
        }

        if (statusCode != null && statusCode >= 500 && statusCode < 600) {
          final retryCount =
              error.requestOptions.extra["retry_5xx_count"] as int? ?? 0;
          if (retryCount < 3) {
            final delay = Duration(
              seconds: min(pow(2, retryCount).toInt(), 60),
            );
            await Future.delayed(delay);
            final retryRequest = error.requestOptions
              ..extra = {
                ...error.requestOptions.extra,
                "retry_5xx_count": retryCount + 1,
              };
            try {
              AppLogger.info(
                "HTTP $statusCode retry attempt ${retryCount + 1} for ${error.requestOptions.path}",
              );
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
