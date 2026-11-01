import "dart:async";
import "dart:collection";
import "dart:math";

import "package:clock/clock.dart";
import "package:dio/dio.dart";
import "package:flutter/widgets.dart";
import "package:takion/src/core/logging/app_logger.dart";
import "package:takion/src/core/network/request_priority.dart";

enum RequestDispatch { sent, dropped }

/// Snapshot of the rate-limit counters observed from Metron responses.
///
/// In addition to the in-memory burst/sustained window counters, the state
/// carries [retryAfterUntil]: an absolute UTC epoch-seconds deadline computed
/// from a `Retry-After` header (or a 429 reset header). The whole state is
/// JSON-serializable so it can be persisted to SQLite ([SyncMetaDao] key
/// `ratelimit:<accountId>`) and restored after the process is killed, which
/// prevents background jobs from firing into a known rate-limit blackout.
class RateLimitState {
  final int sustainedLimit;
  final int sustainedRemaining;
  final int sustainedReset;
  final int burstLimit;
  final int burstRemaining;
  final int burstReset;

  /// Absolute UTC epoch-seconds deadline until which all requests are
  /// throttled after a 429 `Retry-After`. `0` means no active cooldown.
  final int retryAfterUntil;
  final bool hasObservedHeaders;

  const RateLimitState({
    this.sustainedLimit = 5000,
    this.sustainedRemaining = 5000,
    this.sustainedReset = 0,
    this.burstLimit = 20,
    this.burstRemaining = 20,
    this.burstReset = 0,
    this.retryAfterUntil = 0,
    this.hasObservedHeaders = false,
  });

  bool get isRetryAfterActive => retryAfterUntil > _now();

  bool get isSustainedExhausted =>
      sustainedRemaining <= 0 && sustainedReset > _now();

  /// True while any form of rate-limit cooldown blocks new requests.
  bool get isBlocked => isSustainedExhausted || isRetryAfterActive;

  Duration? get sustainedWaitDuration {
    if (!isSustainedExhausted) return null;
    final wait = sustainedReset - _now();
    return Duration(seconds: wait > 0 ? wait + 1 : 0);
  }

  Duration? get retryAfterWaitDuration {
    if (!isRetryAfterActive) return null;
    final wait = retryAfterUntil - _now();
    return Duration(seconds: wait > 0 ? wait + 1 : 0);
  }

  /// The latest UTC time at which requests may be dispatched again, or null
  /// when no sustained-reset or Retry-After cooldown is active.
  DateTime? get blockedUntil {
    final now = _now();
    var latest = 0;
    if (retryAfterUntil > now) latest = retryAfterUntil;
    if (sustainedRemaining <= 0 &&
        sustainedReset > now &&
        sustainedReset > latest) {
      latest = sustainedReset;
    }
    if (latest == 0) return null;
    return DateTime.fromMillisecondsSinceEpoch(latest * 1000, isUtc: true);
  }

  Map<String, dynamic> toJson() => {
    "sustainedLimit": sustainedLimit,
    "sustainedRemaining": sustainedRemaining,
    "sustainedReset": sustainedReset,
    "burstLimit": burstLimit,
    "burstRemaining": burstRemaining,
    "burstReset": burstReset,
    "retryAfterUntil": retryAfterUntil,
    "hasObservedHeaders": hasObservedHeaders,
  };

  factory RateLimitState.fromJson(Map<String, dynamic> json) => RateLimitState(
    sustainedLimit: (json["sustainedLimit"] as num?)?.toInt() ?? 5000,
    sustainedRemaining: (json["sustainedRemaining"] as num?)?.toInt() ?? 5000,
    sustainedReset: (json["sustainedReset"] as num?)?.toInt() ?? 0,
    burstLimit: (json["burstLimit"] as num?)?.toInt() ?? 20,
    burstRemaining: (json["burstRemaining"] as num?)?.toInt() ?? 20,
    burstReset: (json["burstReset"] as num?)?.toInt() ?? 0,
    retryAfterUntil: (json["retryAfterUntil"] as num?)?.toInt() ?? 0,
    hasObservedHeaders: json["hasObservedHeaders"] as bool? ?? false,
  );

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

/// Paces Metron API requests through per-minute burst and daily sustained
/// budgets while preserving strict priority ordering.
///
/// Phase 5 concurrency invariants:
/// - At most [maxConcurrent] requests are in flight at any time.
/// - At most [reservedForeground] of those slots are withheld from
///   background work so interactive user actions are never starved.
/// - At most [maxConcurrentPagination] pagination/snapshot scans run at any
///   time; non-pagination work flows around a blocked scan.
/// - Any `Retry-After` cooldown blocks dispatch and is surfaced through
///   [rateLimitedUntil] so callers can persist/reschedule instead of sleeping.
class MetronRequestScheduler {
  MetronRequestScheduler({
    this.maxRequestsPerMinute = 20,
    this.fallbackDailyLimit = 5000,
    this.reservedForeground = 1,
    this.maxConcurrent = 3,
    this.maxConcurrentPagination = 1,
    this.backgroundMaxWait = const Duration(seconds: 30),
    this.onStateChanged,
  }) {
    _sustainedLimit = fallbackDailyLimit;
    _sustainedRemaining = fallbackDailyLimit;
    _burstLimit = maxRequestsPerMinute;
    _burstRemaining = maxRequestsPerMinute;
    stateNotifier.value = state;
  }

