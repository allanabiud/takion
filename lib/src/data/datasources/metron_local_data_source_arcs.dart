part of 'metron_local_data_source.dart';

mixin _ArcsDataSourceMixin on _DataSourceState {
  Future<void> cacheArcSearchResults(
    String query,
    List<ArcListDto> arcs, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  }) async {
    final searchKey = _getArcSearchKey(query, page, limit);
    final box = await _getBox<List>(_arcSearchBox);
    await box.put(searchKey, arcs.map((entry) => entry.toJson()).toList());

    final searchMetaBox = await _getBox<Map>(_arcSearchMetaBox);
    await searchMetaBox.put(searchKey, {
      'count': count,
      'next': next,
      'previous': previous,
    });

    final metaBox = await _getBox<int>(_cacheMetaBox);
    await metaBox.put(
      _getArcSearchMetaKey(query, page, limit),
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<List<ArcListDto>?> getArcSearchResults(
    String query, {
    required int page,
    required int limit,
  }) async {
    final searchKey = _getArcSearchKey(query, page, limit);
    final box = await _getBox<List>(_arcSearchBox);
    final rawData = box.get(searchKey);
    if (rawData != null) {
      return rawData
          .whereType<Map>()
          .map((entry) => entry.cast<String, dynamic>())
          .map(ArcListDto.fromJson)
          .toList();
    }
    return null;
  }

  Future<DateTime?> getArcSearchResultsCachedAt(
    String query, {
    required int page,
    required int limit,
  }) async {
    final metaBox = await _getBox<int>(_cacheMetaBox);
    final epoch = metaBox.get(_getArcSearchMetaKey(query, page, limit));
    if (epoch == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(epoch);
  }

  Future<ArcSearchPageCacheMeta?> getArcSearchResultsMeta(
    String query, {
    required int page,
    required int limit,
  }) async {
    final searchKey = _getArcSearchKey(query, page, limit);
    final box = await _getBox<Map>(_arcSearchMetaBox);
    final data = box.get(searchKey);
    if (data == null) return null;

    final count = (data['count'] as num?)?.toInt();
    if (count == null) return null;

    return ArcSearchPageCacheMeta(
      count: count,
      next: data['next'] as String?,
      previous: data['previous'] as String?,
    );
  }

  Future<void> cacheArcDetails(ArcDetailsDto details) async {
    final box = await _getBox<Map>(_arcDetailsBox);
    await box.put(details.id, details.toJson());

    final metaBox = await _getBox<int>(_cacheMetaBox);
    await metaBox.put(
      _getArcDetailsMetaKey(details.id),
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<ArcDetailsDto?> getArcDetails(int arcId) async {
    final box = await _getBox<Map>(_arcDetailsBox);
    final data = box.get(arcId);
    if (data == null) return null;
    return ArcDetailsDto.fromJson(data.cast<String, dynamic>());
  }

  Future<DateTime?> getArcDetailsCachedAt(int arcId) async {
    final metaBox = await _getBox<int>(_cacheMetaBox);
    final epoch = metaBox.get(_getArcDetailsMetaKey(arcId));
    if (epoch == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(epoch);
  }

  Future<void> cacheArcIssueListResults(
    int arcId,
    List<IssueListDto> issues, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  }) async {
    final key = _getArcIssueListKey(arcId, page, limit);
    final box = await _getBox<List>(_arcIssueListBox);
    await box.put(key, issues);

    final metaBox = await _getBox<Map>(_arcIssueListMetaBox);
    await metaBox.put(key, {
      'count': count,
      'next': next,
      'previous': previous,
    });

    final cacheMetaBox = await _getBox<int>(_cacheMetaBox);
    await cacheMetaBox.put(
      _getArcIssueListMetaKey(arcId, page, limit),
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<List<IssueListDto>?> getArcIssueListResults(
    int arcId, {
    required int page,
    required int limit,
  }) async {
    final key = _getArcIssueListKey(arcId, page, limit);
    final box = await _getBox<List>(_arcIssueListBox);
    final data = box.get(key);
    if (data != null) {
      return data.cast<IssueListDto>();
    }
    return null;
  }

  Future<DateTime?> getArcIssueListResultsCachedAt(
    int arcId, {
    required int page,
    required int limit,
  }) async {
    final cacheMetaBox = await _getBox<int>(_cacheMetaBox);
    final epoch = cacheMetaBox.get(
      _getArcIssueListMetaKey(arcId, page, limit),
    );
    if (epoch == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(epoch);
  }

  Future<SeriesIssueListPageCacheMeta?> getArcIssueListResultsMeta(
    int arcId, {
    required int page,
    required int limit,
  }) async {
    final key = _getArcIssueListKey(arcId, page, limit);
    final box = await _getBox<Map>(_arcIssueListMetaBox);
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
