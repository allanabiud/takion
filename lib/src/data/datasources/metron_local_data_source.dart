import 'package:takion/src/core/storage/hive_service.dart';
import 'package:takion/src/data/models/collection_item_details_dto.dart';
import 'package:takion/src/data/models/collection_items_response_dto.dart';
import 'package:takion/src/data/models/collection_stats_dto.dart';
import 'package:takion/src/data/models/issue_details_dto.dart';
import 'package:takion/src/data/models/issue_list_dto.dart';
import 'package:takion/src/data/models/missing_series_response_dto.dart';
import 'package:takion/src/data/models/series_details_dto.dart';
import 'package:takion/src/data/models/series_list_dto.dart';

class IssueSearchPageCacheMeta {
  const IssueSearchPageCacheMeta({
    required this.count,
    this.next,
    this.previous,
  });

  final int count;
  final String? next;
  final String? previous;
}

class SeriesSearchPageCacheMeta {
  const SeriesSearchPageCacheMeta({
    required this.count,
    this.next,
    this.previous,
  });

  final int count;
  final String? next;
  final String? previous;
}

class SeriesListPageCacheMeta {
  const SeriesListPageCacheMeta({
    required this.count,
    this.next,
    this.previous,
  });

  final int count;
  final String? next;
  final String? previous;
}

class SeriesIssueListPageCacheMeta {
  const SeriesIssueListPageCacheMeta({
    required this.count,
    this.next,
    this.previous,
  });

  final int count;
  final String? next;
  final String? previous;
}

abstract class MetronLocalDataSource {
  Future<void> cacheCollectionStats(CollectionStatsDto stats);
  Future<CollectionStatsDto?> getCollectionStats();
  Future<DateTime?> getCollectionStatsCachedAt();
  Future<void> cacheCollectionItemsPage(int page, CollectionItemsResponseDto response);
  Future<CollectionItemsResponseDto?> getCollectionItemsPage(int page);
  Future<DateTime?> getCollectionItemsPageCachedAt(int page);
  Future<void> cacheCollectionItemDetails(CollectionItemDetailsDto details);
  Future<CollectionItemDetailsDto?> getCollectionItemDetails(int collectionId);
  Future<DateTime?> getCollectionItemDetailsCachedAt(int collectionId);
  Future<void> cacheMissingSeriesPage(int page, MissingSeriesResponseDto response);
  Future<MissingSeriesResponseDto?> getMissingSeriesPage(int page);
  Future<DateTime?> getMissingSeriesPageCachedAt(int page);

  Future<void> cacheWeeklyReleases(DateTime weekStart, List<IssueListDto> issues);
  Future<List<IssueListDto>?> getWeeklyReleases(DateTime weekStart);
  Future<DateTime?> getWeeklyReleasesCachedAt(DateTime weekStart);
  Future<void> cacheIssueDetails(IssueDetailsDto issue);
  Future<IssueDetailsDto?> getIssueDetails(int issueId);
  Future<DateTime?> getIssueDetailsCachedAt(int issueId);
  Future<void> cacheIssueSearchResults(
    String query,
    List<IssueListDto> issues, {
    required int page,
    required int count,
    String? next,
    String? previous,
  });
  Future<List<IssueListDto>?> getIssueSearchResults(String query, {required int page});
  Future<DateTime?> getIssueSearchResultsCachedAt(String query, {required int page});
  Future<IssueSearchPageCacheMeta?> getIssueSearchResultsMeta(
    String query, {
    required int page,
  });
  Future<void> cacheSeriesSearchResults(
    String query,
    List<SeriesListDto> series, {
    required int page,
    required int count,
    String? next,
    String? previous,
  });
  Future<List<SeriesListDto>?> getSeriesSearchResults(
    String query, {
    required int page,
  });
  Future<DateTime?> getSeriesSearchResultsCachedAt(String query, {required int page});
  Future<SeriesSearchPageCacheMeta?> getSeriesSearchResultsMeta(
    String query, {
    required int page,
  });
  Future<void> cacheSeriesListResults(
    List<SeriesListDto> series, {
    required int page,
    required int count,
    String? next,
    String? previous,
  });
  Future<List<SeriesListDto>?> getSeriesListResults({required int page});
  Future<DateTime?> getSeriesListResultsCachedAt({required int page});
  Future<SeriesListPageCacheMeta?> getSeriesListResultsMeta({required int page});
  Future<void> cacheSeriesDetails(SeriesDetailsDto details);
  Future<SeriesDetailsDto?> getSeriesDetails(int seriesId);
  Future<DateTime?> getSeriesDetailsCachedAt(int seriesId);
  Future<void> cacheSeriesIssueListResults(
    int seriesId,
    List<IssueListDto> issues, {
    required int page,
    required int count,
    String? next,
    String? previous,
  });
  Future<List<IssueListDto>?> getSeriesIssueListResults(
    int seriesId, {
    required int page,
  });
  Future<DateTime?> getSeriesIssueListResultsCachedAt(
    int seriesId, {
    required int page,
  });
  Future<SeriesIssueListPageCacheMeta?> getSeriesIssueListResultsMeta(
    int seriesId, {
    required int page,
  });
}

