import 'package:drift/drift.dart';
import 'package:takion/src/core/cache/user_state_cache.dart';
import 'package:takion/src/data/common/drift/database.dart' as db;
import 'package:takion/src/domain/entities.dart';
import 'package:takion/src/domain/repositories.dart';

class LocalPullListRepository implements PullListRepository {
  LocalPullListRepository(this._database, this._cache);

  static const _localUserId = 'local-user';

  final db.AppDatabase _database;
  final UserStateCache _cache;

  String _idForIssue(int issueId) => 'pull-$issueId';

  String _statusToRaw(PullListEntryStatus value) {
    switch (value) {
      case PullListEntryStatus.upcoming:
        return 'upcoming';
      case PullListEntryStatus.missing:
        return 'missing';
      case PullListEntryStatus.owned:
        return 'owned';
      case PullListEntryStatus.skipped:
        return 'skipped';
    }
  }

  PullListEntryStatus _statusFromRaw(String value) {
    switch (value) {
      case 'missing':
        return PullListEntryStatus.missing;
      case 'owned':
        return PullListEntryStatus.owned;
      case 'skipped':
        return PullListEntryStatus.skipped;
      case 'upcoming':
      default:
        return PullListEntryStatus.upcoming;
    }
  }

  String _sourceToRaw(PullListEntrySource value) {
    switch (value) {
      case PullListEntrySource.subscription:
        return 'subscription';
      case PullListEntrySource.manual:
        return 'manual';
    }
  }

  PullListEntrySource _sourceFromRaw(String value) {
    switch (value) {
      case 'manual':
        return PullListEntrySource.manual;
      case 'subscription':
      default:
        return PullListEntrySource.subscription;
    }
  }

  PullListEntry _toDomain(db.PullListEntry d) {
    return PullListEntry(
      id: d.id,
      userId: d.userId,
      metronSeriesId: d.metronSeriesId,
      metronIssueId: d.metronIssueId,
      releaseDate: d.releaseDate,
      entryStatus: _statusFromRaw(d.entryStatus),
      source: _sourceFromRaw(d.source),
      generatedAt: DateTime.parse(d.generatedAt),
      createdAt: DateTime.parse(d.createdAt),
      updatedAt: DateTime.parse(d.updatedAt),
    );
  }

  @override
  Future<List<PullListEntry>> listEntries({
    DateTime? fromDate,
    DateTime? toDate,
    PullListEntryStatus? status,
    int limit = 100,
    int offset = 0,
  }) async {
    final rows = await _database.pullListDao.getEntries(
      fromDate: fromDate,
      toDate: toDate,
      status: status != null ? _statusToRaw(status) : null,
      limit: limit,
      offset: offset,
    );
    return rows.map(_toDomain).toList();
  }

  @override
  Future<PullListEntry?> getEntryByIssueId(int metronIssueId) async {
    final cached = _cache.getPullListEntry(metronIssueId);
    if (cached != null) return cached;
    final d = await _database.pullListDao.getByIssueId(metronIssueId);
    if (d != null) {
      final entry = _toDomain(d);
      _cache.setPullListEntry(metronIssueId, entry);
      return entry;
    }
    return null;
  }

  @override
  Future<PullListEntry> upsertManualEntry({
    required int metronSeriesId,
    required int metronIssueId,
    DateTime? releaseDate,
    PullListEntryStatus entryStatus = PullListEntryStatus.upcoming,
  }) async {
    final existing = await _database.pullListDao.getByIssueId(metronIssueId);
    final now = DateTime.now().toUtc();
    final entry = PullListEntry(
      id: existing?.id ?? _idForIssue(metronIssueId),
      userId: _localUserId,
      metronSeriesId: metronSeriesId,
      metronIssueId: metronIssueId,
      releaseDate: releaseDate,
      entryStatus: entryStatus,
      source: PullListEntrySource.manual,
      generatedAt: now,
      createdAt: existing != null ? DateTime.parse(existing.createdAt) : now,
      updatedAt: now,
    );

    await _database.pullListDao.upsert(
      db.PullListEntriesCompanion(
        id: Value(entry.id),
        userId: Value(entry.userId),
        metronIssueId: Value(entry.metronIssueId),
        metronSeriesId: Value(entry.metronSeriesId),
        entryStatus: Value(_statusToRaw(entry.entryStatus)),
        releaseDate: Value(entry.releaseDate),
        source: Value(_sourceToRaw(entry.source)),
        generatedAt: Value(entry.generatedAt.toIso8601String()),
        createdAt: Value(entry.createdAt.toIso8601String()),
        updatedAt: Value(entry.updatedAt.toIso8601String()),
      ),
    );

    _cache.setPullListEntry(metronIssueId, entry);
    return entry;
  }

  @override
  Future<PullListEntry> updateEntryStatus({
    required int metronIssueId,
    required PullListEntryStatus status,
  }) async {
    final current = await getEntryByIssueId(metronIssueId);
    if (current == null) {
      throw StateError(
        'Pull list entry does not exist for issue $metronIssueId',
      );
    }
    final updated = PullListEntry(
      id: current.id,
      userId: current.userId,
      metronSeriesId: current.metronSeriesId,
      metronIssueId: current.metronIssueId,
      releaseDate: current.releaseDate,
      entryStatus: status,
      source: current.source,
      generatedAt: current.generatedAt,
      createdAt: current.createdAt,
      updatedAt: DateTime.now().toUtc(),
    );
    await _database.pullListDao.upsert(
      db.PullListEntriesCompanion(
        id: Value(updated.id),
        userId: Value(updated.userId),
        metronIssueId: Value(updated.metronIssueId),
        metronSeriesId: Value(updated.metronSeriesId),
        entryStatus: Value(_statusToRaw(updated.entryStatus)),
        releaseDate: Value(updated.releaseDate),
        source: Value(_sourceToRaw(updated.source)),
        generatedAt: Value(updated.generatedAt.toIso8601String()),
        createdAt: Value(updated.createdAt.toIso8601String()),
        updatedAt: Value(updated.updatedAt.toIso8601String()),
      ),
    );
    _cache.setPullListEntry(metronIssueId, updated);
    return updated;
  }

  @override
  Future<void> deleteEntryByIssueId(int metronIssueId) async {
    await _database.pullListDao.deleteByIssueId(metronIssueId);
    _cache.removePullListEntry(metronIssueId);
  }

  @override
  Future<List<PullListEntry>> deleteEntriesBySeriesId(
    int metronSeriesId,
  ) async {
    final entries = await listEntries(
      status: PullListEntryStatus.upcoming,
      limit: 1000,
    );
    final toDelete = entries
        .where((e) => e.metronSeriesId == metronSeriesId)
        .toList();
    for (final entry in toDelete) {
      await _database.pullListDao.deleteByIssueId(entry.metronIssueId);
    }
    return toDelete;
  }

  @override
  Future<void> upsertSubscriptionEntries(
    List<({int metronSeriesId, int metronIssueId, DateTime? releaseDate})>
    entries,
  ) async {
    if (entries.isEmpty) return;
    await _database.pullListDao.upsertSubscriptionEntries(entries);
  }
}
