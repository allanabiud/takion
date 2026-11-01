import "dart:async";
import "package:takion/src/core/logging/app_logger.dart";
import "package:takion/src/core/network/metron_request_scheduler.dart";
import "package:takion/src/core/performance/performance_metrics.dart";
import "package:takion/src/core/sync/adapters/remote_sync_adapter.dart";
import "package:takion/src/core/sync/metron_sync_state.dart";
import "package:takion/src/core/sync/outbox/outbox_executor.dart";
import "package:takion/src/data/common/drift/daos/outbox_dao.dart";
import "package:takion/src/data/common/drift/daos/sync_job_dao.dart";
import "package:takion/src/data/common/drift/daos/sync_lease_dao.dart";
import "package:uuid/uuid.dart";

enum SyncEngineStatus { success, alreadyRunning, yieldedRateLimit, failed }

class SyncEngineRunResult {
  const SyncEngineRunResult({
    required this.status,
    this.outboxResult,
    this.adapterResults = const {},
    this.errorMessage,
  });

  const SyncEngineRunResult.alreadyRunning()
    : status = SyncEngineStatus.alreadyRunning,
      outboxResult = null,
      adapterResults = const {},
      errorMessage = null;

  final SyncEngineStatus status;
  final OutboxDrainResult? outboxResult;
  final Map<String, SyncAdapterResult> adapterResults;
  final String? errorMessage;

  bool get isSuccess => status == SyncEngineStatus.success;
  bool get wasAlreadyRunning => status == SyncEngineStatus.alreadyRunning;
}

class SyncEngine {
  SyncEngine({
    required SyncLeaseDao leaseDao,
    required SyncJobDao jobDao,
    required OutboxDao outboxDao,
    required OutboxExecutor outboxExecutor,
    required List<RemoteSyncAdapter> adapters,
    MetronRequestScheduler? scheduler,
    String? runnerId,
  }) : _leaseDao = leaseDao,
       _jobDao = jobDao,
       _outboxDao = outboxDao,
       _outboxExecutor = outboxExecutor,
       _adapters = {for (final a in adapters) a.resource: a},
       _scheduler = scheduler,
       _runnerId = runnerId ?? "runner-${const Uuid().v4().substring(0, 8)}" {
    _initQueueWatch();
  }

  final SyncLeaseDao _leaseDao;
  final SyncJobDao _jobDao;
  final OutboxDao _outboxDao;
  final OutboxExecutor _outboxExecutor;
  final Map<String, RemoteSyncAdapter> _adapters;
  final MetronRequestScheduler? _scheduler;
  final String _runnerId;

  /// Fallback retry delay used when a rate-limit yield happens without a
  /// known reset time.
  static const _rateLimitFallbackDelay = Duration(seconds: 60);

  final StreamController<MetronSyncState> _stateController =
      StreamController<MetronSyncState>.broadcast();
  MetronSyncState _currentState = const MetronSyncState();

  StreamSubscription<int>? _outboxSub;
  Timer? _debounceTimer;

  MetronSyncState get currentState => _currentState;
  Stream<MetronSyncState> get stateStream => _stateController.stream;

  void _emit(MetronSyncState state) {
    _currentState = state;
    if (!_stateController.isClosed) {
      _stateController.add(state);
    }
  }

  void _initQueueWatch() {
    _outboxSub = _outboxDao.watchPendingCount().listen((count) {
      _emit(_currentState.copyWith(pendingQueueCount: count));
      if (count > 0 && !_currentState.isSyncing) {
        scheduleSync(debounce: const Duration(seconds: 3));
      }
    });
  }

