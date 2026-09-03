import "package:drift/drift.dart";
import "package:takion/src/core/logging/app_logger.dart";
import "package:takion/src/core/sync/offline_queue/offline_write_queue.dart";
import "package:takion/src/data/common/drift/database.dart" as db;
import "package:takion/src/domain/wishlist/entities/wishlist_item.dart";
import "package:takion/src/domain/wishlist/repositories/wishlist_repository.dart";

class WishlistSyncResult {
  const WishlistSyncResult({
    required this.itemsFetched,
    required this.itemsUpdated,
    required this.isSuccess,
    this.errorMessage,
  });

  final int itemsFetched;
  final int itemsUpdated;
  final bool isSuccess;
  final String? errorMessage;
}

class WishlistSyncManager {
  WishlistSyncManager({
    required db.AppDatabase database,
    required MetronWishlistRepository wishlistRepository,
    OfflineWriteQueue? offlineWriteQueue,
  })  : _database = database,
        _wishlistRepository = wishlistRepository,
        _offlineWriteQueue = offlineWriteQueue;

  static const String _syncMetaKey = "metron_last_wishlist_sync";

  final db.AppDatabase _database;
  final MetronWishlistRepository _wishlistRepository;
  final OfflineWriteQueue? _offlineWriteQueue;

  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  Future<WishlistSyncResult> syncWishlist() async {
    if (_isSyncing) {
      return const WishlistSyncResult(
        itemsFetched: 0,
        itemsUpdated: 0,
        isSuccess: false,
        errorMessage: "Wishlist sync already in progress",
      );
    }

    _isSyncing = true;
    try {
      if (_offlineWriteQueue != null) {
        await _offlineWriteQueue.processQueue();
      }

      var page = 1;
      final remoteItems = <WishlistItem>[];

      while (true) {
        final pageItems = await _wishlistRepository.getWishListItems(page: page);
        if (pageItems.isEmpty) break;
        remoteItems.addAll(pageItems);
        if (pageItems.length < 20) break;
        page++;
      }

      final updatedCount = await _reconcileWishlistItems(remoteItems);
      final now = DateTime.now().toUtc();
      await _database.syncMetaDao.set(_syncMetaKey, now.toIso8601String());

      AppLogger.info(
        "Wishlist sync completed: ${remoteItems.length} fetched, $updatedCount updated",
      );

      return WishlistSyncResult(
        itemsFetched: remoteItems.length,
        itemsUpdated: updatedCount,
        isSuccess: true,
      );
    } catch (e, st) {
      AppLogger.error("Wishlist sync failed", error: e, stackTrace: st);
      return WishlistSyncResult(
        itemsFetched: 0,
        itemsUpdated: 0,
        isSuccess: false,
        errorMessage: e.toString(),
      );
    } finally {
      _isSyncing = false;
    }
  }

  Future<int> _reconcileWishlistItems(List<WishlistItem> remoteItems) async {
    final nowIso = DateTime.now().toUtc().toIso8601String();
    final remoteIds = remoteItems.map((item) => item.id).toSet();
    final companions = <db.WishlistItemsCompanion>[];

    for (final item in remoteItems) {
      final existing = await _database.wishlistDao.getByIssueId(item.issueId);

      if (existing != null && existing.syncStatus != "synced") {
        // Pending local modifications take priority until synced
        continue;
      }

      companions.add(
        db.WishlistItemsCompanion(
          id: Value(item.id),
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
          addedOn: Value(item.addedOn),
          modified: Value(item.modified),
          syncStatus: const Value("synced"),
          createdAt: Value(existing?.createdAt ?? nowIso),
          updatedAt: Value(nowIso),
        ),
      );
    }

    if (companions.isNotEmpty) {
      await _database.wishlistDao.batchUpsert(companions);
    }

    // Reconcile local items that were deleted remotely
    final localItems = await _database.wishlistDao.getAll();
    final toDeleteIds = <int>[];

    for (final local in localItems) {
      if (local.syncStatus == "synced" && !remoteIds.contains(local.id)) {
        toDeleteIds.add(local.id);
      }
    }

    if (toDeleteIds.isNotEmpty) {
      await _database.wishlistDao.batchDeleteByIds(toDeleteIds);
    }

    return companions.length;
  }
}