class MetronLocalDataSourceImpl implements MetronLocalDataSource {
  final HiveService _hiveService;
  static const String _weeklyBox = 'weekly_releases_box';
  static const String _issueDetailsBox = 'issue_details_box';
  static const String _issueSearchBox = 'issue_search_box';
  static const String _issueSearchMetaBox = 'issue_search_meta_box';
  static const String _seriesSearchBox = 'series_search_box';
  static const String _seriesSearchMetaBox = 'series_search_meta_box';
  static const String _seriesListBox = 'series_list_box';
  static const String _seriesListMetaBox = 'series_list_meta_box';
  static const String _seriesDetailsBox = 'series_details_box';
  static const String _seriesIssueListBox = 'series_issue_list_box';
  static const String _seriesIssueListMetaBox = 'series_issue_list_meta_box';
  static const String _collectionStatsBox = 'collection_stats_box';
  static const String _collectionItemsBox = 'collection_items_box';
  static const String _collectionItemDetailsBox = 'collection_item_details_box';
  static const String _missingSeriesBox = 'missing_series_box';
  static const String _cacheMetaBox = 'cache_meta_box';

  MetronLocalDataSourceImpl(this._hiveService);

  String _getWeekKey(DateTime date) {
    // Standardize to Sunday start
    final offset = date.weekday % 7;
    final sunday = DateTime(date.year, date.month, date.day).subtract(Duration(days: offset));
    return "${sunday.year}-${sunday.month}-${sunday.day}";
  }

  String _getMetaKey(String key) => 'weekly_releases:$key';
  String _getCollectionStatsMetaKey() => 'collection_stats:singleton';
  String _getCollectionItemsMetaKey(int page) => 'collection_items:p$page';
  String _getCollectionItemDetailsMetaKey(int collectionId) =>
      'collection_item_details:$collectionId';
  String _getMissingSeriesMetaKey(int page) => 'missing_series:p$page';
  String _getIssueDetailsMetaKey(int issueId) => 'issue_details:$issueId';
  String _getSeriesDetailsMetaKey(int seriesId) => 'series_details:$seriesId';
  String _normalizeSearchQuery(String query) => query.trim().toLowerCase();
    String _getIssueSearchKey(String query, int page) =>
      '${_normalizeSearchQuery(query)}::p$page';
    String _getIssueSearchMetaKey(String query, int page) =>
      'issue_search:${_getIssueSearchKey(query, page)}';
      String _getSeriesSearchKey(String query, int page) =>
        '${_normalizeSearchQuery(query)}::p$page';
      String _getSeriesSearchMetaKey(String query, int page) =>
        'series_search:${_getSeriesSearchKey(query, page)}';
  String _getSeriesListKey(int page) => 'series_list:p$page';
  String _getSeriesListMetaKey(int page) => 'series_list:${_getSeriesListKey(page)}';
    String _getSeriesIssueListKey(int seriesId, int page) =>
      'series_issue_list:$seriesId:p$page';
    String _getSeriesIssueListMetaKey(int seriesId, int page) =>
      'series_issue_list:${_getSeriesIssueListKey(seriesId, page)}';

    @override
    Future<void> cacheCollectionStats(CollectionStatsDto stats) async {
      final box = await _hiveService.openBox<Map>(_collectionStatsBox);
      await box.put('singleton', stats.toJson());

      final metaBox = await _hiveService.openBox<int>(_cacheMetaBox);
      await metaBox.put(
        _getCollectionStatsMetaKey(),
        DateTime.now().millisecondsSinceEpoch,
      );
    }