  final int maxRequestsPerMinute;
  final int fallbackDailyLimit;

  /// Number of concurrent request slots withheld from background work.
  /// Clamped to `maxConcurrent - 1` so a single-slot scheduler cannot
  /// deadlock background requests forever.
  final int reservedForeground;
  final int maxConcurrent;

  /// Maximum number of concurrent pagination/snapshot scans.
  final int maxConcurrentPagination;
  final Duration backgroundMaxWait;

  /// Invoked (synchronously) whenever the observable state changes. Callers
  /// typically debounce and persist the state to SQLite here.
  final void Function(RateLimitState state)? onStateChanged;

  int get _effectiveForegroundReservation =>
      min(reservedForeground, max(0, maxConcurrent - 1));

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
  int _burstLimit = 20;
  int _burstRemaining = 20;
  int _burstReset = 0;
  int _retryAfterUntil = 0;
  bool _hasObservedHeaders = false;

  int _activeRequests = 0;
  int _activePaginationScans = 0;
  Timer? _wakeTimer;

  int get burstLimit => _burstLimit;

  /// Number of requests currently in flight.
  int get activeRequestCount => _activeRequests;

  /// Number of pagination/snapshot scans currently in flight.
  int get activePaginationScanCount => _activePaginationScans;

  final ValueNotifier<RateLimitState> stateNotifier = ValueNotifier(
    const RateLimitState(),
  );

  RateLimitState get state => RateLimitState(
    sustainedLimit: _sustainedLimit,
    sustainedRemaining: _sustainedRemaining,
    sustainedReset: _sustainedReset,
    burstLimit: _burstLimit,
    burstRemaining: _burstRemaining,
    burstReset: _burstReset,
    retryAfterUntil: _retryAfterUntil,
    hasObservedHeaders: _hasObservedHeaders,
  );

  void _notify() {
    stateNotifier.value = state;
    onStateChanged?.call(state);
  }

  bool get _sustainedExhausted =>
      _sustainedRemaining <= 0 &&
      _sustainedReset > clock.now().millisecondsSinceEpoch ~/ 1000;

  bool get _retryAfterActive =>
      _retryAfterUntil > clock.now().millisecondsSinceEpoch ~/ 1000;

  bool get _isBlocked => _sustainedExhausted || _retryAfterActive;

  /// The latest UTC time at which any request may be dispatched again, or
  /// null when no sustained-reset or Retry-After cooldown is active. Used by
  /// the sync engine to reschedule durable jobs instead of sleeping.
  DateTime? get rateLimitedUntil {
    final now = clock.now().millisecondsSinceEpoch ~/ 1000;
    var latest = 0;
    if (_retryAfterUntil > now) latest = _retryAfterUntil;
    if (_sustainedRemaining <= 0 && _sustainedReset > now) {
      latest = max(latest, _sustainedReset);
    }
    if (latest == 0) return null;
    return DateTime.fromMillisecondsSinceEpoch(latest * 1000, isUtc: true);
  }

  /// Hydrates scheduler state from a persisted snapshot (e.g. after the app
  /// process was killed during a 429 cooldown). Counters and the
  /// Retry-After deadline are restored so requests remain throttled without
  /// needing to hit the network first.
  void restoreState(RateLimitState restored) {
    _sustainedLimit = restored.sustainedLimit;
    _sustainedRemaining = restored.sustainedRemaining;
    _sustainedReset = restored.sustainedReset;
    _burstLimit = restored.burstLimit;
    _burstRemaining = restored.burstRemaining;
    _burstReset = restored.burstReset;
    _retryAfterUntil = restored.retryAfterUntil;
    _hasObservedHeaders = restored.hasObservedHeaders;
    _notify();
    _pump();
  }

  /// Starts a Retry-After cooldown of [duration] measured from now. Relative
  /// duration (not a server timestamp) keeps the deadline safe against clock
  /// drift between the device and Metron.
  void noteRetryAfter(Duration duration) {
    noteRetryAfterUntil(clock.now().toUtc().add(duration));
  }

