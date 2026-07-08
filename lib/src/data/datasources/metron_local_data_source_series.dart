part of 'metron_local_data_source.dart';

mixin _SeriesDataSourceMixin on _DataSourceState {
  Future<void> cacheSeriesSearchResults(
    String query,
    List<SeriesListDto> series, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  }) async {
    final searchKey = _getSeriesSearchKey(query, page, limit);
    final box = await _getBox<List>(_seriesSearchBox);
    await box.put(searchKey, series.map((entry) => entry.toJson()).toList());

    final searchMetaBox = await _getBox<Map>(_seriesSearchMetaBox);
    await searchMetaBox.put(searchKey, {
      'count': count,
      'next': next,
      'previous': previous,
    });

    final metaBox = await _getBox<int>(_cacheMetaBox);
    await metaBox.put(
      _getSeriesSearchMetaKey(query, page, limit),
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<List<SeriesListDto>?> getSeriesSearchResults(
    String query, {
    required int page,
    required int limit,
  }) async {
    final searchKey = _getSeriesSearchKey(query, page, limit);
    final box = await _getBox<List>(_seriesSearchBox);
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

  Future<DateTime?> getSeriesSearchResultsCachedAt(
    String query, {
    required int page,
    required int limit,
  }) async {
    final metaBox = await _getBox<int>(_cacheMetaBox);
    final epoch = metaBox.get(_getSeriesSearchMetaKey(query, page, limit));
    if (epoch == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(epoch);
  }

  Future<SeriesSearchPageCacheMeta?> getSeriesSearchResultsMeta(
    String query, {
    required int page,
    required int limit,
  }) async {
    final searchKey = _getSeriesSearchKey(query, page, limit);
    final box = await _getBox<Map>(_seriesSearchMetaBox);
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

  Future<void> cacheSeriesListResults(
    List<SeriesListDto> series, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  }) async {
    final key = _getSeriesListKey(page, limit);
    final box = await _getBox<List>(_seriesListBox);
    await box.put(key, series.map((entry) => entry.toJson()).toList());

    final metaBox = await _getBox<Map>(_seriesListMetaBox);
    await metaBox.put(key, {
      'count': count,
      'next': next,
      'previous': previous,
    });

    final cacheMetaBox = await _getBox<int>(_cacheMetaBox);
    await cacheMetaBox.put(
      _getSeriesListMetaKey(page, limit),
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<List<SeriesListDto>?> getSeriesListResults({
    required int page,
    required int limit,
  }) async {
    final key = _getSeriesListKey(page, limit);
    final box = await _getBox<List>(_seriesListBox);
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

  Future<DateTime?> getSeriesListResultsCachedAt({
    required int page,
    required int limit,
  }) async {
    final cacheMetaBox = await _getBox<int>(_cacheMetaBox);
    final epoch = cacheMetaBox.get(_getSeriesListMetaKey(page, limit));
    if (epoch == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(epoch);
  }

  Future<SeriesListPageCacheMeta?> getSeriesListResultsMeta({
    required int page,
    required int limit,
  }) async {
    final key = _getSeriesListKey(page, limit);
    final box = await _getBox<Map>(_seriesListMetaBox);
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

  Future<void> cacheSeriesDetails(SeriesDetailsDto details) async {
    final box = await _getBox<Map>(_seriesDetailsBox);
    await box.put(details.id, details.toJson());

    final metaBox = await _getBox<int>(_cacheMetaBox);
    await metaBox.put(
      _getSeriesDetailsMetaKey(details.id),
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<SeriesDetailsDto?> getSeriesDetails(int seriesId) async {
    final box = await _getBox<Map>(_seriesDetailsBox);
    final data = box.get(seriesId);
    if (data == null) return null;
    return SeriesDetailsDto.fromJson(data.cast<String, dynamic>());
  }

  Future<DateTime?> getSeriesDetailsCachedAt(int seriesId) async {
    final metaBox = await _getBox<int>(_cacheMetaBox);
    final epoch = metaBox.get(_getSeriesDetailsMetaKey(seriesId));
    if (epoch == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(epoch);
  }

  Future<void> cacheSeriesIssueListResults(
    int seriesId,
    List<IssueListDto> issues, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  }) async {
    final key = _getSeriesIssueListKey(seriesId, page, limit);
    final box = await _getBox<List>(_seriesIssueListBox);
    await box.put(key, issues);

    final metaBox = await _getBox<Map>(_seriesIssueListMetaBox);
    await metaBox.put(key, {
      'count': count,
      'next': next,
      'previous': previous,
    });

    final cacheMetaBox = await _getBox<int>(_cacheMetaBox);
    await cacheMetaBox.put(
      _getSeriesIssueListMetaKey(seriesId, page, limit),
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<List<IssueListDto>?> getSeriesIssueListResults(
    int seriesId, {
    required int page,
    required int limit,
  }) async {
    final key = _getSeriesIssueListKey(seriesId, page, limit);
    final box = await _getBox<List>(_seriesIssueListBox);
    final data = box.get(key);
    if (data != null) {
      return data.cast<IssueListDto>();
    }
    return null;
  }

  Future<DateTime?> getSeriesIssueListResultsCachedAt(
    int seriesId, {
    required int page,
    required int limit,
  }) async {
    final cacheMetaBox = await _getBox<int>(_cacheMetaBox);
    final epoch = cacheMetaBox.get(
      _getSeriesIssueListMetaKey(seriesId, page, limit),
    );
    if (epoch == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(epoch);
  }

  Future<SeriesIssueListPageCacheMeta?> getSeriesIssueListResultsMeta(
    int seriesId, {
    required int page,
    required int limit,
  }) async {
    final key = _getSeriesIssueListKey(seriesId, page, limit);
    final box = await _getBox<Map>(_seriesIssueListMetaBox);
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
