import "package:takion/src/domain/wishlist/entities/wishlist_item.dart";

abstract class WishlistRepository {
  Stream<List<WishlistItem>> watchWishListItems({int? seriesId});

  Future<List<WishlistItem>> getWishListItems({int page = 1});

  Future<WishlistItem?> getItemByIssueId(int issueId);

  Future<WishlistItem?> getItemById(int itemId);

  Future<int> getItemCount();

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
  });

  Future<void> acquireWishListItem({
    required int itemId,
    DateTime? purchaseDate,
    double? purchasePrice,
    String purchasePriceCurrency = "USD",
    String? purchaseStore,
    String? notes,
  });

  Future<void> removeFromWishList(int itemId);

  Future<void> removeFromWishListByIssueId(int issueId);
}

typedef MetronWishlistRepository = WishlistRepository;
typedef MetronWishListRepository = WishlistRepository;
