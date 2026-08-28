import "package:flutter/foundation.dart";
import "package:takion/src/core/logging/app_logger.dart";

/// Metric record created by [PerformanceTracer].
class PerformanceTrace {
  final String name;
  final Duration duration;
  final Map<String, dynamic> attributes;
  final DateTime timestamp;

  const PerformanceTrace({
    required this.name,
    required this.duration,
    required this.attributes,
    required this.timestamp,
  });

  @override
  String toString() =>
      "PerformanceTrace(name: $name, duration: ${duration.inMilliseconds}ms, attributes: $attributes)";
}

/// Lightweight performance tracing utility for screen load, DB query, cache, and sync measurement.
class PerformanceTracer {
  PerformanceTracer._();

  static final List<PerformanceTrace> _recentTraces = [];
  static int _cacheHits = 0;
  static int _cacheMisses = 0;
  static int _networkRequestCount = 0;

  static List<PerformanceTrace> get recentTraces =>
      List.unmodifiable(_recentTraces);
  static int get cacheHits => _cacheHits;
  static int get cacheMisses => _cacheMisses;
  static int get networkRequestCount => _networkRequestCount;
  static double get cacheHitRatio => (_cacheHits + _cacheMisses) == 0
      ? 0.0
      : _cacheHits / (_cacheHits + _cacheMisses);

  /// Measures the execution duration of an asynchronous operation [action].
  static Future<T> traceAsync<T>(
    String name,
    Future<T> Function() action, {
    Map<String, dynamic> attributes = const {},
  }) async {
    final stopwatch = Stopwatch()..start();
    try {
      final result = await action();
      stopwatch.stop();
      _record(name, stopwatch.elapsed, attributes);
      return result;
    } catch (e) {
      stopwatch.stop();
      _record(name, stopwatch.elapsed, {...attributes, "error": e.toString()});
      rethrow;
    }
  }

  /// Measures the execution duration of a synchronous operation [action].
  static T traceSync<T>(
    String name,
    T Function() action, {
    Map<String, dynamic> attributes = const {},
  }) {
    final stopwatch = Stopwatch()..start();
    try {
      final result = action();
      stopwatch.stop();
      _record(name, stopwatch.elapsed, attributes);
      return result;
    } catch (e) {
      stopwatch.stop();
      _record(name, stopwatch.elapsed, {...attributes, "error": e.toString()});
      rethrow;
    }
  }

  /// Records a cache event (hit or miss).
  static void recordCacheEvent({required bool isHit, String? key}) {
    if (isHit) {
      _cacheHits++;
    } else {
      _cacheMisses++;
    }
    if (kDebugMode) {
      AppLogger.debug(
        "PerformanceTracer Cache ${isHit ? 'HIT' : 'MISS'}: key=$key (hitRatio=${(cacheHitRatio * 100).toStringAsFixed(1)}%)",
      );
    }
  }

  /// Increments the network request counter.
  static void recordNetworkRequest({String? endpoint}) {
    _networkRequestCount++;
    if (kDebugMode) {
      AppLogger.debug(
        "PerformanceTracer Network Request: endpoint=$endpoint total=$_networkRequestCount",
      );
    }
  }

  /// Resets recorded counters and trace history (useful for test isolation).
  static void reset() {
    _recentTraces.clear();
    _cacheHits = 0;
    _cacheMisses = 0;
    _networkRequestCount = 0;
  }

  static void _record(
    String name,
    Duration duration,
    Map<String, dynamic> attributes,
  ) {
    final trace = PerformanceTrace(
      name: name,
      duration: duration,
      attributes: attributes,
      timestamp: DateTime.now().toUtc(),
    );
    _recentTraces.add(trace);
    if (_recentTraces.length > 200) {
      _recentTraces.removeAt(0);
    }
    if (kDebugMode) {
      AppLogger.debug(
        "PerformanceTracer [$name]: ${duration.inMilliseconds}ms $attributes",
      );
    }
  }
}
