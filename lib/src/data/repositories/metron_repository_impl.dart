import 'package:takion/src/data/datasources/metron_local_data_source.dart';
import 'package:takion/src/data/datasources/metron_remote_data_source.dart';
import 'package:takion/src/data/models/issue_dto.dart';
import 'package:takion/src/data/models/series_dto.dart';
import 'package:takion/src/domain/entities/collection_stats.dart';
import 'package:takion/src/domain/entities/issue.dart';
import 'package:takion/src/domain/entities/series.dart';
import 'package:takion/src/domain/repositories/metron_repository.dart';

class MetronRepositoryImpl implements MetronRepository {
  final MetronRemoteDataSource _remoteDataSource;
  final MetronLocalDataSource _localDataSource;

  MetronRepositoryImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<List<Issue>> getWeeklyReleases() async {
    return getWeeklyReleasesForDate(DateTime.now());
  }

  @override
  Future<List<Issue>> getWeeklyReleasesForDate(DateTime date) async {
    final cachedDtos = await _localDataSource.getWeeklyReleases(date);
    if (cachedDtos != null && cachedDtos.isNotEmpty) {
      return cachedDtos.map((e) => e.toEntity()).toList();
    }

    try {
      final remoteDtos = await _remoteDataSource.getWeeklyReleasesForDate(date);
      await _localDataSource.cacheWeeklyReleases(date, remoteDtos);
      return remoteDtos.map((e) => e.toEntity()).toList();
    } catch (e) {
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
  Future<List<Issue>> getRecentlyModifiedIssues({int limit = 12}) async {
    final dtos = await _remoteDataSource.getRecentlyModifiedIssues(
      limit: limit,
    );
    return dtos.map((e) => e.toEntity()).take(limit).toList();
  }

  @override
  Future<List<Issue>> searchIssues(
    String query, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final cached = await _localDataSource.getSearchResults(query, 'issue');
      if (cached != null) {
        return cached.cast<IssueDto>().map((e) => e.toEntity()).toList();
      }
    }

    final dtos = await _remoteDataSource.searchIssues(query);
    await _localDataSource.cacheSearchResults(query, 'issue', dtos);
    return dtos.map((e) => e.toEntity()).toList();
  }

  @override
  Future<List<Series>> searchSeries(
    String query, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final cached = await _localDataSource.getSearchResults(query, 'series');
      if (cached != null) {
        return cached.cast<SeriesDto>().map((e) => e.toEntity()).toList();
      }
    }

    final dtos = await _remoteDataSource.searchSeries(query);
    await _localDataSource.cacheSearchResults(query, 'series', dtos);
    return dtos.map((e) => e.toEntity()).toList();
  }

  @override
  Future<CollectionStats> getCollectionStats() async {
    final cachedDto = await _localDataSource.getCollectionStats();
    if (cachedDto != null) {
      return cachedDto.toEntity();
    }

    final dto = await _remoteDataSource.getCollectionStats();
    await _localDataSource.cacheCollectionStats(dto);
    return dto.toEntity();
  }

  @override
  Future<List<Issue>> getUnreadIssues() async {
    final dtos = await _remoteDataSource.getUnreadIssues();
    return dtos.map((e) => e.toEntity()).toList();
  }
}
