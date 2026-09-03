import "dart:async";
import "package:connectivity_plus/connectivity_plus.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:takion/src/core/sync/connectivity_monitor.dart";

class MockConnectivity extends Mock implements Connectivity {}

void main() {
  group("ConnectivityMonitor", () {
    late MockConnectivity connectivity;
    late StreamController<List<ConnectivityResult>> controller;
    late ConnectivityMonitor monitor;

    setUp(() {
      connectivity = MockConnectivity();
      controller = StreamController<List<ConnectivityResult>>.broadcast();
      when(() => connectivity.onConnectivityChanged)
          .thenAnswer((_) => controller.stream);
      monitor = ConnectivityMonitor(connectivity: connectivity);
    });

    tearDown(() {
      monitor.dispose();
      controller.close();
    });

    test("isOnline returns true when wifi or mobile connected", () async {
      when(() => connectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi]);

      final online = await monitor.isOnline();
      expect(online, isTrue);
    });

    test("isOnline returns false when none", () async {
      when(() => connectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.none]);

      final online = await monitor.isOnline();
      expect(online, isFalse);
    });

    test("triggers onReconnected callback when transitioning offline -> online",
        () async {
      var reconnectedCount = 0;
      monitor.startMonitoring(onReconnected: () {
        reconnectedCount++;
      });

      // Emit offline
      controller.add([ConnectivityResult.none]);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(reconnectedCount, 0);

      // Emit online (transition triggers callback)
      controller.add([ConnectivityResult.wifi]);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(reconnectedCount, 1);

      // Emit online again (already online, should not trigger again)
      controller.add([ConnectivityResult.mobile]);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(reconnectedCount, 1);
    });
  });
}
