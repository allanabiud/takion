part of 'metron_local_data_source.dart';

mixin _ImprintsDataSourceMixin on _DataSourceState {
  Future<void> cacheImprintSearchResults(
    String query,
    List<ImprintListDto> imprints, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  }) async {
    final searchKey = _getImprintSearchKey(query, page, limit);
    final box = await _getBox<List>(_imprintSearchBox);
    await box.put(
        searchKey, imprints.map((entry) => entry.toJson()).toList());

    final searchMetaBox = await _getBox<Map>(_imprintSearchMetaBox);
    await searchMetaBox.put(searchKey, {
      'count': count,
      'next': next,
      'previous': previous,
    });

    final metaBox = await _getBox<int>(_cacheMetaBox);
    await metaBox.put(
      _getImprintSearchMetaKey(query, page, limit),
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<List<ImprintListDto>?> getImprintSearchResults(
    String query, {
    required int page,
    required int limit,
  }) async {
    final searchKey = _getImprintSearchKey(query, page, limit);
    final box = await _getBox<List>(_imprintSearchBox);
    final rawData = box.get(searchKey);
    if (rawData != null) {
      return rawData
          .whereType<Map>()
          .map((entry) => entry.cast<String, dynamic>())
          .map(ImprintListDto.fromJson)
          .toList();
    }
    return null;
  }

  Future<DateTime?> getImprintSearchResultsCachedAt(
    String query, {
    required int page,
    required int limit,
  }) async {
    final metaBox = await _getBox<int>(_cacheMetaBox);
    final epoch =
        metaBox.get(_getImprintSearchMetaKey(query, page, limit));
    if (epoch == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(epoch);
  }

  Future<ImprintSearchPageCacheMeta?> getImprintSearchResultsMeta(
    String query, {
    required int page,
    required int limit,
  }) async {
    final searchKey = _getImprintSearchKey(query, page, limit);
    final box = await _getBox<Map>(_imprintSearchMetaBox);
    final data = box.get(searchKey);
    if (data == null) return null;

    final count = (data['count'] as num?)?.toInt();
    if (count == null) return null;

    return ImprintSearchPageCacheMeta(
      count: count,
      next: data['next'] as String?,
      previous: data['previous'] as String?,
    );
  }

  Future<void> cacheImprintDetails(ImprintDetailsDto details) async {
    final box = await _getBox<Map>(_imprintDetailsBox);
    await box.put(details.id, details.toJson());

    final metaBox = await _getBox<int>(_cacheMetaBox);
    await metaBox.put(
      _getImprintDetailsMetaKey(details.id),
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<ImprintDetailsDto?> getImprintDetails(int imprintId) async {
    final box = await _getBox<Map>(_imprintDetailsBox);
    final data = box.get(imprintId);
    if (data == null) return null;
    return ImprintDetailsDto.fromJson(data.cast<String, dynamic>());
  }

  Future<DateTime?> getImprintDetailsCachedAt(int imprintId) async {
    final metaBox = await _getBox<int>(_cacheMetaBox);
    final epoch = metaBox.get(_getImprintDetailsMetaKey(imprintId));
    if (epoch == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(epoch);
  }
}
