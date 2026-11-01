import "package:dio/dio.dart";
import "package:takion/src/core/network/remote_page.dart";
import "package:takion/src/data/wishlist/dto/wishlist_dto.dart";

abstract class MetronWishlistRemoteDataSource {
  Future<RemotePage<WishListItemDto>> getWishListPage({
    Uri? pageUrl,
    CancelToken? cancelToken,
  });

  Future<List<WishListReadDto>> getWishLists({
    int page = 1,
    CancelToken? cancelToken,
  });

  Future<WishListReadDto> getWishList(int id, {CancelToken? cancelToken});

  Future<List<WishListItemDto>> getWishListItems({
    int page = 1,
    DateTime? modifiedGt,
    CancelToken? cancelToken,
  });

  Future<WishListItemDto> addToWishList(
    WishListAddItemDto item, {
    CancelToken? cancelToken,
  });

  Future<void> acquireWishListItem(
    int itemId,
    AcquireWishListItemDto request, {
    CancelToken? cancelToken,
  });

  Future<void> removeFromWishList(int itemId, {CancelToken? cancelToken});
}
