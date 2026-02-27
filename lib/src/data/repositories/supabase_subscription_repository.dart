import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:takion/src/domain/entities/series_subscription.dart';
import 'package:takion/src/domain/repositories/subscription_repository.dart';

class SupabaseSubscriptionRepository implements SubscriptionRepository {
  SupabaseSubscriptionRepository(this._client);

  final SupabaseClient _client;

  String _requireUserId() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('User must be authenticated to access subscriptions.');
    }
    return userId;
  }

  SeriesSubscription _mapRow(Map<String, dynamic> row) {
    return SeriesSubscription(
      id: row['id'] as String,
      userId: row['user_id'] as String,
      metronSeriesId: row['metron_series_id'] as int,
      isActive: row['is_active'] as bool,
      autoAddToPullList: row['auto_add_to_pull_list'] as bool,
      subscribedAt: DateTime.parse(row['subscribed_at'] as String),
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }

  @override
  Future<List<SeriesSubscription>> listSubscriptions({
    bool activeOnly = true,
    int limit = 100,
    int offset = 0,
  }) async {
    final userId = _requireUserId();
    final query = _client
        .from('series_subscriptions')
        .select(
          'id, user_id, metron_series_id, is_active, auto_add_to_pull_list, subscribed_at, created_at, updated_at',
        )
        .eq('user_id', userId);

    final rows = await (activeOnly
        ? query.eq('is_active', true)
        : query
    )
        .order('subscribed_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (rows as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(_mapRow)
        .toList();
  }

  @override
  Future<SeriesSubscription?> getSubscriptionBySeriesId(int metronSeriesId) async {
    final userId = _requireUserId();
    final row = await _client
        .from('series_subscriptions')
        .select(
          'id, user_id, metron_series_id, is_active, auto_add_to_pull_list, subscribed_at, created_at, updated_at',
        )
        .eq('user_id', userId)
        .eq('metron_series_id', metronSeriesId)
        .maybeSingle();

    if (row == null) return null;
    return _mapRow(row);
  }

  @override
  Future<SeriesSubscription> subscribe({
    required int metronSeriesId,
    bool autoAddToPullList = true,
  }) async {
    final userId = _requireUserId();

    final row = await _client
        .from('series_subscriptions')
        .upsert({
          'user_id': userId,
          'metron_series_id': metronSeriesId,
          'is_active': true,
          'auto_add_to_pull_list': autoAddToPullList,
          'subscribed_at': DateTime.now().toUtc().toIso8601String(),
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        }, onConflict: 'user_id,metron_series_id')
        .select(
          'id, user_id, metron_series_id, is_active, auto_add_to_pull_list, subscribed_at, created_at, updated_at',
        )
        .single();

    return _mapRow(row);
  }

  @override
  Future<void> unsubscribe(int metronSeriesId) async {
    final userId = _requireUserId();
    await _client
        .from('series_subscriptions')
        .update({
          'is_active': false,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('user_id', userId)
        .eq('metron_series_id', metronSeriesId);
  }

  @override
  Future<SeriesSubscription> setAutoAddToPullList({
    required int metronSeriesId,
    required bool enabled,
  }) async {
    final userId = _requireUserId();

    final row = await _client
        .from('series_subscriptions')
        .update({
          'auto_add_to_pull_list': enabled,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('user_id', userId)
        .eq('metron_series_id', metronSeriesId)
        .select(
          'id, user_id, metron_series_id, is_active, auto_add_to_pull_list, subscribed_at, created_at, updated_at',
        )
        .single();

    return _mapRow(row);
  }
}
