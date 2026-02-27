import 'package:takion/src/core/network/supabase_service.dart';
import 'package:takion/src/domain/entities/issue_list.dart';
import 'package:takion/src/domain/repositories/catalog_repository.dart';

class CatalogSyncHelper {
  CatalogSyncHelper(this._catalogRepository, this._catalogReleaseService);

  final CatalogRepository _catalogRepository;
  final SupabaseCatalogReleaseService _catalogReleaseService;

  Future<int> upsertIssues(List<IssueList> issues) async {
    return _catalogReleaseService.upsertWeeklyIssues(issues);
  }

  Future<int> syncWeek(
    DateTime date, {
    bool forceRefresh = false,
  }) async {
    final issues = await _catalogRepository.getWeeklyReleasesForDate(
      date,
      forceRefresh: forceRefresh,
    );
    return _catalogReleaseService.upsertWeeklyIssues(issues);
  }
}
