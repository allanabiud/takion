import "package:takion/src/data/catalog/datasources/local/metron_page_cache_keys.dart";
import "package:takion/src/data/catalog/datasources/local/paged_local_cache.dart";
import "package:takion/src/data/catalog/dto/dto.dart";
import "package:takion/src/data/common/drift/database.dart";

abstract class MetronReleasesLocalDataSource {
  Future<void> cacheWeeklyReleases(
    DateTime weekStart,
    List<IssueListDto> issues,
  );
  Future<List<IssueListDto>?> getWeeklyReleases(DateTime weekStart);
  Future<DateTime?> getWeeklyReleasesCachedAt(DateTime weekStart);
  Future<void> cacheFocReleases(DateTime weekStart, List<IssueListDto> issues);
  Future<List<IssueListDto>?> getFocReleases(DateTime weekStart);
  Future<DateTime?> getFocReleasesCachedAt(DateTime weekStart);
}

class MetronReleasesLocalDataSourceImpl implements MetronReleasesLocalDataSource {
  MetronReleasesLocalDataSourceImpl(AppDatabase db)
      : _weeklyReleases = PagedLocalCache<IssueListDto>(
          db: db,
          cacheKeyPrefix: "weekly_releases",
          entityType: "weekly_releases",
          fromJson: IssueListDto.fromJson,
          toJson: (i) => i.toJson(),
          withMeta: false,
        ),
        _focReleases = PagedLocalCache<IssueListDto>(
          db: db,
          cacheKeyPrefix: "foc_releases",
          entityType: "foc_releases",
          fromJson: IssueListDto.fromJson,
          toJson: (i) => i.toJson(),
          withMeta: false,
        );

  final PagedLocalCache<IssueListDto> _weeklyReleases;
  final PagedLocalCache<IssueListDto> _focReleases;

  @override
  Future<void> cacheWeeklyReleases(
    DateTime weekStart,
    List<IssueListDto> issues,
  ) async {
    await _weeklyReleases.cache(MetronPageCacheKeys.weekKey(weekStart), issues);
  }

  @override
  Future<List<IssueListDto>?> getWeeklyReleases(DateTime weekStart) async {
    return _weeklyReleases.get(MetronPageCacheKeys.weekKey(weekStart));
  }

  @override
  Future<DateTime?> getWeeklyReleasesCachedAt(DateTime weekStart) async {
    return _weeklyReleases.cachedAt(MetronPageCacheKeys.weekKey(weekStart));
  }

  @override
  Future<void> cacheFocReleases(
    DateTime weekStart,
    List<IssueListDto> issues,
  ) async {
    await _focReleases.cache(MetronPageCacheKeys.weekKey(weekStart), issues);
  }

  @override
  Future<List<IssueListDto>?> getFocReleases(DateTime weekStart) async {
    return _focReleases.get(MetronPageCacheKeys.weekKey(weekStart));
  }

  @override
  Future<DateTime?> getFocReleasesCachedAt(DateTime weekStart) async {
    return _focReleases.cachedAt(MetronPageCacheKeys.weekKey(weekStart));
  }
}
