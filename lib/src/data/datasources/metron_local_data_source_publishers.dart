part of 'metron_local_data_source.dart';

mixin _PublishersDataSourceMixin on _DataSourceState {
  Future<void> cachePublisherSearchResults(
    String query,
    List<PublisherListDto> publishers, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  }) async {
    final searchKey = _getPublisherSearchKey(query, page, limit);
    final box = await _getBox<List>(_publisherSearchBox);
    await box.put(searchKey, publishers.map((entry) => entry.toJson()).toList());

    final searchMetaBox = await _getBox<Map>(_publisherSearchMetaBox);
    await searchMetaBox.put(searchKey, {
      'count': count,
      'next': next,
      'previous': previous,
    });

    final metaBox = await _getBox<int>(_cacheMetaBox);
    await metaBox.put(
      _getPublisherSearchMetaKey(query, page, limit),
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<List<PublisherListDto>?> getPublisherSearchResults(
    String query, {
    required int page,
    required int limit,
  }) async {
    final searchKey = _getPublisherSearchKey(query, page, limit);
    final box = await _getBox<List>(_publisherSearchBox);
    final rawData = box.get(searchKey);
    if (rawData != null) {
      return rawData
          .whereType<Map>()
          .map((entry) => entry.cast<String, dynamic>())
          .map(PublisherListDto.fromJson)
          .toList();
    }
    return null;
  }

  Future<DateTime?> getPublisherSearchResultsCachedAt(
    String query, {
    required int page,
    required int limit,
  }) async {
    final metaBox = await _getBox<int>(_cacheMetaBox);
    final epoch = metaBox.get(_getPublisherSearchMetaKey(query, page, limit));
    if (epoch == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(epoch);
  }

  Future<PublisherSearchPageCacheMeta?> getPublisherSearchResultsMeta(
    String query, {
    required int page,
    required int limit,
  }) async {
    final searchKey = _getPublisherSearchKey(query, page, limit);
    final box = await _getBox<Map>(_publisherSearchMetaBox);
    final data = box.get(searchKey);
    if (data == null) return null;

    final count = (data['count'] as num?)?.toInt();
    if (count == null) return null;

    return PublisherSearchPageCacheMeta(
      count: count,
      next: data['next'] as String?,
      previous: data['previous'] as String?,
    );
  }

  Future<void> cachePublisherDetails(PublisherDetailsDto details) async {
    final box = await _getBox<Map>(_publisherDetailsBox);
    await box.put(details.id, details.toJson());

    final metaBox = await _getBox<int>(_cacheMetaBox);
    await metaBox.put(
      _getPublisherDetailsMetaKey(details.id),
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<PublisherDetailsDto?> getPublisherDetails(int publisherId) async {
    final box = await _getBox<Map>(_publisherDetailsBox);
    final data = box.get(publisherId);
    if (data == null) return null;
    return PublisherDetailsDto.fromJson(data.cast<String, dynamic>());
  }

  Future<DateTime?> getPublisherDetailsCachedAt(int publisherId) async {
    final metaBox = await _getBox<int>(_cacheMetaBox);
    final epoch = metaBox.get(_getPublisherDetailsMetaKey(publisherId));
    if (epoch == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(epoch);
  }

  Future<void> cachePublisherSeriesListResults(
    int publisherId,
    List<SeriesListDto> series, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  }) async {
    final searchKey = _getPublisherSeriesListKey(publisherId, page, limit);
    final box = await _getBox<List>(_publisherSeriesListBox);
    await box.put(searchKey, series.map((entry) => entry.toJson()).toList());

    final searchMetaBox = await _getBox<Map>(_publisherSeriesListMetaBox);
    await searchMetaBox.put(searchKey, {
      'count': count,
      'next': next,
      'previous': previous,
    });

    final metaBox = await _getBox<int>(_cacheMetaBox);
    await metaBox.put(
      _getPublisherSeriesListMetaKey(publisherId, page, limit),
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<List<SeriesListDto>?> getPublisherSeriesListResults(
    int publisherId, {
    required int page,
    required int limit,
  }) async {
    final searchKey = _getPublisherSeriesListKey(publisherId, page, limit);
    final box = await _getBox<List>(_publisherSeriesListBox);
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

  Future<DateTime?> getPublisherSeriesListResultsCachedAt(
    int publisherId, {
    required int page,
    required int limit,
  }) async {
    final metaBox = await _getBox<int>(_cacheMetaBox);
    final epoch = metaBox.get(_getPublisherSeriesListMetaKey(publisherId, page, limit));
    if (epoch == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(epoch);
  }

  Future<SeriesIssueListPageCacheMeta?> getPublisherSeriesListResultsMeta(
    int publisherId, {
    required int page,
    required int limit,
  }) async {
    final searchKey = _getPublisherSeriesListKey(publisherId, page, limit);
    final box = await _getBox<Map>(_publisherSeriesListMetaBox);
    final data = box.get(searchKey);
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
