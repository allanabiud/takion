import 'package:dio/dio.dart';
import 'package:takion/src/domain/entities.dart';
import 'package:takion/src/core/constants/pagination.dart';

abstract class TeamRepository {
  Future<TeamListPage> getTeamList({
    String? nextUrl,
    int page = 1,
    int limit = metronDefaultPageSize,
    DateTime? modifiedGt,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  });

  Future<TeamListPage> searchTeams(
    String query, {
    String? nextUrl,
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  });

  Future<TeamDetails> getTeamDetails(int teamId, {bool forceRefresh = false});

  Future<CharacterIssueListPage> getTeamIssueList(
    int teamId, {
    String? nextUrl,
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  });
}
