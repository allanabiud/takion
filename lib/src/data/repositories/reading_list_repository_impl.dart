import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/data/datasources/reading_list_local_data_source.dart';
import 'package:takion/src/domain/entities/reading_list.dart';
import 'package:takion/src/domain/repositories/reading_list_repository.dart';

final readingListRepositoryProvider = Provider<ReadingListRepository>((ref) {
  return ReadingListRepositoryImpl(
    ref.read(readingListLocalDataSourceProvider),
  );
});

class ReadingListRepositoryImpl implements ReadingListRepository {
  final ReadingListLocalDataSource _dataSource;

  ReadingListRepositoryImpl(this._dataSource);

  @override
  Future<void> createList(ReadingList list) => _dataSource.saveList(list);

  @override
  Future<void> updateList(ReadingList list) => _dataSource.saveList(list);

  @override
  Future<void> deleteList(String id) => _dataSource.deleteList(id);

  @override
  Future<List<ReadingList>> getAllLists() => _dataSource.getAllLists();

  @override
  Future<ReadingList?> getListById(String id) => _dataSource.getListById(id);

  @override
  Future<void> addItemToList(String listId, ReadingListItem item) async {
    final list = await _dataSource.getListById(listId);
    if (list != null) {
      if (list.items.any((i) => i.targetId == item.targetId)) return;
      final updatedItems = List<ReadingListItem>.from(list.items)..add(item);
      final updatedList = list.copyWith(
        items: updatedItems,
        updatedAt: DateTime.now(),
      );
      await _dataSource.saveList(updatedList);
    }
  }

  @override
  Future<void> addItemsToList(
    String listId,
    List<ReadingListItem> items,
  ) async {
    final list = await _dataSource.getListById(listId);
    if (list != null) {
      final existingIds = list.items.map((i) => i.targetId).toSet();
      final newUniqueItems = items
          .where((i) => !existingIds.contains(i.targetId))
          .toList();

      if (newUniqueItems.isEmpty) return;

      final updatedItems = List<ReadingListItem>.from(list.items)
        ..addAll(newUniqueItems);
      final updatedList = list.copyWith(
        items: updatedItems,
        updatedAt: DateTime.now(),
      );
      await _dataSource.saveList(updatedList);
    }
  }

  @override
  Future<void> removeItemFromList(String listId, String targetId) async {
    final list = await _dataSource.getListById(listId);
    if (list != null) {
      final updatedItems = list.items
          .where((item) => item.targetId != targetId)
          .toList();
      final updatedList = list.copyWith(
        items: updatedItems,
        updatedAt: DateTime.now(),
      );
      await _dataSource.saveList(updatedList);
    }
  }
}
