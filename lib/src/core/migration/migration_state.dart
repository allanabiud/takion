enum MigrationStatus { notStarted, migrating, completed, skipped, failed }

class MigrationResult {
  const MigrationResult({required this.migrated, required this.failed});
  final int migrated;
  final int failed;
}

class MigrationProgress {
  const MigrationProgress({
    this.status = MigrationStatus.notStarted,
    this.currentStep,
    this.totalCollection = 0,
    this.migratedCollection = 0,
    this.failedCollection = 0,
    this.totalSubscriptions = 0,
    this.migratedSubscriptions = 0,
    this.failedSubscriptions = 0,
    this.totalWishlist = 0,
    this.migratedWishlist = 0,
    this.failedWishlist = 0,
    this.errorMessage,
    this.elapsedMs = 0,
  });

  final MigrationStatus status;
  final String? currentStep;
  final int totalCollection;
  final int migratedCollection;
  final int failedCollection;
  final int totalSubscriptions;
  final int migratedSubscriptions;
  final int failedSubscriptions;
  final int totalWishlist;
  final int migratedWishlist;
  final int failedWishlist;
  final String? errorMessage;
  final int elapsedMs;

  int get totalItems => totalCollection + totalSubscriptions + totalWishlist;
  int get migratedItems =>
      migratedCollection + migratedSubscriptions + migratedWishlist;
  int get failedItems => failedCollection + failedSubscriptions + failedWishlist;
  int get processedItems => migratedItems + failedItems;

  double get progressFraction {
    if (totalItems == 0) return 1.0;
    return (processedItems / totalItems).clamp(0.0, 1.0);
  }

  Duration get elapsed => Duration(milliseconds: elapsedMs);

  Duration? get estimatedRemaining {
    if (processedItems == 0 || totalItems == 0) return null;
    final remaining = totalItems - processedItems;
    if (remaining <= 0) return null;
    final msPerItem = elapsedMs / processedItems;
    return Duration(milliseconds: (msPerItem * remaining).round());
  }

  bool get isMigrating => status == MigrationStatus.migrating;
  bool get isCompleted => status == MigrationStatus.completed;
  bool get hasFailed => status == MigrationStatus.failed;

  MigrationProgress copyWith({
    MigrationStatus? status,
    String? currentStep,
    int? totalCollection,
    int? migratedCollection,
    int? failedCollection,
    int? totalSubscriptions,
    int? migratedSubscriptions,
    int? failedSubscriptions,
    int? totalWishlist,
    int? migratedWishlist,
    int? failedWishlist,
    String? errorMessage,
    int? elapsedMs,
  }) {
    return MigrationProgress(
      status: status ?? this.status,
      currentStep: currentStep ?? this.currentStep,
      totalCollection: totalCollection ?? this.totalCollection,
      migratedCollection: migratedCollection ?? this.migratedCollection,
      failedCollection: failedCollection ?? this.failedCollection,
      totalSubscriptions: totalSubscriptions ?? this.totalSubscriptions,
      migratedSubscriptions:
          migratedSubscriptions ?? this.migratedSubscriptions,
      failedSubscriptions: failedSubscriptions ?? this.failedSubscriptions,
      totalWishlist: totalWishlist ?? this.totalWishlist,
      migratedWishlist: migratedWishlist ?? this.migratedWishlist,
      failedWishlist: failedWishlist ?? this.failedWishlist,
      errorMessage: errorMessage,
      elapsedMs: elapsedMs ?? this.elapsedMs,
    );
  }
}
