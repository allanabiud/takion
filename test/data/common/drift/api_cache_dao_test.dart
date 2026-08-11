import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:takion/src/data/common/drift/database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> insertAt(String cacheKey, Duration age) async {
    await db.apiCache.insertOnConflictUpdate(
      ApiCacheCompanion.insert(
        cacheKey: cacheKey,
        entityType: 'test',
        payload: '{}',
        cachedAt: DateTime.now().toUtc().subtract(age),
      ),
    );
  }

  Future<Set<String>> remainingKeys() async {
    final rows = await db.apiCacheDao.getByPrefix('');
    return rows.map((r) => r.cacheKey).toSet();
  }

  group('deleteStaleEntries', () {
    test('deletes stale search results after 3 hours', () async {
      await insertAt('series_search:foo', const Duration(hours: 4));
      await insertAt('issue_search:foo', const Duration(hours: 4));
      await insertAt('character_search:foo', const Duration(hours: 4));
      await insertAt('creator_search:foo', const Duration(hours: 4));
      await insertAt('universe_search:foo', const Duration(hours: 4));
      await insertAt('imprint_search:foo', const Duration(hours: 4));
      await insertAt('team_search:foo', const Duration(hours: 4));
      await insertAt('arc_search:foo', const Duration(hours: 4));
      await insertAt('publisher_search:foo', const Duration(hours: 4));
      await insertAt('upc_prefix:12345', const Duration(hours: 4));

      await db.apiCacheDao.deleteStaleEntries();

      expect(await remainingKeys(), isEmpty);
    });

    test('keeps fresh search results and recent weekly releases', () async {
      await insertAt('series_search:foo', const Duration(hours: 1));
      await insertAt('weekly_releases:current', const Duration(hours: 2));

      await db.apiCacheDao.deleteStaleEntries();

      expect(
        await remainingKeys(),
        containsAll(['series_search:foo', 'weekly_releases:current']),
      );
    });

    test('keeps the previous broken search_results prefix untouched', () async {
      await insertAt('search_results:foo', const Duration(hours: 4));
      await insertAt('series_search:foo', const Duration(hours: 4));

      await db.apiCacheDao.deleteStaleEntries();

      expect(await remainingKeys(), contains('search_results:foo'));
      expect(await remainingKeys(), isNot(contains('series_search:foo')));
    });

    test('deletes stale detail pages and the 7-day catch-all', () async {
      await insertAt('issue_details:1', const Duration(hours: 25));
      await insertAt('series_details:1', const Duration(hours: 49));
      await insertAt('misc:old', const Duration(days: 8));

      await db.apiCacheDao.deleteStaleEntries();

      expect(await remainingKeys(), isEmpty);
    });
  });
}
