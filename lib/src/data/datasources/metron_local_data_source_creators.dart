part of 'metron_local_data_source.dart';

mixin _CreatorsDataSourceMixin on _DataSourceState {
  Future<void> cacheCreatorSearchResults(
    String query,
    List<CreatorListDto> creators, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  }) async {
    final searchKey = _getCreatorSearchKey(query, page, limit);
    final box = await _getBox<List>(_creatorSearchBox);
    await box.put(
        searchKey, creators.map((entry) => entry.toJson()).toList());

    final searchMetaBox = await _getBox<Map>(_creatorSearchMetaBox);
    await searchMetaBox.put(searchKey, {
      'count': count,
      'next': next,
      'previous': previous,
    });

    final metaBox = await _getBox<int>(_cacheMetaBox);
    await metaBox.put(
      _getCreatorSearchMetaKey(query, page, limit),
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<List<CreatorListDto>?> getCreatorSearchResults(
    String query, {
    required int page,
    required int limit,
  }) async {
    final searchKey = _getCreatorSearchKey(query, page, limit);
    final box = await _getBox<List>(_creatorSearchBox);
    final rawData = box.get(searchKey);
    if (rawData != null) {
      return rawData
          .whereType<Map>()
          .map((entry) => entry.cast<String, dynamic>())
          .map(CreatorListDto.fromJson)
          .toList();
    }
    return null;
  }

  Future<DateTime?> getCreatorSearchResultsCachedAt(
    String query, {
    required int page,
    required int limit,
  }) async {
    final metaBox = await _getBox<int>(_cacheMetaBox);
    final epoch =
        metaBox.get(_getCreatorSearchMetaKey(query, page, limit));
    if (epoch == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(epoch);
  }

  Future<CreatorSearchPageCacheMeta?> getCreatorSearchResultsMeta(
    String query, {
    required int page,
    required int limit,
  }) async {
    final searchKey = _getCreatorSearchKey(query, page, limit);
    final box = await _getBox<Map>(_creatorSearchMetaBox);
    final data = box.get(searchKey);
    if (data == null) return null;

    final count = (data['count'] as num?)?.toInt();
    if (count == null) return null;

    return CreatorSearchPageCacheMeta(
      count: count,
      next: data['next'] as String?,
      previous: data['previous'] as String?,
    );
  }

  Future<void> cacheCreatorDetails(CreatorDetailsDto details) async {
    final box = await _getBox<Map>(_creatorDetailsBox);
    await box.put(details.id, details.toJson());

    final metaBox = await _getBox<int>(_cacheMetaBox);
    await metaBox.put(
      _getCreatorDetailsMetaKey(details.id),
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<CreatorDetailsDto?> getCreatorDetails(int creatorId) async {
    final box = await _getBox<Map>(_creatorDetailsBox);
    final data = box.get(creatorId);
    if (data == null) return null;
    return CreatorDetailsDto.fromJson(data.cast<String, dynamic>());
  }

  Future<DateTime?> getCreatorDetailsCachedAt(int creatorId) async {
    final metaBox = await _getBox<int>(_cacheMetaBox);
    final epoch = metaBox.get(_getCreatorDetailsMetaKey(creatorId));
    if (epoch == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(epoch);
  }
}
