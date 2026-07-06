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

  String _normalizeTargetId(String targetId, bool isSeries) {
    final normalized = targetId.trim().toLowerCase();
    final expectedPrefix = isSeries ? 'series-' : 'issue-';

    if (normalized.startsWith(expectedPrefix)) {
      return normalized;
    }

    final alternatePrefix = isSeries ? 'issue-' : 'series-';
    if (normalized.startsWith(alternatePrefix)) {
      return '$expectedPrefix${normalized.substring(alternatePrefix.length)}';
    }

    return '$expectedPrefix$normalized';
  }

  ReadingList _normalizeListItems(ReadingList list) {
    final uniqueItems = <String, ReadingListItem>{};
    for (final item in list.items) {
      final normalizedTargetId = _normalizeTargetId(
        item.targetId,
        item.isSeries,
      );
      uniqueItems[normalizedTargetId] = item.copyWith(
        targetId: normalizedTargetId,
      );
    }

    return list.copyWith(items: uniqueItems.values.toList());
  }

  @override
  Future<void> createList(ReadingList list) {
    return _dataSource.saveList(_normalizeListItems(list));
  }

  @override
  Future<void> updateList(ReadingList list) {
    return _dataSource.saveList(_normalizeListItems(list));
  }

  @override
  Future<void> deleteList(String id) => _dataSource.deleteList(id);

  @override
  Future<List<ReadingList>> getAllLists() async {
    final lists = await _dataSource.getAllLists();
    return lists.map(_normalizeListItems).toList();
  }

  @override
  Future<ReadingList?> getListById(String id) async {
    final list = await _dataSource.getListById(id);
    return list == null ? null : _normalizeListItems(list);
  }

  @override
  Future<void> addItemToList(String listId, ReadingListItem item) async {
    final list = await _dataSource.getListById(listId);
    if (list != null) {
      final normalizedList = _normalizeListItems(list);
      final normalizedItem = item.copyWith(
        targetId: _normalizeTargetId(item.targetId, item.isSeries),
      );

      if (normalizedList.items.any(
        (i) => i.targetId == normalizedItem.targetId,
      )) {
        return;
      }
      final updatedItems = List<ReadingListItem>.from(normalizedList.items)
        ..add(normalizedItem);
      final updatedList = normalizedList.copyWith(
        items: _normalizeListItems(
          normalizedList.copyWith(items: updatedItems),
        ).items,
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
      final normalizedList = _normalizeListItems(list);
      final existingIds = normalizedList.items.map((i) => i.targetId).toSet();
      final normalizedIncomingItems = items
          .map(
            (item) => item.copyWith(
              targetId: _normalizeTargetId(item.targetId, item.isSeries),
            ),
          )
          .toList();

      final newUniqueItems = normalizedIncomingItems
          .where((i) => !existingIds.contains(i.targetId))
          .toList();

      if (newUniqueItems.isEmpty) return;

      final updatedItems = List<ReadingListItem>.from(normalizedList.items)
        ..addAll(newUniqueItems);
      final updatedList = normalizedList.copyWith(
        items: _normalizeListItems(
          normalizedList.copyWith(items: updatedItems),
        ).items,
        updatedAt: DateTime.now(),
      );
      await _dataSource.saveList(updatedList);
    }
  }

  @override
  Future<void> removeItemFromList(String listId, String targetId) async {
    final list = await _dataSource.getListById(listId);
    if (list != null) {
      final normalizedList = _normalizeListItems(list);
      final normalizedTargetId = _normalizeTargetId(
        targetId,
        list.contentType == ListContentType.series,
      );
      final updatedItems = normalizedList.items
          .where((item) => item.targetId != normalizedTargetId)
          .toList();
      final updatedList = normalizedList.copyWith(
        items: updatedItems,
        updatedAt: DateTime.now(),
      );
      await _dataSource.saveList(updatedList);
    }
  }

  @override
  Future<bool> isItemInList(String listId, String targetId) async {
    final list = await _dataSource.getListById(listId);
    if (list == null) return false;
    final normalizedTargetId = _normalizeTargetId(
      targetId,
      list.contentType == ListContentType.series,
    );
    return _normalizeListItems(
      list,
    ).items.any((item) => item.targetId == normalizedTargetId);
  }

  @override
  Future<ReadingList?> findByMetronSourceId(int metronSourceId) async {
    final all = await _dataSource.getAllLists();
    try {
      return all.firstWhere(
        (list) => list.metronSourceId == metronSourceId,
      );
    } catch (_) {
      return null;
    }
  }
}
