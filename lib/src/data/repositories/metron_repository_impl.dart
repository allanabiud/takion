import 'package:takion/src/data/datasources/metron_local_data_source.dart';
import 'package:takion/src/data/datasources/metron_remote_data_source.dart';
import 'package:takion/src/domain/entities/issue.dart';
import 'package:takion/src/domain/entities/series.dart';
import 'package:takion/src/domain/repositories/metron_repository.dart';

class MetronRepositoryImpl implements MetronRepository {
  final MetronRemoteDataSource _remoteDataSource;
  final MetronLocalDataSource _localDataSource;

  MetronRepositoryImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<List<Issue>> getWeeklyReleases() async {
    try {
      final remoteDtos = await _remoteDataSource.getWeeklyReleases();
      await _localDataSource.cacheIssues(remoteDtos);
      return remoteDtos.map((e) => e.toEntity()).toList();
    } catch (e) {
      final cachedDtos = await _localDataSource.getCachedIssues();
      if (cachedDtos.isNotEmpty) {
        return cachedDtos.map((e) => e.toEntity()).toList();
      }
      rethrow;
    }
  }

  @override
  Future<Issue> getIssueDetails(int id) async {
    final cachedDto = await _localDataSource.getIssueDetail(id);
    if (cachedDto != null) {
      return cachedDto.toEntity();
    }

    final remoteDto = await _remoteDataSource.getIssueDetails(id);
    await _localDataSource.cacheIssueDetail(remoteDto);
    return remoteDto.toEntity();
  }

  @override
  Future<List<Issue>> searchIssues(String query) async {
    final dtos = await _remoteDataSource.searchIssues(query);
    for (var dto in dtos) {
      await _localDataSource.cacheIssueDetail(dto);
    }
    return dtos.map((e) => e.toEntity()).toList();
  }

  @override
  Future<List<Series>> searchSeries(String query) async {
    final dtos = await _remoteDataSource.searchSeries(query);
    // We could cache series here if we expand local data source
    return dtos.map((e) => e.toEntity()).toList();
  }
}
