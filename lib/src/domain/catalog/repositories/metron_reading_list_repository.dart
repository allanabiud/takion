import 'package:dio/dio.dart';
import 'package:takion/src/domain/entities.dart';
import 'package:takion/src/core/constants/pagination.dart';

abstract class MetronReadingListRepository {
  Future<MetronReadingListPage> searchReadingLists({
    String? nextUrl,
    int page = 1,
    int limit = metronDefaultPageSize,
    String? name,
    String? listType,
    String? attributionSource,
    String? publisher,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  });

  Future<MetronReadingListDetail> getReadingListDetail(
    int id, {
    bool forceRefresh = false,
  });

  Future<List<MetronReadingListItem>> getReadingListItems(int id);
}
