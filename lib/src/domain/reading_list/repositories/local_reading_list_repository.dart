import 'package:takion/src/domain/entities.dart';

abstract class LocalReadingListRepository {
  Future<void> createList(LocalReadingList list);
  Future<void> updateList(LocalReadingList list);
  Future<void> deleteList(String id);
  Future<List<LocalReadingList>> getAllLists();
  Future<LocalReadingList?> getListById(String id);
  Future<void> addItemToList(String listId, LocalReadingListItem item);
  Future<void> addItemsToList(String listId, List<LocalReadingListItem> items);
  Future<void> removeItemFromList(String listId, String targetId);
  Future<bool> isItemInList(String listId, String targetId);
  Future<LocalReadingList?> findByMetronSourceId(int metronSourceId);
  Future<LocalReadingList?> findByMetronArcId(int metronArcId);
}
