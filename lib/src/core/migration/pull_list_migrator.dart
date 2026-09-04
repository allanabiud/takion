import "package:drift/drift.dart";
import "package:takion/src/core/logging/app_logger.dart";
import "package:takion/src/core/migration/migration_state.dart";
import "package:takion/src/data/common/drift/database.dart" as db;
import "package:takion/src/data/pull_list/datasources/remote/metron_pull_list_remote_data_source.dart";

class PullListMigrator {
  PullListMigrator({
    required db.AppDatabase database,
    required MetronPullListRemoteDataSource remoteDataSource,
  })  : _database = database,
        _remoteDataSource = remoteDataSource;

  final db.AppDatabase _database;
  final MetronPullListRemoteDataSource _remoteDataSource;

  static const int _batchSize = 18;
  static const Duration _batchDelay = Duration(seconds: 60);

  Future<List<db.SeriesSubscription>> getUnmigratedSubscriptions() async {
    return (_database.select(_database.seriesSubscriptions)
          ..where((t) => t.isActive.equals(true) & t.metronPullListId.isNull()))
        .get();
  }

  Future<int> countUnmigrated() async {
    final items = await getUnmigratedSubscriptions();
    return items.length;
  }

  Future<MigrationResult> migrate({
    void Function(int migrated, int total)? onProgress,
    bool Function()? isCancelled,
  }) async {
    final unmigrated = await getUnmigratedSubscriptions();
    if (unmigrated.isEmpty) return const MigrationResult(migrated: 0, failed: 0);

    var migratedCount = 0;
    var failedCount = 0;
    final total = unmigrated.length;

    for (var i = 0; i < unmigrated.length; i++) {
      if (isCancelled?.call() == true) break;

      if (i > 0 && i % _batchSize == 0) {
        await Future<void>.delayed(_batchDelay);
      }

      final sub = unmigrated[i];
      try {
        final dto = await _remoteDataSource.addSeriesToPullList(
          sub.metronSeriesId,
        );

        await (_database.update(_database.seriesSubscriptions)
              ..where((t) => t.id.equals(sub.id)))
            .write(
          db.SeriesSubscriptionsCompanion(
            metronPullListId: Value(dto.id),
            syncStatus: const Value("synced"),
            updatedAt: Value(DateTime.now().toUtc().toIso8601String()),
          ),
        );

        migratedCount++;
        onProgress?.call(migratedCount + failedCount, total);
      } catch (e, st) {
        failedCount++;
        AppLogger.warning(
          "Failed to migrate series subscription #${sub.metronSeriesId}",
          error: e,
          stackTrace: st,
        );
        onProgress?.call(migratedCount + failedCount, total);
      }
    }

    return MigrationResult(migrated: migratedCount, failed: failedCount);
  }
}
