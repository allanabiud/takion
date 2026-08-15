import "dart:math";

import "package:dio/dio.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/core/cache/cache_header_store.dart";
import "package:takion/src/core/logging/app_logger.dart";
import "package:takion/src/core/network/conditional_interceptor.dart";
import "package:takion/src/core/network/rate_limit_interceptor.dart";
import "package:takion/src/core/performance/performance_metrics.dart";
import "package:takion/src/core/storage/drift_database_provider.dart";
import "package:takion/src/core/auth/auth_provider.dart";

final cacheHeaderStoreProvider = Provider<CacheHeaderStore>((ref) {
  return CacheHeaderStore();
});

final rateLimitInterceptorProvider = Provider<RateLimitInterceptor>((ref) {
  return RateLimitInterceptor();
});

final dioProvider = Provider<Dio>((ref) {
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

  // Rate limiter early in the chain, shared via provider.
  final rateLimitInterceptor = ref.read(rateLimitInterceptorProvider);
  dio.interceptors.add(rateLimitInterceptor);

  final headerStore = ref.read(cacheHeaderStoreProvider);
  final db = ref.read(driftDatabaseProvider);
  dio.interceptors.add(ConditionalRequestInterceptor(headerStore, db));

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        options.extra["start_time"] = DateTime.now().millisecondsSinceEpoch;
        final dao = ref.read(driftDatabaseProvider).settingsDao;
        final token = await dao.getString("metron_api_token");
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
        return handler.next(response);
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
            final dao = ref.read(driftDatabaseProvider).settingsDao;
            await dao.deleteByKey("metron_api_token");
            ref.invalidate(authStateProvider);
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
});