    @override
    Future<CollectionStatsDto?> getCollectionStats() async {
      final box = await _hiveService.openBox<Map>(_collectionStatsBox);
      final data = box.get('singleton');
      if (data == null) return null;
      return CollectionStatsDto.fromJson(data.cast<String, dynamic>());
    }

    @override
    Future<DateTime?> getCollectionStatsCachedAt() async {
      final metaBox = await _hiveService.openBox<int>(_cacheMetaBox);
      final epoch = metaBox.get(_getCollectionStatsMetaKey());
      if (epoch == null) return null;
      return DateTime.fromMillisecondsSinceEpoch(epoch);
    }

    @override
    Future<void> cacheCollectionItemsPage(
      int page,
      CollectionItemsResponseDto response,
    ) async {
      final box = await _hiveService.openBox<Map>(_collectionItemsBox);
      await box.put('p$page', response.toJson());

      final metaBox = await _hiveService.openBox<int>(_cacheMetaBox);
      await metaBox.put(
        _getCollectionItemsMetaKey(page),
        DateTime.now().millisecondsSinceEpoch,
      );
    }

    @override
    Future<CollectionItemsResponseDto?> getCollectionItemsPage(int page) async {
      final box = await _hiveService.openBox<Map>(_collectionItemsBox);
      final data = box.get('p$page');
      if (data == null) return null;
      return CollectionItemsResponseDto.fromJson(data.cast<String, dynamic>());
    }

    @override
    Future<DateTime?> getCollectionItemsPageCachedAt(int page) async {
      final metaBox = await _hiveService.openBox<int>(_cacheMetaBox);
      final epoch = metaBox.get(_getCollectionItemsMetaKey(page));
      if (epoch == null) return null;
      return DateTime.fromMillisecondsSinceEpoch(epoch);
    }

    @override
    Future<void> cacheCollectionItemDetails(CollectionItemDetailsDto details) async {
      final box = await _hiveService.openBox<Map>(_collectionItemDetailsBox);
      await box.put(details.id, details.toJson());

      final metaBox = await _hiveService.openBox<int>(_cacheMetaBox);
      await metaBox.put(
        _getCollectionItemDetailsMetaKey(details.id),
        DateTime.now().millisecondsSinceEpoch,
      );
    }

    @override
    Future<CollectionItemDetailsDto?> getCollectionItemDetails(
      int collectionId,
    ) async {
      final box = await _hiveService.openBox<Map>(_collectionItemDetailsBox);
      final data = box.get(collectionId);
      if (data == null) return null;
      return CollectionItemDetailsDto.fromJson(data.cast<String, dynamic>());
    }

    @override
    Future<DateTime?> getCollectionItemDetailsCachedAt(int collectionId) async {
      final metaBox = await _hiveService.openBox<int>(_cacheMetaBox);
      final epoch = metaBox.get(_getCollectionItemDetailsMetaKey(collectionId));
      if (epoch == null) return null;
      return DateTime.fromMillisecondsSinceEpoch(epoch);
    }

    @override
    Future<void> cacheMissingSeriesPage(
      int page,
      MissingSeriesResponseDto response,
    ) async {
      final box = await _hiveService.openBox<Map>(_missingSeriesBox);
      await box.put('p$page', response.toJson());

      final metaBox = await _hiveService.openBox<int>(_cacheMetaBox);
      await metaBox.put(
        _getMissingSeriesMetaKey(page),
        DateTime.now().millisecondsSinceEpoch,
      );
    }

    @override
    Future<MissingSeriesResponseDto?> getMissingSeriesPage(int page) async {
      final box = await _hiveService.openBox<Map>(_missingSeriesBox);
      final data = box.get('p$page');
      if (data == null) return null;
      return MissingSeriesResponseDto.fromJson(data.cast<String, dynamic>());
    }

    @override
    Future<DateTime?> getMissingSeriesPageCachedAt(int page) async {
      final metaBox = await _hiveService.openBox<int>(_cacheMetaBox);
      final epoch = metaBox.get(_getMissingSeriesMetaKey(page));
      if (epoch == null) return null;
      return DateTime.fromMillisecondsSinceEpoch(epoch);
    }

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

