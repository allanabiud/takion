import 'package:dio/dio.dart';
import 'package:takion/src/domain/entities.dart';
import 'package:takion/src/core/constants/pagination.dart';

abstract class IssueRepository {
  Future<List<IssueList>> getWeeklyReleasesForDate(
    DateTime date, {
    bool forceRefresh = false,
    CancelToken? cancelToken,
  });

  Future<List<IssueList>> getFocReleasesForDate(
    DateTime date, {
    bool forceRefresh = false,
    CancelToken? cancelToken,
  });

  Future<IssueDetails> getIssueDetails(
    int issueId, {
    bool forceRefresh = false,
  });

  Future<IssueSearchPage> searchIssues(
    String query, {
    String? nextUrl,
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  });

  Future<IssueSearchPage> searchIssuesByUpc(
    String upc, {
    CancelToken? cancelToken,
    bool forceRefresh = false,
  });

  Future<IssueSearchPage> searchIssuesByUpcPrefix(
    String prefix, {
    CancelToken? cancelToken,
    bool forceRefresh = false,
  });

  Future<IssueSearchPage> getIssueList({
    String? nextUrl,
    int page = 1,
    bool forceRefresh = false,
    String? ordering,
    DateTime? modifiedGt,
    int? limit,
    CancelToken? cancelToken,
  });
}
