import "package:flutter_test/flutter_test.dart";
import "package:takion/src/core/diagnostics/performance_tracer.dart";

void main() {
  group("PerformanceTracer", () {
    setUp(PerformanceTracer.reset);

    test("records async trace with duration and attributes", () async {
      final res = await PerformanceTracer.traceAsync(
        "test_async_operation",
        () async {
          await Future.delayed(const Duration(milliseconds: 10));
          return 42;
        },
        attributes: {"screen": "test_screen"},
      );

      expect(res, 42);
      expect(PerformanceTracer.recentTraces, hasLength(1));
      final trace = PerformanceTracer.recentTraces.first;
      expect(trace.name, "test_async_operation");
      expect(trace.duration.inMilliseconds, greaterThanOrEqualTo(5));
      expect(trace.attributes["screen"], "test_screen");
    });

    test("records sync trace with duration and attributes", () {
      final res = PerformanceTracer.traceSync(
        "test_sync_operation",
        () => "hello",
        attributes: {"itemCount": 5},
      );

      expect(res, "hello");
      expect(PerformanceTracer.recentTraces, hasLength(1));
      final trace = PerformanceTracer.recentTraces.first;
      expect(trace.name, "test_sync_operation");
      expect(trace.attributes["itemCount"], 5);
    });

    test("tracks cache hit ratio accurately", () {
      PerformanceTracer.recordCacheEvent(isHit: true, key: "key1");
      PerformanceTracer.recordCacheEvent(isHit: true, key: "key2");
      PerformanceTracer.recordCacheEvent(isHit: false, key: "key3");

      expect(PerformanceTracer.cacheHits, 2);
      expect(PerformanceTracer.cacheMisses, 1);
      expect(PerformanceTracer.cacheHitRatio, closeTo(2 / 3, 0.01));
    });

    test("tracks network request count accurately", () {
      PerformanceTracer.recordNetworkRequest(endpoint: "/api/issue/1/");
      PerformanceTracer.recordNetworkRequest(endpoint: "/api/series/2/");

      expect(PerformanceTracer.networkRequestCount, 2);
    });

    test(
      "rethrows errors while recording trace with error attribute",
      () async {
        await expectLater(
          () => PerformanceTracer.traceAsync(
            "failing_operation",
            () async => throw Exception("something broke"),
          ),
          throwsA(isA<Exception>()),
        );

        expect(PerformanceTracer.recentTraces, hasLength(1));
        final trace = PerformanceTracer.recentTraces.first;
        expect(trace.name, "failing_operation");
        expect(trace.attributes["error"], contains("something broke"));
      },
    );
  });
}
