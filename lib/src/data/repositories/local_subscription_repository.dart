import 'package:takion/src/core/storage/hive_service.dart';
import 'package:takion/src/domain/entities/series_subscription.dart';
import 'package:takion/src/domain/repositories/subscription_repository.dart';

class LocalSubscriptionRepository implements SubscriptionRepository {
  LocalSubscriptionRepository(this._hiveService);

  static const _localUserId = 'local-user';
  static const _boxName = 'local_subscriptions_box';

  final HiveService _hiveService;

  String _idForSeries(int seriesId) => 'sub-$seriesId';

  Map<String, dynamic> _toMap(SeriesSubscription sub) {
    return {
      'id': sub.id,
      'user_id': sub.userId,
      'metron_series_id': sub.metronSeriesId,
      'is_active': sub.isActive,
      'auto_add_to_pull_list': sub.autoAddToPullList,
      'subscribed_at': sub.subscribedAt.toIso8601String(),
      'created_at': sub.createdAt.toIso8601String(),
      'updated_at': sub.updatedAt.toIso8601String(),
    };
  }

  SeriesSubscription _fromMap(Map<String, dynamic> map) {
    return SeriesSubscription(
      id: map['id'] as String,
      userId: map['user_id'] as String? ?? _localUserId,
      metronSeriesId: map['metron_series_id'] as int,
      isActive: map['is_active'] as bool? ?? true,
      autoAddToPullList: map['auto_add_to_pull_list'] as bool? ?? true,
      subscribedAt: DateTime.parse(map['subscribed_at'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Future<List<SeriesSubscription>> _all() async {
    final box = await _hiveService.openBox<Map>(_boxName);
    final entries = box.values
        .map((raw) => _fromMap(raw.cast<String, dynamic>()))
        .toList();
    entries.sort((a, b) => b.subscribedAt.compareTo(a.subscribedAt));
    return entries;
  }

  @override
  Future<List<SeriesSubscription>> listSubscriptions({
    bool activeOnly = true,
    int limit = 100,
    int offset = 0,
  }) async {
    final all = await _all();
    final filtered = activeOnly
        ? all.where((item) => item.isActive).toList()
        : all;
    if (offset >= filtered.length) return <SeriesSubscription>[];
    final end = (offset + limit).clamp(0, filtered.length);
    return filtered.sublist(offset, end);
  }

  @override
  Future<SeriesSubscription?> getSubscriptionBySeriesId(
    int metronSeriesId,
  ) async {
    final box = await _hiveService.openBox<Map>(_boxName);
    final raw = box.get(metronSeriesId.toString());
    if (raw == null) return null;
    return _fromMap(raw.cast<String, dynamic>());
  }

  @override
  Future<SeriesSubscription> subscribe({
    required int metronSeriesId,
    bool autoAddToPullList = true,
  }) async {
    final box = await _hiveService.openBox<Map>(_boxName);
    final existingRaw = box.get(metronSeriesId.toString());
    final existing = existingRaw == null
        ? null
        : _fromMap(existingRaw.cast<String, dynamic>());
    final now = DateTime.now().toUtc();
    final value = SeriesSubscription(
      id: existing?.id ?? _idForSeries(metronSeriesId),
      userId: _localUserId,
      metronSeriesId: metronSeriesId,
      isActive: true,
      autoAddToPullList: autoAddToPullList,
      subscribedAt: existing?.subscribedAt ?? now,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );
    await box.put(metronSeriesId.toString(), _toMap(value));
    return value;
  }

  @override
  Future<void> unsubscribe(int metronSeriesId) async {
    final current = await getSubscriptionBySeriesId(metronSeriesId);
    if (current == null) return;
    final updated = SeriesSubscription(
      id: current.id,
      userId: current.userId,
      metronSeriesId: current.metronSeriesId,
      isActive: false,
      autoAddToPullList: current.autoAddToPullList,
      subscribedAt: current.subscribedAt,
      createdAt: current.createdAt,
      updatedAt: DateTime.now().toUtc(),
    );
    final box = await _hiveService.openBox<Map>(_boxName);
    await box.put(metronSeriesId.toString(), _toMap(updated));
  }

  @override
  Future<SeriesSubscription> setAutoAddToPullList({
    required int metronSeriesId,
    required bool enabled,
  }) async {
    final current = await getSubscriptionBySeriesId(metronSeriesId);
    if (current == null) {
      return subscribe(
        metronSeriesId: metronSeriesId,
        autoAddToPullList: enabled,
      );
    }
    final updated = SeriesSubscription(
      id: current.id,
      userId: current.userId,
      metronSeriesId: current.metronSeriesId,
      isActive: current.isActive,
      autoAddToPullList: enabled,
      subscribedAt: current.subscribedAt,
      createdAt: current.createdAt,
      updatedAt: DateTime.now().toUtc(),
    );
    final box = await _hiveService.openBox<Map>(_boxName);
    await box.put(metronSeriesId.toString(), _toMap(updated));
    return updated;
  }
}
