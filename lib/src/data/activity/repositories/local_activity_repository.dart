import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:takion/src/data/common/drift/database.dart' as db;
import 'package:takion/src/domain/entities.dart';
import 'package:takion/src/domain/repositories.dart';

class LocalActivityRepository implements ActivityRepository {
  LocalActivityRepository(this._database);

  final db.AppDatabase _database;

  LibraryActivityEvent _toDomain(db.ActivityEvent d) {
    return LibraryActivityEvent(
      id: d.id,
      userId: d.userId,
      type: ActivityEventType.values.firstWhere((t) => t.name == d.eventType),
      issueId: d.issueId ?? 0,
      seriesId: d.seriesId ?? 0,
      seriesName: d.seriesName,
      issueNumber: d.issueNumber,
      imageUrl: d.imageUrl,
      timestamp: DateTime.parse(d.timestamp),
      metadata: d.metadata != null && d.metadata!.isNotEmpty
          ? jsonDecode(d.metadata!) as Map<String, dynamic>
          : null,
    );
  }

  String _metadataToRaw(Map<String, dynamic>? metadata) {
    if (metadata == null || metadata.isEmpty) return '';
    return jsonEncode(metadata);
  }

  @override
  Future<void> addEvent(LibraryActivityEvent event) async {
    await _database.activityDao.insert(
      db.ActivityEventsCompanion(
        id: Value(event.id),
        userId: Value(event.userId),
        eventType: Value(event.type.name),
        issueId: Value(event.issueId),
        seriesId: Value(event.seriesId),
        seriesName: Value(event.seriesName),
        issueNumber: Value(event.issueNumber),
        imageUrl: Value(event.imageUrl),
        metadata: Value(_metadataToRaw(event.metadata)),
        timestamp: Value(event.timestamp.toIso8601String()),
      ),
    );
  }

  @override
  Future<void> batchAddEvents(List<LibraryActivityEvent> events) async {
    if (events.isEmpty) return;
    final companions = events
        .map(
          (event) => db.ActivityEventsCompanion(
            id: Value(event.id),
            userId: Value(event.userId),
            eventType: Value(event.type.name),
            issueId: Value(event.issueId),
            seriesId: Value(event.seriesId),
            seriesName: Value(event.seriesName),
            issueNumber: Value(event.issueNumber),
            imageUrl: Value(event.imageUrl),
            metadata: Value(_metadataToRaw(event.metadata)),
            timestamp: Value(event.timestamp.toIso8601String()),
          ),
        )
        .toList();
    await _database.activityDao.batchInsert(companions);
  }

  @override
  Future<List<LibraryActivityEvent>> listEvents({
    int limit = 50,
    int offset = 0,
    ActivityEventType? typeFilter,
  }) async {
    final rows = await _database.activityDao.watchAll().first;
    var events = rows.map(_toDomain).toList();
    if (typeFilter != null) {
      events = events.where((e) => e.type == typeFilter).toList();
    }
    if (offset >= events.length) return <LibraryActivityEvent>[];
    final end = (offset + limit).clamp(0, events.length);
    return events.sublist(offset, end);
  }

  @override
  Future<List<LibraryActivityEvent>> getEventsBySeries(int seriesId) async {
    final rows = await _database.activityDao.watchBySeriesId(seriesId).first;
    return rows.map(_toDomain).toList();
  }

  @override
  Stream<List<LibraryActivityEvent>> watchRecent({int limit = 100}) {
    return _database.activityDao
        .watchRecent(limit: limit)
        .map((rows) => rows.map(_toDomain).toList());
  }

  @override
  Stream<List<LibraryActivityEvent>> watchBySeriesId(int seriesId) {
    return _database.activityDao
        .watchBySeriesId(seriesId)
        .map((rows) => rows.map(_toDomain).toList());
  }

  @override
  Future<int> count({ActivityEventType? typeFilter}) async {
    final all = await _database.activityDao.watchAll().first;
    if (typeFilter == null) return all.length;
    return all.where((d) => d.eventType == typeFilter.name).length;
  }

  @override
  Future<void> deleteEventsByIssueIds(
    List<int> issueIds, {
    ActivityEventType? type,
  }) async {
    await _database.activityDao.deleteByIssueIds(
      issueIds,
      eventType: type?.name,
    );
  }
}
