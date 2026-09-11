enum SyncStatus { idle, syncing, success, error }

class MetronSyncState {
  const MetronSyncState({
    this.status = SyncStatus.idle,
    this.currentPhase,
    this.lastSyncedAt,
    this.collectionItemsSynced = 0,
    this.pullListSeriesSynced = 0,
    this.pullListIssuesSynced = 0,
    this.wishlistItemsSynced = 0,
    this.pendingQueueCount = 0,
    this.errorMessage,
  });

  final SyncStatus status;
  final String? currentPhase;
  final DateTime? lastSyncedAt;
  final int collectionItemsSynced;
  final int pullListSeriesSynced;
  final int pullListIssuesSynced;
  final int wishlistItemsSynced;
  final int pendingQueueCount;
  final String? errorMessage;

  bool get isSyncing => status == SyncStatus.syncing;
  bool get hasError => status == SyncStatus.error;
  bool get isSuccess => status == SyncStatus.success;
  bool get isIdle => status == SyncStatus.idle;

  MetronSyncState copyWith({
    SyncStatus? status,
    String? currentPhase,
    DateTime? lastSyncedAt,
    int? collectionItemsSynced,
    int? pullListSeriesSynced,
    int? pullListIssuesSynced,
    int? wishlistItemsSynced,
    int? pendingQueueCount,
    String? errorMessage,
  }) {
    return MetronSyncState(
      status: status ?? this.status,
      currentPhase: currentPhase,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      collectionItemsSynced:
          collectionItemsSynced ?? this.collectionItemsSynced,
      pullListSeriesSynced: pullListSeriesSynced ?? this.pullListSeriesSynced,
      pullListIssuesSynced: pullListIssuesSynced ?? this.pullListIssuesSynced,
      wishlistItemsSynced: wishlistItemsSynced ?? this.wishlistItemsSynced,
      pendingQueueCount: pendingQueueCount ?? this.pendingQueueCount,
      errorMessage: errorMessage,
    );
  }
}
