import "dart:convert";

import "package:flutter_test/flutter_test.dart";
import "package:takion/src/core/performance/performance_metrics.dart";

/// Phase 5 Step 3: cache-outcome accounting, quota/sync telemetry, and the
/// redacted diagnostics report.
void main() {
  late PerformanceMetrics metrics;

  setUp(() {
    metrics = PerformanceMetrics();
  });

  tearDown(() => metrics.clear);

  group("cache outcome accounting", () {
    test(
      "cacheHitRatio counts hits and 304 restorations over all outcomes",
      () {
        expect(
          metrics.cacheHitRatio,
          0.0,
          reason: "empty ratio starts at zero",
        );

        metrics.recordCacheOutcome(CacheOutcome.cacheHit, count: 3);
        metrics.recordCacheOutcome(
          CacheOutcome.validation304Restored,
          count: 2,
        );
        metrics.recordCacheOutcome(CacheOutcome.network200Fresh, count: 4);
        metrics.recordCacheOutcome(CacheOutcome.cacheMiss, count: 1);

        // (3 hits + 2 restorations) / 10 classified outcomes.
        expect(metrics.cacheHitRatio, 0.5);
        expect(metrics.cacheOutcomes[CacheOutcome.validation304Restored], 2);
      },
    );

    test("recordCacheHit and recordCacheMiss feed both maps and outcomes", () {
      metrics.recordCacheHit("series_details");
      metrics.recordCacheHit("series_details");
      metrics.recordCacheMiss("issue_search");

      expect(metrics.cacheHits["series_details"], 2);
      expect(metrics.cacheMisses["issue_search"], 1);
      expect(metrics.cacheOutcomes[CacheOutcome.cacheHit], 2);
      expect(metrics.cacheOutcomes[CacheOutcome.cacheMiss], 1);
    });

    test("listeners are notified on every recording", () {
      var notifications = 0;
      metrics.addListener(() => notifications++);

      metrics.recordCacheOutcome(CacheOutcome.cacheMiss);
      metrics.recordThrottleDelay(const Duration(seconds: 1));
      metrics.recordConflict();
      metrics.recordFirstLocalContent(
        "library",
        const Duration(milliseconds: 120),
      );

      expect(notifications, 4);
    });
  });

  group("quota and sync telemetry", () {
    test("throttle delays accumulate into a cumulative duration", () {
      metrics.recordThrottleDelay(const Duration(seconds: 5));
      metrics.recordThrottleDelay(const Duration(milliseconds: 1500));
      metrics.recordThrottleDelay(Duration.zero); // no-op guard

      expect(
        metrics.rateLimitThrottleDuration,
        const Duration(seconds: 6, milliseconds: 500),
      );
    });

    test(
      "conflicts and first-local-content latency are tracked per screen",
      () {
        metrics.recordConflict(count: 2);
        metrics.recordConflict();
        metrics.recordFirstLocalContent(
          "library",
          const Duration(milliseconds: 90),
        );
        metrics.recordFirstLocalContent(
          "issues",
          const Duration(milliseconds: 140),
        );

        expect(metrics.conflictCount, 3);
        expect(metrics.firstLocalContentMs["library"], 90);
        expect(metrics.firstLocalContentMs["issues"], 140);
      },
    );

    test(
      "api calls are bucketed by endpoint and capped at 20 recent records",
      () {
        for (var i = 0; i < 25; i++) {
          metrics.recordApiCall(
            "collection/",
            duration: Duration(milliseconds: i),
            statusCode: 200,
          );
        }

        expect(metrics.requestsByEndpoint["collection/"], 25);
        expect(metrics.totalApiRequests, 25);
        expect(metrics.recentApiRecords.length, 20);
        // Newest record first.
        expect(metrics.recentApiRecords.first.duration.inMilliseconds, 24);
      },
    );
  });

  group("buildDiagnosticsReport", () {
    test("report is valid JSON with network, cache, and sync sections", () {
      metrics.recordApiCall(
        "collection/",
        duration: const Duration(milliseconds: 12),
      );
      metrics.recordHttp429();
      metrics.recordRetryAfter429();
      metrics.recordCacheOutcome(CacheOutcome.validation304Restored);
      metrics.recordConflict();

      final decoded =
          jsonDecode(metrics.buildDiagnosticsReport()) as Map<String, dynamic>;

      final network = decoded["network"] as Map<String, dynamic>;
      expect(network["totalApiRequests"], 1);
      expect(network["http429Count"], 1);
      expect(network["retryAfter429Count"], 1);
      expect((network["requestsByEndpoint"] as Map)["collection/"], 1);

      final cache = decoded["cache"] as Map<String, dynamic>;
      expect(cache["outcomes"]["validation304Restored"], 1);

      expect((decoded["sync"] as Map)["conflictCount"], 1);
      expect(decoded["generatedAt"], isNotNull);
    });

    test("tokens, authorization headers, and passwords are redacted", () {
      final report = metrics.buildDiagnosticsReport(
        extra: {
          "token": "Bearer sekret-token-123",
          "auth": "Authorization: Basic Zm9vOmJhcg==",
          "password": "hunter2",
        },
      );

      expect(report, isNot(contains("sekret-token-123")));
      expect(report, isNot(contains("Zm9vOmJhcg==")));
      expect(report, isNot(contains("hunter2")));
      expect(report, contains("[REDACTED]"));
      // Redaction must not corrupt the JSON envelope.
      expect(jsonDecode(report), isA<Map<String, dynamic>>());
    });
  });

  test("clear resets counters, ratios, and recent records", () {
    metrics.recordCacheOutcome(CacheOutcome.cacheHit, count: 5);
    metrics.recordApiCall(
      "collection/",
      duration: const Duration(milliseconds: 3),
    );
    metrics.recordThrottleDelay(const Duration(seconds: 30));
    metrics.recordConflict(count: 4);
    metrics.recordFirstLocalContent(
      "library",
      const Duration(milliseconds: 80),
    );

    metrics.clear();

    expect(metrics.cacheHitRatio, 0.0);
    expect(metrics.totalApiRequests, 0);
    expect(metrics.rateLimitThrottleDuration, Duration.zero);
    expect(metrics.conflictCount, 0);
    expect(metrics.recentApiRecords, isEmpty);
    expect(metrics.firstLocalContentMs, isEmpty);
  });
}
