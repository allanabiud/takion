import 'package:dio/dio.dart';
import 'package:takion/src/domain/entities/entities.dart';
import 'package:takion/src/domain/repositories/repositories.dart';
import 'package:takion/src/core/constants/pagination.dart';

abstract class MetronRepository implements CatalogRepository {
  @override
  Future<List<IssueList>> getWeeklyReleasesForDate(
    DateTime date, {
    bool forceRefresh = false,
  });

  @override
  Future<List<IssueList>> getFocReleasesForDate(
    DateTime date, {
    bool forceRefresh = false,
  });

  @override
  Future<IssueDetails> getIssueDetails(
    int issueId, {
    bool forceRefresh = false,
  });

  @override
  Future<IssueSearchPage> searchIssues(
    String query, {
    String? nextUrl,
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  });

  @override
  Future<IssueSearchPage> getIssueList({
    String? nextUrl,
    int page = 1,
    bool forceRefresh = false,
    String? ordering,
    DateTime? modifiedGt,
    int? limit,
    CancelToken? cancelToken,
  });

  @override
  Future<SeriesSearchPage> searchSeries(
    String query, {
    String? nextUrl,
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  });

  @override
  Future<SeriesListPage> getSeriesList({
    String? nextUrl,
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  });

  @override
  Future<SeriesDetails> getSeriesDetails(
    int seriesId, {
    bool forceRefresh = false,
  });

  @override
  Future<SeriesIssueListPage> getSeriesIssueList(
    int seriesId, {
    String? nextUrl,
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  });

  @override
  Future<CharacterListPage> searchCharacters(
    String query, {
    String? nextUrl,
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  });

  Future<CharacterListPage> getCharacterList({
    String? nextUrl,
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  });

  @override
  Future<CharacterDetails> getCharacterDetails(
    int characterId, {
    bool forceRefresh = false,
  });

  @override
  Future<CharacterIssueListPage> getCharacterIssueList(
    int characterId, {
    String? nextUrl,
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  });

  Future<CreatorListPage> getCreatorList({
    String? nextUrl,
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  });

  @override
  Future<CreatorListPage> searchCreators(
    String query, {
    String? nextUrl,
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  });

  @override
  Future<CreatorDetails> getCreatorDetails(
    int creatorId, {
    bool forceRefresh = false,
  });

  Future<UniverseListPage> getUniverseList({
    String? nextUrl,
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  });

  @override
  Future<UniverseListPage> searchUniverses(
    String query, {
    String? nextUrl,
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  });

  @override
  Future<UniverseDetails> getUniverseDetails(
    int universeId, {
    bool forceRefresh = false,
  });

  Future<ImprintListPage> getImprintList({
    String? nextUrl,
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  });

  @override
  Future<ImprintListPage> searchImprints(
    String query, {
    String? nextUrl,
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  });

  @override
  Future<ImprintDetails> getImprintDetails(
    int imprintId, {
    bool forceRefresh = false,
  });

  Future<TeamListPage> getTeamList({
    String? nextUrl,
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  });

  @override
  Future<TeamListPage> searchTeams(
    String query, {
    String? nextUrl,
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  });

  @override
  Future<TeamDetails> getTeamDetails(
    int teamId, {
    bool forceRefresh = false,
  });

  Future<ArcListPage> getArcList({
    String? nextUrl,
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  });

  @override
  Future<ArcListPage> searchArcs(
    String query, {
    String? nextUrl,
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  });

  @override
  Future<ArcDetails> getArcDetails(
    int arcId, {
    bool forceRefresh = false,
  });

  @override
  Future<ArcIssueListPage> getArcIssueList(
    int arcId, {
    String? nextUrl,
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  });

  Future<PublisherListPage> getPublisherList({
    String? nextUrl,
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  });

  @override
  Future<PublisherListPage> searchPublishers(
    String query, {
    String? nextUrl,
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  });

  @override
  Future<PublisherDetails> getPublisherDetails(
    int publisherId, {
    bool forceRefresh = false,
  });

  @override
  Future<SeriesListPage> getPublisherSeriesList(
    int publisherId, {
    String? nextUrl,
    int page = 1,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  });

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

  Future<MetronReadingListDetail> getReadingListDetail(int id, {bool forceRefresh = false});

  Future<List<MetronReadingListItem>> getReadingListItems(int id);
}
