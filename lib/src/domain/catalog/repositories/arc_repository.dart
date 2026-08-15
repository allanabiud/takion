import "package:dio/dio.dart";
import "package:takion/src/domain/entities.dart";
import "package:takion/src/core/constants/pagination.dart";

abstract class ArcRepository {
  Future<ArcListPage> getArcList({
    String? nextUrl,
    int page = 1,
    int limit = metronDefaultPageSize,
    DateTime? modifiedGt,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  });

  Future<ArcListPage> searchArcs(
    String query, {
    String? nextUrl,
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  });

  Future<ArcDetails> getArcDetails(int arcId, {bool forceRefresh = false});

  Future<ArcIssueListPage> getArcIssueList(
    int arcId, {
    String? nextUrl,
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  });

  Future<List<IssueList>> getArcIssueListAll(
    int arcId, {
    bool forceRefresh = false,
  });
}
