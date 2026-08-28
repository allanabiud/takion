import "dart:async";
import "dart:collection";
import "dart:math";

import "package:clock/clock.dart";
import "package:dio/dio.dart";
import "package:flutter/widgets.dart";
import "package:takion/src/core/logging/app_logger.dart";
import "package:takion/src/core/network/request_priority.dart";

enum RequestDispatch { sent, dropped }

class RateLimitState {
  final int sustainedLimit;
  final int sustainedRemaining;
  final int sustainedReset;
  final int burstRemaining;
  final int burstReset;
  final bool hasObservedHeaders;

  const RateLimitState({
    this.sustainedLimit = 5000,
    this.sustainedRemaining = 5000,
    this.sustainedReset = 0,
    this.burstRemaining = 20,
    this.burstReset = 0,
    this.hasObservedHeaders = false,
  });

  bool get isSustainedExhausted =>
      sustainedRemaining <= 0 && sustainedReset > _now();

  Duration? get sustainedWaitDuration {
    if (!isSustainedExhausted) return null;
    final wait = sustainedReset - _now();
    return Duration(seconds: wait > 0 ? wait + 1 : 0);
  }

  static int _now() => clock.now().millisecondsSinceEpoch ~/ 1000;
}

class _ScheduledRequest {
  _ScheduledRequest({
    required this.request,
    required this.priority,
    required this.enqueuedAt,
    required this.completer,
  });

  final RequestOptions request;
  RequestPriority priority;
  final DateTime enqueuedAt;
  final Completer<RequestDispatch> completer;
}

class MetronRequestScheduler {
  MetronRequestScheduler({
    this.maxRequestsPerMinute = 20,
    this.fallbackDailyLimit = 5000,
    this.reservedForeground = 3,
    this.maxConcurrent = 8,
    this.backgroundMaxWait = const Duration(seconds: 30),
  }) {
    _sustainedLimit = fallbackDailyLimit;
    _sustainedRemaining = fallbackDailyLimit;
    _burstRemaining = maxRequestsPerMinute;
    stateNotifier.value = state;
  }

  final int maxRequestsPerMinute;
  final int fallbackDailyLimit;
  final int reservedForeground;
  final int maxConcurrent;
  final Duration backgroundMaxWait;

  final List<int> _recentRequests = [];
  final List<int> _recentBackgroundRequests = [];

  final List<Queue<_ScheduledRequest>> _queue = [
    Queue<_ScheduledRequest>(),
    Queue<_ScheduledRequest>(),
    Queue<_ScheduledRequest>(),
    Queue<_ScheduledRequest>(),
  ];

  int _sustainedLimit = 5000;
  int _sustainedRemaining = 5000;
  int _sustainedReset = 0;
  int _burstRemaining = 20;
  int _burstReset = 0;
  bool _hasObservedHeaders = false;

  int _activeRequests = 0;
  Timer? _wakeTimer;

  final ValueNotifier<RateLimitState> stateNotifier = ValueNotifier(
    const RateLimitState(),
  );

  RateLimitState get state => RateLimitState(
    sustainedLimit: _sustainedLimit,
    sustainedRemaining: _sustainedRemaining,
    sustainedReset: _sustainedReset,
    burstRemaining: _burstRemaining,
    burstReset: _burstReset,
    hasObservedHeaders: _hasObservedHeaders,
  );

  void _notify() => stateNotifier.value = state;

  bool get _sustainedExhausted =>
      _sustainedRemaining <= 0 &&
      _sustainedReset > clock.now().millisecondsSinceEpoch ~/ 1000;

  Future<RequestDispatch> enqueue({
    required RequestOptions request,
    required RequestPriority priority,
  }) {
    final completer = Completer<RequestDispatch>();
    _queue[priority.level].addLast(
      _ScheduledRequest(
        request: request,
        priority: priority,
        enqueuedAt: clock.now(),
        completer: completer,
      ),
    );
    _pump();
    return completer.future;
  }

  void requestCompleted() {
    _activeRequests = max(0, _activeRequests - 1);
    _pump();
  }

  void onResponse(Map<String, List<String>> headers) {
    if (headers.isNotEmpty) _updateFromHeaders(headers);
    _notify();
    requestCompleted();
  }

  void onError({required int? statusCode, Map<String, List<String>>? headers}) {
    if (statusCode != 429) {
      _sustainedRemaining = min(_sustainedLimit, _sustainedRemaining + 1);
      _burstRemaining = min(maxRequestsPerMinute, _burstRemaining + 1);
    }
    if (headers != null && headers.isNotEmpty) _updateFromHeaders(headers);
    _notify();
    requestCompleted();
  }

  void _pump() {
    _pruneWindow();
    _applyDeadlines();
    if (_sustainedExhausted) {
      _scheduleWake();
      return;
    }
    while (_activeRequests < maxConcurrent) {
      final next = _nextDispatchable();
      if (next == null) break;
      _dispatch(next);
    }
    _scheduleWake();
  }

  void _pruneWindow() {
    final nowMs = clock.now().millisecondsSinceEpoch;
    final oneMinuteMs = const Duration(minutes: 1).inMilliseconds;
    _recentRequests.removeWhere((ms) => nowMs - ms > oneMinuteMs);
    _recentBackgroundRequests.removeWhere((ms) => nowMs - ms > oneMinuteMs);
  }

