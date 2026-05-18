import 'package:takion/src/core/storage/hive_service.dart';
import 'package:takion/src/domain/entities/pull_list_entry.dart';
import 'package:takion/src/domain/repositories/pull_list_repository.dart';

class LocalPullListRepository implements PullListRepository {
  LocalPullListRepository(this._hiveService);

  static const _localUserId = 'local-user';
  static const _boxName = 'local_pull_list_box';

  final HiveService _hiveService;

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

  Map<String, dynamic> _toMap(PullListEntry entry) {
    return {
      'id': entry.id,
      'user_id': entry.userId,
      'metron_series_id': entry.metronSeriesId,
      'metron_issue_id': entry.metronIssueId,
      'release_date': entry.releaseDate?.toIso8601String(),
      'entry_status': _statusToRaw(entry.entryStatus),
      'source': _sourceToRaw(entry.source),
      'generated_at': entry.generatedAt.toIso8601String(),
      'created_at': entry.createdAt.toIso8601String(),
      'updated_at': entry.updatedAt.toIso8601String(),
    };
  }

  PullListEntry _fromMap(Map<String, dynamic> map) {
    return PullListEntry(
      id: map['id'] as String,
      userId: map['user_id'] as String? ?? _localUserId,
      metronSeriesId: map['metron_series_id'] as int,
      metronIssueId: map['metron_issue_id'] as int,
      releaseDate: DateTime.tryParse(map['release_date'] as String? ?? ''),
      entryStatus: _statusFromRaw(map['entry_status'] as String? ?? 'upcoming'),
      source: _sourceFromRaw(map['source'] as String? ?? 'subscription'),
      generatedAt: DateTime.parse(map['generated_at'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  Future<List<PullListEntry>> _all() async {
    final box = await _hiveService.openBox<Map>(_boxName);
    final list = box.values
        .map((raw) => _fromMap(raw.cast<String, dynamic>()))
        .toList();
    list.sort((a, b) {
      final left = a.releaseDate ?? DateTime(2100);
      final right = b.releaseDate ?? DateTime(2100);
      final dateCmp = left.compareTo(right);
      if (dateCmp != 0) return dateCmp;
      return b.createdAt.compareTo(a.createdAt);
    });
    return list;
  }

  @override
  Future<List<PullListEntry>> listEntries({
    DateTime? fromDate,
    DateTime? toDate,
    PullListEntryStatus? status,
    int limit = 100,
    int offset = 0,
  }) async {
    var entries = await _all();
    if (fromDate != null) {
      final from = _dateOnly(fromDate);
      entries = entries.where((entry) {
        final release = entry.releaseDate;
        return release != null && !_dateOnly(release).isBefore(from);
      }).toList();
    }
    if (toDate != null) {
      final to = _dateOnly(toDate);
      entries = entries.where((entry) {
        final release = entry.releaseDate;
        return release != null && !_dateOnly(release).isAfter(to);
      }).toList();
    }
    if (status != null) {
      entries = entries.where((entry) => entry.entryStatus == status).toList();
    }
    if (offset >= entries.length) return <PullListEntry>[];
    final end = (offset + limit).clamp(0, entries.length);
    return entries.sublist(offset, end);
  }

  @override
  Future<PullListEntry?> getEntryByIssueId(int metronIssueId) async {
    final box = await _hiveService.openBox<Map>(_boxName);
    final raw = box.get(metronIssueId.toString());
    if (raw == null) return null;
    return _fromMap(raw.cast<String, dynamic>());
  }

  @override
  Future<PullListEntry> upsertManualEntry({
    required int metronSeriesId,
    required int metronIssueId,
    DateTime? releaseDate,
    PullListEntryStatus entryStatus = PullListEntryStatus.upcoming,
  }) async {
    final box = await _hiveService.openBox<Map>(_boxName);
    final existingRaw = box.get(metronIssueId.toString());
    final existing = existingRaw == null
        ? null
        : _fromMap(existingRaw.cast<String, dynamic>());
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
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );
    await box.put(metronIssueId.toString(), _toMap(entry));
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
    final box = await _hiveService.openBox<Map>(_boxName);
    await box.put(metronIssueId.toString(), _toMap(updated));
    return updated;
  }

  @override
  Future<void> deleteEntryByIssueId(int metronIssueId) async {
    final box = await _hiveService.openBox<Map>(_boxName);
    await box.delete(metronIssueId.toString());
  }

  @override
  Future<void> deleteEntriesBySeriesId(int metronSeriesId) async {
    final box = await _hiveService.openBox<Map>(_boxName);
    final keysToDelete = box.values
        .where((raw) {
          final map = raw;
          final status = map['entry_status'] as String;

          final isUpcoming = status == 'upcoming';

          return map['metron_series_id'] as int == metronSeriesId && isUpcoming;
        })
        .map((raw) => (raw)['metron_issue_id'].toString())
        .toList();
    for (final key in keysToDelete) {
      await box.delete(key);
    }
  }

  @override
  Future<void> upsertSubscriptionEntries(
    List<({int metronSeriesId, int metronIssueId, DateTime? releaseDate})>
    entries,
  ) async {
    if (entries.isEmpty) return;
    final box = await _hiveService.openBox<Map>(_boxName);
    final now = DateTime.now().toUtc();
    for (final item in entries) {
      final existingRaw = box.get(item.metronIssueId.toString());
      final existing = existingRaw == null
          ? null
          : _fromMap(existingRaw.cast<String, dynamic>());
      final entry = PullListEntry(
        id: existing?.id ?? _idForIssue(item.metronIssueId),
        userId: _localUserId,
        metronSeriesId: item.metronSeriesId,
        metronIssueId: item.metronIssueId,
        releaseDate: item.releaseDate,
        entryStatus: PullListEntryStatus.upcoming,
        source: PullListEntrySource.subscription,
        generatedAt: now,
        createdAt: existing?.createdAt ?? now,
        updatedAt: now,
      );
      await box.put(item.metronIssueId.toString(), _toMap(entry));
    }
  }

  @override
  Future<int> regenerateFromSubscriptions({
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    return 0;
  }
}
