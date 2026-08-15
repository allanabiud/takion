import "package:drift/drift.dart";
import "package:takion/src/core/logging/app_logger.dart";
import "package:takion/src/data/common/drift/database.dart";

/// Applies a remote sync payload (full snapshot or delta) to the local
/// database, including LWW conflict resolution and delete-tombstone handling.
class SyncDeltaApplier {
  const SyncDeltaApplier(this._db);

  final AppDatabase _db;

  static bool isSupportedVersion(Object? version) =>
      version == 1 || version == 2;

  static const knownTableNames = [
    "library_items",
    "library_read_logs",
    "pull_list_entries",
    "series_subscriptions",
    "activity_events",
    "reading_lists",
    "reading_list_items",
    "favorite_series",
    "favorite_issues",
    "favorite_characters",
    "favorite_creators",
    "favorite_reading_lists",
  ];

  Future<void> applyDelta(Map<String, dynamic> payload) async {
    final version = payload["version"];
    final remoteDeviceId = payload["deviceId"] as String?;
    final fromTimestamp = payload["fromTimestamp"] as String?;
    final remoteToTimestamp = payload["toTimestamp"] as String?;

    // v1 and v2-null-fromTimestamp are full snapshots (always apply); real deltas are skipped if already applied.
    final isDelta = version == 2 && fromTimestamp != null;
    if (isDelta && remoteDeviceId != null && remoteToTimestamp != null) {
      final watermark = await _getRemoteWatermark(remoteDeviceId);
      final wm = watermark == null ? null : DateTime.tryParse(watermark);
      final to = DateTime.tryParse(remoteToTimestamp);
      if (wm != null && to != null && !to.isAfter(wm)) {
        AppLogger.info(
          "Skipping already-applied delta from $remoteDeviceId "
          "(to $remoteToTimestamp <= watermark $watermark)",
        );
        return;
      }
    }

    final tables = payload["tables"] as Map<String, dynamic>? ?? {};

    await _db.transaction(() async {
      for (final tableEntry in tables.entries) {
        final tableName = tableEntry.key;
        final tableData = tableEntry.value as Map<String, dynamic>;

        // Skip unknown tables gracefully.
        if (!knownTableNames.contains(tableName)) {
          AppLogger.warning("Unknown table in sync payload: $tableName");
          continue;
        }

        final inserts = tableData["inserts"] as List<dynamic>? ?? [];
        final updates = tableData["updates"] as List<dynamic>? ?? [];
        final deletes = tableData["deletes"] as List<dynamic>? ?? [];

        final rowsToUpsert = [
          ...inserts,
          ...updates,
        ].cast<Map<String, dynamic>>();

        for (final row in rowsToUpsert) {
          try {
            await _upsertTableRow(tableName, row);
          } catch (e) {
            AppLogger.error(
              "Failed to upsert row in $tableName (PK: ${row[_getPrimaryKeyName(tableName)]})",
              error: e,
            );
          }
        }

        for (final pk in deletes) {
          try {
            await _deleteTableRow(
              tableName,
              pk.toString(),
              remoteToTimestamp: remoteToTimestamp,
            );
          } catch (e) {
            AppLogger.error(
              "Failed to delete row $pk from $tableName",
              error: e,
            );
          }
        }
      }
    });

    if (remoteDeviceId != null && remoteToTimestamp != null) {
      await _advanceRemoteWatermark(remoteDeviceId, remoteToTimestamp);
    }
  }

  Future<String?> _getRemoteWatermark(String deviceId) =>
      _db.syncMetaDao.get("remote_watermark:$deviceId");

  Future<void> _advanceRemoteWatermark(
    String deviceId,
    String timestamp,
  ) async {
    final existing = await _getRemoteWatermark(deviceId);
    final newTs = DateTime.tryParse(timestamp);
    final oldTs = existing == null ? null : DateTime.tryParse(existing);
    if (newTs != null && (oldTs == null || newTs.isAfter(oldTs))) {
      await _db.syncMetaDao.set("remote_watermark:$deviceId", timestamp);
    }
  }

  TableInfo<Table, dynamic> _getTable(String tableName) {
    switch (tableName) {
      case "library_items":
        return _db.libraryItems;
      case "library_read_logs":
        return _db.libraryReadLogs;
      case "pull_list_entries":
        return _db.pullListEntries;
      case "series_subscriptions":
        return _db.seriesSubscriptions;
      case "activity_events":
        return _db.activityEvents;
      case "reading_lists":
        return _db.readingLists;
      case "reading_list_items":
        return _db.readingListItems;
      case "favorite_series":
        return _db.favoriteSeries;
      case "favorite_issues":
        return _db.favoriteIssues;
      case "favorite_characters":
        return _db.favoriteCharacters;
      case "favorite_creators":
        return _db.favoriteCreators;
      case "favorite_reading_lists":
        return _db.favoriteReadingLists;
      default:
        throw ArgumentError("Unknown table name: $tableName");
    }
  }

  Insertable<dynamic> _rowToCompanion(
    String tableName,
    Map<String, dynamic> json,
  ) {
    switch (tableName) {
      case "library_items":
        return LibraryItem.fromJson(json);
      case "library_read_logs":
        return LibraryReadLog.fromJson(json);
      case "pull_list_entries":
        return PullListEntry.fromJson(json);
      case "series_subscriptions":
        return SeriesSubscription.fromJson(json);
      case "activity_events":
        return ActivityEvent.fromJson(json);
      case "reading_lists":
        return ReadingList.fromJson(json);
      case "reading_list_items":
        return ReadingListItem.fromJson(json);
      case "favorite_series":
        return FavoriteSery.fromJson(json);
      case "favorite_issues":
        return FavoriteIssue.fromJson(json);
      case "favorite_characters":
        return FavoriteCharacter.fromJson(json);
      case "favorite_creators":
        return FavoriteCreator.fromJson(json);
      case "favorite_reading_lists":
        return FavoriteReadingList.fromJson(json);
      default:
        throw ArgumentError("Unknown table name: $tableName");
    }
  }

