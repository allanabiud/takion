import 'package:dio/dio.dart';
import 'package:takion/src/domain/entities.dart';
import 'package:takion/src/core/constants/pagination.dart';

abstract class ImprintRepository {
  Future<ImprintListPage> getImprintList({
    String? nextUrl,
    int page = 1,
    int limit = metronDefaultPageSize,
    DateTime? modifiedGt,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  });

  Future<int> refreshImprintListDelta({DateTime? modifiedGt});

  Future<ImprintListPage> searchImprints(
    String query, {
    String? nextUrl,
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  });

  Future<ImprintDetails> getImprintDetails(
    int imprintId, {
    bool forceRefresh = false,
  });
}
