import "package:takion/src/core/commands/wishlist_command_service.dart";
import "package:takion/src/core/network/remote_page.dart";
import "package:takion/src/core/sync/offline_queue/offline_write_queue.dart";
import "package:takion/src/data/common/drift/database.dart" as db;
import "package:takion/src/domain/wishlist/entities/wishlist_item.dart";
import "package:takion/src/domain/wishlist/repositories/wishlist_repository.dart";

class LocalWishlistRepository implements WishlistRepository {
  LocalWishlistRepository(
    this._database, {
    OfflineWriteQueue? offlineQueue,
    WishlistCommandService? commandService,
  }) : _commandService = commandService ?? WishlistCommandService(_database);

  final db.AppDatabase _database;
  final WishlistCommandService _commandService;

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
  Future<RemotePage<WishlistItem>> getWishListPage({Uri? pageUrl}) async {
    final items = await getWishListItems();
    return RemotePage<WishlistItem>(
      items: items,
      count: items.length,
      next: null,
      previous: null,
      fetchedAt: DateTime.now().toUtc(),
    );
  }

  @override
  Future<List<WishlistItem>> getWishListItems({
    int page = 1,
    DateTime? modifiedGt,
  }) async {
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
    final item = await _commandService.addToWishlist(
      issueId: issueId,
      seriesId: seriesId,
      seriesName: seriesName,
      issueNumber: issueNumber,
      imageUrl: imageUrl,
      priority: priority,
      desiredGrade: desiredGrade,
      maxPrice: maxPrice,
      maxPriceCurrency: maxPriceCurrency,
      notes: notes,
    );

    return _toDomain(item);
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
    final wishlistItem =
        (await _database.wishlistDao.getById(itemId)) ??
        (await _database.wishlistDao.getByIssueId(itemId));
    final issueId = wishlistItem?.issueId ?? itemId;

    await _commandService.acquireIssue(
      issueId: issueId,
      seriesId: wishlistItem?.seriesId,
      purchaseDate: purchaseDate,
      purchasePrice: purchasePrice,
      purchasePriceCurrency: purchasePriceCurrency,
      purchaseStore: purchaseStore,
      notes: notes,
    );
  }

  @override
  Future<void> removeFromWishList(int itemId) async {
    final existing = await _database.wishlistDao.getById(itemId);
    final issueId = existing?.issueId ?? itemId;
    await _commandService.removeFromWishlist(issueId: issueId);
  }

  @override
  Future<void> removeFromWishListByIssueId(int issueId) async {
    final existing = await _database.wishlistDao.getByIssueId(issueId);
    if (existing == null) return;

    await _commandService.removeFromWishlist(issueId: issueId);
  }
}
