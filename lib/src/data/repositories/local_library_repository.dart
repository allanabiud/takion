import 'package:takion/src/core/storage/hive_service.dart';
import 'package:takion/src/domain/entities/library_item.dart';
import 'package:takion/src/domain/entities/library_read_log.dart';
import 'package:takion/src/domain/repositories/library_repository.dart';

class LocalLibraryRepository implements LibraryRepository {
  LocalLibraryRepository(this._hiveService);

  static const _localUserId = 'local-user';
  static const itemsBoxName = 'local_library_items_box';
  static const readLogsBoxName = 'local_library_read_logs_box';
  static const _itemsBox = itemsBoxName;
  static const _readLogsBox = readLogsBoxName;

  final HiveService _hiveService;

  String _idForIssue(int issueId) => 'lib-$issueId';

  String _readLogId(int issueId) =>
      'read-$issueId-${DateTime.now().microsecondsSinceEpoch}';

  String _ownershipToRaw(LibraryOwnershipStatus status) {
    switch (status) {
      case LibraryOwnershipStatus.owned:
        return 'owned';
      case LibraryOwnershipStatus.notOwned:
        return 'not_owned';
      case LibraryOwnershipStatus.wishlist:
        return 'wishlist';
    }
  }

  LibraryOwnershipStatus _ownershipFromRaw(String raw) {
    switch (raw) {
      case 'owned':
        return LibraryOwnershipStatus.owned;
      case 'wishlist':
        return LibraryOwnershipStatus.wishlist;
      case 'not_owned':
      default:
        return LibraryOwnershipStatus.notOwned;
    }
  }

  String _formatToRaw(LibraryItemFormat format) {
    switch (format) {
      case LibraryItemFormat.print:
        return 'print';
      case LibraryItemFormat.digital:
        return 'digital';
      case LibraryItemFormat.both:
        return 'both';
    }
  }

  LibraryItemFormat _formatFromRaw(String raw) {
    switch (raw) {
      case 'digital':
        return LibraryItemFormat.digital;
      case 'both':
        return LibraryItemFormat.both;
      case 'print':
      default:
        return LibraryItemFormat.print;
    }
  }

  Map<String, dynamic> _itemToMap(LibraryItem item) {
    return {
      'id': item.id,
      'user_id': item.userId,
      'metron_issue_id': item.metronIssueId,
      'metron_series_id': item.metronSeriesId,
      'ownership_status': _ownershipToRaw(item.ownershipStatus),
      'is_read': item.isRead,
      'rating': item.rating,
      'purchase_date': item.purchaseDate?.toIso8601String(),
      'price_paid': item.pricePaid,
      'quantity_owned': item.quantityOwned,
      'format': _formatToRaw(item.format),
      'first_read_at': item.firstReadAt?.toIso8601String(),
      'condition_grade': item.conditionGrade,
      'acquired_on': item.acquiredOn?.toIso8601String(),
      'notes': item.notes,
      'created_at': item.createdAt.toIso8601String(),
      'updated_at': item.updatedAt.toIso8601String(),
    };
  }

