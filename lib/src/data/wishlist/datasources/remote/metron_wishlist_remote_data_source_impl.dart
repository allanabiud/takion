import "package:dio/dio.dart";
import "package:takion/src/core/network/remote_page.dart";
import "package:takion/src/core/network/request_priority.dart";
import "package:takion/src/data/wishlist/datasources/remote/metron_wishlist_remote_data_source.dart";
import "package:takion/src/data/wishlist/dto/wishlist_dto.dart";

class MetronWishlistRemoteDataSourceImpl
    implements MetronWishlistRemoteDataSource {
  final Dio _dio;

  MetronWishlistRemoteDataSourceImpl(this._dio);

  @override
  Future<RemotePage<WishListItemDto>> getWishListPage({
    Uri? pageUrl,
    CancelToken? cancelToken,
  }) async {
    try {
      // Sequential pagination is capped at one in-flight scan by the
      // request scheduler (Phase 5 Step 2).
      final scanOptions = Options(extra: const {paginationScanExtraKey: true});
      final Response<dynamic> response;
      if (pageUrl != null) {
        response = await _dio.getUri(
          pageUrl,
          cancelToken: cancelToken,
          options: scanOptions,
        );
      } else {
        response = await _dio.get(
          "wish_list/items/",
          cancelToken: cancelToken,
          options: scanOptions,
        );
      }

      final data = response.data as Map<String, dynamic>;
      final results = data["results"] as List<dynamic>? ?? const [];
      final items = results
          .whereType<Map<String, dynamic>>()
          .map(WishListItemDto.fromJson)
          .toList();
      final count = data["count"] as int? ?? items.length;
      final nextRaw = data["next"] as String?;
      final prevRaw = data["previous"] as String?;

      return RemotePage<WishListItemDto>(
        items: items,
        count: count,
        next: nextRaw != null && nextRaw.isNotEmpty
            ? Uri.tryParse(nextRaw)
            : null,
        previous: prevRaw != null && prevRaw.isNotEmpty
            ? Uri.tryParse(prevRaw)
            : null,
        fetchedAt: DateTime.now().toUtc(),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return RemotePage<WishListItemDto>(
          items: const [],
          count: 0,
          next: null,
          previous: null,
          fetchedAt: DateTime.now().toUtc(),
        );
      }
      rethrow;
    }
  }

  @override
  Future<List<WishListReadDto>> getWishLists({
    int page = 1,
    CancelToken? cancelToken,
  }) async {
    try {
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
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return const [];
      }
      rethrow;
    }
  }

  @override
  Future<WishListReadDto> getWishList(
    int id, {
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.get("wish_list/$id/", cancelToken: cancelToken);
    return WishListReadDto.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<WishListItemDto>> getWishListItems({
    int page = 1,
    DateTime? modifiedGt,
    CancelToken? cancelToken,
  }) async {
    try {
      final queryParameters = <String, dynamic>{"page": page};
      if (modifiedGt != null) {
        queryParameters["modified_gt"] = modifiedGt.toUtc().toIso8601String();
      }
      final response = await _dio.get(
        "wish_list/items/",
        queryParameters: queryParameters,
        cancelToken: cancelToken,
      );
      final data = response.data as Map<String, dynamic>;
      final results = data["results"] as List<dynamic>? ?? [];
      return results
          .whereType<Map<String, dynamic>>()
          .map(WishListItemDto.fromJson)
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return const [];
      }
      rethrow;
    }
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
    try {
      await _dio.post(
        "wish_list/items/$itemId/acquire/",
        data: request.toJson(),
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return;
      }
      rethrow;
    }
  }

  @override
  Future<void> removeFromWishList(
    int itemId, {
    CancelToken? cancelToken,
  }) async {
    try {
      await _dio.delete(
        "wish_list/items/$itemId/remove/",
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return;
      }
      rethrow;
    }
  }
}
