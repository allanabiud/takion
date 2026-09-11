import "dart:async";
import "package:takion/src/core/logging/app_logger.dart";
import "package:takion/src/core/migration/migration_manager.dart";
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
    Duration periodicInterval = const Duration(minutes: 15),
  })  : _collectionSyncManager = collectionSyncManager,
        _pullListSyncManager = pullListSyncManager,
        _wishlistSyncManager = wishlistSyncManager,
        _migrationManager = migrationManager,
        _offlineWriteQueue = offlineWriteQueue,
        _periodicInterval = periodicInterval {
    _initAutoSyncListeners();
  }

  final CollectionSyncManager _collectionSyncManager;
  final PullListSyncManager _pullListSyncManager;
  final WishlistSyncManager _wishlistSyncManager;
  final MigrationManager? _migrationManager;
  final OfflineWriteQueue? _offlineWriteQueue;
  final Duration _periodicInterval;

  final StreamController<MetronSyncState> _stateController =
      StreamController<MetronSyncState>.broadcast();

  MetronSyncState _currentState = const MetronSyncState();
  Timer? _debounceTimer;
  Timer? _periodicTimer;
  StreamSubscription<int>? _pendingWritesSub;
  DateTime _lastSyncTriggeredAt = DateTime.fromMillisecondsSinceEpoch(0);

  MetronSyncState get currentState => _currentState;
  Stream<MetronSyncState> get stateStream => _stateController.stream;

  void _emit(MetronSyncState newState) {
    _currentState = newState;
    if (!_stateController.isClosed) {
      _stateController.add(newState);
    }
  }

  void _initAutoSyncListeners() {
    if (_offlineWriteQueue != null) {
      _pendingWritesSub = _offlineWriteQueue.watchPendingCount().listen((count) {
        if (count > 0 &&
            !_currentState.isSyncing &&
            DateTime.now().difference(_lastSyncTriggeredAt) >
                const Duration(minutes: 1)) {
          scheduleSync();
        }
      });
    }

    if (_periodicInterval > Duration.zero) {
      _periodicTimer = Timer.periodic(_periodicInterval, (_) {
        AppLogger.debug("Periodic in-app Metron sync triggered");
        syncAll();
      });
    }
  }

  /// Schedules a debounced background sync (e.g. after local changes are enqueued).
  void scheduleSync({Duration debounce = const Duration(seconds: 3)}) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounce, () {
      AppLogger.info("Executing scheduled debounced Metron sync");
      syncAll();
    });
  }

  Future<MetronSyncState> syncAll({bool forceFullSync = false}) async {
    if (_currentState.isSyncing) {
      return _currentState;
    }

    _debounceTimer?.cancel();
    _lastSyncTriggeredAt = DateTime.now();

    _emit(
      _currentState.copyWith(
        status: SyncStatus.syncing,
        currentPhase: "Syncing pending changes",
        errorMessage: null,
      ),
    );

    try {
      // 1. Process pending offline write entries
      if (_offlineWriteQueue != null) {
        await _offlineWriteQueue.processAllEntries();
      }

      // 2. Automatically migrate any legacy/unmigrated local data to Metron
      final migration = _migrationManager;
      if (migration != null) {
        final needsMigration = await migration.isMigrationNeeded();
        if (needsMigration) {
          _emit(_currentState.copyWith(currentPhase: "Migrating local data to Metron"));
          await migration.runMigration();
        }
      }

      // 3. Sync Collection (pull remote changes)
      _emit(_currentState.copyWith(currentPhase: "Syncing collection"));
      final colResult = await _collectionSyncManager.syncCollection(
        forceFullSync: forceFullSync,
      );

      // 4. Sync Pull List & Subscriptions
      _emit(_currentState.copyWith(currentPhase: "Syncing pull list"));
      final pullResult = await _pullListSyncManager.syncPullList();

      // 5. Sync Wishlist
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
    _debounceTimer?.cancel();
    _periodicTimer?.cancel();
    _pendingWritesSub?.cancel();
    _stateController.close();
  }
}
