import "package:takion/src/domain/catalog/entities/entities.dart";
import "package:takion/src/domain/entities.dart";

/// Local reads against the cached Metron catalog tables.
///
/// Presentation features use this instead of reaching into the Drift entity
/// DAO directly, keeping the cache rows out of the presentation layer.
abstract class LocalCatalogRepository {
  Future<SeriesList?> getSeries(int seriesId);

  Future<Map<int, SeriesList>> getSeriesByIds(List<int> seriesIds);

  Future<LocalIssue?> getIssue(int issueId);

  Future<Map<int, LocalIssue>> getIssuesByIds(List<int> issueIds);

  Future<CreatorList?> getCreator(int creatorId);

  Future<Map<int, CreatorList>> getCreatorsByIds(List<int> creatorIds);

  Future<List<LocalIssue>> getIssuesBySeries(
    int seriesId, {
    int limit = 200,
  });

  Stream<SeriesList?> watchSeries(int seriesId);

  Stream<String?> watchSeriesCoverUrl(int seriesId);

  Future<List<SeriesList>> searchSeriesLocally(
    String query, {
    int limit = 50,
  });

  /// Fully-hydrated (characters, credits, publisher) stream for a series row.
  Stream<SeriesDetails?> watchSeriesDetails(int seriesId);

  /// Fully-hydrated (characters, credits, publisher) stream for an issue row.
  Stream<IssueDetails?> watchIssueDetails(int issueId);

  Stream<List<LocalIssue>> watchIssuesBySeries(int seriesId);

  Stream<List<LocalIssue>> watchAllIssues();

  /// Maps cached issues into fully-hydrated [IssueDetails] (including
  /// publisher, characters, and credits from the junction tables).
  Future<List<IssueDetails>> hydrateIssueDetails(List<int> issueIds);

  Future<IssueDetails?> hydrateIssueDetail(int issueId);
}