  /// Starts a Retry-After cooldown until [untilUtc], keeping the later of
  /// the new deadline and any cooldown already in effect.
  void noteRetryAfterUntil(DateTime untilUtc) {
    final until = untilUtc.toUtc();
    final untilSeconds = until.millisecondsSinceEpoch ~/ 1000;
    if (untilSeconds <= _retryAfterUntil) return;
    _retryAfterUntil = untilSeconds;
    _notify();
    _scheduleWake();
  }

  /// Cancels the pending wake timer. Call when this scheduler instance is
  /// discarded so no background timer outlives it.
  void dispose() {
    _wakeTimer?.cancel();
    _wakeTimer = null;
  }

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

  void requestCompleted({RequestOptions? request}) {
    _activeRequests = max(0, _activeRequests - 1);
    if (request != null && isPaginationScan(request)) {
      _activePaginationScans = max(0, _activePaginationScans - 1);
    }
    _pump();
  }

  void onResponse(
    Map<String, List<String>> headers, {
    RequestOptions? request,
  }) {
    if (headers.isNotEmpty) _updateFromHeaders(headers);
    _notify();
    requestCompleted(request: request);
  }

  void onError({
    required int? statusCode,
    Map<String, List<String>>? headers,
    RequestOptions? request,
  }) {
    if (statusCode != 429) {
      _sustainedRemaining = min(_sustainedLimit, _sustainedRemaining + 1);
      _burstRemaining = min(_burstLimit, _burstRemaining + 1);
    }
    if (headers != null && headers.isNotEmpty) _updateFromHeaders(headers);
    _notify();
    requestCompleted(request: request);
  }

  void _pump() {
    _pruneWindow();
    _applyDeadlines();
    if (_isBlocked) {
      _scheduleWake();
      return;
    }
    while (_activeRequests < maxConcurrent) {
      final availableSlots = maxConcurrent - _activeRequests;
      final next = _nextDispatchable(availableSlots: availableSlots);
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

  /// Returns the next request that may dispatch given [availableSlots], or
  /// null when the head of every queue is blocked.
  ///
  /// Ordering rules:
  /// - Queues are scanned in strict priority order.
  /// - Background requests may not occupy the slots reserved for foreground
  ///   work; when the reservation is hit the scan stops (queue order kept).
  /// - A pagination scan blocked by [maxConcurrentPagination] is skipped so
  ///   non-pagination work flows around it.
  /// - Rate-window blocks (burst/sustained) stop the scan to keep ordering.
  _ScheduledRequest? _nextDispatchable({required int availableSlots}) {
    final reservation = _effectiveForegroundReservation;
    for (final q in _queue) {
      for (final candidate in q) {
        if (candidate.priority.isBackground && availableSlots <= reservation) {
          return null;
        }
        if (isPaginationScan(candidate.request) &&
            _activePaginationScans >= maxConcurrentPagination) {
          continue;
        }
        if (!_canDispatch(candidate)) return null;
        return candidate;
      }
    }
    return null;
  }

  bool _canDispatch(_ScheduledRequest req) {
    if (_isBlocked) return false;
    if (_recentRequests.length >= _burstLimit) return false;
    if (req.priority.isBackground) {
      final bgCap = max(1, _burstLimit - reservedForeground);
      if (_recentBackgroundRequests.length >= bgCap) return false;
    }
    return true;
  }

  void _dispatch(_ScheduledRequest req) {
    _queue[req.priority.level].remove(req);
    _activeRequests++;
    if (isPaginationScan(req.request)) _activePaginationScans++;
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

    if (_recentRequests.length >= _burstLimit) {
      nextWake = _timestampToDateTime(_recentRequests.first + oneMinuteMs);
    }
    final bgCap = max(1, _burstLimit - reservedForeground);
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
    if (_retryAfterActive) {
      nextWake = _earlier(
        nextWake,
        _timestampToDateTime(_retryAfterUntil * 1000),
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
    final burstLimit = _parseIntHeader(headers, "x-ratelimit-burst-limit");
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
    if (burstLimit != null) {
      _burstLimit = burstLimit;
      _hasObservedHeaders = true;
    }
    if (burstRemaining != null) {
      _burstRemaining = burstRemaining;
      // Infer total burst limit: remaining + already dispatched in this window
      final inferred = burstRemaining + _recentRequests.length;
      if (inferred > _burstLimit) _burstLimit = inferred;
    }
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

/// Computes the minimum delay between sequential Metron API requests
/// based on the current burst limit, with a 200ms safety margin.
Duration rateLimitDelayFromBurstLimit(int burstLimit) {
  final ms = 60000 ~/ burstLimit + 200;
  return Duration(milliseconds: ms);
}
