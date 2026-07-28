import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/storage/drift_database_provider.dart';
import 'package:takion/src/data/common/drift/database.dart' as db;
import 'package:takion/src/domain/entities.dart';
import 'package:takion/src/domain/repositories.dart';
import 'package:takion/src/core/logging/app_logger.dart';

final readingListLocalDataSourceProvider = Provider<ReadingListRepository>((
  ref,
) {
  return ReadingListLocalDataSource(ref.read(driftDatabaseProvider));
});

class ReadingListLocalDataSource implements ReadingListRepository {
  final db.AppDatabase _database;

  ReadingListLocalDataSource(this._database);

  ReadingList _toDomain(db.ReadingList d) {
    List<ReadingListItem> items;
    try {
      final decoded = jsonDecode(d.itemsJson) as List<dynamic>;
      items = decoded
          .map((e) => ReadingListItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      AppLogger.warning('Failed to decode reading list items', error: e);
      items = <ReadingListItem>[];
    }

    return ReadingList(
      id: d.id,
      title: d.title,
      description: d.description,
      isOrdered: d.isOrdered,
      contentType: ListContentType.values.firstWhere(
        (t) => t.name == d.contentType,
      ),
      createdAt: DateTime.parse(d.createdAt),
      updatedAt: DateTime.parse(d.updatedAt),
      items: items,
      metronSourceId: d.metronSourceId,
      metronAttributionSource: d.metronAttributionSource,
      metronAttributionUrl: d.metronAttributionUrl,
      metronImageUrl: d.metronImageUrl,
      metronListType: d.metronListType,
      lastSyncedAt: d.lastSyncedAt != null
          ? DateTime.tryParse(d.lastSyncedAt!)
          : null,
    );
  }

  @override
  Future<void> createList(ReadingList list) async {
    await _database.readingListDao.upsertList(
      db.ReadingListsCompanion(
        id: Value(list.id),
        title: Value(list.title),
        description: Value(list.description),
        isOrdered: Value(list.isOrdered),
        contentType: Value(list.contentType.name),
        itemsJson: Value(
          jsonEncode(list.items.map((i) => i.toJson()).toList()),
        ),
        metronSourceId: Value(list.metronSourceId),
        metronAttributionSource: Value(list.metronAttributionSource),
        metronAttributionUrl: Value(list.metronAttributionUrl),
        metronImageUrl: Value(list.metronImageUrl),
        metronListType: Value(list.metronListType),
        lastSyncedAt: Value(list.lastSyncedAt?.toIso8601String()),
        createdAt: Value(list.createdAt.toIso8601String()),
        updatedAt: Value(list.updatedAt.toIso8601String()),
      ),
    );
  }

  @override
  Future<void> updateList(ReadingList list) async {
    await createList(list);
  }

  @override
  Future<void> deleteList(String id) async {
    await _database.readingListDao.deleteById(id);
  }

  @override
  Future<List<ReadingList>> getAllLists() async {
    final rows = await _database.readingListDao.watchAll().first;
    return rows.map(_toDomain).toList();
  }

  @override
  Future<ReadingList?> getListById(String id) async {
    final d = await _database.readingListDao.getById(id);
    return d != null ? _toDomain(d) : null;
  }

  @override
  Future<void> addItemToList(String listId, ReadingListItem item) async {
    final list = await getListById(listId);
    if (list == null) return;
    final items = List<ReadingListItem>.from(list.items)..add(item);
    final updated = list.copyWith(items: items, updatedAt: DateTime.now());
    await updateList(updated);
  }

  @override
  Future<void> addItemsToList(
    String listId,
    List<ReadingListItem> items,
  ) async {
    final list = await getListById(listId);
    if (list == null) return;
    final updatedItems = List<ReadingListItem>.from(list.items)..addAll(items);
    final updated = list.copyWith(
      items: updatedItems,
      updatedAt: DateTime.now(),
    );
    await updateList(updated);
  }

  @override
  Future<void> removeItemFromList(String listId, String targetId) async {
    final list = await getListById(listId);
    if (list == null) return;
    final items = list.items
        .where((item) => item.targetId != targetId)
        .toList();
    final updated = list.copyWith(items: items, updatedAt: DateTime.now());
    await updateList(updated);
  }

  @override
  Future<bool> isItemInList(String listId, String targetId) async {
    final list = await getListById(listId);
    if (list == null) return false;
    return list.items.any((item) => item.targetId == targetId);
  }

  @override
  Future<ReadingList?> findByMetronSourceId(int metronSourceId) async {
    final all = await getAllLists();
    try {
      return all.firstWhere((list) => list.metronSourceId == metronSourceId);
    } catch (_) {
      return null;
    }
  }
}
