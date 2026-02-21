import 'package:takion/src/domain/entities/collection_stats.dart';
import 'package:takion/src/domain/entities/issue.dart';
import 'package:takion/src/domain/entities/series.dart';

abstract class MetronRepository {
  Future<List<Issue>> getWeeklyReleases();
  Future<List<Issue>> getWeeklyReleasesForDate(DateTime date);
  Future<List<Issue>> searchIssues(String query, {bool forceRefresh = false});
  Future<List<Series>> searchSeries(String query, {bool forceRefresh = false});
  // Add others later: Character, Creator, Arc
  Future<Issue> getIssueDetails(int id);
  Future<List<Issue>> getRecentlyModifiedIssues({int limit = 12});
  Future<CollectionStats> getCollectionStats();
  Future<List<Issue>> getUnreadIssues();
}
