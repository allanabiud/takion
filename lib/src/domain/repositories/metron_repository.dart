import 'package:dio/dio.dart';
import 'package:takion/src/domain/entities/arc_details.dart';
import 'package:takion/src/domain/entities/arc_issue_list_page.dart';
import 'package:takion/src/domain/entities/arc_list_page.dart';
import 'package:takion/src/domain/entities/character_details.dart';
import 'package:takion/src/domain/entities/character_issue_list_page.dart';
import 'package:takion/src/domain/entities/character_list_page.dart';
import 'package:takion/src/domain/entities/creator_details.dart';
import 'package:takion/src/domain/entities/creator_list_page.dart';
import 'package:takion/src/domain/entities/issue_list.dart';
import 'package:takion/src/domain/entities/issue_details.dart';
import 'package:takion/src/domain/entities/issue_search_page.dart';
import 'package:takion/src/domain/entities/series_details.dart';
import 'package:takion/src/domain/entities/series_issue_list_page.dart';
import 'package:takion/src/domain/entities/series_list_page.dart';
import 'package:takion/src/domain/entities/series_search_page.dart';
import 'package:takion/src/domain/entities/universe_details.dart';
import 'package:takion/src/domain/entities/universe_list_page.dart';
import 'package:takion/src/domain/entities/imprint_details.dart';
import 'package:takion/src/domain/entities/imprint_list_page.dart';
import 'package:takion/src/domain/entities/team_details.dart';
import 'package:takion/src/domain/entities/team_list_page.dart';
import 'package:takion/src/domain/repositories/catalog_repository.dart';
import 'package:takion/src/domain/entities/publisher_details.dart';
import 'package:takion/src/domain/entities/publisher_list_page.dart';
import 'package:takion/src/domain/entities/metron_reading_list_detail.dart';
import 'package:takion/src/domain/entities/metron_reading_list_item.dart';
import 'package:takion/src/domain/entities/metron_reading_list_page.dart';
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
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  });

  @override
  Future<IssueSearchPage> getIssueList({
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
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  });

  @override
  Future<SeriesListPage> getSeriesList({
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
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  });

  @override
  Future<CharacterListPage> searchCharacters(
    String query, {
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  });

  Future<CharacterListPage> getCharacterList({
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
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  });

  Future<CreatorListPage> getCreatorList({
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  });

  @override
  Future<CreatorListPage> searchCreators(
    String query, {
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
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  });

  @override
  Future<UniverseListPage> searchUniverses(
    String query, {
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
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  });

  @override
  Future<ImprintListPage> searchImprints(
    String query, {
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
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  });

  @override
  Future<TeamListPage> searchTeams(
    String query, {
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
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  });

  @override
  Future<ArcListPage> searchArcs(
    String query, {
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
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  });

  Future<PublisherListPage> getPublisherList({
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  });

  @override
  Future<PublisherListPage> searchPublishers(
    String query, {
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
    int page = 1,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  });

  Future<MetronReadingListPage> searchReadingLists({
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
