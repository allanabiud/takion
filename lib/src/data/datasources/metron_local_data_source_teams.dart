part of 'metron_local_data_source.dart';

mixin _TeamsDataSourceMixin on _DataSourceState {
  Future<void> cacheTeamSearchResults(
    String query,
    List<TeamListDto> teams, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  }) async {
    final searchKey = _getTeamSearchKey(query, page, limit);
    final box = await _getBox<List>(_teamSearchBox);
    await box.put(searchKey, teams.map((entry) => entry.toJson()).toList());

    final searchMetaBox = await _getBox<Map>(_teamSearchMetaBox);
    await searchMetaBox.put(searchKey, {
      'count': count,
      'next': next,
      'previous': previous,
    });

    final metaBox = await _getBox<int>(_cacheMetaBox);
    await metaBox.put(
      _getTeamSearchMetaKey(query, page, limit),
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<List<TeamListDto>?> getTeamSearchResults(
    String query, {
    required int page,
    required int limit,
  }) async {
    final searchKey = _getTeamSearchKey(query, page, limit);
    final box = await _getBox<List>(_teamSearchBox);
    final rawData = box.get(searchKey);
    if (rawData != null) {
      return rawData
          .whereType<Map>()
          .map((entry) => entry.cast<String, dynamic>())
          .map(TeamListDto.fromJson)
          .toList();
    }
    return null;
  }

  Future<DateTime?> getTeamSearchResultsCachedAt(
    String query, {
    required int page,
    required int limit,
  }) async {
    final metaBox = await _getBox<int>(_cacheMetaBox);
    final epoch = metaBox.get(_getTeamSearchMetaKey(query, page, limit));
    if (epoch == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(epoch);
  }

  Future<TeamSearchPageCacheMeta?> getTeamSearchResultsMeta(
    String query, {
    required int page,
    required int limit,
  }) async {
    final searchKey = _getTeamSearchKey(query, page, limit);
    final box = await _getBox<Map>(_teamSearchMetaBox);
    final data = box.get(searchKey);
    if (data == null) return null;

    final count = (data['count'] as num?)?.toInt();
    if (count == null) return null;

    return TeamSearchPageCacheMeta(
      count: count,
      next: data['next'] as String?,
      previous: data['previous'] as String?,
    );
  }

  Future<void> cacheTeamDetails(TeamDetailsDto details) async {
    final box = await _getBox<Map>(_teamDetailsBox);
    await box.put(details.id, details.toJson());

    final metaBox = await _getBox<int>(_cacheMetaBox);
    await metaBox.put(
      _getTeamDetailsMetaKey(details.id),
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<TeamDetailsDto?> getTeamDetails(int teamId) async {
    final box = await _getBox<Map>(_teamDetailsBox);
    final data = box.get(teamId);
    if (data == null) return null;
    return TeamDetailsDto.fromJson(data.cast<String, dynamic>());
  }

  Future<DateTime?> getTeamDetailsCachedAt(int teamId) async {
    final metaBox = await _getBox<int>(_cacheMetaBox);
    final epoch = metaBox.get(_getTeamDetailsMetaKey(teamId));
    if (epoch == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(epoch);
  }
}