  /// Debounces a request to sync.
  void scheduleSync({
    Duration debounce = const Duration(seconds: 3),
    String reason = "outbox_pending",
  }) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounce, () {
      AppLogger.info("Executing debounced sync job: $reason");
      requestSync(reason: reason);
    });
  }

  /// Requests a sync run, enqueueing a durable job and triggering execution.
  Future<SyncEngineRunResult> requestSync({
    required String reason,
    String? resource,
    bool forceFullSync = false,
    int priority = 0,
    String accountId = "local-user",
  }) async {
    final jobId = await _jobDao.enqueueOrMerge(
      accountId: accountId,
      reason: reason,
      resource: resource,
      priority: priority,
    );

    return runDueWork(
      trigger: reason,
      resource: resource,
      forceFullSync: forceFullSync,
      accountId: accountId,
      jobId: jobId,
    );
  }

  /// Runs due work if the database lease can be acquired.
  /// Guarantees that only one isolate (foreground or Workmanager) runs at a time.
  Future<SyncEngineRunResult> runDueWork({
    required String trigger,
    String? resource,
    bool forceFullSync = false,
    String accountId = "local-user",
    String? jobId,
  }) async {
    // Phase 5 Step 1: never fire into a known rate-limit blackout. Yield
    // immediately and reschedule the durable job at the reset time instead
    // of burning quota on requests that would 429 anyway.
    final blockedUntil = _scheduler?.rateLimitedUntil;
    if (blockedUntil != null && blockedUntil.isAfter(DateTime.now().toUtc())) {
      AppLogger.info(
        "SyncEngine: Rate-limited until $blockedUntil — yielding run "
        "(job: ${jobId ?? "none"}).",
      );
      return _yieldRateLimit(jobId: jobId, retryAt: blockedUntil);
    }

    final leaseName = "metron:$accountId";
    const leaseTtl = Duration(minutes: 9);

    final acquired = await _leaseDao.tryAcquire(
      name: leaseName,
      ownerId: _runnerId,
      ttl: leaseTtl,
    );

    if (!acquired) {
      AppLogger.info(
        "SyncEngine: Lease '$leaseName' already held by another runner. Skipping run.",
      );
      return const SyncEngineRunResult.alreadyRunning();
    }

    Timer? heartbeatTimer;
    heartbeatTimer = Timer.periodic(const Duration(minutes: 2), (_) async {
      final renewed = await _leaseDao.heartbeat(
        name: leaseName,
        ownerId: _runnerId,
        ttl: leaseTtl,
      );
      if (!renewed) {
        AppLogger.warning("SyncEngine: Failed to renew lease heartbeat");
      }
    });

    _emit(
      _currentState.copyWith(
        status: SyncStatus.syncing,
        currentPhase: "Draining outbox writes",
        errorMessage: null,
      ),
    );

    OutboxDrainResult? drainResult;
    final adapterResults = <String, SyncAdapterResult>{};
    String? criticalError;

    try {
      // 1. Drain pending outbox writes
      drainResult = await _outboxExecutor.drain(
        accountId: accountId,
        budget: const Duration(minutes: 3),
      );

      if (drainResult.stoppedDueToRateLimit) {
        AppLogger.warning(
          "SyncEngine: Outbox drain stopped due to rate limit quota.",
        );
        return _yieldRateLimit(jobId: jobId, outboxResult: drainResult);
      }

      // 2. Run resource pull adapters
      final budget = SyncBudget(
        maxRequests: 50,
        timeBudget: const Duration(minutes: 5),
      );

      final targetAdapters = resource != null
          ? [_adapters[resource]].whereType<RemoteSyncAdapter>().toList()
          : _adapters.values.toList();

      for (final adapter in targetAdapters) {
        if (!budget.canMakeAnotherRequest) {
          AppLogger.info(
            "SyncEngine: Budget reached during adapter run (${adapter.resource})",
          );
          break;
        }

        _emit(
          _currentState.copyWith(currentPhase: "Syncing ${adapter.resource}"),
        );

        final result = await adapter.sync(
          accountId: accountId,
          budget: budget,
          forceFullSync: forceFullSync,
          onProgress: (count) {
            if (adapter.resource == "collection") {
              _emit(_currentState.copyWith(collectionItemsSynced: count));
            } else if (adapter.resource == "pull_series") {
              _emit(_currentState.copyWith(pullListSeriesSynced: count));
            } else if (adapter.resource == "pull_issues") {
              _emit(_currentState.copyWith(pullListIssuesSynced: count));
            } else if (adapter.resource == "wishlist") {
              _emit(_currentState.copyWith(wishlistItemsSynced: count));
            }
          },
        );
        adapterResults[adapter.resource] = result;

        if (adapter.resource == "collection") {
          _emit(
            _currentState.copyWith(collectionItemsSynced: result.itemsUpdated),
          );
        } else if (adapter.resource == "pull_series") {
          _emit(
            _currentState.copyWith(pullListSeriesSynced: result.itemsUpdated),
          );
        } else if (adapter.resource == "pull_issues") {
          _emit(
            _currentState.copyWith(pullListIssuesSynced: result.itemsUpdated),
          );
        } else if (adapter.resource == "wishlist") {
          _emit(
            _currentState.copyWith(wishlistItemsSynced: result.itemsUpdated),
          );
        }
      }

      if (drainResult.conflictCount > 0) {
        AppPerformanceMetrics.instance.recordConflict(
          count: drainResult.conflictCount,
        );
      }

      if (jobId != null) {
        await _jobDao.completeJob(jobId);
      }

      final hasErrors = adapterResults.values.any((r) => !r.isSuccess);
      final now = DateTime.now().toUtc();

      _emit(
        _currentState.copyWith(
          status: hasErrors ? SyncStatus.error : SyncStatus.success,
          currentPhase: hasErrors ? "Completed with errors" : "Idle",
          lastSyncedAt: now,
          errorMessage: hasErrors
              ? adapterResults.values
                    .firstWhere((r) => !r.isSuccess)
                    .errorMessage
              : null,
        ),
      );

      return SyncEngineRunResult(
        status: hasErrors ? SyncEngineStatus.failed : SyncEngineStatus.success,
        outboxResult: drainResult,
        adapterResults: adapterResults,
      );
    } catch (e, st) {
      AppLogger.error("SyncEngine runDueWork failed", error: e, stackTrace: st);
      criticalError = e.toString();
      if (jobId != null) {
        await _jobDao.failJob(jobId, error: criticalError);
      }
      _emit(
        _currentState.copyWith(
          status: SyncStatus.error,
          currentPhase: "Failed",
          errorMessage: criticalError,
        ),
      );
      return SyncEngineRunResult(
        status: SyncEngineStatus.failed,
        outboxResult: drainResult,
        adapterResults: adapterResults,
        errorMessage: criticalError,
      );
    } finally {
      heartbeatTimer.cancel();
      await _leaseDao.release(leaseName, _runnerId);
    }
  }

  /// Yields a run due to an active rate-limit cooldown: the durable job is
  /// rescheduled with a `notBefore` equal to the reset time so neither the
  /// foreground nor the Workmanager continuation fires into the blackout
  /// ([SyncJobDao.failJob] with `retryAt` keeps the job `pending`).
  Future<SyncEngineRunResult> _yieldRateLimit({
    String? jobId,
    DateTime? retryAt,
    OutboxDrainResult? outboxResult,
  }) async {
    final until =
        retryAt ??
        _scheduler?.rateLimitedUntil ??
        DateTime.now().toUtc().add(_rateLimitFallbackDelay);

    if (jobId != null) {
      await _jobDao.failJob(
        jobId,
        error: "Rate limit exhausted; waiting until reset",
        retryAt: until,
      );
    }

    _emit(
      _currentState.copyWith(
        status: SyncStatus.error,
        currentPhase: "Rate limit reached",
        errorMessage:
            "Rate limit reached; sync resumes automatically "
            "at ${until.toIso8601String()}.",
      ),
    );

    return SyncEngineRunResult(
      status: SyncEngineStatus.yieldedRateLimit,
      outboxResult: outboxResult,
      errorMessage: "Rate-limited until ${until.toIso8601String()}",
    );
  }

  void dispose() {
    _debounceTimer?.cancel();
    _outboxSub?.cancel();
    _stateController.close();
  }
}
