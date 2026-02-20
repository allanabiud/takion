import 'package:takion/src/domain/entities/issue.dart';
import 'package:takion/src/domain/entities/series.dart';

abstract class MetronRepository {
  Future<List<Issue>> getWeeklyReleases();
  Future<List<Issue>> searchIssues(String query);
  Future<List<Series>> searchSeries(String query);
  // Add others later: Character, Creator, Arc
  Future<Issue> getIssueDetails(int id);
}
