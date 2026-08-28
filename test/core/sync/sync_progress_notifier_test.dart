import "package:flutter_test/flutter_test.dart";
import "package:takion/src/core/sync/sync_progress_notifier.dart";

void main() {
  group("SyncProgressNotifier", () {
    test("initial state is idle", () {
      final notifier = SyncProgressNotifier();
      expect(notifier.value.phase, equals(SyncPhase.idle));
      expect(notifier.value.message, isNull);
    });

    test("setPhase updates phase and dispatches notification", () {
      final notifier = SyncProgressNotifier();
      var notificationCount = 0;
      notifier.addListener(() => notificationCount++);

      notifier.setPhase(
        SyncPhase.downloading,
        message: "Downloading sync delta...",
        progress: 0.5,
      );

      expect(notificationCount, equals(1));
      expect(notifier.value.phase, equals(SyncPhase.downloading));
      expect(notifier.value.message, equals("Downloading sync delta..."));
      expect(notifier.value.progress, equals(0.5));
    });

    test("reset restores initial idle state", () {
      final notifier = SyncProgressNotifier();
      notifier.setPhase(SyncPhase.uploading);
      notifier.reset();

      expect(notifier.value.phase, equals(SyncPhase.idle));
    });
  });
}
