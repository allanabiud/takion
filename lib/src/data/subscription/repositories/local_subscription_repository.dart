import "package:drift/drift.dart";
import "package:takion/src/core/sync/offline_queue/offline_write_queue.dart";
import "package:takion/src/data/common/drift/database.dart" as db;
import "package:takion/src/domain/entities.dart";
import "package:takion/src/domain/repositories.dart";

class LocalSubscriptionRepository implements SubscriptionRepository {
  LocalSubscriptionRepository(
    this._database, {
    OfflineWriteQueue? offlineQueue,
  }) : _offlineQueue = offlineQueue;

  static const _localUserId = "local-user";

  final db.AppDatabase _database;
  final OfflineWriteQueue? _offlineQueue;

  String _idForSeries(int seriesId) => "sub-$seriesId";

  SeriesSubscription _toDomain(db.SeriesSubscription d) {
    return SeriesSubscription(
      id: d.id,
      userId: d.userId,
      metronSeriesId: d.metronSeriesId,
      metronPullListId: d.metronPullListId,
      syncStatus: d.syncStatus,
      isActive: d.isActive,
      autoAddToPullList: d.autoAddPull,
      subscribedAt: DateTime.parse(d.subscribedAt),
      createdAt: DateTime.parse(d.createdAt),
      updatedAt: DateTime.parse(d.updatedAt),
    );
  }

  @override
  Stream<SeriesSubscription?> watchSubscriptionBySeriesId(int metronSeriesId) {
    return _database.subscriptionDao
        .watchBySeriesId(metronSeriesId)
        .map((row) => row == null ? null : _toDomain(row));
  }

  @override
  Future<List<SeriesSubscription>> listSubscriptions({
    bool activeOnly = true,
    int limit = 100,
    int offset = 0,
  }) async {
    final rows = await _database.subscriptionDao.getSubscriptions(
      activeOnly: activeOnly,
      limit: limit,
      offset: offset,
    );
    return rows.map(_toDomain).toList();
  }

  @override
  Future<SeriesSubscription?> getSubscriptionBySeriesId(
    int metronSeriesId,
  ) async {
    final d = await _database.subscriptionDao.getBySeriesId(metronSeriesId);
    return d != null ? _toDomain(d) : null;
  }

  @override
  Future<SeriesSubscription> subscribe({
    required int metronSeriesId,
    bool autoAddToPullList = true,
  }) async {
    final existing = await _database.subscriptionDao.getBySeriesId(
      metronSeriesId,
    );
    final now = DateTime.now().toUtc();
    final syncStatus = _offlineQueue != null ? "pending" : (existing?.syncStatus ?? "synced");
    final value = SeriesSubscription(
      id: existing?.id ?? _idForSeries(metronSeriesId),
      userId: _localUserId,
      metronSeriesId: metronSeriesId,
      metronPullListId: existing?.metronPullListId,
      syncStatus: syncStatus,
      isActive: true,
      autoAddToPullList: autoAddToPullList,
      subscribedAt: existing != null
          ? DateTime.parse(existing.subscribedAt)
          : now,
      createdAt: existing != null ? DateTime.parse(existing.createdAt) : now,
      updatedAt: now,
    );

    await _database.subscriptionDao.upsert(
      db.SeriesSubscriptionsCompanion(
        id: Value(value.id),
        userId: Value(value.userId),
        metronSeriesId: Value(value.metronSeriesId),
        metronPullListId: Value(value.metronPullListId),
        syncStatus: Value(value.syncStatus),
        isActive: Value(value.isActive),
        autoAddPull: Value(value.autoAddToPullList),
        subscribedAt: Value(value.subscribedAt.toIso8601String()),
        createdAt: Value(value.createdAt.toIso8601String()),
        updatedAt: Value(value.updatedAt.toIso8601String()),
      ),
    );

    if (_offlineQueue != null) {
      await _offlineQueue.enqueuePullListAdd(seriesId: metronSeriesId);
    }

    return value;
  }

  @override
  Future<void> unsubscribe(int metronSeriesId) async {
    final current = await getSubscriptionBySeriesId(metronSeriesId);
    if (current == null) return;
    final now = DateTime.now().toUtc();
    final syncStatus = _offlineQueue != null ? "pending" : "synced";
    final updated = SeriesSubscription(
      id: current.id,
      userId: current.userId,
      metronSeriesId: current.metronSeriesId,
      metronPullListId: current.metronPullListId,
      syncStatus: syncStatus,
      isActive: false,
      autoAddToPullList: current.autoAddToPullList,
      subscribedAt: current.subscribedAt,
      createdAt: current.createdAt,
      updatedAt: now,
    );
    await _database.subscriptionDao.upsert(
      db.SeriesSubscriptionsCompanion(
        id: Value(updated.id),
        userId: Value(updated.userId),
        metronSeriesId: Value(updated.metronSeriesId),
        metronPullListId: Value(updated.metronPullListId),
        syncStatus: Value(updated.syncStatus),
        isActive: Value(updated.isActive),
        autoAddPull: Value(updated.autoAddToPullList),
        subscribedAt: Value(updated.subscribedAt.toIso8601String()),
        createdAt: Value(updated.createdAt.toIso8601String()),
        updatedAt: Value(updated.updatedAt.toIso8601String()),
      ),
    );

    if (_offlineQueue != null) {
      await _offlineQueue.enqueuePullListRemove(seriesId: metronSeriesId);
    }
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
    final now = DateTime.now().toUtc();
    final updated = SeriesSubscription(
      id: current.id,
      userId: current.userId,
      metronSeriesId: current.metronSeriesId,
      isActive: current.isActive,
      autoAddToPullList: enabled,
      subscribedAt: current.subscribedAt,
      createdAt: current.createdAt,
      updatedAt: now,
    );
    await _database.subscriptionDao.upsert(
      db.SeriesSubscriptionsCompanion(
        id: Value(updated.id),
        userId: Value(updated.userId),
        metronSeriesId: Value(updated.metronSeriesId),
        isActive: Value(updated.isActive),
        autoAddPull: Value(updated.autoAddToPullList),
        subscribedAt: Value(updated.subscribedAt.toIso8601String()),
        createdAt: Value(updated.createdAt.toIso8601String()),
        updatedAt: Value(updated.updatedAt.toIso8601String()),
      ),
    );
    return updated;
  }
}
