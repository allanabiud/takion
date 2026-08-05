import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:takion/src/data/common/drift/database.dart';
import 'package:takion/src/data/reading_list/repositories/local_reading_list_local_data_source.dart';
import 'package:takion/src/domain/entities.dart';
import 'package:takion/src/domain/repositories.dart';

void main() {
  late AppDatabase db;
  late LocalReadingListRepository repository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = LocalReadingListLocalDataSource(db);
  });

  tearDown(() async {
    await db.close();
  });

  LocalReadingList listWithItems(List<LocalReadingListItem> items) {
    final now = DateTime.now();
    return LocalReadingList(
      id: 'list-1',
      title: 'Weekly Pulls',
      description: 'desc',
      isOrdered: true,
      contentType: ListContentType.series,
      createdAt: now,
      updatedAt: now,
      items: items,
    );
  }

  LocalReadingListItem item(String targetId, {bool isSeries = true}) =>
      LocalReadingListItem(
        targetId: targetId,
        isSeries: isSeries,
        role: ItemRole.standard,
        isRead: false,
      );

  test('createList mirrors items into reading_list_items with timestamps', () async {
    await repository.createList(
      listWithItems([item('series-1'), item('series-2')]),
    );

    final rows = await db.select(db.readingListItems).get();
    expect(rows, hasLength(2));
    expect(rows[0].id, 'list-1:series-1');
    expect(rows[1].id, 'list-1:series-2');
    expect(rows[0].listId, 'list-1');
    expect(rows[0].targetId, 'series-1');
    expect(rows[0].sortOrder, 0);
    expect(rows[0].createdAt, isNotNull);
    expect(rows[0].updatedAt, isNotNull);
  });

  test('addItemToList creates a new syncable row', () async {
    await repository.createList(listWithItems([item('series-1')]));
    await repository.addItemToList('list-1', item('series-2'));

    final rows = await db.select(db.readingListItems).get();
    expect(rows, hasLength(2));
    expect(rows.map((r) => r.targetId).toSet(), {'series-1', 'series-2'});
    expect(rows.firstWhere((r) => r.targetId == 'series-2').updatedAt,
        isNotNull);
  });

  test('removeItemFromList deletes the row and records a tombstone', () async {
    await repository.createList(
      listWithItems([item('series-1'), item('series-2')]),
    );
    await repository.removeItemFromList('list-1', 'series-1');

    final rows = await db.select(db.readingListItems).get();
    expect(rows, hasLength(1));
    expect(rows.first.targetId, 'series-2');

    final tombstone = await db.syncMetaDao.get(
      'delete:reading_list_items:list-1:series-1',
    );
    expect(tombstone, isNotNull);
  });

  test('re-add after removal survives in the table', () async {
    await repository.createList(listWithItems([item('series-1')]));
    await repository.removeItemFromList('list-1', 'series-1');
    await repository.addItemToList('list-1', item('series-1'));

    final rows = await db.select(db.readingListItems).get();
    expect(rows, hasLength(1));
    expect(rows.first.targetId, 'series-1');
  });
}
