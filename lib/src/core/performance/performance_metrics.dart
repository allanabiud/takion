import "dart:collection";
import "package:flutter/foundation.dart";

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
}

class PerformanceMetrics extends ChangeNotifier {
  final Map<String, int> _cacheHits = <String, int>{};
  final Map<String, int> _cacheMisses = <String, int>{};
  final Map<String, int> _apiCalls = <String, int>{};
  final Map<String, int> _providerCalls = <String, int>{};
  final Map<String, int> _providerTotalMs = <String, int>{};
  final List<ApiCallRecord> _recentApiRecords = [];

  int _http429Count = 0;
  int _retryAfter429Count = 0;
  int _totalApiRequests = 0;

  Map<String, int> get cacheHits => UnmodifiableMapView(_cacheHits);
  Map<String, int> get cacheMisses => UnmodifiableMapView(_cacheMisses);
  Map<String, int> get apiCalls => UnmodifiableMapView(_apiCalls);
  Map<String, int> get providerCalls => UnmodifiableMapView(_providerCalls);
  Map<String, int> get providerTotalMs => UnmodifiableMapView(_providerTotalMs);
  List<ApiCallRecord> get recentApiRecords =>
      UnmodifiableListView(_recentApiRecords);

  int get http429Count => _http429Count;
  int get retryAfter429Count => _retryAfter429Count;
  int get totalApiRequests => _totalApiRequests;

  void recordCacheHit(String key) {
    _cacheHits[key] = (_cacheHits[key] ?? 0) + 1;
    notifyListeners();
  }

  void recordCacheMiss(String key) {
    _cacheMisses[key] = (_cacheMisses[key] ?? 0) + 1;
    notifyListeners();
  }

  void recordApiCall(String key, {Duration? duration, int? statusCode}) {
    _apiCalls[key] = (_apiCalls[key] ?? 0) + 1;
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

  void clear() {
    _cacheHits.clear();
    _cacheMisses.clear();
    _apiCalls.clear();
    _providerCalls.clear();
    _providerTotalMs.clear();
    _recentApiRecords.clear();
    _http429Count = 0;
    _retryAfter429Count = 0;
    _totalApiRequests = 0;
    notifyListeners();
  }
}

class AppPerformanceMetrics {
  AppPerformanceMetrics._();

  static final PerformanceMetrics instance = PerformanceMetrics();
}
