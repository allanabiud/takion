import "dart:async";
import "package:takion/src/core/logging/app_logger.dart";
import "package:takion/src/core/migration/migration_manager.dart";
import "package:takion/src/core/sync/metron_sync_state.dart";
import "package:takion/src/core/sync/offline_queue/offline_write_queue.dart";
import "package:takion/src/core/sync/sync_engine.dart";
import "package:takion/src/data/collection/sync/collection_sync_manager.dart";
import "package:takion/src/data/pull_list/sync/pull_list_sync_manager.dart";
import "package:takion/src/data/wishlist/sync/wishlist_sync_manager.dart";

/// A UI-facing facade for Metron synchronization.
/// Delegates to [SyncEngine] when available, or falls back to domain sync managers.
class MetronSyncManager {
  MetronSyncManager({
    SyncEngine? syncEngine,
    CollectionSyncManager? collectionSyncManager,
    PullListSyncManager? pullListSyncManager,
    WishlistSyncManager? wishlistSyncManager,
    MigrationManager? migrationManager,
    OfflineWriteQueue? offlineWriteQueue,
  }) : _syncEngine = syncEngine,
       _collectionSyncManager = collectionSyncManager,
       _pullListSyncManager = pullListSyncManager,
       _wishlistSyncManager = wishlistSyncManager,
       _migrationManager = migrationManager,
       _offlineWriteQueue = offlineWriteQueue {
    if (_syncEngine != null) {
      _currentState = _syncEngine.currentState;
      _engineSub = _syncEngine.stateStream.listen(_emit);
    } else {
      _initAutoSyncListeners();
    }
  }

  final SyncEngine? _syncEngine;
  final CollectionSyncManager? _collectionSyncManager;
  final PullListSyncManager? _pullListSyncManager;
  final WishlistSyncManager? _wishlistSyncManager;
  final MigrationManager? _migrationManager;
  final OfflineWriteQueue? _offlineWriteQueue;

  final StreamController<MetronSyncState> _stateController =
      StreamController<MetronSyncState>.broadcast();

  MetronSyncState _currentState = const MetronSyncState();
  Timer? _debounceTimer;
  StreamSubscription<int>? _pendingWritesSub;
  StreamSubscription<MetronSyncState>? _engineSub;
  DateTime _lastSyncTriggeredAt = DateTime.fromMillisecondsSinceEpoch(0);

  MetronSyncState get currentState =>
      _syncEngine != null ? _syncEngine.currentState : _currentState;
  Stream<MetronSyncState> get stateStream {
    final controller = StreamController<MetronSyncState>(sync: true);
    controller.add(currentState);
    final sub = _stateController.stream.listen(
      controller.add,
      onError: controller.addError,
      onDone: controller.close,
    );
    controller.onCancel = () {
      sub.cancel();
      controller.close();
    };
    return controller.stream;
  }

  void _emit(MetronSyncState newState) {
    _currentState = newState;
    if (!_stateController.isClosed) {
      _stateController.add(newState);
    }
  }

  void _initAutoSyncListeners() {
    if (_offlineWriteQueue != null) {
      _pendingWritesSub = _offlineWriteQueue.watchPendingCount().listen((
        count,
      ) {
        if (count > 0 &&
            !_currentState.isSyncing &&
            DateTime.now().difference(_lastSyncTriggeredAt) >
                const Duration(minutes: 1)) {
          scheduleSync();
        }
      });
    }
  }

  /// Schedules a debounced background sync.
  void scheduleSync({
    Duration debounce = const Duration(seconds: 3),
    String reason = "scheduled",
  }) {
    if (_syncEngine != null) {
      _syncEngine.scheduleSync(debounce: debounce, reason: reason);
      return;
    }
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounce, () {
      AppLogger.info("Executing scheduled debounced Metron sync");
      syncAll();
    });
  }

  Future<MetronSyncState> syncAll({bool forceFullSync = false}) async {
    if (_syncEngine != null) {
      await _syncEngine.requestSync(
        reason: "manual",
        forceFullSync: forceFullSync,
      );
      return _syncEngine.currentState;
    }

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

      // 2. Automatically migrate legacy local data to Metron
      final migration = _migrationManager;
      if (migration != null) {
        final needsMigration = await migration.isMigrationNeeded();
        if (needsMigration) {
          _emit(
            _currentState.copyWith(
              currentPhase: "Migrating local data to Metron",
            ),
          );
          await migration.runMigration();
        }
      }

      // 3. Sync Collection
      _emit(_currentState.copyWith(currentPhase: "Syncing collection"));
      final colResult = _collectionSyncManager != null
          ? await _collectionSyncManager.syncCollection(
              forceFullSync: forceFullSync,
              onProgress: (count) {
                _emit(
                  _currentState.copyWith(
                    currentPhase: "Syncing collection",
                    collectionItemsSynced: count,
                  ),
                );
              },
            )
          : null;

      // 4. Sync Pull List & Subscriptions
      _emit(
        _currentState.copyWith(
          currentPhase: "Syncing pull list",
          collectionItemsSynced: colResult?.itemsFetched ?? 0,
        ),
      );
      final pullResult = _pullListSyncManager != null
          ? await _pullListSyncManager.syncPullList(
              forceFullSync: forceFullSync,
              onProgress: (seriesCount, issuesCount) {
                _emit(
                  _currentState.copyWith(
                    currentPhase: "Syncing pull list",
                    pullListSeriesSynced: seriesCount,
                    pullListIssuesSynced: issuesCount,
                  ),
                );
              },
            )
          : null;

      // 5. Sync Wishlist
      _emit(
        _currentState.copyWith(
          currentPhase: "Syncing wishlist",
          pullListSeriesSynced: pullResult?.seriesFetched ?? 0,
          pullListIssuesSynced: pullResult?.issuesFetched ?? 0,
        ),
      );
      final wishResult = _wishlistSyncManager != null
          ? await _wishlistSyncManager.syncWishlist(
              forceFullSync: forceFullSync,
              onProgress: (count) {
                _emit(
                  _currentState.copyWith(
                    currentPhase: "Syncing wishlist",
                    wishlistItemsSynced: count,
                  ),
                );
              },
            )
          : null;

      final now = DateTime.now().toUtc();
      final hasFailures =
          (colResult != null && !colResult.isSuccess) ||
          (pullResult != null && !pullResult.isSuccess) ||
          (wishResult != null && !wishResult.isSuccess);

      final resultState = _currentState.copyWith(
        status: hasFailures ? SyncStatus.error : SyncStatus.success,
        currentPhase: hasFailures ? "Completed with errors" : "Idle",
        lastSyncedAt: now,
        collectionItemsSynced: colResult?.itemsFetched ?? 0,
        pullListSeriesSynced: pullResult?.seriesFetched ?? 0,
        pullListIssuesSynced: pullResult?.issuesFetched ?? 0,
        wishlistItemsSynced: wishResult?.itemsFetched ?? 0,
        errorMessage:
            colResult?.errorMessage ??
            pullResult?.errorMessage ??
            wishResult?.errorMessage,
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
    _pendingWritesSub?.cancel();
    _engineSub?.cancel();
    _stateController.close();
  }
}
