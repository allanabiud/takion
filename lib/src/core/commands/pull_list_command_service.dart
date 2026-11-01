import "package:drift/drift.dart";
import "package:takion/src/core/commands/outbox_constants.dart";
import "package:takion/src/data/common/drift/database.dart" as db;

/// Service that executes pull list series subscription mutations atomically
/// against the local database and records an intent in the durable outbox within
/// the same Drift transaction.
class PullListCommandService {
  PullListCommandService(
    this._database, {
    this.defaultAccountId = "local-user",
  });

  final db.AppDatabase _database;
  final String defaultAccountId;

  String idForSeries(int seriesId) => "sub-$seriesId";

  /// Optimistically subscribes to a series and enqueues pull list add.
  Future<db.SeriesSubscription> subscribe({
    required int seriesId,
    bool autoAddToPullList = true,
    String? accountId,
  }) async {
    final effectiveAccount = accountId ?? defaultAccountId;
    final now = DateTime.now().toUtc();
    final nowIso = now.toIso8601String();
    final localId = idForSeries(seriesId);

    return _database.transaction(() async {
      final existing = await _database.subscriptionDao.getBySeriesId(seriesId);

      final companion = db.SeriesSubscriptionsCompanion(
        id: Value(existing?.id ?? localId),
        userId: Value(effectiveAccount),
        metronSeriesId: Value(seriesId),
        metronPullListId: Value(existing?.metronPullListId),
        syncStatus: const Value(ProjectionSyncState.pending),
        isActive: const Value(true),
        autoAddPull: Value(autoAddToPullList),
        subscribedAt: Value(existing?.subscribedAt ?? nowIso),
        remoteModified: Value(existing?.remoteModified),
        deletedAt: const Value(null),
        createdAt: Value(existing?.createdAt ?? nowIso),
        updatedAt: Value(nowIso),
      );

      await _database.subscriptionDao.upsert(companion);

      await _database.outboxDao.coalesceCreate(
        accountId: effectiveAccount,
        entityType: OutboxEntityType.subscription,
        entityLocalId: localId,
        entityRemoteId: existing?.metronPullListId,
        coalesceKey: "subscription:$seriesId",
        payload: <String, dynamic>{"series": seriesId},
        baseRemoteModified: existing?.remoteModified,
      );

      final result = await _database.subscriptionDao.getBySeriesId(seriesId);
      return result!;
    });
  }

  /// Optimistically unsubscribes from a series and enqueues pull list remove.
  Future<void> unsubscribe({required int seriesId, String? accountId}) async {
    final effectiveAccount = accountId ?? defaultAccountId;
    final localId = idForSeries(seriesId);

    await _database.transaction(() async {
      final existing = await _database.subscriptionDao.getBySeriesId(seriesId);
      if (existing == null) return;

      if (existing.metronPullListId == null) {
        // Created locally and never reached remote: delete directly and cancel outbox
        await _database.subscriptionDao.deleteById(localId);
        await _database.outboxDao.coalesceDelete(
          accountId: effectiveAccount,
          entityType: OutboxEntityType.subscription,
          entityLocalId: localId,
          coalesceKey: "subscription:$seriesId",
        );
      } else {
        // Exists on remote: mark soft deleted locally and queue remote delete
        await _database.subscriptionDao.applyOptimisticDelete(localId);
        await _database.outboxDao.coalesceDelete(
          accountId: effectiveAccount,
          entityType: OutboxEntityType.subscription,
          entityLocalId: localId,
          entityRemoteId: existing.metronPullListId,
          coalesceKey: "subscription:$seriesId",
          baseRemoteModified: existing.remoteModified,
        );
      }
    });
  }

  /// Toggles the autoAddPull setting for an active subscription.
  Future<db.SeriesSubscription> setAutoAddToPullList({
    required int seriesId,
    required bool enabled,
    String? accountId,
  }) async {
    final localId = idForSeries(seriesId);
    return _database.transaction(() async {
      final existing = await _database.subscriptionDao.getBySeriesId(seriesId);
      if (existing == null) {
        return subscribe(
          seriesId: seriesId,
          autoAddToPullList: enabled,
          accountId: accountId,
        );
      }

      await _database.subscriptionDao.applyOptimisticPatch(
        localId,
        autoAddPull: Value(enabled),
      );

      final updated = await _database.subscriptionDao.getBySeriesId(seriesId);
      return updated!;
    });
  }
}
