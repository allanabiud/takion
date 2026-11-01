import "dart:collection";
import "dart:convert";

import "package:flutter/foundation.dart";
import "package:takion/src/core/logging/app_logger.dart";

class ApiCallRecord {
  final String path;
  final DateTime timestamp;
  final Duration duration;
  final int? statusCode;

  ApiCallRecord({
    required this.path,
    required this.timestamp,
    required this.duration,
    this.statusCode,
  });

  Map<String, dynamic> toJson() => {
    "path": path,
    "timestamp": timestamp.toIso8601String(),
    "durationMs": duration.inMilliseconds,
    "statusCode": statusCode,
  };
}

/// Classification of how a request was satisfied by the cache layer.
enum CacheOutcome {
  /// Served from a fresh local cache entry without touching the network.
  cacheHit,

  /// No usable cache entry existed; a network fetch was required.
  cacheMiss,

  /// A conditional request returned 304 and the cached payload was restored.
  validation304Restored,

  /// A network fetch returned a fresh 200 payload.
  network200Fresh,
}

class PerformanceMetrics extends ChangeNotifier {
  final Map<String, int> _cacheHits = <String, int>{};
  final Map<String, int> _cacheMisses = <String, int>{};
  final Map<String, int> _apiCalls = <String, int>{};
  final Map<String, int> _providerCalls = <String, int>{};
  final Map<String, int> _providerTotalMs = <String, int>{};
  final List<ApiCallRecord> _recentApiRecords = [];
  final Map<CacheOutcome, int> _cacheOutcomes = <CacheOutcome, int>{
    for (final outcome in CacheOutcome.values) outcome: 0,
  };
  final Map<String, int> _requestsByEndpoint = <String, int>{};
  final Map<String, int> _firstLocalContentMs = <String, int>{};

  int _http429Count = 0;
  int _retryAfter429Count = 0;
  int _totalApiRequests = 0;
  int _rateLimitThrottleMs = 0;
  int _conflictCount = 0;

  Map<String, int> get cacheHits => UnmodifiableMapView(_cacheHits);
  Map<String, int> get cacheMisses => UnmodifiableMapView(_cacheMisses);
  Map<String, int> get apiCalls => UnmodifiableMapView(_apiCalls);
  Map<String, int> get providerCalls => UnmodifiableMapView(_providerCalls);
  Map<String, int> get providerTotalMs => UnmodifiableMapView(_providerTotalMs);
  List<ApiCallRecord> get recentApiRecords =>
      UnmodifiableListView(_recentApiRecords);
  Map<CacheOutcome, int> get cacheOutcomes =>
      UnmodifiableMapView(_cacheOutcomes);
  Map<String, int> get requestsByEndpoint =>
      UnmodifiableMapView(_requestsByEndpoint);
  Map<String, int> get firstLocalContentMs =>
      UnmodifiableMapView(_firstLocalContentMs);

  int get http429Count => _http429Count;
  int get retryAfter429Count => _retryAfter429Count;
  int get totalApiRequests => _totalApiRequests;

  /// Cumulative time spent throttled by rate limits (429 cooldowns and
  /// scheduler-imposed delays).
  Duration get rateLimitThrottleDuration =>
      Duration(milliseconds: _rateLimitThrottleMs);

  /// Number of remote-vs-local conflict resolutions observed.
  int get conflictCount => _conflictCount;

  /// Combined cache hit ratio: fresh hits plus 304 restorations over all
  /// classified cache outcomes.
  double get cacheHitRatio {
    final total = _cacheOutcomes.values.fold<int>(0, (a, b) => a + b);
    if (total == 0) return 0.0;
    final hits =
        (_cacheOutcomes[CacheOutcome.cacheHit] ?? 0) +
        (_cacheOutcomes[CacheOutcome.validation304Restored] ?? 0);
    return hits / total;
  }

  void recordCacheHit(String key) {
    _cacheHits[key] = (_cacheHits[key] ?? 0) + 1;
    recordCacheOutcome(CacheOutcome.cacheHit);
  }

  void recordCacheMiss(String key) {
    _cacheMisses[key] = (_cacheMisses[key] ?? 0) + 1;
    recordCacheOutcome(CacheOutcome.cacheMiss);
  }

