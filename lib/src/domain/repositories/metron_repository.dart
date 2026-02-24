import 'package:takion/src/domain/entities/collection_stats.dart';
import 'package:takion/src/domain/entities/collection_items_page.dart';
import 'package:takion/src/domain/entities/collection_item_details.dart';
import 'package:takion/src/domain/entities/collection_scrobble_result.dart';
import 'package:takion/src/domain/entities/missing_series_page.dart';
import 'package:takion/src/domain/entities/issue_list.dart';
import 'package:takion/src/domain/entities/issue_details.dart';
import 'package:takion/src/domain/entities/issue_search_page.dart';
import 'package:takion/src/domain/entities/series_details.dart';
import 'package:takion/src/domain/entities/series_issue_list_page.dart';
import 'package:takion/src/domain/entities/series_list_page.dart';
import 'package:takion/src/domain/entities/series_search_page.dart';

abstract class MetronRepository {
  Future<CollectionStats> getCollectionStats({
    bool forceRefresh = false,
  });

  Future<CollectionItemsPage> getCollectionItems({
    int page = 1,
    bool forceRefresh = false,
  });

  Future<CollectionItemDetails> getCollectionItemDetails(int collectionId);

  Future<CollectionScrobbleResult> scrobbleIssueRead({
    required int issueId,
    DateTime? dateRead,
    int? rating,
  });

  Future<MissingSeriesPage> getMissingSeries({
    int page = 1,
    bool forceRefresh = false,
  });

  Future<List<IssueList>> getWeeklyReleasesForDate(
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
    bool forceRefresh = false,
  });

  Future<SeriesSearchPage> searchSeries(
    String query, {
    int page = 1,
    bool forceRefresh = false,
  });

  Future<SeriesListPage> getSeriesList({
    int page = 1,
    bool forceRefresh = false,
  });

  Future<SeriesDetails> getSeriesDetails(
    int seriesId, {
    bool forceRefresh = false,
  });

  Future<SeriesIssueListPage> getSeriesIssueList(
    int seriesId, {
    int page = 1,
    bool forceRefresh = false,
  });
}
