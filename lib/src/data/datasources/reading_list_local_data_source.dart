import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/storage/hive_service.dart';
import 'package:takion/src/domain/entities/entities.dart';
import 'package:takion/src/domain/repositories/repositories.dart';
import 'package:hive_ce/hive.dart';
import 'package:takion/src/core/logging/app_logger.dart';

final readingListLocalDataSourceProvider = Provider<ReadingListRepository>((ref) {
  return ReadingListLocalDataSource(ref.read(hiveServiceProvider));
});

class ReadingListLocalDataSource implements ReadingListRepository {
  final HiveService _hiveService;
  static const String _boxName = 'reading_lists_box';

  ReadingListLocalDataSource(this._hiveService);

  Future<Box<ReadingList>> _getBox() async {
    return _hiveService.openBox<ReadingList>(_boxName);
  }

  @override
  Future<void> createList(ReadingList list) async {
    final box = await _getBox();
    await box.put(list.id, list);
    await _hiveService.recordTimestamp(_boxName, list.id);
  }

  @override
  Future<void> updateList(ReadingList list) async {
    final box = await _getBox();
    await box.put(list.id, list);
    await _hiveService.recordTimestamp(_boxName, list.id);
  }

  @override
  Future<void> deleteList(String id) async {
    final box = await _getBox();
    await box.delete(id);
    await _hiveService.deleteTimestamp(_boxName, id);
  }

  @override
  Future<List<ReadingList>> getAllLists() async {
    final box = await _getBox();
    return box.values.toList();
  }

  @override
  Future<ReadingList?> getListById(String id) async {
    final box = await _getBox();
    return box.get(id);
  }

  @override
  Future<void> addItemToList(String listId, ReadingListItem item) async {
    final box = await _getBox();
    final list = box.get(listId);
    if (list == null) return;
    final items = List<ReadingListItem>.from(list.items)..add(item);
    await box.put(listId, list.copyWith(items: items, updatedAt: DateTime.now()));
    await _hiveService.recordTimestamp(_boxName, listId);
  }

  @override
  Future<void> addItemsToList(String listId, List<ReadingListItem> items) async {
    final box = await _getBox();
    final list = box.get(listId);
    if (list == null) return;
    final updatedItems = List<ReadingListItem>.from(list.items)..addAll(items);
    await box.put(listId, list.copyWith(items: updatedItems, updatedAt: DateTime.now()));
    await _hiveService.recordTimestamp(_boxName, listId);
  }

  @override
  Future<void> removeItemFromList(String listId, String targetId) async {
    final box = await _getBox();
    final list = box.get(listId);
    if (list == null) return;
    final items = list.items.where((i) => i.targetId != targetId).toList();
    await box.put(listId, list.copyWith(items: items, updatedAt: DateTime.now()));
    await _hiveService.recordTimestamp(_boxName, listId);
  }

  @override
  Future<bool> isItemInList(String listId, String targetId) async {
    final box = await _getBox();
    final list = box.get(listId);
    if (list == null) return false;
    return list.items.any((i) => i.targetId == targetId);
  }

  @override
  Future<ReadingList?> findByMetronSourceId(int metronSourceId) async {
    final box = await _getBox();
    try {
      return box.values.firstWhere((l) => l.metronSourceId == metronSourceId);
    } catch (e) {
      AppLogger.verbose('Reading list not found for metronSourceId', error: e);
      return null;
    }
  }
}
