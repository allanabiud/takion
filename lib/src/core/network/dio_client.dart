import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:takion/src/core/network/metron_account_service.dart';
import 'package:takion/src/core/network/rate_limit_interceptor.dart';
import 'package:takion/src/core/perf/performance_metrics.dart';

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

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        AppPerformanceMetrics.instance.recordApiCall(options.path);
        final metronAccountService = ref.read(metronAccountServiceProvider);
        final creds = await metronAccountService.getApiCredentials();
        if (creds != null) {
          final auth =
              'Basic ${base64Encode(utf8.encode('${creds['username']}:${creds['password']}'))}';
          options.headers['Authorization'] = auth;
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
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
