import "dart:async";
import "package:takion/src/core/logging/app_logger.dart";
import "package:takion/src/core/migration/collection_migrator.dart";
import "package:takion/src/core/migration/migration_state.dart";
import "package:takion/src/core/migration/pull_list_migrator.dart";
import "package:takion/src/core/migration/wishlist_migrator.dart";
import "package:takion/src/data/common/drift/database.dart" as db;

class MigrationManager {
  MigrationManager({
    required db.AppDatabase database,
    required CollectionMigrator collectionMigrator,
    required PullListMigrator pullListMigrator,
    WishlistMigrator? wishlistMigrator,
  }) : _database = database,
       _collectionMigrator = collectionMigrator,
       _pullListMigrator = pullListMigrator,
       _wishlistMigrator = wishlistMigrator;

  static const String _migrationCompletedKey = "metron_migration_completed";

  final db.AppDatabase _database;
  final CollectionMigrator _collectionMigrator;
  final PullListMigrator _pullListMigrator;
  final WishlistMigrator? _wishlistMigrator;

  final StreamController<MigrationProgress> _progressController =
      StreamController<MigrationProgress>.broadcast();

  MigrationProgress _currentProgress = const MigrationProgress();
  bool _cancelled = false;
  int _retryCount = 0;
  Timer? _retryTimer;
  static const _maxAutoRetries = 3;

  MigrationProgress get currentProgress => _currentProgress;
  Stream<MigrationProgress> get progressStream => _progressController.stream;

  void _emit(MigrationProgress progress) {
    _currentProgress = progress;
    if (!_progressController.isClosed) {
      _progressController.add(progress);
    }
  }

  void cancel() {
    _cancelled = true;
    _retryTimer?.cancel();
  }

  void _scheduleAutoRetry() {
    _retryCount++;
    final delaySeconds = 30 * _retryCount;
    AppLogger.info(
      "Scheduling auto-retry #$_retryCount in ${delaySeconds}s for ${_currentProgress.failedItems} failed items",
    );
    _emit(
      _currentProgress.copyWith(
        currentStep:
            "Retrying ${_currentProgress.failedItems} failed items in ${delaySeconds}s (attempt $_retryCount/$_maxAutoRetries)...",
      ),
    );
    _retryTimer?.cancel();
    _retryTimer = Timer(Duration(seconds: delaySeconds), () async {
      if (_cancelled) return;
      AppLogger.info("Auto-retry #$_retryCount starting");
      await runMigration();
    });
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
    final unmigratedWish = await _wishlistMigrator?.countUnmigrated() ?? 0;

    return (unmigratedCollection + unmigratedSubs + unmigratedWish) > 0;
  }

  Future<MigrationProgress> runMigration() async {
    if (_currentProgress.isMigrating) {
      return _currentProgress;
    }

    _cancelled = false;
    if (_retryTimer == null || !_retryTimer!.isActive) {
      _retryCount = 0;
    }
    final stopwatch = Stopwatch()..start();

    try {
      final totalCol = await _collectionMigrator.countUnmigrated();
      final totalSubs = await _pullListMigrator.countUnmigrated();
      final totalWish = await _wishlistMigrator?.countUnmigrated() ?? 0;

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
      _emit(
        _currentProgress.copyWith(
          currentStep: "Migrating collection (0/$totalCol)",
        ),
      );
      final colResult = await _collectionMigrator.migrate(
        onProgress: (processed, total) {
          _emit(
            _currentProgress.copyWith(
              migratedCollection: processed,
              currentStep: "Migrating collection ($processed/$total)",
              elapsedMs: stopwatch.elapsedMilliseconds,
            ),
          );
        },
        isCancelled: () => _cancelled,
      );

      // 2. Migrate subscriptions / pull list
      MigrationResult subResult = const MigrationResult(migrated: 0, failed: 0);
      if (!_cancelled) {
        _emit(
          _currentProgress.copyWith(
            currentStep: "Migrating subscriptions (0/$totalSubs)",
            failedCollection: colResult.failed,
          ),
        );
        subResult = await _pullListMigrator.migrate(
          onProgress: (processed, total) {
            _emit(
              _currentProgress.copyWith(
                migratedSubscriptions: processed,
                currentStep: "Migrating subscriptions ($processed/$total)",
                elapsedMs: stopwatch.elapsedMilliseconds,
              ),
            );
          },
          isCancelled: () => _cancelled,
        );
      }

      // 3. Migrate wishlist
      MigrationResult wishResult = const MigrationResult(
        migrated: 0,
        failed: 0,
      );
      if (!_cancelled && _wishlistMigrator != null && totalWish > 0) {
        _emit(
          _currentProgress.copyWith(
            currentStep: "Migrating wishlist (0/$totalWish)",
            failedSubscriptions: subResult.failed,
          ),
        );
        wishResult = await _wishlistMigrator.migrate(
          onProgress: (processed, total) {
            _emit(
              _currentProgress.copyWith(
                migratedWishlist: processed,
                currentStep: "Migrating wishlist ($processed/$total)",
                elapsedMs: stopwatch.elapsedMilliseconds,
              ),
            );
          },
          isCancelled: () => _cancelled,
        );
      }

      stopwatch.stop();

      if (_cancelled) {
        final cancelledProgress = _currentProgress.copyWith(
          status: MigrationStatus.failed,
          currentStep: "Migration cancelled",
          failedCollection: colResult.failed,
          failedSubscriptions: subResult.failed,
          failedWishlist: wishResult.failed,
          errorMessage: "Migration was cancelled by user",
          elapsedMs: stopwatch.elapsedMilliseconds,
        );
        _emit(cancelledProgress);
        return cancelledProgress;
      }

      await _database.settingsDao.setBool(_migrationCompletedKey, true);

      final totalFailed =
          colResult.failed + subResult.failed + wishResult.failed;
      final completedProgress = _currentProgress.copyWith(
        status: MigrationStatus.completed,
        currentStep: "Migration completed",
        migratedCollection: colResult.migrated,
        migratedSubscriptions: subResult.migrated,
        migratedWishlist: wishResult.migrated,
        failedCollection: colResult.failed,
        failedSubscriptions: subResult.failed,
        failedWishlist: wishResult.failed,
        elapsedMs: stopwatch.elapsedMilliseconds,
      );

      _emit(completedProgress);
      AppLogger.info(
        "One-time migration finished: ${colResult.migrated} collection, ${subResult.migrated} subs, ${wishResult.migrated} wishlist "
        "($totalFailed failed)",
      );

      if (totalFailed > 0 && _retryCount < _maxAutoRetries) {
        _scheduleAutoRetry();
      }

      return completedProgress;
    } catch (e, st) {
      stopwatch.stop();
      AppLogger.error("One-time migration failed", error: e, stackTrace: st);
      final errorProgress = _currentProgress.copyWith(
        status: MigrationStatus.failed,
        currentStep: "Migration failed",
        errorMessage: e.toString(),
        elapsedMs: stopwatch.elapsedMilliseconds,
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
    _retryTimer?.cancel();
    _progressController.close();
  }
}
