import "package:drift/drift.dart";
import "package:takion/src/core/logging/app_logger.dart";
import "package:takion/src/data/collection/datasources/remote/metron_collection_remote_data_source.dart";
import "package:takion/src/data/common/drift/database.dart" as db;

class CollectionMigrator {
  CollectionMigrator({
    required db.AppDatabase database,
    required MetronCollectionRemoteDataSource remoteDataSource,
  })  : _database = database,
        _remoteDataSource = remoteDataSource;

  final db.AppDatabase _database;
  final MetronCollectionRemoteDataSource _remoteDataSource;

  Future<List<db.LibraryItem>> getUnmigratedItems() async {
    return (_database.select(_database.libraryItems)
          ..where(
            (t) =>
                t.ownershipStatus.equals("owned") &
                t.metronCollectionId.isNull(),
          ))
        .get();
  }

  Future<int> countUnmigrated() async {
    final items = await getUnmigratedItems();
    return items.length;
  }

  Future<int> migrate({
    void Function(int migrated, int total)? onProgress,
  }) async {
    final unmigrated = await getUnmigratedItems();
    if (unmigrated.isEmpty) return 0;

    var migratedCount = 0;
    final total = unmigrated.length;

    for (final item in unmigrated) {
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

        await (_database.update(_database.libraryItems)
              ..where((t) => t.id.equals(item.id)))
            .write(
          db.LibraryItemsCompanion(
            metronCollectionId: Value(dto.id),
            syncStatus: const Value("synced"),
            updatedAt: Value(DateTime.now().toUtc().toIso8601String()),
          ),
        );

        migratedCount++;
        onProgress?.call(migratedCount, total);
      } catch (e, st) {
        AppLogger.warning(
          "Failed to migrate library item #${item.metronIssueId}",
          error: e,
          stackTrace: st,
        );
      }
    }

    return migratedCount;
  }
}
