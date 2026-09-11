import "package:dio/dio.dart";
import "package:flutter/widgets.dart";
import "package:workmanager/workmanager.dart";
import "package:takion/src/core/logging/app_logger.dart";
import "package:takion/src/core/notifications/notification_service.dart";
import "package:takion/src/data/collection/datasources/remote/metron_collection_remote_data_source_impl.dart";
import "package:takion/src/data/collection/repositories/metron_collection_repository_impl.dart";
import "package:takion/src/data/collection/sync/collection_sync_manager.dart";
import "package:takion/src/data/common/drift/database.dart";
import "package:takion/src/data/common/services/drive_backup_service.dart";
import "package:takion/src/data/pull_list/datasources/remote/metron_pull_list_remote_data_source_impl.dart";
import "package:takion/src/data/pull_list/repositories/metron_pull_list_repository_impl.dart";
import "package:takion/src/data/pull_list/sync/pull_list_sync_manager.dart";
import "package:takion/src/data/wishlist/datasources/remote/metron_wishlist_remote_data_source_impl.dart";
import "package:takion/src/data/wishlist/repositories/metron_wishlist_repository_impl.dart";
import "package:takion/src/data/wishlist/sync/wishlist_sync_manager.dart";
import "package:takion/src/presentation/providers/drive_sync_provider.dart";

const String periodicSyncTaskName = "com.takion.app.periodic_sync";
const String metronSyncTaskName = "com.takion.app.metron_sync";

@pragma("vm:entry-point")
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    AppLogger.info("Workmanager background task executing: $taskName");
    WidgetsFlutterBinding.ensureInitialized();

    if (taskName == metronSyncTaskName) {
      return _handleMetronSync();
    }
    return _handleDriveSync();
  });
}

Future<bool> _handleMetronSync() async {
  AppDatabase? db;
  try {
    db = AppDatabase();
    final token = await db.settingsDao.getString("metron_api_token");
    if (token == null || token.trim().isEmpty) {
      AppLogger.info("Metron background sync skipped: no API token");
      return true;
    }

    await NotificationService.instance.showMetronSyncNotification(
      title: "Metron Syncing",
      body: "Starting background sync...",
    );

    final dio = Dio(
      BaseOptions(
        baseUrl: "https://metron.cloud/api/",
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        validateStatus: (status) =>
            status != null && ((status >= 200 && status < 300) || status == 304),
        headers: {"Authorization": "Bearer ${token.trim()}"},
      ),
    );

    final colRemote = MetronCollectionRemoteDataSourceImpl(dio);
    final pullRemote = MetronPullListRemoteDataSourceImpl(dio);
    final wishRemote = MetronWishlistRemoteDataSourceImpl(dio);

    final colRepo = MetronCollectionRepositoryImpl(colRemote);
    final pullRepo = MetronPullListRepositoryImpl(pullRemote);
    final wishRepo = MetronWishlistRepositoryImpl(remoteDataSource: wishRemote);

    final colSync = CollectionSyncManager(
      database: db,
      collectionRepository: colRepo,
    );
    final pullSync = PullListSyncManager(
      database: db,
      pullListRepository: pullRepo,
    );
    final wishSync = WishlistSyncManager(
      database: db,
      wishlistRepository: wishRepo,
    );

    final phases = ["Syncing collection", "Syncing pull list", "Syncing wishlist"];
    for (var i = 0; i < phases.length; i++) {
      await NotificationService.instance.updateMetronSyncProgress(
        progress: i,
        maxProgress: phases.length,
        body: phases[i],
      );

      switch (i) {
        case 0:
          await colSync.syncCollection();
        case 1:
          await pullSync.syncPullList();
        case 2:
          await wishSync.syncWishlist();
      }
    }

    await NotificationService.instance.cancelMetronSyncNotification();
    AppLogger.info("Metron background sync completed successfully");
    return true;
  } catch (e) {
    AppLogger.error("Metron background sync failed", error: e);
    try {
      await NotificationService.instance.showMetronSyncNotification(
        title: "Metron Sync Failed",
        body: "Unable to complete background sync.",
        isOngoing: false,
      );
    } catch (_) {}
    return false;
  } finally {
    try {
      await db?.close();
    } catch (closeError) {
      AppLogger.warning(
        "Error closing background database",
        error: closeError,
      );
    }
  }
}

Future<bool> _handleDriveSync() async {
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
      title: "Backing up to Google Drive",
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
      AppLogger.warning(
        "Error closing background database",
        error: closeError,
      );
    }
  }
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

  Future<void> scheduleMetronSync() async {
    if (!_initialized) {
      await init();
    }
    try {
      await cancelMetronSync();
      await Workmanager().registerPeriodicTask(
        metronSyncTaskName,
        metronSyncTaskName,
        frequency: const Duration(hours: 3),
        existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
        constraints: Constraints(networkType: NetworkType.connected),
      );
      AppLogger.info("Scheduled Metron background sync (every 3 hours)");
    } catch (e) {
      AppLogger.error("Failed to schedule Metron sync task", error: e);
    }
  }

  Future<void> cancelMetronSync() async {
    try {
      await Workmanager().cancelByUniqueName(metronSyncTaskName);
      AppLogger.info("Cancelled Metron background sync task");
    } catch (e) {
      AppLogger.warning("Failed to cancel Metron sync task", error: e);
    }
  }

  Future<void> backupOnRestart({
    required AppDatabase db,
    required DriveSyncService driveService,
  }) async {
    try {
      final enabled = await db.settingsDao.getBool(
        "drive_sync_enabled",
        defaultValue: false,
      );
      if (!enabled) return;

      final autoBackup = await db.settingsDao.getBool(
        "drive_auto_backup_on_restart",
        defaultValue: false,
      );
      if (!autoBackup) return;

      final lastSyncRaw = await db.syncMetaDao.get("last_sync_timestamp");
      if (lastSyncRaw != null) {
        final lastSync = DateTime.tryParse(lastSyncRaw);
        if (lastSync != null) {
          final elapsed = DateTime.now().difference(lastSync);
          if (elapsed < const Duration(hours: 3)) {
            AppLogger.info(
              "Skipping auto backup: last backup was ${elapsed.inMinutes}m ago (< 3h)",
            );
            return;
          }
        }
      }

      final account = await driveService.signInSilently();
      if (account == null) {
        AppLogger.info("Skipping auto backup: user not signed in");
        return;
      }

      AppLogger.info("Running automatic backup on app restart");
      await driveService.triggerSync(ignoreThrottle: true);
    } catch (e) {
      AppLogger.warning("Auto backup on restart failed", error: e);
    }
  }
}