  void recordCacheOutcome(CacheOutcome outcome, {int count = 1}) {
    _cacheOutcomes[outcome] = (_cacheOutcomes[outcome] ?? 0) + count;
    notifyListeners();
  }

  void recordApiCall(String key, {Duration? duration, int? statusCode}) {
    _apiCalls[key] = (_apiCalls[key] ?? 0) + 1;
    _requestsByEndpoint[key] = (_requestsByEndpoint[key] ?? 0) + 1;
    _totalApiRequests++;

    if (duration != null) {
      _recentApiRecords.insert(
        0,
        ApiCallRecord(
          path: key,
          timestamp: DateTime.now(),
          duration: duration,
          statusCode: statusCode,
        ),
      );
      if (_recentApiRecords.length > 20) {
        _recentApiRecords.removeLast();
      }
    }

    notifyListeners();
  }

  void recordHttp429() {
    _http429Count++;
    notifyListeners();
  }

  void recordRetryAfter429() {
    _retryAfter429Count++;
    notifyListeners();
  }

  /// Records time spent throttled by a rate-limit cooldown.
  void recordThrottleDelay(Duration duration) {
    if (duration <= Duration.zero) return;
    _rateLimitThrottleMs += duration.inMilliseconds;
    notifyListeners();
  }

  /// Records a remote-vs-local conflict resolution.
  void recordConflict({int count = 1}) {
    _conflictCount += count;
    notifyListeners();
  }

  /// Records how long a screen took to render its first local (cached) content.
  void recordFirstLocalContent(String screen, Duration duration) {
    _firstLocalContentMs[screen] = duration.inMilliseconds;
    notifyListeners();
  }

  void recordProviderTiming(String provider, Duration duration) {
    _providerCalls[provider] = (_providerCalls[provider] ?? 0) + 1;
    _providerTotalMs[provider] =
        (_providerTotalMs[provider] ?? 0) + duration.inMilliseconds;
    notifyListeners();
  }

  Future<T> trackProvider<T>(
    String provider,
    Future<T> Function() action,
  ) async {
    final sw = Stopwatch()..start();
    try {
      return await action();
    } finally {
      sw.stop();
      recordProviderTiming(provider, sw.elapsed);
    }
  }

  /// Builds a JSON diagnostics report suitable for bug reports. The output
  /// is passed through [LogSanitizer.sanitize] so tokens, authorization
  /// headers, and passwords never leave the device in clear text.
  String buildDiagnosticsReport({Map<String, dynamic> extra = const {}}) {
    final report = <String, dynamic>{
      "generatedAt": DateTime.now().toUtc().toIso8601String(),
      "network": {
        "totalApiRequests": _totalApiRequests,
        "http429Count": _http429Count,
        "retryAfter429Count": _retryAfter429Count,
        "throttleDurationMs": _rateLimitThrottleMs,
        "requestsByEndpoint": _requestsByEndpoint,
      },
      "cache": {
        "hitRatio": double.parse(cacheHitRatio.toStringAsFixed(3)),
        "outcomes": {
          for (final entry in _cacheOutcomes.entries)
            entry.key.name: entry.value,
        },
        "hitsByCategory": _cacheHits,
        "missesByCategory": _cacheMisses,
      },
      "sync": {"conflictCount": _conflictCount},
      "firstLocalContentMs": _firstLocalContentMs,
      "providerLatencyMs": _providerTotalMs,
      "recentApiCalls": _recentApiRecords
          .take(20)
          .map((r) => r.toJson())
          .toList(),
      if (extra.isNotEmpty) "extra": extra,
    };
    return LogSanitizer.sanitize(jsonEncode(report));
  }

  void clear() {
    _cacheHits.clear();
    _cacheMisses.clear();
    _apiCalls.clear();
    _providerCalls.clear();
    _providerTotalMs.clear();
    _recentApiRecords.clear();
    _cacheOutcomes.updateAll((_, _) => 0);
    _requestsByEndpoint.clear();
    _firstLocalContentMs.clear();
    _http429Count = 0;
    _retryAfter429Count = 0;
    _totalApiRequests = 0;
    _rateLimitThrottleMs = 0;
    _conflictCount = 0;
    notifyListeners();
  }
}

class AppPerformanceMetrics {
  AppPerformanceMetrics._();

  static final PerformanceMetrics instance = PerformanceMetrics();
}
