import "dart:async";
import "package:takion/src/core/logging/app_logger.dart";
import "package:takion/src/core/migration/collection_migrator.dart";
import "package:takion/src/core/migration/migration_state.dart";
import "package:takion/src/core/migration/pull_list_migrator.dart";
import "package:takion/src/core/migration/wish_list_migrator.dart";
import "package:takion/src/data/common/drift/database.dart" as db;

class MigrationManager {
  MigrationManager({
    required db.AppDatabase database,
    required CollectionMigrator collectionMigrator,
    required PullListMigrator pullListMigrator,
    required WishListMigrator wishListMigrator,
  })  : _database = database,
        _collectionMigrator = collectionMigrator,
        _pullListMigrator = pullListMigrator,
        _wishListMigrator = wishListMigrator;

  static const String _migrationCompletedKey = "metron_migration_completed";

  final db.AppDatabase _database;
  final CollectionMigrator _collectionMigrator;
  final PullListMigrator _pullListMigrator;
  final WishListMigrator _wishListMigrator;

  final StreamController<MigrationProgress> _progressController =
      StreamController<MigrationProgress>.broadcast();

  MigrationProgress _currentProgress = const MigrationProgress();

  MigrationProgress get currentProgress => _currentProgress;
  Stream<MigrationProgress> get progressStream => _progressController.stream;

  void _emit(MigrationProgress progress) {
    _currentProgress = progress;
    if (!_progressController.isClosed) {
      _progressController.add(progress);
    }
  }

  Future<bool> isMigrationCompleted() async {
    return _database.settingsDao.getBool(
      _migrationCompletedKey,
      defaultValue: false,
    );
  }

  Future<bool> isMigrationNeeded() async {
    final completed = await isMigrationCompleted();
    if (completed) return false;

    final unmigratedCollection = await _collectionMigrator.countUnmigrated();
    final unmigratedSubs = await _pullListMigrator.countUnmigrated();
    final unmigratedWishlist = await _wishListMigrator.countUnmigrated();

    return (unmigratedCollection + unmigratedSubs + unmigratedWishlist) > 0;
  }

  Future<MigrationProgress> runMigration() async {
    if (_currentProgress.isMigrating) {
      return _currentProgress;
    }

    try {
      final totalCol = await _collectionMigrator.countUnmigrated();
      final totalSubs = await _pullListMigrator.countUnmigrated();
      final totalWish = await _wishListMigrator.countUnmigrated();

      _emit(
        MigrationProgress(
          status: MigrationStatus.migrating,
          currentStep: "Starting migration",
          totalCollection: totalCol,
          totalSubscriptions: totalSubs,
          totalWishlist: totalWish,
        ),
      );

      // 1. Migrate collection
      _emit(_currentProgress.copyWith(currentStep: "Migrating collection"));
      final migratedCol = await _collectionMigrator.migrate(
        onProgress: (migrated, total) {
          _emit(
            _currentProgress.copyWith(
              migratedCollection: migrated,
              currentStep: "Migrated $migrated of $total collection items",
            ),
          );
        },
      );

      // 2. Migrate subscriptions / pull list
      _emit(_currentProgress.copyWith(currentStep: "Migrating subscriptions"));
      final migratedSubs = await _pullListMigrator.migrate(
        onProgress: (migrated, total) {
          _emit(
            _currentProgress.copyWith(
              migratedSubscriptions: migrated,
              currentStep: "Migrated $migrated of $total subscriptions",
            ),
          );
        },
      );

      // 3. Migrate wishlist
      _emit(_currentProgress.copyWith(currentStep: "Migrating wishlist"));
      final migratedWish = await _wishListMigrator.migrate(
        onProgress: (migrated, total) {
          _emit(
            _currentProgress.copyWith(
              migratedWishlist: migrated,
              currentStep: "Migrated $migrated of $total wishlist items",
            ),
          );
        },
      );

      await _database.settingsDao.setBool(_migrationCompletedKey, true);

      final completedProgress = _currentProgress.copyWith(
        status: MigrationStatus.completed,
        currentStep: "Migration completed successfully",
        migratedCollection: migratedCol,
        migratedSubscriptions: migratedSubs,
        migratedWishlist: migratedWish,
      );

      _emit(completedProgress);
      AppLogger.info(
        "One-time migration finished: $migratedCol collection, $migratedSubs subscriptions, $migratedWish wishlist",
      );
      return completedProgress;
    } catch (e, st) {
      AppLogger.error("One-time migration failed", error: e, stackTrace: st);
      final errorProgress = _currentProgress.copyWith(
        status: MigrationStatus.failed,
        currentStep: "Migration failed",
        errorMessage: e.toString(),
      );
      _emit(errorProgress);
      return errorProgress;
    }
  }

  Future<void> skipMigration() async {
    await _database.settingsDao.setBool(_migrationCompletedKey, true);
    _emit(
      _currentProgress.copyWith(
        status: MigrationStatus.skipped,
        currentStep: "Migration skipped by user",
      ),
    );
  }

  void dispose() {
    _progressController.close();
  }
}
