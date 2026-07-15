import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/cache/cache_header_store.dart';
import 'package:takion/src/core/network/conditional_interceptor.dart';
import 'package:takion/src/core/network/rate_limit_interceptor.dart';
import 'package:takion/src/core/performance/performance_metrics.dart';
import 'package:takion/src/core/storage/hive_service.dart';

final cacheHeaderStoreProvider = Provider<CacheHeaderStore>((ref) {
  return CacheHeaderStore();
});

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://metron.cloud/api/',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  // Rate limiter should be early in the chain
  dio.interceptors.add(RateLimitInterceptor());

  // Conditional request interceptor
  final headerStore = ref.read(cacheHeaderStoreProvider);
  dio.interceptors.add(ConditionalRequestInterceptor(headerStore));

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        options.extra['start_time'] = DateTime.now().millisecondsSinceEpoch;
        final hiveService = ref.read(hiveServiceProvider);
        final box = hiveService.getBoxIfOpen<String>('metron_account_box') ??
            await hiveService.openBox<String>('metron_account_box');
        final username = box.get('username')?.trim();
        final password = box.get('password')?.trim();
        if (username != null &&
            username.isNotEmpty &&
            password != null &&
            password.isNotEmpty) {
          final auth =
              'Basic ${base64Encode(utf8.encode('$username:$password'))}';
          options.headers['Authorization'] = auth;
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        final startTime = response.requestOptions.extra['start_time'] as int?;
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
        final startTime = error.requestOptions.extra['start_time'] as int?;
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
        if (error.response?.statusCode == 429) {
          AppPerformanceMetrics.instance.recordHttp429();
        }
        if (error.response?.statusCode == 429 &&
            error.requestOptions.extra['retried_after_429'] != true) {
          final retryAfterHeader = error.response?.headers.value('retry-after');
          final retryAfterSeconds = int.tryParse(retryAfterHeader ?? '');

          if (retryAfterSeconds != null && retryAfterSeconds > 0) {
            AppPerformanceMetrics.instance.recordRetryAfter429();
            await Future.delayed(Duration(seconds: retryAfterSeconds));
            final retryRequest = error.requestOptions
              ..extra = {
                ...error.requestOptions.extra,
                'retried_after_429': true,
              };

            try {
              final response = await dio.fetch(retryRequest);
              return handler.resolve(response);
            } on DioException catch (retryError) {
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
