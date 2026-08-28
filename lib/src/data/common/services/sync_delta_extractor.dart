import "package:drift/drift.dart";
import "package:takion/src/data/common/drift/database.dart";
import "package:uuid/uuid.dart";

class SyncDeltaExtractor {
  const SyncDeltaExtractor(
    this._db, {
    this.uuidGenerator,
    this.clock = DateTime.now,
  });

  final AppDatabase _db;
  final String Function()? uuidGenerator;
  final DateTime Function() clock;

  Future<Map<String, dynamic>> extractDelta(DateTime? since) async {
    final sinceStr = since?.toUtc().toIso8601String();
    final tablesData = <String, Map<String, dynamic>>{};
    final allMeta = await _db.syncMetaDao.getAll();

    List<String> getDeletesForTable(String tableName) {
      final deletes = <String>[];
      final prefix = "delete:$tableName:";
      for (final entry in allMeta.entries) {
        if (entry.key.startsWith(prefix)) {
          final id = entry.key.substring(prefix.length);
          if (since != null) {
            final timestamp = DateTime.tryParse(entry.value);
            if (timestamp != null && timestamp.isAfter(since)) {
              deletes.add(id);
            }
          } else {
            deletes.add(id);
          }
        }
      }
      return deletes;
    }

    final query = _db.select;

    Future<List<Map<String, dynamic>>> queryTableSince<T extends Table, D>(
      TableInfo<T, D> table,
      Expression<bool> Function(T)? whereClause,
    ) async {
      final selectQuery = query(table);
      if (whereClause != null) {
        selectQuery.where(whereClause);
      }
      final rows = await selectQuery.get();
      return rows
          .map<Map<String, dynamic>>((r) => (r as DataClass).toJson())
          .toList();
    }

    tablesData["library_items"] = {
      "inserts": await queryTableSince(
        _db.libraryItems,
        (sinceStr != null)
            ? (LibraryItems t) => t.updatedAt.isBiggerThan(Constant(sinceStr))
            : null,
      ),
      "updates": <Map<String, dynamic>>[],
      "deletes": getDeletesForTable("library_items"),
    };

    tablesData["library_read_logs"] = {
      "inserts": await queryTableSince(
        _db.libraryReadLogs,
        (sinceStr != null)
            ? (LibraryReadLogs t) =>
                  t.createdAt.isBiggerThan(Constant(sinceStr))
            : null,
      ),
      "updates": <Map<String, dynamic>>[],
      "deletes": getDeletesForTable("library_read_logs"),
    };

    tablesData["pull_list_entries"] = {
      "inserts": await queryTableSince(
        _db.pullListEntries,
        (sinceStr != null)
            ? (PullListEntries t) =>
                  t.updatedAt.isBiggerThan(Constant(sinceStr))
            : null,
      ),
      "updates": <Map<String, dynamic>>[],
      "deletes": getDeletesForTable("pull_list_entries"),
    };

    tablesData["series_subscriptions"] = {
      "inserts": await queryTableSince(
        _db.seriesSubscriptions,
        (sinceStr != null)
            ? (SeriesSubscriptions t) =>
                  t.updatedAt.isBiggerThan(Constant(sinceStr))
            : null,
      ),
      "updates": <Map<String, dynamic>>[],
      "deletes": getDeletesForTable("series_subscriptions"),
    };

    tablesData["activity_events"] = {
      "inserts": await queryTableSince(
        _db.activityEvents,
        (sinceStr != null)
            ? (ActivityEvents t) => t.timestamp.isBiggerThan(Constant(sinceStr))
            : null,
      ),
      "updates": <Map<String, dynamic>>[],
      "deletes": getDeletesForTable("activity_events"),
    };

    tablesData["reading_lists"] = {
      "inserts": await queryTableSince(
        _db.readingLists,
        (sinceStr != null)
            ? (ReadingLists t) => t.updatedAt.isBiggerThan(Constant(sinceStr))
            : null,
      ),
      "updates": <Map<String, dynamic>>[],
      "deletes": getDeletesForTable("reading_lists"),
    };

    tablesData["reading_list_items"] = {
      "inserts": await queryTableSince(
        _db.readingListItems,
        (sinceStr != null)
            ? (ReadingListItems t) =>
                  t.updatedAt.isBiggerThan(Constant(sinceStr))
            : null,
      ),
      "updates": <Map<String, dynamic>>[],
      "deletes": getDeletesForTable("reading_list_items"),
    };

    tablesData["favorite_series"] = {
      "inserts": await queryTableSince(
        _db.favoriteSeries,
        (sinceStr != null)
            ? (FavoriteSeries t) => t.updatedAt.isBiggerThan(Constant(sinceStr))
            : null,
      ),
      "updates": <Map<String, dynamic>>[],
      "deletes": getDeletesForTable("favorite_series"),
    };

    tablesData["favorite_issues"] = {
      "inserts": await queryTableSince(
        _db.favoriteIssues,
        (sinceStr != null)
            ? (FavoriteIssues t) => t.updatedAt.isBiggerThan(Constant(sinceStr))
            : null,
      ),
      "updates": <Map<String, dynamic>>[],
      "deletes": getDeletesForTable("favorite_issues"),
    };

    tablesData["favorite_characters"] = {
      "inserts": await queryTableSince(
        _db.favoriteCharacters,
        (sinceStr != null)
            ? (FavoriteCharacters t) =>
                  t.updatedAt.isBiggerThan(Constant(sinceStr))
            : null,
      ),
      "updates": <Map<String, dynamic>>[],
      "deletes": getDeletesForTable("favorite_characters"),
    };

    tablesData["favorite_creators"] = {
      "inserts": await queryTableSince(
        _db.favoriteCreators,
        (sinceStr != null)
            ? (FavoriteCreators t) =>
                  t.updatedAt.isBiggerThan(Constant(sinceStr))
            : null,
      ),
      "updates": <Map<String, dynamic>>[],
      "deletes": getDeletesForTable("favorite_creators"),
    };

    tablesData["favorite_reading_lists"] = {
      "inserts": await queryTableSince(
        _db.favoriteReadingLists,
        (sinceStr != null)
            ? (FavoriteReadingLists t) =>
                  t.updatedAt.isBiggerThan(Constant(sinceStr))
            : null,
      ),
      "updates": <Map<String, dynamic>>[],
      "deletes": getDeletesForTable("favorite_reading_lists"),
    };

    return {
      "version": 2,
      "deviceId": await getDeviceId(),
      "fromTimestamp": sinceStr,
      "toTimestamp": clock().toUtc().toIso8601String(),
      "tables": tablesData,
    };
  }

  /// Drops delete-tombstone rows in sync_meta older than [cutoff].
  Future<void> pruneDeletedRows(DateTime cutoff) async {
    final allMeta = await _db.syncMetaDao.getAll();
    for (final entry in allMeta.entries) {
      if (entry.key.startsWith("delete:")) {
        final timestamp = DateTime.tryParse(entry.value);
        if (timestamp != null && timestamp.isBefore(cutoff)) {
          await _db.syncMetaDao.deleteByKey(entry.key);
        }
      }
    }
  }

  Future<String> getDeviceId() async {
    final existingId = await _db.syncMetaDao.get("local_device_id");
    if (existingId == null) {
      final newId = uuidGenerator?.call() ?? const Uuid().v4();
      await _db.syncMetaDao.set("local_device_id", newId);
      return newId;
    }
    return existingId;
  }
}
