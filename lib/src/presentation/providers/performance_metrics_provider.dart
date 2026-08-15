import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/core/performance/performance_metrics.dart";

final performanceMetricsProvider = Provider<PerformanceMetrics>((ref) {
  return AppPerformanceMetrics.instance;
});
