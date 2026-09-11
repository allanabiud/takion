import "package:takion/src/data/wishlist/datasources/remote/metron_wishlist_remote_data_source.dart";
import "package:takion/src/data/wishlist/dto/wishlist_dto.dart";
import "package:takion/src/domain/wishlist/entities/wishlist_item.dart";
import "package:takion/src/domain/wishlist/repositories/wishlist_repository.dart";

class MetronWishlistRepositoryImpl implements MetronWishlistRepository {
  MetronWishlistRepositoryImpl({
    required MetronWishlistRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final MetronWishlistRemoteDataSource _remoteDataSource;

  @override
  Stream<List<WishlistItem>> watchWishListItems({int? seriesId}) {
    throw UnsupportedError(
      "watchWishListItems is only supported by the local repository cache",
    );
  }

  @override
  Future<List<WishlistItem>> getWishListItems({
    int page = 1,
    DateTime? modifiedGt,
  }) async {
    final dtos = await _remoteDataSource.getWishListItems(
      page: page,
      modifiedGt: modifiedGt,
    );
    return dtos.map((dto) => dto.toEntity()).toList();
  }

  @override
  Future<WishlistItem?> getItemByIssueId(int issueId) async {
    throw UnsupportedError(
      "getItemByIssueId is only supported by the local repository cache",
    );
  }

  @override
  Future<WishlistItem?> getItemById(int itemId) async {
    throw UnsupportedError(
      "getItemById is only supported by the local repository cache",
    );
  }

  @override
  Future<int> getItemCount() async {
    final wishlists = await _remoteDataSource.getWishLists();
    if (wishlists.isEmpty) return 0;
    return wishlists.first.itemCount;
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
    final dto = await _remoteDataSource.addToWishList(
      WishListAddItemDto(
        issueId: issueId,
        priority: priority,
        desiredGrade: desiredGrade,
        maxPrice: maxPrice,
        maxPriceCurrency: maxPriceCurrency,
        notes: notes,
      ),
    );
    return dto.toEntity();
  }

  @override
  Future<void> acquireWishListItem({
    required int itemId,
    DateTime? purchaseDate,
    double? purchasePrice,
    String purchasePriceCurrency = "USD",
    String? purchaseStore,
    String? notes,
  }) {
    return _remoteDataSource.acquireWishListItem(
      itemId,
      AcquireWishListItemDto(
        purchaseDate: purchaseDate?.toIso8601String().split("T").first,
        purchasePrice: purchasePrice,
        purchasePriceCurrency: purchasePriceCurrency,
        purchaseStore: purchaseStore,
        notes: notes,
      ),
    );
  }

  @override
  Future<void> removeFromWishList(int itemId) {
    return _remoteDataSource.removeFromWishList(itemId);
  }

  @override
  Future<void> removeFromWishListByIssueId(int issueId) {
    throw UnsupportedError(
      "removeFromWishListByIssueId requires Metron item ID for remote API calls",
    );
  }
}
