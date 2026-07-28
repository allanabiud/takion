import 'package:takion/src/domain/entities.dart';

abstract class LibraryRepository {
  Future<int> getItemCount();

  Future<List<LibraryItem>> listItems({int limit = 50, int offset = 0});

  Future<LibraryItem?> getItemByIssueId(int metronIssueId);

  Future<List<LibraryItem>> getItemsBySeriesId(int metronSeriesId);

  Future<void> batchUpsertItems(int seriesId, List<LibraryItem> items);

  Future<void> batchDeleteItemsByIssueId(List<int> metronIssueIds);

  Future<void> batchAddReadLogs(List<LibraryReadLog> logs);

  Future<void> batchDeleteReadLogsByItemIds(List<String> collectionItemIds);

  Future<LibraryItem> upsertItem({
    required int metronIssueId,
    required int metronSeriesId,
    required LibraryOwnershipStatus ownershipStatus,
    bool isRead = false,
    int? rating,
    DateTime? purchaseDate,
    double? pricePaid,
    int quantityOwned = 1,
    LibraryItemFormat format = LibraryItemFormat.print,
    DateTime? firstReadAt,
    String? conditionGrade,
    DateTime? acquiredOn,
    String? notes,
  });

  Future<List<LibraryReadLog>> getReadLogsByIssueId(int metronIssueId);

  Future<LibraryReadLog> addReadLog({
    required int metronIssueId,
    required DateTime readAt,
    String? notes,
  });

  Future<void> deleteReadLogById(String readLogId);

  Future<void> deleteItemByIssueId(int metronIssueId);

  Future<Set<int>> getOwnedIssueIds(List<int> metronIssueIds);

  Future<void> updateItemPricePaid(int metronIssueId, double pricePaid);
}
