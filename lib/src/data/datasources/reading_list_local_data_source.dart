import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/storage/hive_service.dart';
import 'package:takion/src/domain/entities/reading_list.dart';
import 'package:hive_ce/hive.dart';

final readingListLocalDataSourceProvider = Provider((ref) {
  return ReadingListLocalDataSource(ref.read(hiveServiceProvider));
});

class ReadingListLocalDataSource {
  final HiveService _hiveService;
  static const String _boxName = 'reading_lists_box';

  ReadingListLocalDataSource(this._hiveService);

  Future<Box<ReadingList>> _getBox() async {
    return _hiveService.openBox<ReadingList>(_boxName);
  }

  Future<void> saveList(ReadingList list) async {
    final box = await _getBox();
    await box.put(list.id, list);
  }

  Future<void> deleteList(String id) async {
    final box = await _getBox();
    await box.delete(id);
  }

  Future<List<ReadingList>> getAllLists() async {
    final box = await _getBox();
    return box.values.toList();
  }

  Future<ReadingList?> getListById(String id) async {
    final box = await _getBox();
    return box.get(id);
  }
}
