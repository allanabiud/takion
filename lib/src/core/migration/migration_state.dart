enum MigrationStatus { notStarted, migrating, completed, skipped, failed }

class MigrationProgress {
  const MigrationProgress({
    this.status = MigrationStatus.notStarted,
    this.currentStep,
    this.totalCollection = 0,
    this.migratedCollection = 0,
    this.totalSubscriptions = 0,
    this.migratedSubscriptions = 0,
    this.totalWishlist = 0,
    this.migratedWishlist = 0,
    this.errorMessage,
  });

  final MigrationStatus status;
  final String? currentStep;
  final int totalCollection;
  final int migratedCollection;
  final int totalSubscriptions;
  final int migratedSubscriptions;
  final int totalWishlist;
  final int migratedWishlist;
  final String? errorMessage;

  int get totalItems => totalCollection + totalSubscriptions + totalWishlist;
  int get migratedItems =>
      migratedCollection + migratedSubscriptions + migratedWishlist;

  double get progressFraction {
    if (totalItems == 0) return 1.0;
    return (migratedItems / totalItems).clamp(0.0, 1.0);
  }

  bool get isMigrating => status == MigrationStatus.migrating;
  bool get isCompleted => status == MigrationStatus.completed;
  bool get hasFailed => status == MigrationStatus.failed;

  MigrationProgress copyWith({
    MigrationStatus? status,
    String? currentStep,
    int? totalCollection,
    int? migratedCollection,
    int? totalSubscriptions,
    int? migratedSubscriptions,
    int? totalWishlist,
    int? migratedWishlist,
    String? errorMessage,
  }) {
    return MigrationProgress(
      status: status ?? this.status,
      currentStep: currentStep,
      totalCollection: totalCollection ?? this.totalCollection,
      migratedCollection: migratedCollection ?? this.migratedCollection,
      totalSubscriptions: totalSubscriptions ?? this.totalSubscriptions,
      migratedSubscriptions:
          migratedSubscriptions ?? this.migratedSubscriptions,
      totalWishlist: totalWishlist ?? this.totalWishlist,
      migratedWishlist: migratedWishlist ?? this.migratedWishlist,
      errorMessage: errorMessage,
    );
  }
}
