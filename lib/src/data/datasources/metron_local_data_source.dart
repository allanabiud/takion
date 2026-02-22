import 'package:takion/src/core/storage/hive_service.dart';
import 'package:takion/src/data/models/collection_stats_dto.dart';
import 'package:takion/src/data/models/issue_dto.dart';

abstract class MetronLocalDataSource {
  Future<void> cacheWeeklyReleases(DateTime weekStart, List<IssueDto> issues);
  Future<List<IssueDto>?> getWeeklyReleases(DateTime weekStart);
  Future<void> cacheSearchResults(String query, String type, List<dynamic> results);
  Future<List<dynamic>?> getSearchResults(String query, String type);
  Future<void> cacheCollectionStats(CollectionStatsDto stats);
  Future<CollectionStatsDto?> getCollectionStats();
  Future<void> cacheIssueDetail(IssueDto issue);
  Future<IssueDto?> getIssueDetail(int id);
}

class MetronLocalDataSourceImpl implements MetronLocalDataSource {
  final HiveService _hiveService;
  static const String _weeklyBox = 'weekly_releases_box';
  static const String _searchBox = 'search_results_box';
  static const String _detailsBox = 'issue_details_box';
  static const String _statsBox = 'collection_stats_box';

  MetronLocalDataSourceImpl(this._hiveService);

  String _getSearchKey(String query, String type) => "${type.toLowerCase()}_${query.toLowerCase().trim()}";

  String _getWeekKey(DateTime date) {
    // Standardize to Sunday start
    final offset = date.weekday % 7;
    final sunday = DateTime(date.year, date.month, date.day).subtract(Duration(days: offset));
    return "${sunday.year}-${sunday.month}-${sunday.day}";
  }

  @override
  Future<void> cacheWeeklyReleases(DateTime weekStart, List<IssueDto> issues) async {
    final box = await _hiveService.openBox<List>(_weeklyBox);
    await box.put(_getWeekKey(weekStart), issues);
  }

  @override
  Future<List<IssueDto>?> getWeeklyReleases(DateTime weekStart) async {
    final box = await _hiveService.openBox<List>(_weeklyBox);
    final data = box.get(_getWeekKey(weekStart));
    if (data != null) {
      return data.cast<IssueDto>();
    }
    return null;
  }

  @override
  Future<void> cacheSearchResults(String query, String type, List<dynamic> results) async {
    final box = await _hiveService.openBox<List>(_searchBox);
    await box.put(_getSearchKey(query, type), results);
  }

  @override
  Future<List<dynamic>?> getSearchResults(String query, String type) async {
    final box = await _hiveService.openBox<List>(_searchBox);
    final data = box.get(_getSearchKey(query, type));
    return data?.cast<dynamic>();
  }

  @override
  Future<void> cacheCollectionStats(CollectionStatsDto stats) async {
    final box = await _hiveService.openBox<CollectionStatsDto>(_statsBox);
    await box.put('current_stats', stats);
  }

  @override
  Future<CollectionStatsDto?> getCollectionStats() async {
    final box = await _hiveService.openBox<CollectionStatsDto>(_statsBox);
    return box.get('current_stats');
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
