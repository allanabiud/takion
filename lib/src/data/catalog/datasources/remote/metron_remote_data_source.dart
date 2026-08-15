import "package:dio/dio.dart";
import "package:takion/src/data/catalog/dto/dto.dart";
import "package:takion/src/data/reading_list/dto/dto.dart";

abstract class MetronRemoteDataSource {
  Future<Response> getWeeklyReleasesForDate(
    DateTime date, {
    CancelToken? cancelToken,
  });
  Future<Response> getFocReleasesForDate(
    DateTime date, {
    CancelToken? cancelToken,
  });
  Future<Response> getIssueDetails(int issueId);
  Future<IssueSearchResponseDto> searchIssuesByUpc(
    String upc, {
    CancelToken? cancelToken,
  });
  Future<IssueSearchResponseDto> searchIssuesByUpcPrefix(
    String prefix, {
    CancelToken? cancelToken,
  });
  Future<IssueSearchResponseDto> getIssueSearchPage(
    String url, {
    CancelToken? cancelToken,
  });
  Future<IssueSearchResponseDto> searchIssues(
    String query, {
    Uri? nextUrl,
    int page = 1,
    DateTime? modifiedGt,
    CancelToken? cancelToken,
  });
  Future<IssueSearchResponseDto> getIssueList({
    Uri? nextUrl,
    int page = 1,
    String? ordering,
    DateTime? modifiedGt,
    CancelToken? cancelToken,
  });
  Future<SeriesListResponseDto> getSeriesList({
    Uri? nextUrl,
    int page = 1,
    DateTime? modifiedGt,
    CancelToken? cancelToken,
  });
  Future<SeriesSearchResponseDto> searchSeries(
    String query, {
    Uri? nextUrl,
    int page = 1,
    DateTime? modifiedGt,
    CancelToken? cancelToken,
  });
  Future<Response> getSeriesDetails(int seriesId);
  Future<SeriesIssueListResponseDto> getSeriesIssueList(
    int seriesId, {
    Uri? nextUrl,
    int page = 1,
    String? ordering,
    DateTime? storeDateGte,
    DateTime? storeDateLte,
    CancelToken? cancelToken,
  });
  Future<CharacterListResponseDto> getCharacterList({
    Uri? nextUrl,
    int page = 1,
    DateTime? modifiedGt,
    CancelToken? cancelToken,
  });
  Future<CharacterListResponseDto> searchCharacters(
    String query, {
    Uri? nextUrl,
    int page = 1,
    CancelToken? cancelToken,
  });
  Future<Response> getCharacterDetails(int characterId);
  Future<SeriesIssueListResponseDto> getCharacterIssueList(
    int characterId, {
    Uri? nextUrl,
    int page = 1,
    CancelToken? cancelToken,
  });

  Future<CreatorListResponseDto> getCreatorList({
    Uri? nextUrl,
    int page = 1,
    DateTime? modifiedGt,
    CancelToken? cancelToken,
  });

  Future<CreatorListResponseDto> searchCreators(
    String query, {
    Uri? nextUrl,
    int page = 1,
    CancelToken? cancelToken,
  });

  Future<Response> getCreatorDetails(int creatorId);

  Future<UniverseListResponseDto> getUniverseList({
    Uri? nextUrl,
    int page = 1,
    DateTime? modifiedGt,
    CancelToken? cancelToken,
  });

  Future<UniverseListResponseDto> searchUniverses(
    String query, {
    Uri? nextUrl,
    int page = 1,
    CancelToken? cancelToken,
  });

  Future<Response> getUniverseDetails(int universeId);

  Future<ImprintListResponseDto> getImprintList({
    Uri? nextUrl,
    int page = 1,
    DateTime? modifiedGt,
    CancelToken? cancelToken,
  });

  Future<ImprintListResponseDto> searchImprints(
    String query, {
    Uri? nextUrl,
    int page = 1,
    CancelToken? cancelToken,
  });

  Future<Response> getImprintDetails(int imprintId);

  Future<TeamListResponseDto> getTeamList({
    Uri? nextUrl,
    int page = 1,
    DateTime? modifiedGt,
    CancelToken? cancelToken,
  });

  Future<TeamListResponseDto> searchTeams(
    String query, {
    Uri? nextUrl,
    int page = 1,
    CancelToken? cancelToken,
  });

  Future<Response> getTeamDetails(int teamId);
  Future<SeriesIssueListResponseDto> getTeamIssueList(
    int teamId, {
    Uri? nextUrl,
    int page = 1,
    CancelToken? cancelToken,
  });
  Future<ArcListResponseDto> getArcList({
    Uri? nextUrl,
    int page = 1,
    DateTime? modifiedGt,
    CancelToken? cancelToken,
  });

  Future<ArcListResponseDto> searchArcs(
    String query, {
    Uri? nextUrl,
    int page = 1,
    CancelToken? cancelToken,
  });
  Future<Response> getArcDetails(int arcId);
  Future<SeriesIssueListResponseDto> getArcIssueList(
    int arcId, {
    Uri? nextUrl,
    int page = 1,
    CancelToken? cancelToken,
  });

  Future<PublisherListResponseDto> getPublisherList({
    Uri? nextUrl,
    int page = 1,
    DateTime? modifiedGt,
    CancelToken? cancelToken,
  });

  Future<PublisherListResponseDto> searchPublishers(
    String query, {
    Uri? nextUrl,
    int page = 1,
    CancelToken? cancelToken,
  });

  Future<Response> getPublisherDetails(int publisherId);

  Future<SeriesListResponseDto> getPublisherSeriesList(
    int publisherId, {
    Uri? nextUrl,
    int page = 1,
    CancelToken? cancelToken,
  });

  Future<ReadingListResponseDto> getReadingLists({
    Uri? nextUrl,
    int page = 1,
    String? name,
    String? listType,
    String? attributionSource,
    String? publisher,
    DateTime? modifiedGt,
    CancelToken? cancelToken,
  });

  Future<Response> getReadingListDetail(int id);

  Future<ReadingListItemResponseDto> getReadingListItems(
    int id, {
    Uri? nextUrl,
    int page = 1,
    CancelToken? cancelToken,
  });
}