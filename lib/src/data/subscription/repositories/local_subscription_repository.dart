import "package:takion/src/core/commands/pull_list_command_service.dart";
import "package:takion/src/core/sync/offline_queue/offline_write_queue.dart";
import "package:takion/src/data/common/drift/database.dart" as db;
import "package:takion/src/domain/entities.dart";
import "package:takion/src/domain/repositories.dart";

class LocalSubscriptionRepository implements SubscriptionRepository {
  LocalSubscriptionRepository(
    this._database, {
    OfflineWriteQueue? offlineQueue,
    PullListCommandService? commandService,
  }) : _commandService = commandService ?? PullListCommandService(_database);

  final db.AppDatabase _database;
  final PullListCommandService _commandService;

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
    final sub = await _commandService.subscribe(
      seriesId: metronSeriesId,
      autoAddToPullList: autoAddToPullList,
    );

    return _toDomain(sub);
  }

  @override
  Future<void> unsubscribe(int metronSeriesId) async {
    await _commandService.unsubscribe(seriesId: metronSeriesId);
  }

  @override
  Future<SeriesSubscription> setAutoAddToPullList({
    required int metronSeriesId,
    required bool enabled,
  }) async {
    final sub = await _commandService.setAutoAddToPullList(
      seriesId: metronSeriesId,
      enabled: enabled,
    );
    return _toDomain(sub);
  }
}
