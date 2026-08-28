import "package:drift/native.dart";
import "package:flutter_test/flutter_test.dart";
import "package:takion/src/core/sync/sync_journal.dart";
import "package:takion/src/data/common/drift/database.dart";

void main() {
  group("SyncJournal", () {
    late AppDatabase db;
    late SyncJournal journal;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      journal = SyncJournal(db.syncMetaDao);
    });

    tearDown(() async {
      await db.close();
    });

    test("sets and retrieves sync timestamps", () async {
      expect(await journal.getLastSyncTime(), isNull);
      expect(await journal.getLastUploadedTime(), isNull);

      final nowIso = DateTime.utc(2026, 8, 28, 12, 0).toIso8601String();
      await journal.setSyncTimestamps(nowIso);

      final syncTime = await journal.getLastSyncTime();
      final uploadTime = await journal.getLastUploadedTime();

      expect(syncTime, equals(DateTime.utc(2026, 8, 28, 12, 0)));
      expect(uploadTime, equals(DateTime.utc(2026, 8, 28, 12, 0)));
    });

    test("acquires and releases sync lock correctly", () async {
      final locked = await journal.acquireLock();
      expect(locked, isTrue);

      // Second attempt while locked fails
      final secondAttempt = await journal.acquireLock();
      expect(secondAttempt, isFalse);

      await journal.releaseLock();

      final afterRelease = await journal.acquireLock();
      expect(afterRelease, isTrue);
    });

    test("evaluates throttle status accurately", () async {
      expect(await journal.isThrottled(), isFalse);

      await journal.setLastSyncAttempt(DateTime.now());
      expect(await journal.isThrottled(), isTrue);

      expect(
        await journal.isThrottled(minInterval: Duration.zero),
        isFalse,
      );
    });

    test("records sync attempts without failure", () async {
      await journal.record(
        phase: "upload",
        success: true,
        elapsedMs: 120,
      );

      final lastSuccess = await db.syncMetaDao.get("last_sync_success_time");
      expect(lastSuccess, isNotNull);
    });
  });
}
