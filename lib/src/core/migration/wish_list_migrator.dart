import "package:drift/drift.dart";
import "package:takion/src/core/logging/app_logger.dart";
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

  Future<int> migrate({
    void Function(int migrated, int total)? onProgress,
  }) async {
    final legacy = await getLegacyWishlistItems();
    final unsynced = await getUnsyncedWishlistItems();
    final total = legacy.length + unsynced.length;
    if (total == 0) return 0;

    var migratedCount = 0;
    final nowIso = DateTime.now().toUtc().toIso8601String();

    // 1. Migrate legacy library wishlist rows to Metron and into WishlistItems table
    for (final leg in legacy) {
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

        // Remove legacy item from LibraryItems
        await (_database.delete(_database.libraryItems)
              ..where((t) => t.id.equals(leg.id)))
            .go();

        migratedCount++;
        onProgress?.call(migratedCount, total);
      } catch (e, st) {
        AppLogger.warning(
          "Failed to migrate legacy wishlist item #${leg.metronIssueId}",
          error: e,
          stackTrace: st,
        );
      }
    }

    // 2. Migrate any unsynced local WishlistItems rows
    for (final item in unsynced) {
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
        onProgress?.call(migratedCount, total);
      } catch (e, st) {
        AppLogger.warning(
          "Failed to migrate local wishlist item #${item.issueId}",
          error: e,
          stackTrace: st,
        );
      }
    }

    return migratedCount;
  }
}
