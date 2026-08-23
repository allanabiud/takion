import "dart:async";

import "package:fake_async/fake_async.dart";
import "package:flutter_test/flutter_test.dart";
import "package:dio/dio.dart";
import "package:takion/src/core/network/rate_limit_interceptor.dart";

void main() {
  group("RateLimitInterceptor", () {
    RequestInterceptorHandler run(
      RateLimitInterceptor interceptor, {
      bool background = false,
    }) {
      final options = RequestOptions(path: "/issue/");
      final handler = RequestInterceptorHandler();
      if (background) {
        runZoned(
          () => interceptor.onRequest(options, handler),
          zoneValues: {backgroundZoneKey: true},
        );
      } else {
        interceptor.onRequest(options, handler);
      }
      return handler;
    }

    test("foreground requests are served before waiting background work", () {
      fakeAsync((async) {
        final interceptor = RateLimitInterceptor(
          maxRequestsPerMinute: 3,
          reservedForeground: 1,
        );

        final bg1 = run(interceptor, background: true);
        final bg2 = run(interceptor, background: true);
        final bg3 = run(interceptor, background: true);

        async.flushMicrotasks();
        expect(bg1.isCompleted, isTrue);
        expect(bg2.isCompleted, isTrue);
        expect(
          bg3.isCompleted,
          isFalse,
          reason: "background budget must be capped at 2",
        );

        final fg = run(interceptor, background: false);
        async.flushMicrotasks();
        expect(
          fg.isCompleted,
          isTrue,
          reason: "foreground must bypass background budget cap",
        );

        async.elapse(const Duration(minutes: 1, seconds: 1));
        expect(bg3.isCompleted, isTrue);
      });
    });

    test("foreground requests share the hard per-minute cap", () {
      fakeAsync((async) {
        final interceptor = RateLimitInterceptor(
          maxRequestsPerMinute: 2,
          reservedForeground: 1,
        );

        final fg1 = run(interceptor);
        final fg2 = run(interceptor);
        final fg3 = run(interceptor);

        async.flushMicrotasks();
        expect(fg1.isCompleted, isTrue);
        expect(fg2.isCompleted, isTrue);
        expect(
          fg3.isCompleted,
          isFalse,
          reason: "total budget (2) applies to foreground too",
        );

        async.elapse(const Duration(minutes: 1, seconds: 1));
        expect(fg3.isCompleted, isTrue);
      });
    });

    test("optimistic decrement and header parsing update state", () {
      fakeAsync((async) {
        final interceptor = RateLimitInterceptor(maxRequestsPerMinute: 18);

        final options = RequestOptions(path: "/series/");
        final handler = RequestInterceptorHandler();
        interceptor.onRequest(options, handler);
        async.flushMicrotasks();

        expect(interceptor.state.burstRemaining, 17);

        interceptor.onResponse(
          Response(
            requestOptions: options,
            headers: Headers.fromMap({
              "x-ratelimit-burst-remaining": ["9"],
              "x-ratelimit-sustained-remaining": ["4200"],
            }),
          ),
          ResponseInterceptorHandler(),
        );

        expect(interceptor.state.burstRemaining, 9);
        expect(interceptor.state.sustainedRemaining, 4200);
      });
    });
  });
}
