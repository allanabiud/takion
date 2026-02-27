import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:takion/src/domain/entities/pull_list_entry.dart';
import 'package:takion/src/domain/repositories/pull_list_repository.dart';

class SupabasePullListRepository implements PullListRepository {
  SupabasePullListRepository(this._client);

  final SupabaseClient _client;

  String _requireUserId() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('User must be authenticated to access pull list.');
    }
    return userId;
  }

  PullListEntryStatus _statusFromDb(String value) {
    switch (value) {
      case 'upcoming':
        return PullListEntryStatus.upcoming;
      case 'missing':
        return PullListEntryStatus.missing;
      case 'owned':
        return PullListEntryStatus.owned;
      case 'skipped':
        return PullListEntryStatus.skipped;
      default:
        throw StateError('Unknown pull list status: $value');
    }
  }

  String _statusToDb(PullListEntryStatus status) {
    switch (status) {
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

  PullListEntrySource _sourceFromDb(String value) {
    switch (value) {
      case 'subscription':
        return PullListEntrySource.subscription;
      case 'manual':
        return PullListEntrySource.manual;
      default:
        throw StateError('Unknown pull list source: $value');
    }
  }

  PullListEntry _mapRow(Map<String, dynamic> row) {
    return PullListEntry(
      id: row['id'] as String,
      userId: row['user_id'] as String,
      metronSeriesId: row['metron_series_id'] as int,
      metronIssueId: row['metron_issue_id'] as int,
      releaseDate:
          row['release_date'] != null
              ? DateTime.parse(row['release_date'] as String)
              : null,
      entryStatus: _statusFromDb(row['entry_status'] as String),
      source: _sourceFromDb(row['source'] as String),
      generatedAt: DateTime.parse(row['generated_at'] as String),
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
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
    final userId = _requireUserId();

    var query = _client
        .from('pull_list_entries')
        .select(
          'id, user_id, metron_series_id, metron_issue_id, release_date, entry_status, source, generated_at, created_at, updated_at',
        )
        .eq('user_id', userId);

    if (fromDate != null) {
      query = query.gte('release_date', fromDate.toUtc().toIso8601String().split('T').first);
    }
    if (toDate != null) {
      query = query.lte('release_date', toDate.toUtc().toIso8601String().split('T').first);
    }
    if (status != null) {
      query = query.eq('entry_status', _statusToDb(status));
    }

    final rows = await query
        .order('release_date', ascending: true)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (rows as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(_mapRow)
        .toList();
  }

  @override
  Future<PullListEntry?> getEntryByIssueId(int metronIssueId) async {
    final userId = _requireUserId();
    final row = await _client
        .from('pull_list_entries')
        .select(
          'id, user_id, metron_series_id, metron_issue_id, release_date, entry_status, source, generated_at, created_at, updated_at',
        )
        .eq('user_id', userId)
        .eq('metron_issue_id', metronIssueId)
        .maybeSingle();

    if (row == null) return null;
    return _mapRow(row);
  }

  @override
  Future<PullListEntry> upsertManualEntry({
    required int metronSeriesId,
    required int metronIssueId,
    DateTime? releaseDate,
    PullListEntryStatus entryStatus = PullListEntryStatus.upcoming,
  }) async {
    final userId = _requireUserId();
    final now = DateTime.now().toUtc().toIso8601String();

    final row = await _client
        .from('pull_list_entries')
        .upsert({
          'user_id': userId,
          'metron_series_id': metronSeriesId,
          'metron_issue_id': metronIssueId,
          'release_date': releaseDate?.toUtc().toIso8601String().split('T').first,
          'entry_status': _statusToDb(entryStatus),
          'source': 'manual',
          'generated_at': now,
          'updated_at': now,
        }, onConflict: 'user_id,metron_issue_id')
        .select(
          'id, user_id, metron_series_id, metron_issue_id, release_date, entry_status, source, generated_at, created_at, updated_at',
        )
        .single();

    return _mapRow(row);
  }

  @override
  Future<PullListEntry> updateEntryStatus({
    required int metronIssueId,
    required PullListEntryStatus status,
  }) async {
    final userId = _requireUserId();
    final row = await _client
        .from('pull_list_entries')
        .update({
          'entry_status': _statusToDb(status),
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('user_id', userId)
        .eq('metron_issue_id', metronIssueId)
        .select(
          'id, user_id, metron_series_id, metron_issue_id, release_date, entry_status, source, generated_at, created_at, updated_at',
        )
        .single();

    return _mapRow(row);
  }

  @override
  Future<void> deleteEntryByIssueId(int metronIssueId) async {
    final userId = _requireUserId();
    await _client
        .from('pull_list_entries')
        .delete()
        .eq('user_id', userId)
        .eq('metron_issue_id', metronIssueId);
  }

  @override
  Future<int> regenerateFromSubscriptions({
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    _requireUserId();

    final result = await _client.rpc(
      'regenerate_pull_list_from_subscriptions',
      params: {
        'p_from_date': fromDate?.toUtc().toIso8601String().split('T').first,
        'p_to_date': toDate?.toUtc().toIso8601String().split('T').first,
      },
    );

    if (result is int) return result;
    if (result is num) return result.toInt();
    return int.tryParse(result.toString()) ?? 0;
  }
}
