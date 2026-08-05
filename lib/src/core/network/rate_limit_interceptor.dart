import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:synchronized/synchronized.dart';

class RateLimitState {
  final int sustainedLimit;
  final int sustainedRemaining;
  final int sustainedReset;
  final int burstRemaining;
  final int burstReset;

  const RateLimitState({
    this.sustainedLimit = 4800,
    this.sustainedRemaining = 4800,
    this.sustainedReset = 0,
    this.burstRemaining = 18,
    this.burstReset = 0,
  });

  bool get isSustainedExhausted =>
      sustainedRemaining <= 0 && sustainedReset > _now();

  Duration? get sustainedWaitDuration {
    if (!isSustainedExhausted) return null;
    final wait = sustainedReset - _now();
    return Duration(seconds: wait > 0 ? wait + 1 : 0);
  }

  static int _now() => DateTime.now().millisecondsSinceEpoch ~/ 1000;
}

class RateLimitInterceptor extends Interceptor {
  final _lock = Lock();

  final List<int> _recentRequests = [];

  int _sustainedLimit = 4800;
  int _sustainedRemaining = 4800;
  int _sustainedReset = 0;
  int _burstRemaining = 18;
  int _burstReset = 0;

  final ValueNotifier<RateLimitState> stateNotifier = ValueNotifier(
    const RateLimitState(),
  );

  final int maxRequestsPerMinute;
  final int fallbackDailyLimit;

  RateLimitInterceptor({
    this.maxRequestsPerMinute = 18,
    this.fallbackDailyLimit = 4800,
  }) {
    _sustainedLimit = fallbackDailyLimit;
    _sustainedRemaining = fallbackDailyLimit;
    _burstRemaining = maxRequestsPerMinute;
    stateNotifier.value = state;
  }

  RateLimitState get state => RateLimitState(
    sustainedLimit: _sustainedLimit,
    sustainedRemaining: _sustainedRemaining,
    sustainedReset: _sustainedReset,
    burstRemaining: _burstRemaining,
    burstReset: _burstReset,
  );

  void _notify() => stateNotifier.value = state;

  void _updateFromHeaders(Map<String, List<String>> headers) {
    final sustainedLimit = _parseIntHeader(
      headers,
      'x-ratelimit-sustained-limit',
    );
    final sustainedRemaining = _parseIntHeader(
      headers,
      'x-ratelimit-sustained-remaining',
    );
    final sustainedReset = _parseIntHeader(
      headers,
      'x-ratelimit-sustained-reset',
    );
    final burstRemaining = _parseIntHeader(
      headers,
      'x-ratelimit-burst-remaining',
    );
    final burstReset = _parseIntHeader(headers, 'x-ratelimit-burst-reset');

    if (sustainedLimit != null) _sustainedLimit = sustainedLimit;
    if (sustainedRemaining != null) _sustainedRemaining = sustainedRemaining;
    if (sustainedReset != null) _sustainedReset = sustainedReset;
    if (burstRemaining != null) _burstRemaining = burstRemaining;
    if (burstReset != null) _burstReset = burstReset;
  }

  int? _parseIntHeader(Map<String, List<String>> headers, String name) {
    final value = headers[name]?.firstOrNull;
    if (value == null) return null;
    return int.tryParse(value);
  }

  // Returns null if the budget allows the request, or a Duration to wait before retrying.
  Future<Duration?> _tryConsumeMinuteBudget() {
    return _lock.synchronized<Duration?>(() async {
      final now = DateTime.now();
      final nowMs = now.millisecondsSinceEpoch;

      _recentRequests.removeWhere(
        (ms) => nowMs - ms > const Duration(minutes: 1).inMilliseconds,
      );

      if (_recentRequests.length < maxRequestsPerMinute) {
        _recentRequests.add(nowMs);
        return null;
      }

      final sleepTime =
          const Duration(minutes: 1) -
          now.difference(
            DateTime.fromMillisecondsSinceEpoch(_recentRequests.first),
          );
      return sleepTime > Duration.zero
          ? sleepTime + const Duration(milliseconds: 100)
          : const Duration(milliseconds: 100);
    });
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      // Check sustained (daily) budget first.
      final sustainedWait = state.sustainedWaitDuration;
      if (sustainedWait != null) {
        await Future.delayed(sustainedWait);
      }

      // Check burst (minute) budget.
      while (true) {
        final wait = await _tryConsumeMinuteBudget();
        if (wait == null) break;
        await Future.delayed(wait);
      }

      // Optimistic decrement for the upcoming request.
      _sustainedRemaining = max(0, _sustainedRemaining - 1);
      _burstRemaining = max(0, _burstRemaining - 1);
      _notify();

      handler.next(options);
    } catch (e) {
      if (e is DioException) {
        handler.reject(e);
      } else {
        handler.reject(
          DioException(requestOptions: options, error: e.toString()),
        );
      }
    }
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.headers.map.isNotEmpty) {
      _updateFromHeaders(response.headers.map);
    }
    _notify();
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final statusCode = err.response?.statusCode;
    if (statusCode != 429) {
      _sustainedRemaining = min(_sustainedLimit, _sustainedRemaining + 1);
      _burstRemaining = min(maxRequestsPerMinute, _burstRemaining + 1);
    }
    if (err.response?.headers.map case final headers? when headers.isNotEmpty) {
      _updateFromHeaders(headers);
    }
    _notify();
    handler.next(err);
  }
}
