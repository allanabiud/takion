part of 'metron_local_data_source.dart';

mixin _IssuesDataSourceMixin on _DataSourceState {
  Future<void> cacheIssueDetails(IssueDetailsDto issue) async {
    final box = await _getBox<IssueDetailsDto>(_issueDetailsBox);
    await box.put(issue.id, issue);

    final metaBox = await _getBox<int>(_cacheMetaBox);
    await metaBox.put(
      _getIssueDetailsMetaKey(issue.id),
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<IssueDetailsDto?> getIssueDetails(int issueId) async {
    final box = await _getBox<IssueDetailsDto>(_issueDetailsBox);
    return box.get(issueId);
  }

  Future<DateTime?> getIssueDetailsCachedAt(int issueId) async {
    final metaBox = await _getBox<int>(_cacheMetaBox);
    final epoch = metaBox.get(_getIssueDetailsMetaKey(issueId));
    if (epoch == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(epoch);
  }

  Future<void> cacheIssueSearchResults(
    String query,
    List<IssueListDto> issues, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  }) async {
    final searchKey = _getIssueSearchKey(query, page, limit);
    final box = await _getBox<List>(_issueSearchBox);
    await box.put(searchKey, issues);

    final searchMetaBox = await _getBox<Map>(_issueSearchMetaBox);
    await searchMetaBox.put(searchKey, {
      'count': count,
      'next': next,
      'previous': previous,
    });

    final metaBox = await _getBox<int>(_cacheMetaBox);
    await metaBox.put(
      _getIssueSearchMetaKey(query, page, limit),
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<List<IssueListDto>?> getIssueSearchResults(
    String query, {
    required int page,
    required int limit,
  }) async {
    final searchKey = _getIssueSearchKey(query, page, limit);
    final box = await _getBox<List>(_issueSearchBox);
    final data = box.get(searchKey);
    if (data != null) {
      return data.cast<IssueListDto>();
    }
    return null;
  }

  Future<DateTime?> getIssueSearchResultsCachedAt(
    String query, {
    required int page,
    required int limit,
  }) async {
    final metaBox = await _getBox<int>(_cacheMetaBox);
    final epoch = metaBox.get(_getIssueSearchMetaKey(query, page, limit));
    if (epoch == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(epoch);
  }

  Future<IssueSearchPageCacheMeta?> getIssueSearchResultsMeta(
    String query, {
    required int page,
    required int limit,
  }) async {
    final searchKey = _getIssueSearchKey(query, page, limit);
    final box = await _getBox<Map>(_issueSearchMetaBox);
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

  Future<void> cacheIssueListResults(
    List<IssueListDto> issues, {
    required int page,
    String? ordering,
    DateTime? modifiedGt,
    int? limit,
    required int count,
    String? next,
    String? previous,
  }) async {
    final key = _getIssueListKey(
      page: page,
      ordering: ordering,
      modifiedGt: modifiedGt,
      limit: limit,
    );
    final box = await _getBox<List>(_issueListBox);
    await box.put(key, issues);

    final metaBox = await _getBox<Map>(_issueListMetaBox);
    await metaBox.put(key, {
      'count': count,
      'next': next,
      'previous': previous,
    });

    final cacheMetaBox = await _getBox<int>(_cacheMetaBox);
    await cacheMetaBox.put(
      _getIssueListMetaKey(
        page: page,
        ordering: ordering,
        modifiedGt: modifiedGt,
        limit: limit,
      ),
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<List<IssueListDto>?> getIssueListResults({
    required int page,
    String? ordering,
    DateTime? modifiedGt,
    int? limit,
  }) async {
    final key = _getIssueListKey(
      page: page,
      ordering: ordering,
      modifiedGt: modifiedGt,
      limit: limit,
    );
    final box = await _getBox<List>(_issueListBox);
    final data = box.get(key);
    if (data != null) {
      return data.cast<IssueListDto>();
    }
    return null;
  }

  Future<DateTime?> getIssueListResultsCachedAt({
    required int page,
    String? ordering,
    DateTime? modifiedGt,
    int? limit,
  }) async {
    final cacheMetaBox = await _getBox<int>(_cacheMetaBox);
    final epoch = cacheMetaBox.get(
      _getIssueListMetaKey(
        page: page,
        ordering: ordering,
        modifiedGt: modifiedGt,
        limit: limit,
      ),
    );
    if (epoch == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(epoch);
  }

  Future<IssueSearchPageCacheMeta?> getIssueListResultsMeta({
    required int page,
    String? ordering,
    DateTime? modifiedGt,
    int? limit,
  }) async {
    final key = _getIssueListKey(
      page: page,
      ordering: ordering,
      modifiedGt: modifiedGt,
      limit: limit,
    );
    final box = await _getBox<Map>(_issueListMetaBox);
    final data = box.get(key);
    if (data == null) return null;

    final count = (data['count'] as num?)?.toInt();
    if (count == null) return null;

    return IssueSearchPageCacheMeta(
      count: count,
      next: data['next'] as String?,
      previous: data['previous'] as String?,
    );
  }
}
