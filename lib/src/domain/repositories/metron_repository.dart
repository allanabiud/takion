import 'package:takion/src/domain/entities/issue_list.dart';
import 'package:takion/src/domain/entities/issue_details.dart';
import 'package:takion/src/domain/entities/issue_search_page.dart';
import 'package:takion/src/domain/entities/series_details.dart';
import 'package:takion/src/domain/entities/series_issue_list_page.dart';
import 'package:takion/src/domain/entities/series_list_page.dart';
import 'package:takion/src/domain/entities/series_search_page.dart';
import 'package:takion/src/domain/repositories/catalog_repository.dart';

abstract class MetronRepository implements CatalogRepository {
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
