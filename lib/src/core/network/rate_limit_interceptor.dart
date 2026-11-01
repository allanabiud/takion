import "dart:async";

import "package:dio/dio.dart";
import "package:flutter/widgets.dart";
import "package:takion/src/core/network/metron_request_scheduler.dart";
import "package:takion/src/core/network/rate_limit_state_store.dart";
import "package:takion/src/core/network/request_priority.dart";

export "metron_request_scheduler.dart" show RateLimitState;
export "request_priority.dart" show backgroundZoneKey;

/// Passes every Metron request through the shared [MetronRequestScheduler]
/// and keeps the scheduler's rate-limit state hydrated from persistence.
///
/// When a [RateLimitStateStore] is provided, observed state changes are
/// debounced and persisted to SQLite, and any persisted snapshot is loaded
/// on construction so a 429 cooldown survives process death.
class RateLimitInterceptor extends Interceptor {
  RateLimitInterceptor({
    int? maxRequestsPerMinute,
    int? fallbackDailyLimit,
    int? reservedForeground,
    int? maxConcurrent,
    int? maxConcurrentPagination,
    MetronRequestScheduler? scheduler,
    RateLimitStateStore? stateStore,
    this.accountId = "local-user",
  }) : _scheduler =
           scheduler ??
           MetronRequestScheduler(
             maxRequestsPerMinute: maxRequestsPerMinute ?? 20,
             fallbackDailyLimit: fallbackDailyLimit ?? 5000,
             reservedForeground: reservedForeground ?? 1,
             maxConcurrent: maxConcurrent ?? 3,
             maxConcurrentPagination: maxConcurrentPagination ?? 1,
             onStateChanged: stateStore?.scheduleSave,
           ),
       _stateStore = stateStore {
    if (scheduler == null && stateStore != null) {
      unawaited(hydrate());
    }
  }

  final MetronRequestScheduler _scheduler;
  final RateLimitStateStore? _stateStore;
  final String accountId;

  MetronRequestScheduler get scheduler => _scheduler;

  ValueNotifier<RateLimitState> get stateNotifier => _scheduler.stateNotifier;

  RateLimitState get state => _scheduler.state;

  /// Loads any persisted rate-limit snapshot into the scheduler. Awaiting
  /// this is only required in tests; production hydrates on construction.
  Future<void> hydrate() async {
    final store = _stateStore;
    if (store == null) return;
    final restored = await store.load();
    if (restored != null) {
      _scheduler.restoreState(restored);
    }
  }

  /// Starts a Retry-After cooldown (e.g. after observing a 429) so queued
  /// and future requests are throttled without a busy wait.
  void noteRetryAfter(Duration duration) => _scheduler.noteRetryAfter(duration);

  /// Cancels timers owned by this interceptor. Call when it is discarded.
  void dispose() {
    _scheduler.dispose();
    _stateStore?.dispose();
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final priority = resolveRequestPriority(options);
    try {
      final originalConnectTimeout = options.connectTimeout;
      // Do not count queue waiting time towards socket connection timeout
      options.connectTimeout = null;
      final result = await _scheduler.enqueue(
        request: options,
        priority: priority,
      );
      options.connectTimeout = originalConnectTimeout;
      if (result == RequestDispatch.sent) {
        handler.next(options);
      } else {
        handler.reject(
          DioException(
            requestOptions: options,
            type: DioExceptionType.cancel,
            message: "Request dropped by rate-limit scheduler",
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
    _scheduler.onResponse(
      response.headers.map,
      request: response.requestOptions,
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 429) {
      final cooldown = _retryAfterCooldown(err);
      if (cooldown != null) {
        _scheduler.noteRetryAfter(cooldown);
      }
    }
    _scheduler.onError(
      statusCode: err.response?.statusCode,
      headers: err.response?.headers.map,
      request: err.requestOptions,
    );
    handler.next(err);
  }

  /// Derives a Retry-After cooldown from a 429 response: the `Retry-After`
  /// seconds header first, falling back to the burst reset window, then a
  /// conservative 5 seconds. Returns null when no cooldown should apply.
  static Duration? _retryAfterCooldown(DioException err) {
    final retryAfterRaw = err.response?.headers.value("retry-after");
    final seconds = int.tryParse(retryAfterRaw ?? "");
    if (seconds != null && seconds > 0) {
      return Duration(seconds: seconds);
    }
    final burstResetRaw = err.response?.headers.value(
      "x-ratelimit-burst-reset",
    );
    final burstReset = int.tryParse(burstResetRaw ?? "");
    final now = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
    if (burstReset != null && burstReset > now) {
      return Duration(seconds: burstReset - now);
    }
    return const Duration(seconds: 5);
  }
}
