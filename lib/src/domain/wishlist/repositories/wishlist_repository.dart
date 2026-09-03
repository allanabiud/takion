import "package:takion/src/domain/wishlist/entities/wishlist_item.dart";

abstract class WishlistRepository {
  Future<List<WishlistItem>> getWishListItems({int page = 1});

  Future<WishlistItem> addToWishList({
    required int issueId,
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
}

typedef MetronWishlistRepository = WishlistRepository;
typedef MetronWishListRepository = WishlistRepository;
