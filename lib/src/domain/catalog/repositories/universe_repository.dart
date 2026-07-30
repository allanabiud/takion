import 'package:dio/dio.dart';
import 'package:takion/src/domain/entities.dart';
import 'package:takion/src/core/constants/pagination.dart';

abstract class UniverseRepository {
  Future<UniverseListPage> getUniverseList({
    String? nextUrl,
    int page = 1,
    int limit = metronDefaultPageSize,
    DateTime? modifiedGt,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  });

  Future<int> refreshUniverseListDelta({DateTime? modifiedGt});

  Future<UniverseListPage> searchUniverses(
    String query, {
    String? nextUrl,
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  });

  Future<UniverseDetails> getUniverseDetails(
    int universeId, {
    bool forceRefresh = false,
  });
}
