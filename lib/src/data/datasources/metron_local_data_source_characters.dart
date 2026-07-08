part of 'metron_local_data_source.dart';

mixin _CharactersDataSourceMixin on _DataSourceState {
  Future<void> cacheCharacterSearchResults(
    String query,
    List<CharacterListDto> characters, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  }) async {
    final searchKey = _getCharacterSearchKey(query, page, limit);
    final box = await _getBox<List>(_characterSearchBox);
    await box.put(
        searchKey, characters.map((entry) => entry.toJson()).toList());

    final searchMetaBox = await _getBox<Map>(_characterSearchMetaBox);
    await searchMetaBox.put(searchKey, {
      'count': count,
      'next': next,
      'previous': previous,
    });

    final metaBox = await _getBox<int>(_cacheMetaBox);
    await metaBox.put(
      _getCharacterSearchMetaKey(query, page, limit),
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<List<CharacterListDto>?> getCharacterSearchResults(
    String query, {
    required int page,
    required int limit,
  }) async {
    final searchKey = _getCharacterSearchKey(query, page, limit);
    final box = await _getBox<List>(_characterSearchBox);
    final rawData = box.get(searchKey);
    if (rawData != null) {
      return rawData
          .whereType<Map>()
          .map((entry) => entry.cast<String, dynamic>())
          .map(CharacterListDto.fromJson)
          .toList();
    }
    return null;
  }

  Future<DateTime?> getCharacterSearchResultsCachedAt(
    String query, {
    required int page,
    required int limit,
  }) async {
    final metaBox = await _getBox<int>(_cacheMetaBox);
    final epoch =
        metaBox.get(_getCharacterSearchMetaKey(query, page, limit));
    if (epoch == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(epoch);
  }

  Future<CharacterSearchPageCacheMeta?> getCharacterSearchResultsMeta(
    String query, {
    required int page,
    required int limit,
  }) async {
    final searchKey = _getCharacterSearchKey(query, page, limit);
    final box = await _getBox<Map>(_characterSearchMetaBox);
    final data = box.get(searchKey);
    if (data == null) return null;

    final count = (data['count'] as num?)?.toInt();
    if (count == null) return null;

    return CharacterSearchPageCacheMeta(
      count: count,
      next: data['next'] as String?,
      previous: data['previous'] as String?,
    );
  }

  Future<void> cacheCharacterDetails(CharacterDetailsDto details) async {
    final box = await _getBox<Map>(_characterDetailsBox);
    await box.put(details.id, details.toJson());

    final metaBox = await _getBox<int>(_cacheMetaBox);
    await metaBox.put(
      _getCharacterDetailsMetaKey(details.id),
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<CharacterDetailsDto?> getCharacterDetails(int characterId) async {
    final box = await _getBox<Map>(_characterDetailsBox);
    final data = box.get(characterId);
    if (data == null) return null;
    return CharacterDetailsDto.fromJson(data.cast<String, dynamic>());
  }

  Future<DateTime?> getCharacterDetailsCachedAt(int characterId) async {
    final metaBox = await _getBox<int>(_cacheMetaBox);
    final epoch = metaBox.get(_getCharacterDetailsMetaKey(characterId));
    if (epoch == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(epoch);
  }

  Future<void> cacheCharacterIssueListResults(
    int characterId,
    List<IssueListDto> issues, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  }) async {
    final key = _getCharacterIssueListKey(characterId, page, limit);
    final box = await _getBox<List>(_characterIssueListBox);
    await box.put(key, issues);

    final metaBox = await _getBox<Map>(_characterIssueListMetaBox);
    await metaBox.put(key, {
      'count': count,
      'next': next,
      'previous': previous,
    });

    final cacheMetaBox = await _getBox<int>(_cacheMetaBox);
    await cacheMetaBox.put(
      _getCharacterIssueListMetaKey(characterId, page, limit),
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<List<IssueListDto>?> getCharacterIssueListResults(
    int characterId, {
    required int page,
    required int limit,
  }) async {
    final key = _getCharacterIssueListKey(characterId, page, limit);
    final box = await _getBox<List>(_characterIssueListBox);
    final data = box.get(key);
    if (data != null) {
      return data.cast<IssueListDto>();
    }
    return null;
  }

  Future<DateTime?> getCharacterIssueListResultsCachedAt(
    int characterId, {
    required int page,
    required int limit,
  }) async {
    final cacheMetaBox = await _getBox<int>(_cacheMetaBox);
    final epoch = cacheMetaBox.get(
      _getCharacterIssueListMetaKey(characterId, page, limit),
    );
    if (epoch == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(epoch);
  }

  Future<CharacterIssueListPageCacheMeta?> getCharacterIssueListResultsMeta(
    int characterId, {
    required int page,
    required int limit,
  }) async {
    final key = _getCharacterIssueListKey(characterId, page, limit);
    final box = await _getBox<Map>(_characterIssueListMetaBox);
    final data = box.get(key);
    if (data == null) return null;

    final count = (data['count'] as num?)?.toInt();
    if (count == null) return null;

    return CharacterIssueListPageCacheMeta(
      count: count,
      next: data['next'] as String?,
      previous: data['previous'] as String?,
    );
  }
}