  String _getPrimaryKeyName(String tableName) {
    switch (tableName) {
      case "library_items":
      case "library_read_logs":
      case "pull_list_entries":
      case "series_subscriptions":
      case "activity_events":
      case "reading_lists":
      case "reading_list_items":
        return "id";
      case "favorite_series":
        return "metronSeriesId";
      case "favorite_issues":
        return "metronIssueId";
      case "favorite_characters":
        return "metronCharacterId";
      case "favorite_creators":
        return "metronCreatorId";
      case "favorite_reading_lists":
        return "readingListId";
      default:
        throw ArgumentError("Unknown table name: $tableName");
    }
  }

  String? _getTimestampFieldName(String tableName) {
    switch (tableName) {
      case "library_items":
      case "pull_list_entries":
      case "series_subscriptions":
      case "reading_lists":
      case "favorite_series":
      case "favorite_issues":
      case "favorite_characters":
      case "favorite_creators":
      case "favorite_reading_lists":
        return "updatedAt";
      case "library_read_logs":
        return "createdAt";
      case "activity_events":
        return "timestamp";
      case "reading_list_items":
        return "updatedAt";
      default:
        return null;
    }
  }

  Future<void> _upsertTableRow(
    String tableName,
    Map<String, dynamic> remoteRowJson,
  ) async {
    final table = _getTable(tableName);
    final row = _rowToCompanion(tableName, remoteRowJson);
    final pkName = _getPrimaryKeyName(tableName);
    final pkValue = remoteRowJson[pkName];

    if (pkValue == null) {
      AppLogger.warning("Missing primary key value for table $tableName");
      return;
    }

    final tsFieldName = _getTimestampFieldName(tableName);
    String pkSqlName = pkName;
    if (pkName == "metronSeriesId") {
      pkSqlName = "metron_series_id";
    } else if (pkName == "metronIssueId") {
      pkSqlName = "metron_issue_id";
    } else if (pkName == "metronCharacterId") {
      pkSqlName = "metron_character_id";
    } else if (pkName == "metronCreatorId") {
      pkSqlName = "metron_creator_id";
    } else if (pkName == "readingListId") {
      pkSqlName = "reading_list_id";
    }

    if (tsFieldName != null) {
      String tsSqlName = tsFieldName;
      if (tsFieldName == "updatedAt") {
        tsSqlName = "updated_at";
      } else if (tsFieldName == "createdAt") {
        tsSqlName = "created_at";
      }

      final existing = await _db
          .customSelect(
            "SELECT $tsSqlName FROM $tableName WHERE $pkSqlName = ?",
            variables: [Variable(pkValue)],
          )
          .getSingleOrNull();

      if (existing != null) {
        final localTsVal = existing.read<String>(tsSqlName);
        final remoteTsVal = remoteRowJson[tsFieldName] as String?;
        if (remoteTsVal != null) {
          final localTs = DateTime.tryParse(localTsVal);
          final remoteTs = DateTime.tryParse(remoteTsVal);
          if (localTs != null && remoteTs != null) {
            if (remoteTs.isBefore(localTs)) {
              // Local is strictly newer — keep it (LWW). Equal timestamps
              // resolve in favor of the remote row.
              return;
            }
          }
        }
      }
    }

    await _db.into(table).insertOnConflictUpdate(row);
  }

  Future<void> _deleteTableRow(
    String tableName,
    String pkValue, {
    String? remoteToTimestamp,
  }) async {
    final pkName = _getPrimaryKeyName(tableName);

    String pkSqlName = pkName;
    if (pkName == "metronSeriesId") {
      pkSqlName = "metron_series_id";
    } else if (pkName == "metronIssueId") {
      pkSqlName = "metron_issue_id";
    } else if (pkName == "metronCharacterId") {
      pkSqlName = "metron_character_id";
    } else if (pkName == "metronCreatorId") {
      pkSqlName = "metron_creator_id";
    } else if (pkName == "readingListId") {
      pkSqlName = "reading_list_id";
    }

    dynamic parsedPk = pkValue;
    if (pkName.startsWith("metron")) {
      parsedPk = int.tryParse(pkValue) ?? pkValue;
    }

    // Skip the delete if the local row is newer than the remote snapshot.
    if (remoteToTimestamp != null) {
      final tsFieldName = _getTimestampFieldName(tableName);
      if (tsFieldName != null) {
        String tsSqlName = tsFieldName;
        if (tsFieldName == "updatedAt") {
          tsSqlName = "updated_at";
        } else if (tsFieldName == "createdAt") {
          tsSqlName = "created_at";
        }
        final existing = await _db
            .customSelect(
              "SELECT $tsSqlName FROM $tableName WHERE $pkSqlName = ?",
              variables: [Variable(parsedPk)],
            )
            .getSingleOrNull();
        if (existing != null) {
          final localTs = DateTime.tryParse(existing.read<String>(tsSqlName));
          final remoteTs = DateTime.tryParse(remoteToTimestamp);
          if (localTs != null &&
              remoteTs != null &&
              localTs.isAfter(remoteTs)) {
            // Local row is newer — keep it.
            return;
          }
        }
      }
    }

    await _db.customStatement("DELETE FROM $tableName WHERE $pkSqlName = ?", [
      parsedPk,
    ]);
  }
}