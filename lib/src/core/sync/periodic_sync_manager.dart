import "package:flutter/widgets.dart";
import "package:workmanager/workmanager.dart";
import "package:takion/src/core/logging/app_logger.dart";
import "package:takion/src/core/notifications/notification_service.dart";
import "package:takion/src/data/common/drift/database.dart";
import "package:takion/src/data/common/services/drive_backup_service.dart";
import "package:takion/src/presentation/providers/drive_sync_provider.dart";

const String periodicSyncTaskName = "com.takion.app.periodic_sync";

@pragma("vm:entry-point")
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    AppLogger.info("Workmanager background task executing: $taskName");
    WidgetsFlutterBinding.ensureInitialized();
    AppDatabase? db;
    DriveSyncService? driveService;
    try {
      db = AppDatabase();
      final enabled = await db.settingsDao.getBool(
        "drive_sync_enabled",
        defaultValue: false,
      );

      if (!enabled) {
        AppLogger.info("Workmanager periodic sync skipped: sync is disabled");
        return true;
      }

      driveService = DriveSyncService(db);
      final account = await driveService.signInSilently();
      if (account == null) {
        AppLogger.info("Workmanager periodic sync skipped: user not signed in");
        return true;
      }

      await NotificationService.instance.showSyncNotification(
        title: "Syncing with Google Drive",
        body: "Synchronizing your data...",
        isOngoing: true,
      );

      await driveService.triggerSync(ignoreThrottle: true);

      await driveService.recordSyncOutcome(phase: "background", success: true);

      await NotificationService.instance.cancelSyncNotification();

      return true;
    } catch (e) {
      AppLogger.error("Workmanager periodic sync failed", error: e);
      try {
        await driveService?.recordSyncOutcome(
          phase: "background",
          success: false,
          error: e,
        );
      } catch (_) {}
      try {
        await NotificationService.instance.showSyncNotification(
          title: "Drive Sync Failed",
          body: "Unable to complete background sync.",
          isOngoing: false,
        );
      } catch (_) {}
      return false;
    } finally {
      try {
        await db?.close();
      } catch (closeError) {
        AppLogger.warning("Error closing background database", error: closeError);
      }
    }
  });
}

class PeriodicSyncManager {
  PeriodicSyncManager._();
  static final PeriodicSyncManager instance = PeriodicSyncManager._();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    try {
      await Workmanager().initialize(callbackDispatcher);
      _initialized = true;
      AppLogger.info("PeriodicSyncManager initialized successfully");
    } catch (e) {
      AppLogger.warning("PeriodicSyncManager initialization failed", error: e);
    }
  }

  Future<void> schedulePeriodicSync(SyncInterval interval) async {
    if (!_initialized) {
      await init();
    }
    try {
      await cancelPeriodicSync();
      await Workmanager().registerPeriodicTask(
        periodicSyncTaskName,
        periodicSyncTaskName,
        frequency: interval.duration,
        existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
        constraints: Constraints(networkType: NetworkType.connected),
      );
      AppLogger.info(
        "Scheduled background periodic sync with interval: ${interval.label}",
      );
    } catch (e) {
      AppLogger.error("Failed to schedule periodic sync task", error: e);
    }
  }

  Future<void> cancelPeriodicSync() async {
    try {
      await Workmanager().cancelByUniqueName(periodicSyncTaskName);
      AppLogger.info("Cancelled periodic sync background task");
    } catch (e) {
      AppLogger.warning("Failed to cancel periodic sync task", error: e);
    }
  }
}