  void _applyDeadlines() {
    final now = clock.now();
    final deadline = now.subtract(backgroundMaxWait);

    final dropQueue = _queue[RequestPriority.drop.level];
    while (dropQueue.isNotEmpty &&
        dropQueue.first.enqueuedAt.isBefore(deadline)) {
      final req = dropQueue.removeFirst();
      if (!req.completer.isCompleted) {
        AppLogger.debug(
          "Scheduler dropped P3 request ${req.request.path} (waited "
          "${backgroundMaxWait.inSeconds}s)",
        );
        req.completer.complete(RequestDispatch.dropped);
      }
    }

    final bgQueue = _queue[RequestPriority.background.level];
    while (bgQueue.isNotEmpty && bgQueue.first.enqueuedAt.isBefore(deadline)) {
      final req = bgQueue.removeFirst();
      req.priority = RequestPriority.normal;
      AppLogger.debug(
        "Scheduler promoted P2 request ${req.request.path} to foreground "
        "(waited ${backgroundMaxWait.inSeconds}s)",
      );
      _queue[RequestPriority.normal.level].addLast(req);
    }
  }

  _ScheduledRequest? _nextDispatchable() {
    for (var level = 0; level < _queue.length; level++) {
      final q = _queue[level];
      if (q.isEmpty) continue;
      final candidate = q.first;
      if (_canDispatch(candidate)) return candidate;
      return null;
    }
    return null;
  }

  bool _canDispatch(_ScheduledRequest req) {
    if (_sustainedExhausted) return false;
    if (_recentRequests.length >= maxRequestsPerMinute) return false;
    if (req.priority.isBackground) {
      final bgCap = max(1, maxRequestsPerMinute - reservedForeground);
      if (_recentBackgroundRequests.length >= bgCap) return false;
    }
    return true;
  }

  void _dispatch(_ScheduledRequest req) {
    _queue[req.priority.level].removeFirst();
    _activeRequests++;
    final nowMs = clock.now().millisecondsSinceEpoch;
    _recentRequests.add(nowMs);
    if (req.priority.isBackground) _recentBackgroundRequests.add(nowMs);
    _sustainedRemaining = max(0, _sustainedRemaining - 1);
    _burstRemaining = max(0, _burstRemaining - 1);
    _notify();
    if (!req.completer.isCompleted) {
      req.completer.complete(RequestDispatch.sent);
    }
  }

  void _scheduleWake() {
    _wakeTimer?.cancel();
    _wakeTimer = null;
    final now = clock.now();
    final oneMinuteMs = const Duration(minutes: 1).inMilliseconds;

    DateTime? nextWake;

    if (_recentRequests.length >= maxRequestsPerMinute) {
      nextWake = _timestampToDateTime(_recentRequests.first + oneMinuteMs);
    }
    final bgCap = max(1, maxRequestsPerMinute - reservedForeground);
    if (_recentBackgroundRequests.length >= bgCap) {
      final bgExpiry = _timestampToDateTime(
        _recentBackgroundRequests.first + oneMinuteMs,
      );
      nextWake = _earlier(nextWake, bgExpiry);
    }
    if (_sustainedExhausted) {
      nextWake = _earlier(
        nextWake,
        _timestampToDateTime(_sustainedReset * 1000),
      );
    }
    for (final level in [
      RequestPriority.background.level,
      RequestPriority.drop.level,
    ]) {
      for (final req in _queue[level]) {
        nextWake = _earlier(nextWake, req.enqueuedAt.add(backgroundMaxWait));
      }
    }

    if (nextWake == null) return;
    final delay = nextWake.difference(now);
    if (delay <= Duration.zero) {
      _pump();
      return;
    }
    _wakeTimer = Timer(delay + const Duration(milliseconds: 100), _pump);
  }

  DateTime? _earlier(DateTime? a, DateTime b) {
    if (a == null || b.isBefore(a)) return b;
    return a;
  }

  DateTime _timestampToDateTime(int msSinceEpoch) {
    return DateTime.fromMillisecondsSinceEpoch(msSinceEpoch, isUtc: true);
  }

  void _updateFromHeaders(Map<String, List<String>> headers) {
    final sustainedLimit = _parseIntHeader(
      headers,
      "x-ratelimit-sustained-limit",
    );
    final sustainedRemaining = _parseIntHeader(
      headers,
      "x-ratelimit-sustained-remaining",
    );
    final sustainedReset = _parseIntHeader(
      headers,
      "x-ratelimit-sustained-reset",
    );
    final burstRemaining = _parseIntHeader(
      headers,
      "x-ratelimit-burst-remaining",
    );
    final burstReset = _parseIntHeader(headers, "x-ratelimit-burst-reset");

    if (sustainedLimit != null) {
      _sustainedLimit = sustainedLimit;
      _hasObservedHeaders = true;
    }
    if (sustainedRemaining != null) {
      _sustainedRemaining = sustainedRemaining;
      _hasObservedHeaders = true;
    }
    if (sustainedReset != null) _sustainedReset = sustainedReset;
    if (burstRemaining != null) _burstRemaining = burstRemaining;
    if (burstReset != null) _burstReset = burstReset;
  }

  int? _parseIntHeader(Map<String, List<String>> headers, String name) {
    final target = name.toLowerCase();
    for (final entry in headers.entries) {
      if (entry.key.toLowerCase() == target) {
        final value = entry.value.firstOrNull;
        if (value == null) return null;
        return int.tryParse(value);
      }
    }
    return null;
  }
}
