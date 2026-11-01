import "package:drift/native.dart";
import "package:flutter_test/flutter_test.dart";
import "package:takion/src/core/sync/periodic_sync_manager.dart";
import "package:takion/src/core/sync/sync_journal.dart";
import "package:takion/src/data/common/drift/database.dart";
import "package:takion/src/presentation/providers/drive_sync_provider.dart";

void main() {
  group("isRestartBackupDue (weekly cadence)", () {
    final now = DateTime.utc(2026, 9, 23, 9);

    test("is due when no backup has ever been recorded", () {
      expect(isRestartBackupDue(lastBackup: null, now: now), isTrue);
    });

    test("is due once the last backup is 7 days old or older", () {
      expect(
        isRestartBackupDue(
          lastBackup: now.subtract(const Duration(days: 7)),
          now: now,
        ),
        isTrue,
      );
      expect(
        isRestartBackupDue(
          lastBackup: now.subtract(const Duration(days: 30)),
          now: now,
        ),
        isTrue,
      );
    });

    test("is not due within the 7-day window", () {
      expect(
        isRestartBackupDue(
          lastBackup: now.subtract(const Duration(days: 6, hours: 23)),
          now: now,
        ),
        isFalse,
      );
      expect(
        isRestartBackupDue(
          lastBackup: now.subtract(const Duration(days: 2)),
          now: now,
        ),
        isFalse,
      );
      expect(
        isRestartBackupDue(
          lastBackup: now.subtract(const Duration(hours: 3)),
          now: now,
        ),
        isFalse,
      );
    });

    test("the cadence constant is weekly", () {
      expect(restartBackupInterval, const Duration(days: 7));
    });
  });

  group("SyncInterval weekly default", () {
    test("days7 parses from stored labels", () {
      expect(SyncInterval.fromString("7 days"), SyncInterval.days7);
      expect(SyncInterval.fromString("7d"), SyncInterval.days7);
      expect(SyncInterval.fromString("7_days"), SyncInterval.days7);
      expect(SyncInterval.fromString("days7"), SyncInterval.days7);
      expect(
        SyncInterval.fromString(SyncInterval.days7.label),
        SyncInterval.days7,
      );
    });

    test("unknown or missing values fall back to the weekly default", () {
      expect(SyncInterval.fromString(null), SyncInterval.days7);
      expect(SyncInterval.fromString("nonsense"), SyncInterval.days7);
    });

    test("explicit legacy intervals still parse", () {
      expect(SyncInterval.fromString("1 hr"), SyncInterval.hours1);
      expect(SyncInterval.fromString("3 hrs"), SyncInterval.hours3);
      expect(SyncInterval.fromString("24 hrs"), SyncInterval.hours24);
    });

    test("days7 lasts seven days", () {
      expect(SyncInterval.days7.duration, const Duration(days: 7));
    });

    test("state defaults enable weekly automatic backups", () {
      const state = DriveSyncState();
      expect(state.syncInterval, SyncInterval.days7);
      expect(state.syncIntervalEnabled, isTrue);
      expect(state.autoBackupOnRestart, isTrue);
    });
  });

  group("SyncJournal drive backup timestamp", () {
    late AppDatabase db;
    late SyncJournal journal;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      journal = SyncJournal(db.syncMetaDao);
    });

    tearDown(() async {
      await db.close();
    });

    test("round-trips the last backup time", () async {
      expect(await journal.getLastBackupTime(), isNull);

      final backupTime = DateTime.utc(2026, 9, 23, 12, 30);
      await journal.setLastBackupTime(backupTime);

      expect(await journal.getLastBackupTime(), backupTime);
    });

    test(
      "uses a key distinct from the Drive watermark and Metron sync keys",
      () async {
        expect(
          SyncJournal.driveLastBackupTimestampKey,
          isNot("last_sync_timestamp"),
        );
        expect(
          SyncJournal.driveLastBackupTimestampKey,
          isNot("metron_last_collection_sync"),
        );
        expect(
          SyncJournal.driveLastBackupTimestampKey,
          isNot("metron_last_pull_list_sync"),
        );
        expect(
          SyncJournal.driveLastBackupTimestampKey,
          isNot("metron_last_wishlist_sync"),
        );

        // Writing the backup timestamp must not disturb the watermark.
        await journal.setSyncTimestamps("2026-01-01T00:00:00Z");
        await journal.setLastBackupTime(DateTime.utc(2026, 9, 23));
        expect(await journal.getLastSyncTime(), DateTime.utc(2026, 1, 1));
      },
    );
  });
}