  @override
  Future<void> cacheIssueSearchResults(
    String query,
    List<IssueListDto> issues, {
    required int page,
    required int count,
    String? next,
    String? previous,
  }) async {
    final searchKey = _getIssueSearchKey(query, page);
    final box = await _hiveService.openBox<List>(_issueSearchBox);
    await box.put(searchKey, issues);

    final searchMetaBox = await _hiveService.openBox<Map>(_issueSearchMetaBox);
    await searchMetaBox.put(searchKey, {
      'count': count,
      'next': next,
      'previous': previous,
    });

    final metaBox = await _hiveService.openBox<int>(_cacheMetaBox);
    await metaBox.put(
      _getIssueSearchMetaKey(query, page),
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  Future<List<IssueListDto>?> getIssueSearchResults(
    String query, {
    required int page,
  }) async {
    final searchKey = _getIssueSearchKey(query, page);
    final box = await _hiveService.openBox<List>(_issueSearchBox);
    final data = box.get(searchKey);
    if (data != null) {
      return data.cast<IssueListDto>();
    }
    return null;
  }

  @override
  Future<DateTime?> getIssueSearchResultsCachedAt(
    String query, {
    required int page,
  }) async {
    final metaBox = await _hiveService.openBox<int>(_cacheMetaBox);
    final epoch = metaBox.get(_getIssueSearchMetaKey(query, page));
    if (epoch == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(epoch);
  }

  @override
  Future<IssueSearchPageCacheMeta?> getIssueSearchResultsMeta(
    String query, {
    required int page,
  }) async {
    final searchKey = _getIssueSearchKey(query, page);
    final box = await _hiveService.openBox<Map>(_issueSearchMetaBox);
    final data = box.get(searchKey);
    if (data == null) return null;

    final count = (data['count'] as num?)?.toInt();
    if (count == null) return null;

    return IssueSearchPageCacheMeta(
      count: count,
      next: data['next'] as String?,
      previous: data['previous'] as String?,
    );
  }

  @override
  Future<void> cacheSeriesSearchResults(
    String query,
    List<SeriesListDto> series, {
    required int page,
    required int count,
    String? next,
    String? previous,
  }) async {
    final searchKey = _getSeriesSearchKey(query, page);
    final box = await _hiveService.openBox<List>(_seriesSearchBox);
    await box.put(searchKey, series.map((entry) => entry.toJson()).toList());

    final searchMetaBox = await _hiveService.openBox<Map>(_seriesSearchMetaBox);
    await searchMetaBox.put(searchKey, {
      'count': count,
      'next': next,
      'previous': previous,
    });

    final metaBox = await _hiveService.openBox<int>(_cacheMetaBox);
    await metaBox.put(
      _getSeriesSearchMetaKey(query, page),
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  Future<List<SeriesListDto>?> getSeriesSearchResults(
    String query, {
    required int page,
  }) async {
    final searchKey = _getSeriesSearchKey(query, page);
    final box = await _hiveService.openBox<List>(_seriesSearchBox);
    final rawData = box.get(searchKey);
    if (rawData != null) {
      return rawData
          .whereType<Map>()
          .map((entry) => entry.cast<String, dynamic>())
          .map(SeriesListDto.fromJson)
          .toList();
    }
    return null;
  }

  @override
  Future<DateTime?> getSeriesSearchResultsCachedAt(
    String query, {
    required int page,
  }) async {
    final metaBox = await _hiveService.openBox<int>(_cacheMetaBox);
    final epoch = metaBox.get(_getSeriesSearchMetaKey(query, page));
    if (epoch == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(epoch);
  }

  @override
  Future<SeriesSearchPageCacheMeta?> getSeriesSearchResultsMeta(
    String query, {
    required int page,
  }) async {
    final searchKey = _getSeriesSearchKey(query, page);
    final box = await _hiveService.openBox<Map>(_seriesSearchMetaBox);
    final data = box.get(searchKey);
    if (data == null) return null;

    final count = (data['count'] as num?)?.toInt();
    if (count == null) return null;

    return SeriesSearchPageCacheMeta(
      count: count,
      next: data['next'] as String?,
      previous: data['previous'] as String?,
    );
  }

  @override
  Future<void> cacheSeriesListResults(
    List<SeriesListDto> series, {
    required int page,
    required int count,
    String? next,
    String? previous,
  }) async {
    final key = _getSeriesListKey(page);
    final box = await _hiveService.openBox<List>(_seriesListBox);
    await box.put(key, series.map((entry) => entry.toJson()).toList());

    final metaBox = await _hiveService.openBox<Map>(_seriesListMetaBox);
    await metaBox.put(key, {
      'count': count,
      'next': next,
      'previous': previous,
    });

    final cacheMetaBox = await _hiveService.openBox<int>(_cacheMetaBox);
    await cacheMetaBox.put(
      _getSeriesListMetaKey(page),
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  Future<List<SeriesListDto>?> getSeriesListResults({required int page}) async {
    final key = _getSeriesListKey(page);
    final box = await _hiveService.openBox<List>(_seriesListBox);
    final rawData = box.get(key);
    if (rawData != null) {
      return rawData
          .whereType<Map>()
          .map((entry) => entry.cast<String, dynamic>())
          .map(SeriesListDto.fromJson)
          .toList();
    }
    return null;
  }

  @override
  Future<DateTime?> getSeriesListResultsCachedAt({required int page}) async {
    final cacheMetaBox = await _hiveService.openBox<int>(_cacheMetaBox);
    final epoch = cacheMetaBox.get(_getSeriesListMetaKey(page));
    if (epoch == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(epoch);
  }

  @override
  Future<SeriesListPageCacheMeta?> getSeriesListResultsMeta({required int page}) async {
    final key = _getSeriesListKey(page);
    final box = await _hiveService.openBox<Map>(_seriesListMetaBox);
    final data = box.get(key);
    if (data == null) return null;

    final count = (data['count'] as num?)?.toInt();
    if (count == null) return null;

    return SeriesListPageCacheMeta(
      count: count,
      next: data['next'] as String?,
      previous: data['previous'] as String?,
    );
  }

  @override
  Future<void> cacheSeriesDetails(SeriesDetailsDto details) async {
    final box = await _hiveService.openBox<Map>(_seriesDetailsBox);
    await box.put(details.id, details.toJson());

    final metaBox = await _hiveService.openBox<int>(_cacheMetaBox);
    await metaBox.put(
      _getSeriesDetailsMetaKey(details.id),
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  Future<SeriesDetailsDto?> getSeriesDetails(int seriesId) async {
    final box = await _hiveService.openBox<Map>(_seriesDetailsBox);
    final data = box.get(seriesId);
    if (data == null) return null;
    return SeriesDetailsDto.fromJson(data.cast<String, dynamic>());
  }

  @override
  Future<DateTime?> getSeriesDetailsCachedAt(int seriesId) async {
    final metaBox = await _hiveService.openBox<int>(_cacheMetaBox);
    final epoch = metaBox.get(_getSeriesDetailsMetaKey(seriesId));
    if (epoch == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(epoch);
  }

  @override
  Future<void> cacheSeriesIssueListResults(
    int seriesId,
    List<IssueListDto> issues, {
    required int page,
    required int count,
    String? next,
    String? previous,
  }) async {
    final key = _getSeriesIssueListKey(seriesId, page);
    final box = await _hiveService.openBox<List>(_seriesIssueListBox);
    await box.put(key, issues);

    final metaBox = await _hiveService.openBox<Map>(_seriesIssueListMetaBox);
    await metaBox.put(key, {
      'count': count,
      'next': next,
      'previous': previous,
    });

    final cacheMetaBox = await _hiveService.openBox<int>(_cacheMetaBox);
    await cacheMetaBox.put(
      _getSeriesIssueListMetaKey(seriesId, page),
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  Future<List<IssueListDto>?> getSeriesIssueListResults(
    int seriesId, {
    required int page,
  }) async {
    final key = _getSeriesIssueListKey(seriesId, page);
    final box = await _hiveService.openBox<List>(_seriesIssueListBox);
    final data = box.get(key);
    if (data != null) {
      return data.cast<IssueListDto>();
    }
    return null;
  }

  @override
  Future<DateTime?> getSeriesIssueListResultsCachedAt(
    int seriesId, {
    required int page,
  }) async {
    final cacheMetaBox = await _hiveService.openBox<int>(_cacheMetaBox);
    final epoch = cacheMetaBox.get(_getSeriesIssueListMetaKey(seriesId, page));
    if (epoch == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(epoch);
  }

  @override
  Future<SeriesIssueListPageCacheMeta?> getSeriesIssueListResultsMeta(
    int seriesId, {
    required int page,
  }) async {
    final key = _getSeriesIssueListKey(seriesId, page);
    final box = await _hiveService.openBox<Map>(_seriesIssueListMetaBox);
    final data = box.get(key);
    if (data == null) return null;

    final count = (data['count'] as num?)?.toInt();
    if (count == null) return null;

    return SeriesIssueListPageCacheMeta(
      count: count,
      next: data['next'] as String?,
      previous: data['previous'] as String?,
    );
  }
}
