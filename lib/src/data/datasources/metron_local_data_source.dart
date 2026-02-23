import 'package:takion/src/core/storage/hive_service.dart';
import 'package:takion/src/data/models/issue_details_dto.dart';
import 'package:takion/src/data/models/issue_list_dto.dart';

abstract class MetronLocalDataSource {
  Future<void> cacheWeeklyReleases(DateTime weekStart, List<IssueListDto> issues);
  Future<List<IssueListDto>?> getWeeklyReleases(DateTime weekStart);
  Future<DateTime?> getWeeklyReleasesCachedAt(DateTime weekStart);
  Future<void> cacheIssueDetails(IssueDetailsDto issue);
  Future<IssueDetailsDto?> getIssueDetails(int issueId);
  Future<DateTime?> getIssueDetailsCachedAt(int issueId);
}

class MetronLocalDataSourceImpl implements MetronLocalDataSource {
  final HiveService _hiveService;
  static const String _weeklyBox = 'weekly_releases_box';
  static const String _issueDetailsBox = 'issue_details_box';
  static const String _cacheMetaBox = 'cache_meta_box';

  MetronLocalDataSourceImpl(this._hiveService);

  String _getWeekKey(DateTime date) {
    // Standardize to Sunday start
    final offset = date.weekday % 7;
    final sunday = DateTime(date.year, date.month, date.day).subtract(Duration(days: offset));
    return "${sunday.year}-${sunday.month}-${sunday.day}";
  }

  String _getMetaKey(String key) => 'weekly_releases:$key';
  String _getIssueDetailsMetaKey(int issueId) => 'issue_details:$issueId';

  @override
  Future<void> cacheWeeklyReleases(DateTime weekStart, List<IssueListDto> issues) async {
    final key = _getWeekKey(weekStart);
    final box = await _hiveService.openBox<List>(_weeklyBox);
    await box.put(key, issues);

    final metaBox = await _hiveService.openBox<int>(_cacheMetaBox);
    await metaBox.put(
      _getMetaKey(key),
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  Future<List<IssueListDto>?> getWeeklyReleases(DateTime weekStart) async {
    final box = await _hiveService.openBox<List>(_weeklyBox);
    final data = box.get(_getWeekKey(weekStart));
    if (data != null) {
      return data.cast<IssueListDto>();
    }
    return null;
  }

  @override
  Future<DateTime?> getWeeklyReleasesCachedAt(DateTime weekStart) async {
    final key = _getWeekKey(weekStart);
    final metaBox = await _hiveService.openBox<int>(_cacheMetaBox);
    final epoch = metaBox.get(_getMetaKey(key));
    if (epoch == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(epoch);
  }

  @override
  Future<void> cacheIssueDetails(IssueDetailsDto issue) async {
    final box = await _hiveService.openBox<IssueDetailsDto>(_issueDetailsBox);
    await box.put(issue.id, issue);

    final metaBox = await _hiveService.openBox<int>(_cacheMetaBox);
    await metaBox.put(
      _getIssueDetailsMetaKey(issue.id),
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  Future<IssueDetailsDto?> getIssueDetails(int issueId) async {
    final box = await _hiveService.openBox<IssueDetailsDto>(_issueDetailsBox);
    return box.get(issueId);
  }

  @override
  Future<DateTime?> getIssueDetailsCachedAt(int issueId) async {
    final metaBox = await _hiveService.openBox<int>(_cacheMetaBox);
    final epoch = metaBox.get(_getIssueDetailsMetaKey(issueId));
    if (epoch == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(epoch);
  }
}
