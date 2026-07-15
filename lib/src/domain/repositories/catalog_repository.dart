import 'package:dio/dio.dart';
import 'package:takion/src/domain/entities/entities.dart';
import 'package:takion/src/core/constants/pagination.dart';

abstract class CatalogRepository {
  Future<List<IssueList>> getWeeklyReleasesForDate(
    DateTime date, {
    bool forceRefresh = false,
  });

  Future<List<IssueList>> getFocReleasesForDate(
    DateTime date, {
    bool forceRefresh = false,
  });

  Future<IssueDetails> getIssueDetails(
    int issueId, {
    bool forceRefresh = false,
  });

  Future<IssueSearchPage> searchIssues(
    String query, {
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  });

  Future<IssueSearchPage> getIssueList({
    int page = 1,
    bool forceRefresh = false,
    String? ordering,
    DateTime? modifiedGt,
    int? limit,
    CancelToken? cancelToken,
  });

  Future<SeriesSearchPage> searchSeries(
    String query, {
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  });

  Future<SeriesListPage> getSeriesList({
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  });

  Future<SeriesDetails> getSeriesDetails(
    int seriesId, {
    bool forceRefresh = false,
  });

  Future<SeriesIssueListPage> getSeriesIssueList(
    int seriesId, {
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  });
  Future<CharacterListPage> searchCharacters(
    String query, {
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  });
  Future<CharacterDetails> getCharacterDetails(
    int characterId, {
    bool forceRefresh = false,
  });
  Future<CharacterIssueListPage> getCharacterIssueList(
    int characterId, {
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  });

  Future<CreatorListPage> searchCreators(
    String query, {
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  });

  Future<CreatorDetails> getCreatorDetails(
    int creatorId, {
    bool forceRefresh = false,
  });

  Future<UniverseListPage> searchUniverses(
    String query, {
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  });

  Future<UniverseDetails> getUniverseDetails(
    int universeId, {
    bool forceRefresh = false,
  });

  Future<ImprintListPage> searchImprints(
    String query, {
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  });

  Future<ImprintDetails> getImprintDetails(
    int imprintId, {
    bool forceRefresh = false,
  });

  Future<TeamListPage> searchTeams(
    String query, {
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  });

  Future<TeamDetails> getTeamDetails(
    int teamId, {
    bool forceRefresh = false,
  });

  Future<ArcListPage> searchArcs(
    String query, {
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  });

  Future<ArcDetails> getArcDetails(
    int arcId, {
    bool forceRefresh = false,
  });

  Future<ArcIssueListPage> getArcIssueList(
    int arcId, {
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  });

  Future<PublisherListPage> searchPublishers(
    String query, {
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
    int page = 1,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  });
}
