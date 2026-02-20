import 'package:takion/src/core/storage/hive_service.dart';
import 'package:takion/src/data/models/issue_dto.dart';

abstract class MetronLocalDataSource {
  Future<void> cacheIssues(List<IssueDto> issues);
  Future<List<IssueDto>> getCachedIssues();
  Future<void> cacheIssueDetail(IssueDto issue);
  Future<IssueDto?> getIssueDetail(int id);
}

class MetronLocalDataSourceImpl implements MetronLocalDataSource {
  final HiveService _hiveService;
  static const String _issuesBox = 'issues_box';
  static const String _detailsBox = 'issue_details_box';

  MetronLocalDataSourceImpl(this._hiveService);

  @override
  Future<void> cacheIssues(List<IssueDto> issues) async {
    final box = await _hiveService.openBox<IssueDto>(_issuesBox);
    await box.clear();
    for (var issue in issues) {
      await box.put(issue.id, issue);
      // Also cache in details box for quick lookup
      await cacheIssueDetail(issue);
    }
  }

  @override
  Future<List<IssueDto>> getCachedIssues() async {
    final box = await _hiveService.openBox<IssueDto>(_issuesBox);
    return box.values.toList();
  }

  @override
  Future<void> cacheIssueDetail(IssueDto issue) async {
    final box = await _hiveService.openBox<IssueDto>(_detailsBox);
    await box.put(issue.id, issue);
  }

  @override
  Future<IssueDto?> getIssueDetail(int id) async {
    final box = await _hiveService.openBox<IssueDto>(_detailsBox);
    return box.get(id);
  }
}
