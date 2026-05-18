import 'package:takion/src/domain/entities/reading_list.dart';

abstract class ReadingListRepository {
  Future<void> createList(ReadingList list);
  Future<void> updateList(ReadingList list);
  Future<void> deleteList(String id);
  Future<List<ReadingList>> getAllLists();
  Future<ReadingList?> getListById(String id);
  Future<void> addItemToList(String listId, ReadingListItem item);
  Future<void> addItemsToList(String listId, List<ReadingListItem> items);
  Future<void> removeItemFromList(String listId, String targetId);
  Future<bool> isItemInList(String listId, String targetId);
}
