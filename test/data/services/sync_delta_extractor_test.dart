import "package:drift/drift.dart" show driftRuntimeOptions;
import "package:drift/native.dart";
import "package:flutter_test/flutter_test.dart";
import "package:takion/src/data/common/drift/database.dart";
import "package:takion/src/data/common/services/sync_delta_extractor.dart";

void main() {
  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group("SyncDeltaExtractor deterministic clock and UUID", () {
    test("uses injected clock and custom uuidGenerator", () async {
      final fixedTime = DateTime.utc(2026, 8, 28, 12, 0, 0);
      var uuidCallCount = 0;
      final extractor = SyncDeltaExtractor(
        db,
        clock: () => fixedTime,
        uuidGenerator: () {
          uuidCallCount++;
          return "custom-deterministic-uuid-123";
        },
      );

      final deviceId = await extractor.getDeviceId();
      expect(deviceId, equals("custom-deterministic-uuid-123"));
      expect(uuidCallCount, equals(1));

      // Calling again should return cached deviceId without generating a new one
      final cachedDeviceId = await extractor.getDeviceId();
      expect(cachedDeviceId, equals("custom-deterministic-uuid-123"));
      expect(uuidCallCount, equals(1));

      final delta = await extractor.extractDelta(null);
      expect(delta["version"], equals(2));
      expect(delta["deviceId"], equals("custom-deterministic-uuid-123"));
      expect(delta["toTimestamp"], equals(fixedTime.toIso8601String()));
    });
  });
}
