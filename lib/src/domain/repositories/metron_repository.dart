import 'package:takion/src/domain/entities/issue_list.dart';
import 'package:takion/src/domain/entities/issue_details.dart';

abstract class MetronRepository {
  Future<List<IssueList>> getWeeklyReleasesForDate(
    DateTime date, {
    bool forceRefresh = false,
  });

  Future<IssueDetails> getIssueDetails(
    int issueId, {
    bool forceRefresh = false,
  });
}
