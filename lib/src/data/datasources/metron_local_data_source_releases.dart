part of 'metron_local_data_source.dart';

mixin _ReleasesDataSourceMixin on _DataSourceState {
  Future<void> cacheWeeklyReleases(
    DateTime weekStart,
    List<IssueListDto> issues,
  ) async {
    final key = _getWeekKey(weekStart);
    final box = await _getBox<List>(_weeklyBox);
    await box.put(key, issues);

    final metaBox = await _getBox<int>(_cacheMetaBox);
    await metaBox.put(_getMetaKey(key), DateTime.now().millisecondsSinceEpoch);
  }

  Future<List<IssueListDto>?> getWeeklyReleases(DateTime weekStart) async {
    final box = await _getBox<List>(_weeklyBox);
    final data = box.get(_getWeekKey(weekStart));
    if (data != null) {
      return data.cast<IssueListDto>();
    }
    return null;
  }

  Future<DateTime?> getWeeklyReleasesCachedAt(DateTime weekStart) async {
    final key = _getWeekKey(weekStart);
    final metaBox = await _getBox<int>(_cacheMetaBox);
    final epoch = metaBox.get(_getMetaKey(key));
    if (epoch == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(epoch);
  }

  Future<void> cacheFocReleases(
    DateTime weekStart,
    List<IssueListDto> issues,
  ) async {
    final key = _getWeekKey(weekStart);
    final box = await _getBox<List>(_focBox);
    await box.put(key, issues);

    final metaBox = await _getBox<int>(_cacheMetaBox);
    await metaBox.put(
      _getFocMetaKey(key),
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<List<IssueListDto>?> getFocReleases(DateTime weekStart) async {
    final box = await _getBox<List>(_focBox);
    final data = box.get(_getWeekKey(weekStart));
    if (data != null) {
      return data.cast<IssueListDto>();
    }
    return null;
  }

  Future<DateTime?> getFocReleasesCachedAt(DateTime weekStart) async {
    final key = _getWeekKey(weekStart);
    final metaBox = await _getBox<int>(_cacheMetaBox);
    final epoch = metaBox.get(_getFocMetaKey(key));
    if (epoch == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(epoch);
  }
}
