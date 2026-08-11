import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:takion/src/core/network/metron_request_scheduler.dart';
import 'package:takion/src/core/network/request_priority.dart';

export 'metron_request_scheduler.dart' show RateLimitState;
export 'request_priority.dart' show backgroundZoneKey;

class RateLimitInterceptor extends Interceptor {
  final MetronRequestScheduler _scheduler;

  RateLimitInterceptor({
    int? maxRequestsPerMinute,
    int? fallbackDailyLimit,
    int? reservedForeground,
    MetronRequestScheduler? scheduler,
  }) : _scheduler = scheduler ??
           MetronRequestScheduler(
             maxRequestsPerMinute: maxRequestsPerMinute ?? 20,
             fallbackDailyLimit: fallbackDailyLimit ?? 5000,
             reservedForeground: reservedForeground ?? 3,
           );

  ValueNotifier<RateLimitState> get stateNotifier => _scheduler.stateNotifier;

  RateLimitState get state => _scheduler.state;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final priority = resolveRequestPriority(options);
    try {
      final result = await _scheduler.enqueue(
        request: options,
        priority: priority,
      );
      if (result == RequestDispatch.sent) {
        handler.next(options);
      } else {
        handler.reject(
          DioException(
            requestOptions: options,
            type: DioExceptionType.cancel,
            message: 'Request dropped by rate-limit scheduler',
          ),
        );
      }
    } catch (e) {
      handler.reject(
        DioException(requestOptions: options, error: e.toString()),
      );
    }
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _scheduler.onResponse(response.headers.map);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _scheduler.onError(
      statusCode: err.response?.statusCode,
      headers: err.response?.headers.map,
    );
    handler.next(err);
  }
}
