import "package:dio/dio.dart";
import "package:fake_async/fake_async.dart";
import "package:flutter_test/flutter_test.dart";
import "package:takion/src/core/network/metron_request_scheduler.dart";
import "package:takion/src/core/network/request_priority.dart";

/// Phase 5 Step 2: concurrency limiting, foreground reservation, and
/// pagination scan caps.
void main() {
  group("MetronRequestScheduler concurrency", () {
    late MetronRequestScheduler scheduler;
    final dispatchOrder = <String>[];

    void disposeScheduler() {
      scheduler.dispose();
    }

    _Tracked enqueue(
      RequestPriority priority, {
      String path = "/x/",
      bool pagination = false,
    }) {
      final options = RequestOptions(path: path);
      if (pagination) markPaginationScan(options);
      return _Tracked(
        scheduler.enqueue(request: options, priority: priority),
        options,
        path,
        dispatchOrder,
      );
    }

    void completeRequest(_Tracked tracked) {
      scheduler.requestCompleted(request: tracked.options);
    }

    test("background work is capped at maxConcurrent minus the foreground "
        "reservation", () {
      fakeAsync((async) {
        scheduler = MetronRequestScheduler(
          maxRequestsPerMinute: 20,
          maxConcurrent: 3,
          reservedForeground: 1,
        );
        addTearDown(disposeScheduler);

        final bg1 = enqueue(RequestPriority.background, path: "/bg1");
        final bg2 = enqueue(RequestPriority.background, path: "/bg2");
        final bg3 = enqueue(RequestPriority.background, path: "/bg3");

        async.flushMicrotasks();
        expect(bg1.sent, isTrue);
        expect(bg2.sent, isTrue);
        expect(
          bg3.sent,
          isFalse,
          reason: "background must stop at maxConcurrent - reserved",
        );
        expect(scheduler.activeRequestCount, 2);

        // A foreground request claims the reserved third slot.
        final fg = enqueue(RequestPriority.high, path: "/fg");
        async.flushMicrotasks();
        expect(fg.sent, isTrue, reason: "foreground must get the slot");
        expect(scheduler.activeRequestCount, 3);

        // Freeing a background slot does NOT let background claim the
        // foreground-reserved slot: the last free slot stays reserved.
        completeRequest(bg1);
        async.flushMicrotasks();
        expect(bg3.sent, isFalse);
        expect(scheduler.activeRequestCount, 2);

        // Completing the foreground work releases the reserved slot.
        completeRequest(fg);
        async.flushMicrotasks();
        expect(bg3.sent, isTrue);
        expect(dispatchOrder, ["/bg1", "/bg2", "/fg", "/bg3"]);
      });
    });

    test("reservation never starves background when idle slots remain", () {
      fakeAsync((async) {
        scheduler = MetronRequestScheduler(
          maxRequestsPerMinute: 20,
          maxConcurrent: 4,
          reservedForeground: 1,
        );
        addTearDown(disposeScheduler);

        // 3 background requests fit in 4 slots minus 1 reserved.
        final bgs = [
          enqueue(RequestPriority.background, path: "/b1"),
          enqueue(RequestPriority.background, path: "/b2"),
          enqueue(RequestPriority.background, path: "/b3"),
        ];
        async.flushMicrotasks();
        expect(
          bgs.every((b) => b.sent),
          isTrue,
          reason: "3 background requests fit in 4 - 1 slots",
        );
        expect(scheduler.activeRequestCount, 3);

        // Fourth background request must wait for the reserved slot.
        final bg4 = enqueue(RequestPriority.background, path: "/b4");
        async.flushMicrotasks();
        expect(bg4.sent, isFalse);

        // A foreground request takes the reserved slot.
        final fg = enqueue(RequestPriority.normal, path: "/fg");
        async.flushMicrotasks();
        expect(fg.sent, isTrue);
        expect(scheduler.activeRequestCount, 4);
      });
    });

    test("single-slot scheduler clamps reservation to zero", () {
      fakeAsync((async) {
        scheduler = MetronRequestScheduler(
          maxRequestsPerMinute: 20,
          maxConcurrent: 1,
          reservedForeground: 1,
        );
        addTearDown(disposeScheduler);

        // reservedForeground must clamp to maxConcurrent - 1 = 0, otherwise
        // a single-slot scheduler would deadlock background work forever.
        final bg = enqueue(RequestPriority.background, path: "/bg");
        async.flushMicrotasks();
        expect(bg.sent, isTrue, reason: "background must not deadlock");
        expect(scheduler.activeRequestCount, 1);
      });
    });

    test("at most one pagination scan runs at a time", () {
      fakeAsync((async) {
        scheduler = MetronRequestScheduler(
          maxRequestsPerMinute: 20,
          maxConcurrent: 3,
          maxConcurrentPagination: 1,
        );
        addTearDown(disposeScheduler);

        final scan1 = enqueue(
          RequestPriority.normal,
          path: "/scan1",
          pagination: true,
        );
        final scan2 = enqueue(
          RequestPriority.normal,
          path: "/scan2",
          pagination: true,
        );
        async.flushMicrotasks();
        expect(scan1.sent, isTrue);
        expect(
          scan2.sent,
          isFalse,
          reason: "second scan must wait for the single pagination slot",
        );
        expect(scheduler.activePaginationScanCount, 1);

        // Non-pagination work flows around the blocked scan.
        final other = enqueue(RequestPriority.normal, path: "/other");
        async.flushMicrotasks();
        expect(other.sent, isTrue, reason: "non-scan work must flow around");

        // Completing the scan releases the slot for the queued scan.
        completeRequest(scan1);
        async.flushMicrotasks();
        expect(scan2.sent, isTrue);
        expect(scheduler.activePaginationScanCount, 1);
      });
    });

    test("response completion releases the concurrency slot", () {
      fakeAsync((async) {
        scheduler = MetronRequestScheduler(
          maxRequestsPerMinute: 20,
          maxConcurrent: 2,
          reservedForeground: 0,
        );
        addTearDown(disposeScheduler);

        final a = enqueue(RequestPriority.normal, path: "/a");
        final b = enqueue(RequestPriority.normal, path: "/b");
        final c = enqueue(RequestPriority.normal, path: "/c");
        async.flushMicrotasks();
        expect(a.sent, isTrue);
        expect(b.sent, isTrue);
        expect(c.sent, isFalse);
        expect(scheduler.activeRequestCount, 2);

        scheduler.onResponse(const {}, request: a.options);
        async.flushMicrotasks();
        expect(c.sent, isTrue);
        expect(scheduler.activeRequestCount, 2);
      });
    });
  });
}

class _Tracked {
  _Tracked(this.future, this.options, this.path, this.dispatchOrder) {
    future.then((d) {
      if (d == RequestDispatch.sent) {
        sent = true;
        dispatchOrder.add(path);
      }
    });
  }

  final Future<RequestDispatch> future;
  final RequestOptions options;
  final String path;
  final List<String> dispatchOrder;
  bool sent = false;
}
