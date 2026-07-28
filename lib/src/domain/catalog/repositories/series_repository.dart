import 'package:dio/dio.dart';
import 'package:takion/src/domain/entities.dart';
import 'package:takion/src/core/constants/pagination.dart';

abstract class SeriesRepository {
  Future<SeriesSearchPage> searchSeries(
    String query, {
    String? nextUrl,
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  });

  Future<SeriesListPage> getSeriesList({
    String? nextUrl,
    int page = 1,
    int limit = metronDefaultPageSize,
    DateTime? modifiedGt,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  });

  Future<SeriesDetails> getSeriesDetails(
    int seriesId, {
    bool forceRefresh = false,
  });

  Future<SeriesIssueListPage> getSeriesIssueList(
    int seriesId, {
    String? nextUrl,
    int page = 1,
    int limit = metronDefaultPageSize,
    String? ordering,
    DateTime? storeDateGte,
    DateTime? storeDateLte,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  });
}
