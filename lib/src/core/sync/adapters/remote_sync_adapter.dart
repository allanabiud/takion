class SyncBudget {
  SyncBudget({
    this.maxRequests = 50,
    this.timeBudget = const Duration(minutes: 5),
    DateTime? startTime,
  }) : _startTime = startTime ?? DateTime.now().toUtc(),
       _remainingRequests = maxRequests;

  final int maxRequests;
  final Duration timeBudget;
  final DateTime _startTime;
  int _remainingRequests;

  int get remainingRequests => _remainingRequests;

  bool get canMakeAnotherRequest => _remainingRequests > 0 && !isExpired;

  bool get isExpired =>
      DateTime.now().toUtc().difference(_startTime) >= timeBudget;

  void recordRequest() {
    if (_remainingRequests > 0) {
      _remainingRequests--;
    }
  }
}

class SyncAdapterResult {
  const SyncAdapterResult({
    required this.resource,
    this.itemsFetched = 0,
    this.itemsUpdated = 0,
    this.isSuccess = true,
    this.isComplete = true,
    this.errorMessage,
  });

  final String resource;
  final int itemsFetched;
  final int itemsUpdated;
  final bool isSuccess;
  final bool isComplete;
  final String? errorMessage;
}

abstract interface class RemoteSyncAdapter {
  String get resource;

  Future<SyncAdapterResult> sync({
    required String accountId,
    required SyncBudget budget,
    bool forceFullSync = false,
    void Function(int count)? onProgress,
  });
}