  LibraryItem _itemFromMap(Map<String, dynamic> map) {
    return LibraryItem(
      id: map['id'] as String,
      userId: map['user_id'] as String? ?? _localUserId,
      metronIssueId: map['metron_issue_id'] as int,
      metronSeriesId: map['metron_series_id'] as int,
      ownershipStatus: _ownershipFromRaw(map['ownership_status'] as String),
      isRead: map['is_read'] as bool? ?? false,
      rating: map['rating'] as int?,
      purchaseDate: DateTime.tryParse(map['purchase_date'] as String? ?? ''),
      pricePaid: (map['price_paid'] as num?)?.toDouble(),
      quantityOwned: (map['quantity_owned'] as num?)?.toInt() ?? 1,
      format: _formatFromRaw(map['format'] as String? ?? 'print'),
      firstReadAt: DateTime.tryParse(map['first_read_at'] as String? ?? ''),
      conditionGrade: map['condition_grade'] as String?,
      acquiredOn: DateTime.tryParse(map['acquired_on'] as String? ?? ''),
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> _readLogToMap(LibraryReadLog log) {
    return {
      'id': log.id,
      'user_id': log.userId,
      'collection_item_id': log.collectionItemId,
      'read_at': log.readAt.toIso8601String(),
      'notes': log.notes,
      'created_at': log.createdAt.toIso8601String(),
    };
  }

  LibraryReadLog _readLogFromMap(Map<String, dynamic> map) {
    return LibraryReadLog(
      id: map['id'] as String,
      userId: map['user_id'] as String? ?? _localUserId,
      collectionItemId: map['collection_item_id'] as String,
      readAt: DateTime.parse(map['read_at'] as String),
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Future<List<LibraryItem>> _allItems() async {
    final box = await _hiveService.openBox<Map>(_itemsBox);
    final items = box.values
        .map((raw) => _itemFromMap(raw.cast<String, dynamic>()))
        .toList();
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  @override
  Future<int> getItemCount() async => (await _allItems()).length;

  @override
  Future<List<LibraryItem>> listItems({int limit = 50, int offset = 0}) async {
    final items = await _allItems();
    if (offset >= items.length) return <LibraryItem>[];
    final end = (offset + limit).clamp(0, items.length);
    return items.sublist(offset, end);
  }

  @override
  Future<LibraryItem?> getItemByIssueId(int metronIssueId) async {
    final box = await _hiveService.openBox<Map>(_itemsBox);
    final raw = box.get(metronIssueId.toString());
    if (raw == null) return null;
    return _itemFromMap(raw.cast<String, dynamic>());
  }

  @override
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
  }) async {
    final box = await _hiveService.openBox<Map>(_itemsBox);
    final existingRaw = box.get(metronIssueId.toString());
    final existing = existingRaw == null
        ? null
        : _itemFromMap(existingRaw.cast<String, dynamic>());

    double? resolvedPricePaid;
    if (pricePaid != null) {
      resolvedPricePaid = pricePaid;
    } else if (existing != null) {
      resolvedPricePaid = existing.pricePaid;
    } else {
      resolvedPricePaid = await _hiveService.getIssuePrice(metronIssueId);
    }

    final now = DateTime.now().toUtc();
    final item = LibraryItem(
      id: existing?.id ?? _idForIssue(metronIssueId),
      userId: _localUserId,
      metronIssueId: metronIssueId,
      metronSeriesId: metronSeriesId,
      ownershipStatus: ownershipStatus,
      isRead: isRead,
      rating: rating,
      purchaseDate: purchaseDate,
      pricePaid: resolvedPricePaid,
      quantityOwned: quantityOwned,
      format: format,
      firstReadAt: firstReadAt,
      conditionGrade: conditionGrade,
      acquiredOn: acquiredOn,
      notes: notes,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );
    await box.put(metronIssueId.toString(), _itemToMap(item));
    await _hiveService.recordTimestamp(itemsBoxName, metronIssueId.toString());
    return item;
  }

  @override
  Future<List<LibraryReadLog>> getReadLogsByIssueId(int metronIssueId) async {
    final item = await getItemByIssueId(metronIssueId);
    if (item == null) return <LibraryReadLog>[];
    final box = await _hiveService.openBox<Map>(_readLogsBox);
    final logs = box.values
        .map((raw) => _readLogFromMap(raw.cast<String, dynamic>()))
        .where((log) => log.collectionItemId == item.id)
        .toList();
    logs.sort((a, b) => b.readAt.compareTo(a.readAt));
    return logs;
  }

  @override
  Future<LibraryReadLog> addReadLog({
    required int metronIssueId,
    required DateTime readAt,
    String? notes,
  }) async {
    final item = await getItemByIssueId(metronIssueId);
    if (item == null) {
      throw StateError('Library item does not exist for issue $metronIssueId');
    }

    final now = DateTime.now().toUtc();
    final log = LibraryReadLog(
      id: _readLogId(metronIssueId),
      userId: _localUserId,
      collectionItemId: item.id,
      readAt: readAt,
      notes: notes,
      createdAt: now,
    );
    final box = await _hiveService.openBox<Map>(_readLogsBox);
    await box.put(log.id, _readLogToMap(log));
    await _hiveService.recordTimestamp(readLogsBoxName, log.id);
    return log;
  }

  @override
  Future<void> deleteReadLogById(String readLogId) async {
    final box = await _hiveService.openBox<Map>(_readLogsBox);
    await box.delete(readLogId);
    await _hiveService.deleteTimestamp(readLogsBoxName, readLogId);
  }

  @override
  Future<void> deleteItemByIssueId(int metronIssueId) async {
    final item = await getItemByIssueId(metronIssueId);
    final itemsBox = await _hiveService.openBox<Map>(_itemsBox);
    await itemsBox.delete(metronIssueId.toString());
    await _hiveService.deleteTimestamp(itemsBoxName, metronIssueId.toString());

    if (item == null) return;
    final logsBox = await _hiveService.openBox<Map>(_readLogsBox);
    final keysToDelete = logsBox.keys
        .where((key) {
          final raw = logsBox.get(key);
          if (raw is! Map) return false;
          return raw['collection_item_id'] == item.id;
        })
        .toList(growable: false);
    for (final key in keysToDelete) {
      await logsBox.delete(key);
      await _hiveService.deleteTimestamp(readLogsBoxName, key);
    }
  }

  @override
  Future<Set<int>> getOwnedIssueIds(List<int> metronIssueIds) async {
    if (metronIssueIds.isEmpty) return <int>{};
    final set = metronIssueIds.toSet();
    final items = await _allItems();
    return items
        .where((item) => item.ownershipStatus == LibraryOwnershipStatus.owned)
        .map((item) => item.metronIssueId)
        .where(set.contains)
        .toSet();
  }
}
