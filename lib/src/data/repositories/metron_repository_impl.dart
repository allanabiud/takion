import 'package:takion/src/core/cache/cache_policy.dart';
import 'package:takion/src/data/datasources/metron_local_data_source.dart';
import 'package:takion/src/data/datasources/metron_remote_data_source.dart';
import 'package:takion/src/domain/entities/issue_details.dart';
import 'package:takion/src/domain/entities/issue_list.dart'; // Updated import
import 'package:takion/src/domain/repositories/metron_repository.dart';

class MetronRepositoryImpl implements MetronRepository {
  final MetronRemoteDataSource _remoteDataSource;
  final MetronLocalDataSource _localDataSource;
  final DateTime Function() _now;

  MetronRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource, {
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  @override
  Future<List<IssueList>> getWeeklyReleasesForDate(DateTime date, {bool forceRefresh = false}) async { // Updated to IssueList
    final cachedDtos = await _localDataSource.getWeeklyReleases(date);
    final cachedAt = await _localDataSource.getWeeklyReleasesCachedAt(date);

    if (!forceRefresh && cachedDtos != null && cachedDtos.isNotEmpty) {
      if (cachedAt != null && MetronCachePolicies.weeklyReleases.isFresh(cachedAt, _now())) {
        return cachedDtos.map((entry) => entry.toEntity()).toList();
      }
    }

    try {
      final remoteDtos = await _remoteDataSource.getWeeklyReleasesForDate(date);
      await _localDataSource.cacheWeeklyReleases(date, remoteDtos);
      return remoteDtos.map((entry) => entry.toEntity()).toList();
    } catch (_) {
      if (cachedDtos != null && cachedDtos.isNotEmpty) {
        return cachedDtos.map((entry) => entry.toEntity()).toList();
      }
      rethrow;
    }
  }

  @override
  Future<IssueDetails> getIssueDetails(int issueId, {bool forceRefresh = false}) async {
    final cachedDto = await _localDataSource.getIssueDetails(issueId);
    final cachedAt = await _localDataSource.getIssueDetailsCachedAt(issueId);
    if (!forceRefresh && cachedDto != null) {
      final isFresh = cachedAt != null &&
          MetronCachePolicies.issueDetails.isFresh(cachedAt, _now());
      if (isFresh) {
        return cachedDto.toEntity();
      }
    }

    try {
      final remoteDto = await _remoteDataSource.getIssueDetails(issueId);
      await _localDataSource.cacheIssueDetails(remoteDto);
      return remoteDto.toEntity();
    } catch (_) {
      if (cachedDto != null) {
        return cachedDto.toEntity();
      }
      rethrow;
    }
  }

  @override
  Future<List<IssueList>> searchIssues(
    String query, {
    bool forceRefresh = false,
  }) async {
    final cachedDtos = await _localDataSource.getIssueSearchResults(query);
    final cachedAt = await _localDataSource.getIssueSearchResultsCachedAt(query);

    if (!forceRefresh && cachedDtos != null && cachedDtos.isNotEmpty) {
      final isFresh = cachedAt != null &&
          MetronCachePolicies.searchResults.isFresh(cachedAt, _now());
      if (isFresh) {
        return cachedDtos.map((entry) => entry.toEntity()).toList();
      }
    }

    try {
      final remoteDtos = await _remoteDataSource.searchIssues(query);
      await _localDataSource.cacheIssueSearchResults(query, remoteDtos);
      return remoteDtos.map((entry) => entry.toEntity()).toList();
    } catch (_) {
      if (cachedDtos != null && cachedDtos.isNotEmpty) {
        return cachedDtos.map((entry) => entry.toEntity()).toList();
      }
      rethrow;
    }
  }

}
