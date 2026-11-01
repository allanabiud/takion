import "dart:async";
import "dart:convert";
import "dart:typed_data";

import "package:clock/clock.dart";
import "package:dio/dio.dart";
import "package:drift/native.dart";
import "package:fake_async/fake_async.dart";
import "package:flutter_test/flutter_test.dart";
import "package:takion/src/core/network/metron_request_scheduler.dart";
import "package:takion/src/core/network/rate_limit_interceptor.dart";
import "package:takion/src/core/network/rate_limit_state_store.dart";
import "package:takion/src/core/network/request_priority.dart";
import "package:takion/src/data/common/drift/database.dart";

void main() {
  late AppDatabase db;
  late RateLimitStateStore store;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    store = RateLimitStateStore(
      db.syncMetaDao,
      debounce: const Duration(milliseconds: 10),
    );
  });

  tearDown(() async {
    store.dispose();
    await db.close();
  });

  RequestOptions buildRequest(String path) => RequestOptions(path: path);

  /// Adapter that always answers 429 with the given Retry-After header.
  _Fixed429Adapter adapter429(String retryAfter) =>
      _Fixed429Adapter(retryAfter);

  group("RateLimitStateStore persistence", () {
    test("persists a snapshot as JSON under ratelimit:<accountId>", () async {
      const state = RateLimitState(
        sustainedLimit: 5000,
        sustainedRemaining: 4990,
        sustainedReset: 1793424000,
        burstLimit: 20,
        burstRemaining: 3,
        burstReset: 1793400060,
        retryAfterUntil: 1793400120,
        hasObservedHeaders: true,
      );
      await store.saveNow(state);

      final raw = await db.syncMetaDao.get("ratelimit:local-user");
      expect(raw, isNotNull);
      final decoded = jsonDecode(raw!) as Map<String, dynamic>;
      expect(decoded["retryAfterUntil"], 1793400120);
      expect(decoded["burstRemaining"], 3);
      expect(decoded["hasObservedHeaders"], isTrue);

      final restored = await store.load();
      expect(restored, isNotNull);
      expect(restored!.retryAfterUntil, 1793400120);
      expect(restored.sustainedRemaining, 4990);
      expect(restored.burstReset, 1793400060);
      expect(restored.hasObservedHeaders, isTrue);
    });

    test("corrupt snapshot never blocks networking", () async {
      await db.syncMetaDao.set("ratelimit:local-user", "not-json{");
      final restored = await store.load();
      expect(restored, isNull);
    });

    test("debounced scheduleSave persists the latest state", () async {
      store.scheduleSave(const RateLimitState(burstRemaining: 5));
      store.scheduleSave(const RateLimitState(burstRemaining: 2));
      await Future<void>.delayed(const Duration(milliseconds: 100));

      final restored = await store.load();
      expect(restored, isNotNull);
      expect(restored!.burstRemaining, 2);
    });

    test("clear removes the persisted snapshot", () async {
      await store.saveNow(const RateLimitState(burstRemaining: 1));
      await store.clear();
      expect(await store.load(), isNull);
    });
  });

  group("429 Retry-After persistence", () {
    test("429 through the interceptor persists the cooldown and blocks a fresh "
        "scheduler after restart", () async {
      final fixedNow = DateTime.utc(2026, 10, 30, 12, 0, 0);
      final scheduler = MetronRequestScheduler(
        onStateChanged: store.scheduleSave,
      );
      final interceptor = RateLimitInterceptor(
        scheduler: scheduler,
        stateStore: store,
      );

      // Drive a real request through Dio so the 429 + Retry-After flows
      // through the interceptor exactly like production.
      final dio = Dio(BaseOptions(baseUrl: "https://metron.cloud/api/"))
        ..httpClientAdapter = adapter429("60")
        ..interceptors.add(interceptor);

      await withClock(Clock.fixed(fixedNow), () async {
        await expectLater(
          dio.get<dynamic>("collection/"),
          throwsA(isA<DioException>()),
        );

        // Cooldown observed and exposed to callers.
        expect(
          scheduler.state.retryAfterUntil,
          fixedNow.add(const Duration(seconds: 60)).millisecondsSinceEpoch ~/
              1000,
        );
        expect(scheduler.rateLimitedUntil, isNotNull);
        expect(
          scheduler.rateLimitedUntil!.toUtc(),
          fixedNow.add(const Duration(seconds: 60)),
        );

        // Debounced save lands in SyncMeta.
        await Future<void>.delayed(const Duration(milliseconds: 100));
        final persisted = await store.load();
        expect(persisted, isNotNull);
        expect(persisted!.retryAfterUntil, scheduler.state.retryAfterUntil);

        // Simulated process restart: a fresh scheduler hydrates from
        // SQLite and remains throttled without hitting the network first.
        final restarted = MetronRequestScheduler();
        restarted.restoreState(persisted);
        expect(restarted.rateLimitedUntil, isNotNull);
        expect(restarted.state.isRetryAfterActive, isTrue);

        var sent = false;
        unawaited(
          restarted
              .enqueue(
                request: buildRequest("/issue/"),
                priority: RequestPriority.high,
              )
              .then((d) => sent = d == RequestDispatch.sent),
        );
        await Future<void>.delayed(Duration.zero);
        expect(sent, isFalse);
        expect(restarted.activeRequestCount, 0);
        restarted.dispose();
      });

      // Cancel the wake timer created for the cooldown window.
      interceptor.dispose();
    });

    test("restored Retry-After blocks dispatch until the window elapses, then "
        "releases the queue", () {
      fakeAsync((async) {
        final untilSeconds = clock.now().millisecondsSinceEpoch ~/ 1000 + 60;

        final scheduler = MetronRequestScheduler();
        scheduler.restoreState(RateLimitState(retryAfterUntil: untilSeconds));

        var sent = false;
        scheduler
            .enqueue(
              request: buildRequest("/issue/"),
              priority: RequestPriority.high,
            )
            .then((d) => sent = d == RequestDispatch.sent);

        async.flushMicrotasks();
        expect(sent, isFalse, reason: "must stay throttled during cooldown");
        expect(scheduler.rateLimitedUntil, isNotNull);

        async.elapse(const Duration(seconds: 61));
        async.flushMicrotasks();
        expect(sent, isTrue, reason: "queue must release after cooldown");
      });
    });

    test("noteRetryAfter keeps the later of two cooldowns", () {
      final scheduler = MetronRequestScheduler();
      addTearDown(scheduler.dispose);
      scheduler.noteRetryAfter(const Duration(seconds: 30));
      final first = scheduler.state.retryAfterUntil;
      scheduler.noteRetryAfter(const Duration(seconds: 5));
      expect(scheduler.state.retryAfterUntil, first);
      scheduler.noteRetryAfter(const Duration(seconds: 120));
      expect(scheduler.state.retryAfterUntil, greaterThan(first));
    });
  });
}

/// Adapter that always answers 429 Too Many Requests with a Retry-After
/// header, letting a real Dio chain exercise the interceptor.
class _Fixed429Adapter implements HttpClientAdapter {
  _Fixed429Adapter(this.retryAfterSeconds);

  final String retryAfterSeconds;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      "{}",
      429,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
        "retry-after": [retryAfterSeconds],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
