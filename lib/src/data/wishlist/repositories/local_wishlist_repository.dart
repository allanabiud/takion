import "package:drift/drift.dart";
import "package:takion/src/core/sync/offline_queue/offline_write_queue.dart";
import "package:takion/src/data/common/drift/database.dart" as db;
import "package:takion/src/domain/wishlist/entities/wishlist_item.dart";
import "package:takion/src/domain/wishlist/repositories/wishlist_repository.dart";

class LocalWishlistRepository implements WishlistRepository {
  LocalWishlistRepository(
    this._database, {
    OfflineWriteQueue? offlineQueue,
  }) : _offlineQueue = offlineQueue;

  final db.AppDatabase _database;
  final OfflineWriteQueue? _offlineQueue;

  WishlistItem _toDomain(db.WishlistItem d) {
    return WishlistItem(
      id: d.id,
      issueId: d.issueId,
      seriesId: d.seriesId,
      seriesName: d.seriesName,
      issueNumber: d.issueNumber,
      seriesVolume: d.seriesVolume,
      seriesYearBegan: d.seriesYearBegan,
      coverDate: d.coverDate,
      storeDate: d.storeDate,
      imageUrl: d.imageUrl,
      priority: d.priority,
      desiredGrade: d.desiredGrade,
      maxPrice: d.maxPrice,
      maxPriceCurrency: d.maxPriceCurrency,
      notes: d.notes,
      addedOn: d.addedOn,
      modified: d.modified,
      syncStatus: d.syncStatus,
    );
  }

  @override
  Stream<List<WishlistItem>> watchWishListItems({int? seriesId}) {
    final stream = seriesId != null
        ? _database.wishlistDao.watchBySeries(seriesId)
        : _database.wishlistDao.watchAll();
    return stream.map((rows) => rows.map(_toDomain).toList());
  }

  @override
  Future<List<WishlistItem>> getWishListItems({int page = 1}) async {
    final rows = await _database.wishlistDao.getAll();
    return rows.map(_toDomain).toList();
  }

  @override
  Future<WishlistItem?> getItemByIssueId(int issueId) async {
    final d = await _database.wishlistDao.getByIssueId(issueId);
    return d != null ? _toDomain(d) : null;
  }

  @override
  Future<WishlistItem?> getItemById(int itemId) async {
    final d = await _database.wishlistDao.getById(itemId);
    return d != null ? _toDomain(d) : null;
  }

  @override
  Future<int> getItemCount() async {
    return _database.wishlistDao.getItemCount();
  }

  @override
  Future<WishlistItem> addToWishList({
    required int issueId,
    int? seriesId,
    String? seriesName,
    String? issueNumber,
    String? imageUrl,
    int priority = 3,
    double? desiredGrade,
    double? maxPrice,
    String maxPriceCurrency = "USD",
    String? notes,
  }) async {
    final existing = await _database.wishlistDao.getByIssueId(issueId);
    final now = DateTime.now().toUtc();
    final syncStatus =
        _offlineQueue != null ? "pending" : (existing?.syncStatus ?? "synced");

    final item = WishlistItem(
      id: existing?.id ?? issueId,
      issueId: issueId,
      seriesId: seriesId ?? existing?.seriesId ?? 0,
      seriesName: seriesName ?? existing?.seriesName ?? "Unknown Series",
      issueNumber: issueNumber ?? existing?.issueNumber ?? "",
      seriesVolume: existing?.seriesVolume,
      seriesYearBegan: existing?.seriesYearBegan,
      coverDate: existing?.coverDate,
      storeDate: existing?.storeDate,
      imageUrl: imageUrl ?? existing?.imageUrl,
      priority: priority,
      desiredGrade: desiredGrade ?? existing?.desiredGrade,
      maxPrice: maxPrice ?? existing?.maxPrice,
      maxPriceCurrency: maxPriceCurrency,
      notes: notes ?? existing?.notes,
      addedOn: existing?.addedOn ?? now,
      modified: now,
      syncStatus: syncStatus,
    );

    await _database.wishlistDao.upsert(
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
        syncStatus: Value(item.syncStatus),
        createdAt: Value(existing?.createdAt ?? now.toIso8601String()),
        updatedAt: Value(now.toIso8601String()),
      ),
    );

    if (_offlineQueue != null) {
      await _offlineQueue.enqueueWishlistAdd(
        issueId: issueId,
        priority: priority,
        desiredGrade: desiredGrade,
        maxPrice: maxPrice,
        maxPriceCurrency: maxPriceCurrency,
        notes: notes,
      );
    }

    return item;
  }

  @override
  Future<void> acquireWishListItem({
    required int itemId,
    DateTime? purchaseDate,
    double? purchasePrice,
    String purchasePriceCurrency = "USD",
    String? purchaseStore,
    String? notes,
  }) async {
    await _database.wishlistDao.deleteById(itemId);

    if (_offlineQueue != null) {
      await _offlineQueue.enqueueWishlistAcquire(
        itemId: itemId,
        purchaseDate: purchaseDate,
        purchasePrice: purchasePrice,
        purchasePriceCurrency: purchasePriceCurrency,
        purchaseStore: purchaseStore,
        notes: notes,
      );
    }
  }

  @override
  Future<void> removeFromWishList(int itemId) async {
    await _database.wishlistDao.deleteById(itemId);

    if (_offlineQueue != null) {
      await _offlineQueue.enqueueWishlistRemove(itemId: itemId);
    }
  }

  @override
  Future<void> removeFromWishListByIssueId(int issueId) async {
    final existing = await _database.wishlistDao.getByIssueId(issueId);
    if (existing == null) return;

    await _database.wishlistDao.deleteByIssueId(issueId);

    if (_offlineQueue != null) {
      await _offlineQueue.enqueueWishlistRemove(itemId: existing.id);
    }
  }
}
