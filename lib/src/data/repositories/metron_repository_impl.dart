import 'package:takion/src/core/cache/cache_policy.dart';
import 'package:takion/src/data/datasources/metron_local_data_source.dart';
import 'package:takion/src/data/datasources/metron_remote_data_source.dart';
import 'package:takion/src/domain/entities/collection_stats.dart';
import 'package:takion/src/domain/entities/collection_items_page.dart';
import 'package:takion/src/domain/entities/collection_item_details.dart';
import 'package:takion/src/domain/entities/collection_scrobble_result.dart';
import 'package:takion/src/domain/entities/missing_series_page.dart';
import 'package:takion/src/domain/entities/issue_details.dart';
import 'package:takion/src/domain/entities/issue_list.dart'; // Updated import
import 'package:takion/src/domain/entities/issue_search_page.dart';
import 'package:takion/src/domain/entities/series_details.dart';
import 'package:takion/src/domain/entities/series_issue_list_page.dart';
import 'package:takion/src/domain/entities/series_list_page.dart';
import 'package:takion/src/domain/entities/series_search_page.dart';
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
  Future<CollectionStats> getCollectionStats({
    bool forceRefresh = false,
  }) async {
    final cachedDto = await _localDataSource.getCollectionStats();
    final cachedAt = await _localDataSource.getCollectionStatsCachedAt();

    if (!forceRefresh && cachedDto != null) {
      final isFresh = cachedAt != null &&
          MetronCachePolicies.collectionStats.isFresh(cachedAt, _now());
      if (isFresh) {
        return cachedDto.toEntity();
      }
    }

    try {
      final remoteDto = await _remoteDataSource.getCollectionStats();
      await _localDataSource.cacheCollectionStats(remoteDto);
      return remoteDto.toEntity();
    } catch (_) {
      if (cachedDto != null) {
        return cachedDto.toEntity();
      }
      rethrow;
    }
  }

  @override
  Future<CollectionItemsPage> getCollectionItems({
    int page = 1,
    bool forceRefresh = false,
  }) async {
    final cachedPage = await _localDataSource.getCollectionItemsPage(page);
    final cachedAt = await _localDataSource.getCollectionItemsPageCachedAt(page);

    if (!forceRefresh && cachedPage != null) {
      final isFresh = cachedAt != null &&
          MetronCachePolicies.collectionItems.isFresh(cachedAt, _now());
      if (isFresh) {
        return CollectionItemsPage(
          count: cachedPage.count,
          next: cachedPage.next,
          previous: cachedPage.previous,
          results: cachedPage.results.map((entry) => entry.toEntity()).toList(),
          currentPage: page,
        );
      }
    }

    try {
      final remotePage = await _remoteDataSource.getCollectionItems(page: page);
      await _localDataSource.cacheCollectionItemsPage(page, remotePage);
      return CollectionItemsPage(
        count: remotePage.count,
        next: remotePage.next,
        previous: remotePage.previous,
        results: remotePage.results.map((entry) => entry.toEntity()).toList(),
        currentPage: page,
      );
    } catch (_) {
      if (cachedPage != null) {
        return CollectionItemsPage(
          count: cachedPage.count,
          next: cachedPage.next,
          previous: cachedPage.previous,
          results: cachedPage.results.map((entry) => entry.toEntity()).toList(),
          currentPage: page,
        );
      }
      rethrow;
    }
  }

  @override
  Future<CollectionItemDetails> getCollectionItemDetails(int collectionId) async {
    final cachedDto = await _localDataSource.getCollectionItemDetails(collectionId);
    final cachedAt = await _localDataSource.getCollectionItemDetailsCachedAt(
      collectionId,
    );

    if (cachedDto != null) {
      final isFresh = cachedAt != null &&
          MetronCachePolicies.collectionItemDetails.isFresh(cachedAt, _now());
      if (isFresh) {
        return cachedDto.toEntity();
      }
    }

    try {
      final remoteDto = await _remoteDataSource.getCollectionItemDetails(
        collectionId,
      );
      await _localDataSource.cacheCollectionItemDetails(remoteDto);
      return remoteDto.toEntity();
    } catch (_) {
      if (cachedDto != null) {
        return cachedDto.toEntity();
      }
      rethrow;
    }
  }

  @override
  Future<CollectionScrobbleResult> scrobbleIssueRead({
    required int issueId,
    DateTime? dateRead,
    int? rating,
  }) async {
    final remoteDto = await _remoteDataSource.scrobbleIssueRead(
      issueId: issueId,
      dateRead: dateRead,
      rating: rating,
    );
    return remoteDto.toEntity();
  }

  @override
  Future<MissingSeriesPage> getMissingSeries({
    int page = 1,
    bool forceRefresh = false,
  }) async {
    final cachedPage = await _localDataSource.getMissingSeriesPage(page);
    final cachedAt = await _localDataSource.getMissingSeriesPageCachedAt(page);

    if (!forceRefresh && cachedPage != null) {
      final isFresh = cachedAt != null &&
          MetronCachePolicies.missingSeries.isFresh(cachedAt, _now());
      if (isFresh) {
        return MissingSeriesPage(
          count: cachedPage.count,
          next: cachedPage.next,
          previous: cachedPage.previous,
          results: cachedPage.results.map((entry) => entry.toEntity()).toList(),
          currentPage: page,
        );
      }
    }

    try {
      final remotePage = await _remoteDataSource.getMissingSeries(page: page);
      await _localDataSource.cacheMissingSeriesPage(page, remotePage);
      return MissingSeriesPage(
        count: remotePage.count,
        next: remotePage.next,
        previous: remotePage.previous,
        results: remotePage.results.map((entry) => entry.toEntity()).toList(),
        currentPage: page,
      );
    } catch (_) {
      if (cachedPage != null) {
        return MissingSeriesPage(
          count: cachedPage.count,
          next: cachedPage.next,
          previous: cachedPage.previous,
          results: cachedPage.results.map((entry) => entry.toEntity()).toList(),
          currentPage: page,
        );
      }
      rethrow;
    }
  }

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
  Future<IssueSearchPage> searchIssues(
    String query, {
    int page = 1,
    bool forceRefresh = false,
  }) async {
    final cachedDtos = await _localDataSource.getIssueSearchResults(
      query,
      page: page,
    );
    final cachedAt = await _localDataSource.getIssueSearchResultsCachedAt(
      query,
      page: page,
    );
    final cachedMeta = await _localDataSource.getIssueSearchResultsMeta(
      query,
      page: page,
    );

    if (!forceRefresh && cachedDtos != null && cachedDtos.isNotEmpty) {
      final isFresh = cachedAt != null &&
          MetronCachePolicies.searchResults.isFresh(cachedAt, _now());
      if (isFresh && cachedMeta != null) {
        return IssueSearchPage(
          count: cachedMeta.count,
          next: cachedMeta.next,
          previous: cachedMeta.previous,
          results: cachedDtos.map((entry) => entry.toEntity()).toList(),
          currentPage: page,
        );
      }
    }

    try {
      final remotePage = await _remoteDataSource.searchIssues(query, page: page);
      await _localDataSource.cacheIssueSearchResults(
        query,
        remotePage.results,
        page: page,
        count: remotePage.count,
        next: remotePage.next,
        previous: remotePage.previous,
      );
      return IssueSearchPage(
        count: remotePage.count,
        next: remotePage.next,
        previous: remotePage.previous,
        results: remotePage.results.map((entry) => entry.toEntity()).toList(),
        currentPage: page,
      );
    } catch (_) {
      if (cachedDtos != null && cachedDtos.isNotEmpty && cachedMeta != null) {
        return IssueSearchPage(
          count: cachedMeta.count,
          next: cachedMeta.next,
          previous: cachedMeta.previous,
          results: cachedDtos.map((entry) => entry.toEntity()).toList(),
          currentPage: page,
        );
      }
      rethrow;
    }
  }

  @override
  Future<SeriesSearchPage> searchSeries(
    String query, {
    int page = 1,
    bool forceRefresh = false,
  }) async {
    final cachedDtos = await _localDataSource.getSeriesSearchResults(
      query,
      page: page,
    );
    final cachedAt = await _localDataSource.getSeriesSearchResultsCachedAt(
      query,
      page: page,
    );
    final cachedMeta = await _localDataSource.getSeriesSearchResultsMeta(
      query,
      page: page,
    );

    if (!forceRefresh && cachedDtos != null && cachedDtos.isNotEmpty) {
      final isFresh = cachedAt != null &&
          MetronCachePolicies.searchResults.isFresh(cachedAt, _now());
      if (isFresh && cachedMeta != null) {
        return SeriesSearchPage(
          count: cachedMeta.count,
          next: cachedMeta.next,
          previous: cachedMeta.previous,
          results: cachedDtos.map((entry) => entry.toEntity()).toList(),
          currentPage: page,
        );
      }
    }

    try {
      final remotePage = await _remoteDataSource.searchSeries(query, page: page);
      await _localDataSource.cacheSeriesSearchResults(
        query,
        remotePage.results,
        page: page,
        count: remotePage.count,
        next: remotePage.next,
        previous: remotePage.previous,
      );
      return SeriesSearchPage(
        count: remotePage.count,
        next: remotePage.next,
        previous: remotePage.previous,
        results: remotePage.results.map((entry) => entry.toEntity()).toList(),
        currentPage: page,
      );
    } catch (_) {
      if (cachedDtos != null && cachedDtos.isNotEmpty && cachedMeta != null) {
        return SeriesSearchPage(
          count: cachedMeta.count,
          next: cachedMeta.next,
          previous: cachedMeta.previous,
          results: cachedDtos.map((entry) => entry.toEntity()).toList(),
          currentPage: page,
        );
      }
      rethrow;
    }
  }

  @override
  Future<SeriesListPage> getSeriesList({
    int page = 1,
    bool forceRefresh = false,
  }) async {
    final cachedDtos = await _localDataSource.getSeriesListResults(page: page);
    final cachedAt = await _localDataSource.getSeriesListResultsCachedAt(
      page: page,
    );
    final cachedMeta = await _localDataSource.getSeriesListResultsMeta(
      page: page,
    );

    if (!forceRefresh && cachedDtos != null && cachedDtos.isNotEmpty) {
      final isFresh = cachedAt != null &&
          MetronCachePolicies.searchResults.isFresh(cachedAt, _now());
      if (isFresh && cachedMeta != null) {
        return SeriesListPage(
          count: cachedMeta.count,
          next: cachedMeta.next,
          previous: cachedMeta.previous,
          results: cachedDtos.map((entry) => entry.toEntity()).toList(),
          currentPage: page,
        );
      }
    }

    try {
      final remotePage = await _remoteDataSource.getSeriesList(page: page);
      await _localDataSource.cacheSeriesListResults(
        remotePage.results,
        page: page,
        count: remotePage.count,
        next: remotePage.next,
        previous: remotePage.previous,
      );
      return SeriesListPage(
        count: remotePage.count,
        next: remotePage.next,
        previous: remotePage.previous,
        results: remotePage.results.map((entry) => entry.toEntity()).toList(),
        currentPage: page,
      );
    } catch (_) {
      if (cachedDtos != null && cachedDtos.isNotEmpty && cachedMeta != null) {
        return SeriesListPage(
          count: cachedMeta.count,
          next: cachedMeta.next,
          previous: cachedMeta.previous,
          results: cachedDtos.map((entry) => entry.toEntity()).toList(),
          currentPage: page,
        );
      }
      rethrow;
    }
  }

  @override
  Future<SeriesDetails> getSeriesDetails(
    int seriesId, {
    bool forceRefresh = false,
  }) async {
    final cachedDto = await _localDataSource.getSeriesDetails(seriesId);
    final cachedAt = await _localDataSource.getSeriesDetailsCachedAt(seriesId);

    if (!forceRefresh && cachedDto != null) {
      final isFresh = cachedAt != null &&
          MetronCachePolicies.seriesDetails.isFresh(cachedAt, _now());
      if (isFresh) {
        return cachedDto.toEntity();
      }
    }

    try {
      final remoteDto = await _remoteDataSource.getSeriesDetails(seriesId);
      await _localDataSource.cacheSeriesDetails(remoteDto);
      return remoteDto.toEntity();
    } catch (_) {
      if (cachedDto != null) {
        return cachedDto.toEntity();
      }
      rethrow;
    }
  }

  @override
  Future<SeriesIssueListPage> getSeriesIssueList(
    int seriesId, {
    int page = 1,
    bool forceRefresh = false,
  }) async {
    final cachedDtos = await _localDataSource.getSeriesIssueListResults(
      seriesId,
      page: page,
    );
    final cachedAt = await _localDataSource.getSeriesIssueListResultsCachedAt(
      seriesId,
      page: page,
    );
    final cachedMeta = await _localDataSource.getSeriesIssueListResultsMeta(
      seriesId,
      page: page,
    );

    if (!forceRefresh && cachedDtos != null && cachedDtos.isNotEmpty) {
      final isFresh = cachedAt != null &&
          MetronCachePolicies.seriesIssueList.isFresh(cachedAt, _now());
      if (isFresh && cachedMeta != null) {
        return SeriesIssueListPage(
          count: cachedMeta.count,
          next: cachedMeta.next,
          previous: cachedMeta.previous,
          results: cachedDtos.map((entry) => entry.toEntity()).toList(),
          currentPage: page,
        );
      }
    }

    try {
      final remotePage = await _remoteDataSource.getSeriesIssueList(
        seriesId,
        page: page,
      );
      await _localDataSource.cacheSeriesIssueListResults(
        seriesId,
        remotePage.results,
        page: page,
        count: remotePage.count,
        next: remotePage.next,
        previous: remotePage.previous,
      );
      return SeriesIssueListPage(
        count: remotePage.count,
        next: remotePage.next,
        previous: remotePage.previous,
        results: remotePage.results.map((entry) => entry.toEntity()).toList(),
        currentPage: page,
      );
    } catch (_) {
      if (cachedDtos != null && cachedDtos.isNotEmpty && cachedMeta != null) {
        return SeriesIssueListPage(
          count: cachedMeta.count,
          next: cachedMeta.next,
          previous: cachedMeta.previous,
          results: cachedDtos.map((entry) => entry.toEntity()).toList(),
          currentPage: page,
        );
      }
      rethrow;
    }
  }

}
