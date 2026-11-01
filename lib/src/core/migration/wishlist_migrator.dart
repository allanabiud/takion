import "package:drift/drift.dart";
import "package:takion/src/core/logging/app_logger.dart";
import "package:takion/src/core/migration/migration_state.dart";
import "package:takion/src/data/common/drift/database.dart" as db;
import "package:takion/src/data/wishlist/datasources/remote/metron_wishlist_remote_data_source.dart";
import "package:takion/src/data/wishlist/dto/wishlist_dto.dart";

class WishlistMigrator {
  WishlistMigrator({
    required db.AppDatabase database,
    required MetronWishlistRemoteDataSource remoteDataSource,
    Duration Function()? rateLimitDelay,
  }) : _database = database,
       _remoteDataSource = remoteDataSource,
       _rateLimitDelay = rateLimitDelay;

  final db.AppDatabase _database;
  final MetronWishlistRemoteDataSource _remoteDataSource;
  final Duration Function()? _rateLimitDelay;

  Duration get _currentDelay =>
      _rateLimitDelay?.call() ?? const Duration(milliseconds: 3200);

  Future<List<db.WishlistItem>> getUnmigratedItems() async {
    return (_database.select(_database.wishlistItems)..where(
          (t) => t.syncStatus.equals("pending") | t.id.isSmallerThanValue(0),
        ))
        .get();
  }

  Future<int> countUnmigrated() async {
    final countExp = _database.wishlistItems.id.count();
    final query = _database.selectOnly(_database.wishlistItems)
      ..addColumns([countExp])
      ..where(
        _database.wishlistItems.syncStatus.equals("pending") |
            _database.wishlistItems.id.isSmallerThanValue(0),
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
        final dto = await _remoteDataSource.addToWishList(
          WishListAddItemDto(issueId: item.issueId),
        );

        // Delete old local item if id was temporary negative, and re-insert or update
        if (item.id < 0 || item.id != dto.id) {
          await (_database.delete(
            _database.wishlistItems,
          )..where((t) => t.id.equals(item.id))).go();
          await _database
              .into(_database.wishlistItems)
              .insertOnConflictUpdate(
                db.WishlistItemsCompanion(
                  id: Value(dto.id),
                  issueId: Value(item.issueId),
                  seriesId: Value(item.seriesId),
                  seriesName: Value(item.seriesName),
                  issueNumber: Value(item.issueNumber),
                  seriesVolume: Value(item.seriesVolume),
                  seriesYearBegan: Value(item.seriesYearBegan),
                  coverDate: Value(item.coverDate),
                  storeDate: Value(item.storeDate),
                  imageUrl: Value(item.imageUrl),
                  priority: Value(item.priority),
                  desiredGrade: Value(item.desiredGrade),
                  maxPrice: Value(item.maxPrice),
                  maxPriceCurrency: Value(item.maxPriceCurrency),
                  notes: Value(item.notes),
                  addedOn: Value(item.addedOn ?? DateTime.now()),
                  modified: Value(item.modified ?? DateTime.now()),
                  syncStatus: const Value("synced"),
                  createdAt: Value(item.createdAt),
                  updatedAt: Value(DateTime.now().toUtc().toIso8601String()),
                ),
              );
        } else {
          await (_database.update(
            _database.wishlistItems,
          )..where((t) => t.id.equals(item.id))).write(
            db.WishlistItemsCompanion(
              syncStatus: const Value("synced"),
              updatedAt: Value(DateTime.now().toUtc().toIso8601String()),
            ),
          );
        }

        migratedCount++;
        onProgress?.call(migratedCount + failedCount, total);
      } catch (e, st) {
        failedCount++;
        AppLogger.warning(
          "Failed to migrate wishlist item #${item.issueId}",
          error: e,
          stackTrace: st,
        );
        onProgress?.call(migratedCount + failedCount, total);
      }
    }

    return MigrationResult(migrated: migratedCount, failed: failedCount);
  }
}
