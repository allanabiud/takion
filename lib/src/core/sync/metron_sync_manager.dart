import "dart:async";
import "package:takion/src/core/logging/app_logger.dart";
import "package:takion/src/core/migration/migration_manager.dart";
import "package:takion/src/core/sync/connectivity_monitor.dart";
import "package:takion/src/core/sync/metron_sync_state.dart";
import "package:takion/src/core/sync/offline_queue/offline_write_queue.dart";
import "package:takion/src/data/collection/sync/collection_sync_manager.dart";
import "package:takion/src/data/pull_list/sync/pull_list_sync_manager.dart";
import "package:takion/src/data/wishlist/sync/wishlist_sync_manager.dart";

class MetronSyncManager {
  MetronSyncManager({
    required CollectionSyncManager collectionSyncManager,
    required PullListSyncManager pullListSyncManager,
    required WishlistSyncManager wishlistSyncManager,
    MigrationManager? migrationManager,
    OfflineWriteQueue? offlineWriteQueue,
    ConnectivityMonitor? connectivityMonitor,
  })  : _collectionSyncManager = collectionSyncManager,
        _pullListSyncManager = pullListSyncManager,
        _wishlistSyncManager = wishlistSyncManager,
        _migrationManager = migrationManager,
        _offlineWriteQueue = offlineWriteQueue,
        _connectivityMonitor = connectivityMonitor {
    _initConnectivityListener();
  }

  final CollectionSyncManager _collectionSyncManager;
  final PullListSyncManager _pullListSyncManager;
  final WishlistSyncManager _wishlistSyncManager;
  final MigrationManager? _migrationManager;
  final OfflineWriteQueue? _offlineWriteQueue;
  final ConnectivityMonitor? _connectivityMonitor;

  final StreamController<MetronSyncState> _stateController =
      StreamController<MetronSyncState>.broadcast();

  MetronSyncState _currentState = const MetronSyncState();

  MetronSyncState get currentState => _currentState;
  Stream<MetronSyncState> get stateStream => _stateController.stream;

  void _emit(MetronSyncState newState) {
    _currentState = newState;
    if (!_stateController.isClosed) {
      _stateController.add(newState);
    }
  }

  void _initConnectivityListener() {
    _connectivityMonitor?.startMonitoring(
      onReconnected: () {
        AppLogger.info("Network reconnected: triggering Metron sync");
        syncAll();
      },
    );
  }

  Future<MetronSyncState> syncAll({bool forceFullSync = false}) async {
    if (_currentState.isSyncing) {
      return _currentState;
    }

    final migration = _migrationManager;
    if (migration != null && migration.currentProgress.isMigrating) {
      AppLogger.info("Metron sync deferred: migration in progress");
      return _currentState;
    }

    _emit(
      _currentState.copyWith(
        status: SyncStatus.syncing,
        currentPhase: "Processing offline writes",
        errorMessage: null,
      ),
    );

    try {
      if (_offlineWriteQueue != null) {
        await _offlineWriteQueue.processQueue();
      }

      // 1. Sync Collection
      _emit(_currentState.copyWith(currentPhase: "Syncing collection"));
      final colResult = await _collectionSyncManager.syncCollection(
        forceFullSync: forceFullSync,
      );

      // 2. Sync Pull List & Subscriptions
      _emit(_currentState.copyWith(currentPhase: "Syncing pull list"));
      final pullResult = await _pullListSyncManager.syncPullList();

      // 3. Sync Wishlist
      _emit(_currentState.copyWith(currentPhase: "Syncing wishlist"));
      final wishResult = await _wishlistSyncManager.syncWishlist();

      final now = DateTime.now().toUtc();
      final hasFailures = !colResult.isSuccess ||
          !pullResult.isSuccess ||
          !wishResult.isSuccess;

      final resultState = _currentState.copyWith(
        status: hasFailures ? SyncStatus.error : SyncStatus.success,
        currentPhase: hasFailures ? "Completed with errors" : "Idle",
        lastSyncedAt: now,
        collectionItemsSynced: colResult.itemsFetched,
        pullListSeriesSynced: pullResult.seriesFetched,
        pullListIssuesSynced: pullResult.issuesFetched,
        wishlistItemsSynced: wishResult.itemsFetched,
        errorMessage: colResult.errorMessage ??
            pullResult.errorMessage ??
            wishResult.errorMessage,
      );

      _emit(resultState);
      return resultState;
    } catch (e, st) {
      AppLogger.error("Metron full sync failed", error: e, stackTrace: st);
      final errorState = _currentState.copyWith(
        status: SyncStatus.error,
        currentPhase: "Failed",
        errorMessage: e.toString(),
      );
      _emit(errorState);
      return errorState;
    }
  }

  void dispose() {
    _stateController.close();
  }
}
