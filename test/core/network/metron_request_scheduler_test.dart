import 'package:clock/clock.dart';
import 'package:dio/dio.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:takion/src/core/network/metron_request_scheduler.dart';
import 'package:takion/src/core/network/request_priority.dart';

class _Tracked {
  _Tracked(Future<RequestDispatch> future, this.path, this.onSent) {
    future.then((d) {
      result = d;
      done = true;
      if (d == RequestDispatch.sent) onSent(path);
    });
  }

  final String path;
  final void Function(String path) onSent;

  RequestDispatch? result;
  bool done = false;

  bool get sent => done && result == RequestDispatch.sent;
  bool get dropped => done && result == RequestDispatch.dropped;
}

void main() {
  late MetronRequestScheduler scheduler;
  final dispatchOrder = <String>[];

  setUp(() => dispatchOrder.clear());

  _Tracked enqueue(
    RequestPriority priority, {
    String path = '/x/',
  }) {
    return _Tracked(
      scheduler.enqueue(
        request: RequestOptions(path: path),
        priority: priority,
      ),
      path,
      dispatchOrder.add,
    );
  }

  void completeRequest() {
    scheduler.requestCompleted();
  }

  group('MetronRequestScheduler', () {
    test('P0 dispatches before queued P2/P3 (preemption)', () {
      fakeAsync((async) {
        scheduler = MetronRequestScheduler(
          maxRequestsPerMinute: 18,
          maxConcurrent: 1,
        );

        // First request dispatches immediately, filling the single slot.
        final p3 = enqueue(RequestPriority.drop, path: '/p3');
        final p2 = enqueue(RequestPriority.background, path: '/p2');
        final p0 = enqueue(RequestPriority.high, path: '/p0');

        async.flushMicrotasks();
        expect(p3.sent, isTrue);
        expect(p2.done, isFalse);
        expect(p0.done, isFalse);

        // Free the slot: the queued P0 jumps ahead of the queued P2.
        completeRequest();
        async.flushMicrotasks();
        expect(p0.sent, isTrue);
        expect(p2.done, isFalse);

        completeRequest();
        async.flushMicrotasks();
        expect(p2.sent, isTrue);
        expect(dispatchOrder, ['/p3', '/p0', '/p2']);
      });
    });

    test('FIFO within a priority class', () {
      fakeAsync((async) {
        scheduler = MetronRequestScheduler(
          maxRequestsPerMinute: 18,
          maxConcurrent: 1,
        );

        final a = enqueue(RequestPriority.normal, path: '/a');
        final b = enqueue(RequestPriority.normal, path: '/b');
        final c = enqueue(RequestPriority.normal, path: '/c');

        async.flushMicrotasks();
        expect(a.sent, isTrue);

        completeRequest();
        async.flushMicrotasks();
        expect(b.sent, isTrue);

        completeRequest();
        async.flushMicrotasks();
        expect(c.sent, isTrue);
        expect(dispatchOrder, ['/a', '/b', '/c']);
      });
    });

    test('background reservation is honored: foreground served while '
        'background is capped', () {
      fakeAsync((async) {
        scheduler = MetronRequestScheduler(
          maxRequestsPerMinute: 3,
          reservedForeground: 1,
        );

        // Background cap = 3 - 1 = 2.
        final bg1 = enqueue(RequestPriority.background, path: '/bg1');
        final bg2 = enqueue(RequestPriority.background, path: '/bg2');
        final bg3 = enqueue(RequestPriority.background, path: '/bg3');

        async.flushMicrotasks();
        expect(bg1.sent, isTrue);
        expect(bg2.sent, isTrue);
        expect(bg3.done, isFalse);

        // A foreground request is still served from the reserved slot.
        final fg = enqueue(RequestPriority.normal, path: '/fg');
        async.flushMicrotasks();
        expect(fg.sent, isTrue);

        // Advancing a minute lets the queued background request through.
        async.elapse(const Duration(minutes: 1, seconds: 1));
        expect(bg3.sent, isTrue);
      });
    });

    test('foreground shares the hard per-minute cap', () {
      fakeAsync((async) {
        scheduler = MetronRequestScheduler(
          maxRequestsPerMinute: 2,
          reservedForeground: 1,
        );

        final fg1 = enqueue(RequestPriority.normal, path: '/fg1');
        final fg2 = enqueue(RequestPriority.normal, path: '/fg2');
        final fg3 = enqueue(RequestPriority.normal, path: '/fg3');

        async.flushMicrotasks();
        expect(fg1.sent, isTrue);
        expect(fg2.sent, isTrue);
        expect(fg3.done, isFalse);

        async.elapse(const Duration(minutes: 1, seconds: 1));
        expect(fg3.sent, isTrue);
      });
    });

    test('P3 request is dropped after backgroundMaxWait', () {
      fakeAsync((async) {
        scheduler = MetronRequestScheduler(
          maxRequestsPerMinute: 1,
          reservedForeground: 0,
          maxConcurrent: 8,
          backgroundMaxWait: const Duration(seconds: 30),
        );

        // Blocker consumes the only budget slot.
        final blocker = enqueue(RequestPriority.normal, path: '/blocker');
        async.flushMicrotasks();
        expect(blocker.sent, isTrue);

        // P3 queues behind the full budget, then hits its deadline.
        final p3 = enqueue(RequestPriority.drop, path: '/p3');
        async.flushMicrotasks();
        expect(p3.done, isFalse);

        async.elapse(const Duration(seconds: 31));
        expect(p3.dropped, isTrue);
      });
    });

    test('P2 request is promoted to foreground instead of being dropped', () {
      fakeAsync((async) {
        scheduler = MetronRequestScheduler(
          maxRequestsPerMinute: 1,
          reservedForeground: 0,
          maxConcurrent: 8,
          backgroundMaxWait: const Duration(seconds: 30),
        );

        final blocker = enqueue(RequestPriority.normal, path: '/blocker');
        async.flushMicrotasks();
        expect(blocker.sent, isTrue);

        final p2 = enqueue(RequestPriority.background, path: '/p2');
        async.flushMicrotasks();
        expect(p2.done, isFalse);

        // Past its background deadline, P2 is promoted to foreground and
        // survives; it dispatches once the blocker's budget window expires.
        async.elapse(const Duration(minutes: 1, seconds: 1));
        expect(p2.sent, isTrue);
        expect(dispatchOrder, ['/blocker', '/p2']);
      });
    });

    test('sustained budget exhaustion delays dispatch until reset', () {
      fakeAsync((async) {
        scheduler = MetronRequestScheduler(
          maxRequestsPerMinute: 18,
          maxConcurrent: 8,
        );

        // Simulate a near-exhausted sustained budget from response headers.
        final resetSeconds = clock.now().millisecondsSinceEpoch ~/ 1000 + 60;
        scheduler.onResponse({
          'x-ratelimit-sustained-remaining': ['0'],
          'x-ratelimit-sustained-reset': ['$resetSeconds'],
        });

        final req = enqueue(RequestPriority.normal, path: '/req');
        async.flushMicrotasks();
        expect(req.done, isFalse);

        async.elapse(const Duration(seconds: 61));
        expect(req.sent, isTrue);
      });
    });
  });
}
