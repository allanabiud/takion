import "package:drift/drift.dart";
import "package:takion/src/core/logging/app_logger.dart";
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

  Future<List<db.SeriesSubscription>> getUnmigratedSubscriptions() async {
    return (_database.select(_database.seriesSubscriptions)
          ..where((t) => t.isActive.equals(true) & t.metronPullListId.isNull()))
        .get();
  }

  Future<int> countUnmigrated() async {
    final items = await getUnmigratedSubscriptions();
    return items.length;
  }

  Future<int> migrate({
    void Function(int migrated, int total)? onProgress,
  }) async {
    final unmigrated = await getUnmigratedSubscriptions();
    if (unmigrated.isEmpty) return 0;

    var migratedCount = 0;
    final total = unmigrated.length;

    for (final sub in unmigrated) {
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
        onProgress?.call(migratedCount, total);
      } catch (e, st) {
        AppLogger.warning(
          "Failed to migrate series subscription #${sub.metronSeriesId}",
          error: e,
          stackTrace: st,
        );
      }
    }

    return migratedCount;
  }
}
