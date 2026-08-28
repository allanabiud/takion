import "package:flutter_test/flutter_test.dart";
import "package:takion/src/core/sync/conflict_resolver.dart";

void main() {
  group("ConflictResolver", () {
    const resolver = ConflictResolver();

    test("isSupportedVersion accepts versions 1 and 2", () {
      expect(resolver.isSupportedVersion(1), isTrue);
      expect(resolver.isSupportedVersion(2), isTrue);
      expect(resolver.isSupportedVersion(3), isFalse);
      expect(resolver.isSupportedVersion("invalid"), isFalse);
    });

    test("shouldApplyRemote returns false when device IDs match", () {
      expect(
        resolver.shouldApplyRemote(
          remoteDeviceId: "device-A",
          localDeviceId: "device-A",
        ),
        isFalse,
      );

      expect(
        resolver.shouldApplyRemote(
          remoteDeviceId: "device-B",
          localDeviceId: "device-A",
        ),
        isTrue,
      );
    });

    test("isRemoteNewer checks modification against sync and upload times", () {
      final t1 = DateTime.utc(2026, 1, 1, 10, 0);
      final t2 = DateTime.utc(2026, 1, 1, 11, 0);
      final t3 = DateTime.utc(2026, 1, 1, 12, 0);

      expect(
        resolver.isRemoteNewer(
          remoteModified: t3,
          lastSyncTime: t2,
          lastUploaded: t1,
        ),
        isTrue,
      );

      expect(
        resolver.isRemoteNewer(
          remoteModified: t1,
          lastSyncTime: t2,
          lastUploaded: null,
        ),
        isFalse,
      );

      expect(
        resolver.isRemoteNewer(
          remoteModified: null,
          lastSyncTime: t2,
          lastUploaded: t1,
        ),
        isFalse,
      );
    });

    test("hasDeltaGap detects missed intermediate deltas", () {
      final lastSync = DateTime.utc(2026, 1, 1, 10, 0);

      // fromTimestamp is after local lastSync -> gap
      expect(
        resolver.hasDeltaGap(
          fromTimestampStr: "2026-01-01T12:00:00.000Z",
          lastSyncTime: lastSync,
        ),
        isTrue,
      );

      // fromTimestamp is before or equal to local lastSync -> no gap
      expect(
        resolver.hasDeltaGap(
          fromTimestampStr: "2026-01-01T09:00:00.000Z",
          lastSyncTime: lastSync,
        ),
        isFalse,
      );
    });

    test("hasLocalChanges detects presence of inserts or deletes", () {
      expect(
        resolver.hasLocalChanges({
          "tables": {
            "library_items": {"inserts": [], "deletes": []},
          },
        }),
        isFalse,
      );

      expect(
        resolver.hasLocalChanges({
          "tables": {
            "library_items": {
              "inserts": [
                {"id": "1"},
              ],
              "deletes": [],
            },
          },
        }),
        isTrue,
      );
    });

    test("countChanges totals inserts and deletes accurately", () {
      final delta = {
        "tables": {
          "tableA": {
            "inserts": [1, 2],
            "deletes": [3],
          },
          "tableB": {
            "inserts": [4],
            "deletes": [5, 6],
          },
        },
      };

      expect(resolver.countChanges(delta, "inserts"), equals(3));
      expect(resolver.countChanges(delta, "deletes"), equals(3));
    });
  });
}
