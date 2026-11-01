import "package:drift/drift.dart";
import "package:takion/src/core/logging/app_logger.dart";
import "package:takion/src/core/migration/migration_state.dart";
import "package:takion/src/data/collection/datasources/remote/metron_collection_remote_data_source.dart";
import "package:takion/src/data/common/drift/database.dart" as db;

class CollectionMigrator {
  CollectionMigrator({
    required db.AppDatabase database,
    required MetronCollectionRemoteDataSource remoteDataSource,
    Duration Function()? rateLimitDelay,
  }) : _database = database,
       _remoteDataSource = remoteDataSource,
       _rateLimitDelay = rateLimitDelay;

  final db.AppDatabase _database;
  final MetronCollectionRemoteDataSource _remoteDataSource;
  final Duration Function()? _rateLimitDelay;

  Duration get _currentDelay =>
      _rateLimitDelay?.call() ?? const Duration(milliseconds: 3200);

  Future<List<db.LibraryItem>> getUnmigratedItems() async {
    return (_database.select(_database.libraryItems)..where(
          (t) =>
              t.ownershipStatus.equals("owned") & t.metronCollectionId.isNull(),
        ))
        .get();
  }

  Future<int> countUnmigrated() async {
    final countExp = _database.libraryItems.id.count();
    final query = _database.selectOnly(_database.libraryItems)
      ..addColumns([countExp])
      ..where(
        _database.libraryItems.ownershipStatus.equals("owned") &
            _database.libraryItems.metronCollectionId.isNull(),
      );
    final result = await query.getSingleOrNull();
    return result?.read(countExp) ?? 0;
  }

  Future<MigrationResult> migrate({
    void Function(int migrated, int total)? onProgress,
    bool Function()? isCancelled,
  }) async {
    final unmigrated = await getUnmigratedItems();
    if (unmigrated.isEmpty) {
      return const MigrationResult(migrated: 0, failed: 0);
    }

    var migratedCount = 0;
    var failedCount = 0;
    final total = unmigrated.length;

    for (var i = 0; i < unmigrated.length; i++) {
      if (isCancelled?.call() == true) break;

      if (i > 0) {
        await Future<void>.delayed(_currentDelay);
      }

      final item = unmigrated[i];
      try {
        final dto = await _remoteDataSource.addToCollection(
          issueId: item.metronIssueId,
          quantity: item.quantityOwned,
          bookFormat: item.format.toUpperCase(),
          grade: item.conditionGrade != null
              ? double.tryParse(item.conditionGrade!)
              : null,
          purchaseDate: item.purchaseDate != null
              ? DateTime.tryParse(item.purchaseDate!)
              : null,
          purchasePrice: item.pricePaid,
          notes: item.notes,
        );

        await (_database.update(
          _database.libraryItems,
        )..where((t) => t.id.equals(item.id))).write(
          db.LibraryItemsCompanion(
            metronCollectionId: Value(dto.id),
            syncStatus: const Value("synced"),
            updatedAt: Value(DateTime.now().toUtc().toIso8601String()),
          ),
        );

        migratedCount++;
        onProgress?.call(migratedCount + failedCount, total);
      } catch (e, st) {
        failedCount++;
        AppLogger.warning(
          "Failed to migrate library item #${item.metronIssueId}",
          error: e,
          stackTrace: st,
        );
        onProgress?.call(migratedCount + failedCount, total);
      }
    }

    return MigrationResult(migrated: migratedCount, failed: failedCount);
  }
}
