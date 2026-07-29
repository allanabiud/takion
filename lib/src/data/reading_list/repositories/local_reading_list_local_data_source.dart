import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/storage/drift_database_provider.dart';
import 'package:takion/src/data/common/drift/database.dart' as db;
import 'package:takion/src/domain/entities.dart';
import 'package:takion/src/domain/repositories.dart';
import 'package:takion/src/core/logging/app_logger.dart';

final localReadingListLocalDataSourceProvider =
    Provider<LocalReadingListRepository>((ref) {
      return LocalReadingListLocalDataSource(ref.read(driftDatabaseProvider));
    });

class LocalReadingListLocalDataSource implements LocalReadingListRepository {
  final db.AppDatabase _database;

  LocalReadingListLocalDataSource(this._database);

  LocalReadingList _toDomain(db.ReadingList d) {
    List<LocalReadingListItem> items;
    try {
      final decoded = jsonDecode(d.itemsJson) as List<dynamic>;
      items = decoded
          .map((e) => LocalReadingListItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      AppLogger.warning('Failed to decode reading list items', error: e);
      items = <LocalReadingListItem>[];
    }

    return LocalReadingList(
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
  Future<void> createList(LocalReadingList list) async {
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
  Future<void> updateList(LocalReadingList list) async {
    await createList(list);
  }

  @override
  Future<void> deleteList(String id) async {
    await _database.readingListDao.deleteById(id);
  }

  @override
  Future<List<LocalReadingList>> getAllLists() async {
    final rows = await _database.readingListDao.watchAll().first;
    return rows.map(_toDomain).toList();
  }

  @override
  Future<LocalReadingList?> getListById(String id) async {
    final d = await _database.readingListDao.getById(id);
    return d != null ? _toDomain(d) : null;
  }

  @override
  Future<void> addItemToList(String listId, LocalReadingListItem item) async {
    final list = await getListById(listId);
    if (list == null) return;
    final items = List<LocalReadingListItem>.from(list.items)..add(item);
    final updated = list.copyWith(items: items, updatedAt: DateTime.now());
    await updateList(updated);
  }

  @override
  Future<void> addItemsToList(
    String listId,
    List<LocalReadingListItem> items,
  ) async {
    final list = await getListById(listId);
    if (list == null) return;
    final updatedItems = List<LocalReadingListItem>.from(list.items)
      ..addAll(items);
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
  Future<LocalReadingList?> findByMetronSourceId(int metronSourceId) async {
    final all = await getAllLists();
    try {
      return all.firstWhere((list) => list.metronSourceId == metronSourceId);
    } catch (_) {
      return null;
    }
  }
}
