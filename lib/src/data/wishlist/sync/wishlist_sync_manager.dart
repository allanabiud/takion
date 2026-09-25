import "package:dio/dio.dart";
import "package:drift/drift.dart";
import "package:takion/src/core/logging/app_logger.dart";
import "package:takion/src/data/common/drift/database.dart" as db;
import "package:takion/src/domain/entities.dart";
import "package:takion/src/domain/wishlist/repositories/wishlist_repository.dart";

class WishlistSyncResult {
  const WishlistSyncResult({
    required this.itemsFetched,
    required this.itemsUpdated,
    required this.isSuccess,
    required this.isFullSync,
    this.errorMessage,
  });

  final int itemsFetched;
  final int itemsUpdated;
  final bool isSuccess;
  final bool isFullSync;
  final String? errorMessage;
}

class WishlistSyncManager {
  WishlistSyncManager({
    required db.AppDatabase database,
    required MetronWishlistRepository wishlistRepository,
  })  : _database = database,
        _wishlistRepository = wishlistRepository;

  static const String _syncMetaKey = "metron_last_wishlist_sync";

  final db.AppDatabase _database;
  final MetronWishlistRepository _wishlistRepository;

  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  Future<DateTime?> getLastSyncTime() async {
    final str = await _database.syncMetaDao.get(_syncMetaKey);
    return str != null ? DateTime.tryParse(str) : null;
  }

  Future<WishlistSyncResult> syncWishlist({
    bool forceFullSync = false,
    void Function(int count)? onProgress,
  }) async {
    if (_isSyncing) {
      return const WishlistSyncResult(
        itemsFetched: 0,
        itemsUpdated: 0,
        isSuccess: false,
        isFullSync: false,
        errorMessage: "Wishlist sync already in progress",
      );
    }

    _isSyncing = true;
    try {
      final allRemoteItems = <WishlistItem>[];
      var page = 1;
      final now = DateTime.now().toUtc();

      while (true) {
        final pageItems = await _wishlistRepository.getWishListItems(
          page: page,
        );
        if (pageItems.isEmpty) break;
        allRemoteItems.addAll(pageItems);
        onProgress?.call(allRemoteItems.length);
        if (pageItems.length < 20) break;
        page++;
      }

      final updatedCount = await _reconcileWishlistItems(allRemoteItems);

      await _database.syncMetaDao.set(_syncMetaKey, now.toIso8601String());

      AppLogger.info(
        "Wishlist sync completed: ${allRemoteItems.length} fetched, $updatedCount updated",
      );

      return WishlistSyncResult(
        itemsFetched: allRemoteItems.length,
        itemsUpdated: updatedCount,
        isSuccess: true,
        isFullSync: true,
      );
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      if (statusCode == 404) {
        AppLogger.info(
          "Wishlist sync: no wishlist found on remote (404), treating as empty",
        );
        final localItems = await _database.wishlistDao.getAll();
        final syncedIds = localItems
            .where((i) => i.syncStatus == "synced")
            .map((i) => i.issueId)
            .toList();
        if (syncedIds.isNotEmpty) {
          await _database.wishlistDao.batchDeleteByIssueIds(syncedIds);
        }
        final now = DateTime.now().toUtc();
        await _database.syncMetaDao.set(
          _syncMetaKey,
          now.toIso8601String(),
        );
        return const WishlistSyncResult(
          itemsFetched: 0,
          itemsUpdated: 0,
          isSuccess: true,
          isFullSync: true,
        );
      }
      AppLogger.error("Wishlist sync failed", error: e);
      return WishlistSyncResult(
        itemsFetched: 0,
        itemsUpdated: 0,
        isSuccess: false,
        isFullSync: forceFullSync,
        errorMessage: e.toString(),
      );
    } catch (e, st) {
      AppLogger.error("Wishlist sync failed", error: e, stackTrace: st);
      return WishlistSyncResult(
        itemsFetched: 0,
        itemsUpdated: 0,
        isSuccess: false,
        isFullSync: forceFullSync,
        errorMessage: e.toString(),
      );
    } finally {
      _isSyncing = false;
    }
  }

  Future<int> _reconcileWishlistItems(List<WishlistItem> remoteItems) async {
    final nowIso = DateTime.now().toUtc().toIso8601String();
    final remoteIssueIds = remoteItems.map((item) => item.issueId).toSet();
    final companions = <db.WishlistItemsCompanion>[];

    for (final item in remoteItems) {
      final existing = await _database.wishlistDao.getByIssueId(item.issueId);

      if (existing != null && existing.syncStatus != "synced") {
        continue;
      }

      companions.add(
        db.WishlistItemsCompanion(
          id: Value(existing?.id ?? item.id),
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
          syncStatus: const Value("synced"),
          createdAt: Value(existing?.createdAt ?? nowIso),
          updatedAt: Value(nowIso),
        ),
      );
    }

    if (companions.isNotEmpty) {
      await _database.wishlistDao.batchUpsert(companions);
    }

    final localItems = await _database.wishlistDao.getAll();
    final toDeleteIssueIds = localItems
        .where((i) => !remoteIssueIds.contains(i.issueId) && i.syncStatus == "synced")
        .map((i) => i.issueId)
        .toList();

    if (toDeleteIssueIds.isNotEmpty) {
      if (remoteItems.isEmpty && localItems.isNotEmpty) {
        AppLogger.warning(
          "Skipping wishlist deletion: remote returned 0 items but ${localItems.length} exist locally (possible transient API error)",
        );
      } else {
        await _database.wishlistDao.batchDeleteByIssueIds(toDeleteIssueIds);
      }
    }

    return companions.length;
  }
}
