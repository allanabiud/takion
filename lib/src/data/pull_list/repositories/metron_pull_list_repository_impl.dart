import "package:takion/src/data/pull_list/datasources/remote/metron_pull_list_remote_data_source.dart";
import "package:takion/src/domain/pull_list/entities/pull_list_item.dart";
import "package:takion/src/domain/pull_list/repositories/pull_list_repository.dart";

class MetronPullListRepositoryImpl implements MetronPullListRepository {
  MetronPullListRepositoryImpl(this._remoteDataSource);

  final MetronPullListRemoteDataSource _remoteDataSource;

  @override
  Future<List<PullListSeriesItem>> getPullListSeries({
    int page = 1,
    DateTime? modifiedGt,
  }) async {
    final dtos = await _remoteDataSource.getPullListSeries(
      page: page,
      modifiedGt: modifiedGt,
    );
    return dtos.map((dto) => dto.toEntity()).toList();
  }

  @override
  Future<PullListSeriesItem> addSeriesToPullList(int seriesId) async {
    final dto = await _remoteDataSource.addSeriesToPullList(seriesId);
    return dto.toEntity();
  }

  @override
  Future<void> removeSeriesFromPullList(int seriesId) {
    return _remoteDataSource.removeSeriesFromPullList(seriesId);
  }

  @override
  Future<List<PullListIssueItem>> getPullListIssues({
    int page = 1,
    DateTime? storeDateAfter,
    DateTime? storeDateBefore,
  }) async {
    final dtos = await _remoteDataSource.getPullListIssues(
      page: page,
      storeDateAfter: storeDateAfter,
      storeDateBefore: storeDateBefore,
    );
    return dtos.map((dto) => dto.toEntity()).toList();
  }
}
