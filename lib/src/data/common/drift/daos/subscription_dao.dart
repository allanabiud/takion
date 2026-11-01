import "package:drift/drift.dart";
import "package:takion/src/data/common/drift/database.dart";

class SubscriptionDao extends DatabaseAccessor<AppDatabase> {
  SubscriptionDao(super.db);

  Future<List<SeriesSubscription>> getSubscriptions({
    bool activeOnly = true,
    int limit = 100,
    int offset = 0,
  }) async {
    final query = select(attachedDatabase.seriesSubscriptions);
    if (activeOnly) {
      query.where((t) => t.isActive.equals(true));
    }
    query.orderBy([
      (t) => OrderingTerm(expression: t.subscribedAt, mode: OrderingMode.desc),
    ]);
    query.limit(limit, offset: offset);
    return query.get();
  }

  Future<List<SeriesSubscription>> watchActiveList() async {
    return (select(
      attachedDatabase.seriesSubscriptions,
    )..where((t) => t.isActive.equals(true))).get();
  }

  Stream<List<SeriesSubscription>> watchAll() {
    return select(attachedDatabase.seriesSubscriptions).watch();
  }

  Stream<List<SeriesSubscription>> watchActive() {
    return (select(
      attachedDatabase.seriesSubscriptions,
    )..where((t) => t.isActive.equals(true))).watch();
  }

  Stream<SeriesSubscription?> watchBySeriesId(int metronSeriesId) {
    return (select(attachedDatabase.seriesSubscriptions)
          ..where((t) => t.metronSeriesId.equals(metronSeriesId)))
        .watchSingleOrNull();
  }

  Future<SeriesSubscription?> getBySeriesId(int metronSeriesId) async {
    return (select(
      attachedDatabase.seriesSubscriptions,
    )..where((t) => t.metronSeriesId.equals(metronSeriesId))).getSingleOrNull();
  }

  Future<List<SeriesSubscription>> getBySeriesIds(
    List<int> metronSeriesIds,
  ) async {
    if (metronSeriesIds.isEmpty) return [];
    return (select(
      attachedDatabase.seriesSubscriptions,
    )..where((t) => t.metronSeriesId.isIn(metronSeriesIds))).get();
  }

  Future<SeriesSubscription?> getById(String id) => (select(
    attachedDatabase.seriesSubscriptions,
  )..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> applyOptimisticPatch(
    String id, {
    Value<bool>? isActive,
    Value<bool>? autoAddPull,
    Value<String>? syncStatus,
    Value<String?>? remoteModified,
    Value<String?>? deletedAt,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();
    await (update(
      attachedDatabase.seriesSubscriptions,
    )..where((t) => t.id.equals(id))).write(
      SeriesSubscriptionsCompanion(
        isActive: isActive ?? const Value.absent(),
        autoAddPull: autoAddPull ?? const Value.absent(),
        syncStatus: syncStatus ?? const Value.absent(),
        remoteModified: remoteModified ?? const Value.absent(),
        deletedAt: deletedAt ?? const Value.absent(),
        updatedAt: Value(now),
      ),
    );
  }

  Future<void> applyOptimisticDelete(String id) async {
    final now = DateTime.now().toUtc().toIso8601String();
    await (update(
      attachedDatabase.seriesSubscriptions,
    )..where((t) => t.id.equals(id))).write(
      SeriesSubscriptionsCompanion(
        isActive: const Value(false),
        deletedAt: Value(now),
        syncStatus: const Value("pending"),
        updatedAt: Value(now),
      ),
    );
  }

  Future<void> upsert(SeriesSubscriptionsCompanion entry) async {
    await transaction(() async {
      await into(
        attachedDatabase.seriesSubscriptions,
      ).insertOnConflictUpdate(entry);
      if (entry.id.present) {
        await attachedDatabase.syncMetaDao.deleteByKey(
          "delete:series_subscriptions:${entry.id.value}",
        );
      }
    });
  }

  Future<void> deleteById(String id) async {
    await transaction(() async {
      await (delete(
        attachedDatabase.seriesSubscriptions,
      )..where((t) => t.id.equals(id))).go();
      await attachedDatabase.syncMetaDao.set(
        "delete:series_subscriptions:$id",
        DateTime.now().toUtc().toIso8601String(),
      );
    });
  }

  /// Marks local synced subscriptions inactive/deleted if they were missing from complete snapshot [scanId].
  /// Preserves pending local operations.
  Future<int> reconcileMissingFromScan(String scanId) async {
    final missing =
        await (select(attachedDatabase.seriesSubscriptions)..where(
              (t) =>
                  t.syncStatus.equals("synced") &
                  t.isActive.equals(true) &
                  t.deletedAt.isNull() &
                  (t.lastSeenScanId.isNull() |
                      t.lastSeenScanId.equals(scanId).not()),
            ))
            .get();

    final now = DateTime.now().toUtc().toIso8601String();
    for (final sub in missing) {
      await (update(
        attachedDatabase.seriesSubscriptions,
      )..where((t) => t.id.equals(sub.id))).write(
        SeriesSubscriptionsCompanion(
          isActive: const Value(false),
          deletedAt: Value(now),
          syncStatus: const Value("synced"),
          updatedAt: Value(now),
        ),
      );
    }
    return missing.length;
  }
}
