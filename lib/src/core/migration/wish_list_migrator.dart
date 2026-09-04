import "package:drift/drift.dart";
import "package:takion/src/core/logging/app_logger.dart";
import "package:takion/src/core/migration/migration_state.dart";
import "package:takion/src/data/common/drift/database.dart" as db;
import "package:takion/src/data/wishlist/datasources/remote/metron_wishlist_remote_data_source.dart";
import "package:takion/src/data/wishlist/dto/wishlist_dto.dart";

class WishListMigrator {
  WishListMigrator({
    required db.AppDatabase database,
    required MetronWishlistRemoteDataSource remoteDataSource,
  })  : _database = database,
        _remoteDataSource = remoteDataSource;

  final db.AppDatabase _database;
  final MetronWishlistRemoteDataSource _remoteDataSource;

  static const int _batchSize = 18;
  static const Duration _batchDelay = Duration(seconds: 60);

  Future<List<db.LibraryItem>> getLegacyWishlistItems() async {
    return (_database.select(_database.libraryItems)
          ..where((t) => t.ownershipStatus.equals("wishlist")))
        .get();
  }

  Future<List<db.WishlistItem>> getUnsyncedWishlistItems() async {
    return (_database.select(_database.wishlistItems)
          ..where((t) => t.syncStatus.isNotValue("synced")))
        .get();
  }

  Future<int> countUnmigrated() async {
    final legacy = await getLegacyWishlistItems();
    final unsynced = await getUnsyncedWishlistItems();
    return legacy.length + unsynced.length;
  }

  Future<MigrationResult> migrate({
    void Function(int migrated, int total)? onProgress,
    bool Function()? isCancelled,
  }) async {
    final legacy = await getLegacyWishlistItems();
    final unsynced = await getUnsyncedWishlistItems();
    final total = legacy.length + unsynced.length;
    if (total == 0) return const MigrationResult(migrated: 0, failed: 0);

    var migratedCount = 0;
    var failedCount = 0;
    final nowIso = DateTime.now().toUtc().toIso8601String();

    for (var i = 0; i < legacy.length; i++) {
      if (isCancelled?.call() == true) break;

      if (i > 0 && i % _batchSize == 0) {
        await Future<void>.delayed(_batchDelay);
      }

      final leg = legacy[i];
      try {
        final dto = await _remoteDataSource.addToWishList(
          WishListAddItemDto(
            issueId: leg.metronIssueId,
            priority: 3,
            desiredGrade: leg.conditionGrade != null
                ? double.tryParse(leg.conditionGrade!)
                : null,
            maxPrice: leg.pricePaid,
            notes: leg.notes,
          ),
        );

        await _database.wishlistDao.upsert(
          db.WishlistItemsCompanion(
            id: Value(dto.id),
            issueId: Value(dto.issueId),
            seriesId: Value(dto.seriesId),
            seriesName: Value(dto.seriesName),
            issueNumber: Value(dto.issueNumber),
            seriesVolume: Value(dto.seriesVolume),
            seriesYearBegan: Value(dto.seriesYearBegan),
            coverDate: Value(
              dto.coverDate != null ? DateTime.tryParse(dto.coverDate!) : null,
            ),
            storeDate: Value(
              dto.storeDate != null ? DateTime.tryParse(dto.storeDate!) : null,
            ),
            imageUrl: Value(dto.imageUrl),
            priority: Value(dto.priority),
            desiredGrade: Value(dto.desiredGrade),
            maxPrice: Value(dto.maxPrice),
            maxPriceCurrency: Value(dto.maxPriceCurrency),
            notes: Value(dto.notes),
            syncStatus: const Value("synced"),
            createdAt: Value(nowIso),
            updatedAt: Value(nowIso),
          ),
        );

        await (_database.delete(_database.libraryItems)
              ..where((t) => t.id.equals(leg.id)))
            .go();

        migratedCount++;
        onProgress?.call(migratedCount + failedCount, total);
      } catch (e, st) {
        failedCount++;
        AppLogger.warning(
          "Failed to migrate legacy wishlist item #${leg.metronIssueId}",
          error: e,
          stackTrace: st,
        );
        onProgress?.call(migratedCount + failedCount, total);
      }
    }

    for (var i = 0; i < unsynced.length; i++) {
      if (isCancelled?.call() == true) break;

      if (i > 0 && i % _batchSize == 0) {
        await Future<void>.delayed(_batchDelay);
      }

      final item = unsynced[i];
      try {
        final dto = await _remoteDataSource.addToWishList(
          WishListAddItemDto(
            issueId: item.issueId,
            priority: item.priority,
            desiredGrade: item.desiredGrade,
            maxPrice: item.maxPrice,
            maxPriceCurrency: item.maxPriceCurrency,
            notes: item.notes,
          ),
        );

        if (item.id != dto.id) {
          await _database.wishlistDao.deleteById(item.id);
        }

        await _database.wishlistDao.upsert(
          db.WishlistItemsCompanion(
            id: Value(dto.id),
            issueId: Value(dto.issueId),
            seriesId: Value(dto.seriesId),
            seriesName: Value(dto.seriesName),
            issueNumber: Value(dto.issueNumber),
            seriesVolume: Value(dto.seriesVolume),
            seriesYearBegan: Value(dto.seriesYearBegan),
            coverDate: Value(
              dto.coverDate != null ? DateTime.tryParse(dto.coverDate!) : null,
            ),
            storeDate: Value(
              dto.storeDate != null ? DateTime.tryParse(dto.storeDate!) : null,
            ),
            imageUrl: Value(dto.imageUrl),
            priority: Value(dto.priority),
            desiredGrade: Value(dto.desiredGrade),
            maxPrice: Value(dto.maxPrice),
            maxPriceCurrency: Value(dto.maxPriceCurrency),
            notes: Value(dto.notes),
            syncStatus: const Value("synced"),
            createdAt: Value(item.createdAt),
            updatedAt: Value(nowIso),
          ),
        );

        migratedCount++;
        onProgress?.call(migratedCount + failedCount, total);
      } catch (e, st) {
        failedCount++;
        AppLogger.warning(
          "Failed to migrate local wishlist item #${item.issueId}",
          error: e,
          stackTrace: st,
        );
        onProgress?.call(migratedCount + failedCount, total);
      }
    }

    return MigrationResult(migrated: migratedCount, failed: failedCount);
  }
}
