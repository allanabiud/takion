import "package:dio/dio.dart";
import "package:takion/src/domain/entities.dart";
import "package:takion/src/core/constants/pagination.dart";

abstract class PublisherRepository {
  Future<PublisherListPage> getPublisherList({
    String? nextUrl,
    int page = 1,
    int limit = metronDefaultPageSize,
    DateTime? modifiedGt,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  });

  Future<PublisherListPage> searchPublishers(
    String query, {
    String? nextUrl,
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  });

  Future<PublisherDetails> getPublisherDetails(
    int publisherId, {
    bool forceRefresh = false,
  });

  Future<SeriesListPage> getPublisherSeriesList(
    int publisherId, {
    String? nextUrl,
    int page = 1,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  });
}
