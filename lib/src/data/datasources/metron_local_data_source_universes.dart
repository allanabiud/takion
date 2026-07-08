part of 'metron_local_data_source.dart';

mixin _UniversesDataSourceMixin on _DataSourceState {
  Future<void> cacheUniverseSearchResults(
    String query,
    List<UniverseListDto> universes, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  }) async {
    final searchKey = _getUniverseSearchKey(query, page, limit);
    final box = await _getBox<List>(_universeSearchBox);
    await box.put(
        searchKey, universes.map((entry) => entry.toJson()).toList());

    final searchMetaBox = await _getBox<Map>(_universeSearchMetaBox);
    await searchMetaBox.put(searchKey, {
      'count': count,
      'next': next,
      'previous': previous,
    });

    final metaBox = await _getBox<int>(_cacheMetaBox);
    await metaBox.put(
      _getUniverseSearchMetaKey(query, page, limit),
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<List<UniverseListDto>?> getUniverseSearchResults(
    String query, {
    required int page,
    required int limit,
  }) async {
    final searchKey = _getUniverseSearchKey(query, page, limit);
    final box = await _getBox<List>(_universeSearchBox);
    final rawData = box.get(searchKey);
    if (rawData != null) {
      return rawData
          .whereType<Map>()
          .map((entry) => entry.cast<String, dynamic>())
          .map(UniverseListDto.fromJson)
          .toList();
    }
    return null;
  }

  Future<DateTime?> getUniverseSearchResultsCachedAt(
    String query, {
    required int page,
    required int limit,
  }) async {
    final metaBox = await _getBox<int>(_cacheMetaBox);
    final epoch =
        metaBox.get(_getUniverseSearchMetaKey(query, page, limit));
    if (epoch == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(epoch);
  }

  Future<UniverseSearchPageCacheMeta?> getUniverseSearchResultsMeta(
    String query, {
    required int page,
    required int limit,
  }) async {
    final searchKey = _getUniverseSearchKey(query, page, limit);
    final box = await _getBox<Map>(_universeSearchMetaBox);
    final data = box.get(searchKey);
    if (data == null) return null;

    final count = (data['count'] as num?)?.toInt();
    if (count == null) return null;

    return UniverseSearchPageCacheMeta(
      count: count,
      next: data['next'] as String?,
      previous: data['previous'] as String?,
    );
  }

  Future<void> cacheUniverseDetails(UniverseDetailsDto details) async {
    final box = await _getBox<Map>(_universeDetailsBox);
    await box.put(details.id, details.toJson());

    final metaBox = await _getBox<int>(_cacheMetaBox);
    await metaBox.put(
      _getUniverseDetailsMetaKey(details.id),
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<UniverseDetailsDto?> getUniverseDetails(int universeId) async {
    final box = await _getBox<Map>(_universeDetailsBox);
    final data = box.get(universeId);
    if (data == null) return null;
    return UniverseDetailsDto.fromJson(data.cast<String, dynamic>());
  }

  Future<DateTime?> getUniverseDetailsCachedAt(int universeId) async {
    final metaBox = await _getBox<int>(_cacheMetaBox);
    final epoch = metaBox.get(_getUniverseDetailsMetaKey(universeId));
    if (epoch == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(epoch);
  }
}
