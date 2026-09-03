import "package:dio/dio.dart";
import "package:takion/src/data/wishlist/datasources/remote/metron_wishlist_remote_data_source.dart";
import "package:takion/src/data/wishlist/dto/wishlist_dto.dart";

class MetronWishlistRemoteDataSourceImpl
    implements MetronWishlistRemoteDataSource {
  final Dio _dio;

  MetronWishlistRemoteDataSourceImpl(this._dio);

  @override
  Future<List<WishListReadDto>> getWishLists({
    int page = 1,
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.get(
      "wish_list/",
      queryParameters: {"page": page},
      cancelToken: cancelToken,
    );
    final data = response.data as Map<String, dynamic>;
    final results = data["results"] as List<dynamic>? ?? [];
    return results
        .whereType<Map<String, dynamic>>()
        .map(WishListReadDto.fromJson)
        .toList();
  }

  @override
  Future<WishListReadDto> getWishList(
    int id, {
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.get(
      "wish_list/$id/",
      cancelToken: cancelToken,
    );
    return WishListReadDto.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<WishListItemDto>> getWishListItems({
    int page = 1,
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.get(
      "wish_list/items/",
      queryParameters: {"page": page},
      cancelToken: cancelToken,
    );
    final data = response.data as Map<String, dynamic>;
    final results = data["results"] as List<dynamic>? ?? [];
    return results
        .whereType<Map<String, dynamic>>()
        .map(WishListItemDto.fromJson)
        .toList();
  }

  @override
  Future<WishListItemDto> addToWishList(
    WishListAddItemDto item, {
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.post(
      "wish_list/items/add/",
      data: item.toJson(),
      cancelToken: cancelToken,
    );
    return WishListItemDto.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> acquireWishListItem(
    int itemId,
    AcquireWishListItemDto request, {
    CancelToken? cancelToken,
  }) async {
    await _dio.post(
      "wish_list/items/$itemId/acquire/",
      data: request.toJson(),
      cancelToken: cancelToken,
    );
  }

  @override
  Future<void> removeFromWishList(
    int itemId, {
    CancelToken? cancelToken,
  }) async {
    await _dio.delete(
      "wish_list/items/$itemId/remove/",
      cancelToken: cancelToken,
    );
  }
}
