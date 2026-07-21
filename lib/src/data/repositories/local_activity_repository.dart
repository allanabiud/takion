import 'package:takion/src/core/storage/hive_service.dart';
import 'package:takion/src/domain/entities/entities.dart';
import 'package:takion/src/domain/repositories/repositories.dart';

class LocalActivityRepository implements ActivityRepository {
  LocalActivityRepository(this._hiveService);

  static const _boxName = 'local_library_activity_box';
  static const _localUserId = 'local-user';

  final HiveService _hiveService;

  @override
  Future<void> addEvent(LibraryActivityEvent event) async {
    final box = await _hiveService.openBox<Map>(_boxName);
    await box.put(event.id, {
      'id': event.id,
      'userId': event.userId,
      'type': event.type.name,
      'issueId': event.issueId,
      'seriesId': event.seriesId,
      'seriesName': event.seriesName,
      'issueNumber': event.issueNumber,
      'imageUrl': event.imageUrl,
      'timestamp': event.timestamp.millisecondsSinceEpoch,
      'metadata': event.metadata,
    });
    await _hiveService.recordTimestamp(_boxName, event.id);
  }

  @override
  Future<List<LibraryActivityEvent>> listEvents({
    int limit = 50,
    int offset = 0,
    ActivityEventType? typeFilter,
  }) async {
    final box = await _hiveService.openBox<Map>(_boxName);
    final allEntries = box.toMap().entries.toList()
      ..sort((a, b) {
        final aTs = (a.value['timestamp'] as int?) ?? 0;
        final bTs = (b.value['timestamp'] as int?) ?? 0;
        return bTs.compareTo(aTs);
      });

    final filtered = typeFilter != null
        ? (typeFilter == ActivityEventType.read
            ? allEntries.where((e) =>
                e.value['type'] == ActivityEventType.read.name ||
                e.value['type'] == ActivityEventType.rated.name)
            : allEntries.where((e) => e.value['type'] == typeFilter.name))
        : allEntries;

    final paginated = filtered.skip(offset).take(limit);

    return paginated.map((entry) => _fromMap(entry.value)).toList();
  }

  @override
  Future<List<LibraryActivityEvent>> getEventsBySeries(int seriesId) async {
    final box = await _hiveService.openBox<Map>(_boxName);
    final entries = box.toMap().entries.where(
      (e) => (e.value['seriesId'] as int?) == seriesId,
    );
    final sorted = entries.toList()
      ..sort((a, b) {
        final aTs = (a.value['timestamp'] as int?) ?? 0;
        final bTs = (b.value['timestamp'] as int?) ?? 0;
        return bTs.compareTo(aTs);
      });
    return sorted.map((e) => _fromMap(e.value)).toList();
  }

  @override
  Future<int> count({ActivityEventType? typeFilter}) async {
    final box = await _hiveService.openBox<Map>(_boxName);
    if (typeFilter == null) return box.length;
    if (typeFilter == ActivityEventType.read) {
      return box.toMap().values
          .where((v) =>
              v['type'] == ActivityEventType.read.name ||
              v['type'] == ActivityEventType.rated.name)
          .length;
    }
    return box.toMap().values
        .where((v) => v['type'] == typeFilter.name)
        .length;
  }


  LibraryActivityEvent _fromMap(Map map) {
    return LibraryActivityEvent(
      id: map['id'] as String,
      userId: map['userId'] as String? ?? _localUserId,
      type: ActivityEventType.values.firstWhere(
        (t) => t.name == map['type'],
      ),
      issueId: map['issueId'] as int,
      seriesId: map['seriesId'] as int,
      seriesName: map['seriesName'] as String?,
      issueNumber: map['issueNumber'] as String?,
      imageUrl: map['imageUrl'] as String?,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      metadata: (map['metadata'] as Map?)?.cast<String, dynamic>(),
    );
  }
}



