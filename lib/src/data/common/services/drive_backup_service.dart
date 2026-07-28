import 'dart:convert';
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:drift/drift.dart';
import 'package:takion/src/core/logging/app_logger.dart';
import 'package:takion/src/core/storage/drift_database_provider.dart';
import 'package:takion/src/data/common/drift/database.dart';

final driveSyncServiceProvider = Provider<DriveSyncService>((ref) {
  final db = ref.watch(driftDatabaseProvider);
  return DriveSyncService(db);
});

class DriveSyncService {
  static const _driveScope = 'https://www.googleapis.com/auth/drive.file';
  static const _appFolderName = 'Takion';
  static const _deltaFileName = 'takion_delta_v1.json';
  static const _fullFileName = 'takion_full_v1.json';

  final AppDatabase _db;
  final Dio _dio;
  final GoogleSignIn _googleSignIn;

  DriveSyncService(this._db)
    : _dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 30),
        ),
      ),
      _googleSignIn = GoogleSignIn(scopes: [_driveScope]);

  GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;
  bool get isSignedIn => _googleSignIn.currentUser != null;

  Future<GoogleSignInAccount?> signIn() async {
    return await _googleSignIn.signIn();
  }

  Future<GoogleSignInAccount?> signInSilently({
    bool reAuthenticate = false,
  }) async {
    try {
      final account = await _googleSignIn.signInSilently(
        reAuthenticate: reAuthenticate,
      );
      if (account != null) return account;
      return _googleSignIn.currentUser;
    } catch (e) {
      AppLogger.warning('Google signInSilently failed', error: e);
      return _googleSignIn.currentUser;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  Future<String> _getAccessToken() async {
    var user = _googleSignIn.currentUser;
    user ??= await signInSilently();
    if (user == null) {
      throw StateError('Not signed in to Google Drive');
    }

    GoogleSignInAuthentication auth;
    try {
      auth = await user.authentication;
    } catch (e) {
      user = await signInSilently(reAuthenticate: true);
      if (user == null) {
        throw StateError('Not signed in to Google Drive');
      }
      auth = await user.authentication;
    }

    var token = auth.accessToken;
    if (token == null || token.isEmpty) {
      user = await signInSilently(reAuthenticate: true);
      if (user != null) {
        auth = await user.authentication;
        token = auth.accessToken;
      }
    }

    if (token == null || token.isEmpty) {
      throw StateError(
        'Google Drive access token is empty, please re-authenticate',
      );
    }
    return token;
  }

  Future<Response> _driveGet(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool isRetry = false,
    int retryCount = 0,
  }) async {
    final token = await _getAccessToken();
    final response = await _dio.get(
      path,
      queryParameters: queryParameters,
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
        validateStatus: (status) =>
            status == 200 ||
            status == 401 ||
            status == 404 ||
            status == 429 ||
            status == 403,
      ),
    );
    if (response.statusCode == 401 && !isRetry) {
      AppLogger.info(
        'Drive GET request returned 401, attempting silent token refresh...',
      );
      await signInSilently(reAuthenticate: true);
      return _driveGet(path, queryParameters: queryParameters, isRetry: true);
    }
    if ((response.statusCode == 429 || response.statusCode == 403) &&
        retryCount < 3) {
      final delay = Duration(
        seconds: math.min(math.pow(2, retryCount).toInt(), 60),
      );
      AppLogger.warning(
        'Drive GET HTTP ${response.statusCode} for $path, '
        'retrying in ${delay.inSeconds}s (attempt ${retryCount + 1})',
      );
      await Future.delayed(delay);
      return _driveGet(
        path,
        queryParameters: queryParameters,
        isRetry: isRetry,
        retryCount: retryCount + 1,
      );
    }
    return response;
  }

  Future<String?> _getAppFolderId() async {
    final response = await _driveGet(
      'https://www.googleapis.com/drive/v3/files',
      queryParameters: {
        'q':
            "name='$_appFolderName' and mimeType='application/vnd.google-apps.folder' and trashed=false",
        'fields': 'files(id,name)',
      },
    );
    if (response.statusCode == 404) return null;
    final data = response.data as Map<String, dynamic>;
    final files = data['files'] as List<dynamic>? ?? [];
    if (files.isEmpty) return null;
    return (files.first as Map<String, dynamic>)['id'] as String;
  }

  Future<String> _ensureAppFolderId() async {
    final existingId = await _getAppFolderId();
    if (existingId != null) return existingId;

    final token = await _getAccessToken();
    final response = await _dio.post(
      'https://www.googleapis.com/drive/v3/files',
      data: {
        'name': _appFolderName,
        'mimeType': 'application/vnd.google-apps.folder',
      },
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    final data = response.data as Map<String, dynamic>;
    return data['id'] as String;
  }

  Future<String?> _findFileId(String fileName) async {
    final folderId = await _ensureAppFolderId();
    final response = await _driveGet(
      'https://www.googleapis.com/drive/v3/files',
      queryParameters: {
        'q': "'$folderId' in parents and name='$fileName' and trashed=false",
        'fields': 'files(id,name)',
      },
    );
    if (response.statusCode == 404) return null;
    final data = response.data as Map<String, dynamic>;
    final files = data['files'] as List<dynamic>? ?? [];
    if (files.isEmpty) return null;
    return (files.first as Map<String, dynamic>)['id'] as String;
  }

  Future<DateTime?> _getFileModificationTime(String fileId) async {
    final response = await _driveGet(
      'https://www.googleapis.com/drive/v3/files/$fileId',
      queryParameters: {'fields': 'modifiedTime'},
    );
    if (response.statusCode != 200) return null;
    final data = response.data as Map<String, dynamic>;
    final timeStr = data['modifiedTime'] as String?;
    if (timeStr == null) return null;
    return DateTime.parse(timeStr);
  }

  Future<Uint8List?> _downloadFile(
    String fileId, {
    bool isRetry = false,
    int retryCount = 0,
  }) async {
    final token = await _getAccessToken();
    final response = await _dio.get(
      'https://www.googleapis.com/drive/v3/files/$fileId',
      queryParameters: {'alt': 'media'},
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
        responseType: ResponseType.bytes,
        validateStatus: (status) =>
            status == 200 ||
            status == 401 ||
            status == 404 ||
            status == 429 ||
            status == 403,
      ),
    );
    if (response.statusCode == 401 && !isRetry) {
      AppLogger.info(
        'Drive download returned 401, attempting silent token refresh...',
      );
      await signInSilently(reAuthenticate: true);
      return _downloadFile(fileId, isRetry: true);
    }
    if (response.statusCode == 404) return null;
    if ((response.statusCode == 429 || response.statusCode == 403) &&
        retryCount < 3) {
      final delay = Duration(
        seconds: math.min(math.pow(2, retryCount).toInt(), 60),
      );
      AppLogger.warning(
        'Drive download HTTP ${response.statusCode} for $fileId, '
        'retrying in ${delay.inSeconds}s (attempt ${retryCount + 1})',
      );
      await Future.delayed(delay);
      return _downloadFile(
        fileId,
        isRetry: isRetry,
        retryCount: retryCount + 1,
      );
    }
    return response.data as Uint8List;
  }

  Future<String> _uploadFile(
    String fileName,
    Uint8List fileData, {
    bool isRetry = false,
    int retryCount = 0,
  }) async {
    final token = await _getAccessToken();
    final folderId = await _ensureAppFolderId();
    final existingId = await _findFileId(fileName);

    final metadata = jsonEncode({
      'name': fileName,
      if (existingId == null) 'parents': [folderId],
    });

    final boundary = 'boundary_${DateTime.now().millisecondsSinceEpoch}';
    final bodyBytes = _multipartRelatedBody(
      metadata,
      fileData,
      fileName,
      boundary,
    );
    final uri = existingId != null
        ? Uri.parse(
            'https://www.googleapis.com/upload/drive/v3/files/$existingId?uploadType=multipart',
          )
        : Uri.parse(
            'https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart',
          );

    final request = http.Request(existingId != null ? 'PATCH' : 'POST', uri);
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Content-Type'] = 'multipart/related; boundary=$boundary';
    request.bodyBytes = bodyBytes;

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 401 && !isRetry) {
      AppLogger.info(
        'Drive upload returned 401, attempting silent token refresh...',
      );
      await signInSilently(reAuthenticate: true);
      return _uploadFile(fileName, fileData, isRetry: true);
    }

    if ((response.statusCode == 429 || response.statusCode == 403) &&
        retryCount < 3) {
      final delay = Duration(
        seconds: math.min(math.pow(2, retryCount).toInt(), 60),
      );
      AppLogger.warning(
        'Drive upload HTTP ${response.statusCode} for $fileName, '
        'retrying in ${delay.inSeconds}s (attempt ${retryCount + 1})',
      );
      await Future.delayed(delay);
      return _uploadFile(
        fileName,
        fileData,
        isRetry: isRetry,
        retryCount: retryCount + 1,
      );
    }

    if (response.statusCode != 200) {
      throw StateError(
        'Upload failed (HTTP ${response.statusCode}): ${response.body}',
      );
    }

    final result = jsonDecode(response.body) as Map<String, dynamic>;
    return result['id'] as String;
  }

  List<int> _multipartRelatedBody(
    String metadata,
    Uint8List fileData,
    String fileName,
    String boundary,
  ) {
    final bytes = <int>[];
    bytes.addAll(utf8.encode('--$boundary\r\n'));
    bytes.addAll(
      utf8.encode(
        'Content-Disposition: form-data; name="metadata"\r\n'
        'Content-Type: application/json; charset=UTF-8\r\n\r\n'
        '$metadata\r\n',
      ),
    );
    bytes.addAll(utf8.encode('--$boundary\r\n'));
    bytes.addAll(
      utf8.encode(
        'Content-Disposition: form-data; name="file"; filename="$fileName"\r\n'
        'Content-Type: application/json; charset=UTF-8\r\n\r\n',
      ),
    );
    bytes.addAll(fileData);
    bytes.addAll(utf8.encode('\r\n--$boundary--\r\n'));
    return bytes;
  }

  Future<DateTime?> getLastSyncTime() async {
    final timestamp = await _db.syncMetaDao.get('last_sync_timestamp');
    if (timestamp == null) return null;
    return DateTime.tryParse(timestamp);
  }

  Future<void> triggerSync() async {
    AppLogger.info('Drive sync triggered');

    final deltaFileId = await _findFileId(_deltaFileName);
    final lastSyncTime = await getLastSyncTime();
    bool remoteChangesApplied = false;
    String? remoteToTimestamp;

    if (deltaFileId != null) {
      final remoteModified = await _getFileModificationTime(deltaFileId);
      if (remoteModified != null &&
          (lastSyncTime == null || remoteModified.isAfter(lastSyncTime))) {
        AppLogger.info(
          'Remote sync data is available, downloading and applying',
        );
        final bytes = await _downloadFile(deltaFileId);
        if (bytes != null) {
          final payload =
              jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
          if (payload['version'] == 1) {
            await applyDelta(payload);
            remoteChangesApplied = true;
            remoteToTimestamp = payload['toTimestamp'] as String?;
          }
        }
      }
    } else {
      final fullFileId = await _findFileId(_fullFileName);
      if (fullFileId != null && lastSyncTime == null) {
        AppLogger.info(
          'No delta but full file exists and no local sync, downloading full',
        );
        final bytes = await _downloadFile(fullFileId);
        if (bytes != null) {
          final payload =
              jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
          if (payload['version'] == 1) {
            await applyDelta(payload);
            remoteChangesApplied = true;
            remoteToTimestamp = payload['toTimestamp'] as String?;
          }
        }
      }
    }

    // NOTE: We intentionally use the original lastSyncTime here, not the remote's
    // toTimestamp. This ensures local changes made before the remote timestamp
    // are also extracted and uploaded, forming a complete merged snapshot.
    final localChangesDelta = await extractDelta(lastSyncTime);

    final tables = localChangesDelta['tables'] as Map<String, dynamic>;
    bool hasLocalChanges = false;
    for (final table in tables.values) {
      final inserts = table['inserts'] as List;
      final deletes = table['deletes'] as List;
      if (inserts.isNotEmpty || deletes.isNotEmpty) {
        hasLocalChanges = true;
        break;
      }
    }

    if (hasLocalChanges) {
      AppLogger.info('Uploading local sync data');

      // Upload complete cumulative snapshot so remote file is never truncated
      final fullCumulativePayload = await extractDelta(null);
      final jsonBytes = utf8.encode(jsonEncode(fullCumulativePayload));

      await _uploadFile(_deltaFileName, Uint8List.fromList(jsonBytes));

      // Advance cursor ONLY after upload succeeds
      final nowStr = localChangesDelta['toTimestamp'] as String;
      await _db.syncMetaDao.set('last_sync_timestamp', nowStr);

      // Prune deleted rows older than 30 days
      final now = DateTime.parse(nowStr);
      await _pruneDeletedRows(now.subtract(const Duration(days: 30)));
    } else if (remoteChangesApplied && remoteToTimestamp != null) {
      // Remote changes applied, no local changes — safe to advance cursor
      await _db.syncMetaDao.set('last_sync_timestamp', remoteToTimestamp);
      AppLogger.info('No local changes, but remote changes were applied');
    } else {
      if (lastSyncTime == null) {
        final nowStr = DateTime.now().toUtc().toIso8601String();
        await _db.syncMetaDao.set('last_sync_timestamp', nowStr);
        AppLogger.info('Initialized last_sync_timestamp for empty state');
      } else {
        AppLogger.info('No changes to sync');
      }
    }
  }

  Future<void> forceSync() async {
    AppLogger.info('Forcing full sync snapshot upload');
    final delta = await extractDelta(null);
    final jsonBytes = utf8.encode(jsonEncode(delta));
    await _uploadFile(_fullFileName, Uint8List.fromList(jsonBytes));

    await _uploadFile(_deltaFileName, Uint8List.fromList(jsonBytes));

    final nowStr = delta['toTimestamp'] as String;
    await _db.syncMetaDao.set('last_sync_timestamp', nowStr);

    final now = DateTime.parse(nowStr);
    await _pruneDeletedRows(now.subtract(const Duration(days: 30)));
  }

  Future<void> restoreFromDrive() async {
    AppLogger.info('Restore from Drive started');

    String? fileId = await _findFileId(_deltaFileName);
    fileId ??= await _findFileId(_fullFileName);

    if (fileId == null) {
      throw StateError('No sync data found on Google Drive');
    }

    final bytes = await _downloadFile(fileId);
    if (bytes == null) {
      throw StateError('Failed to download sync data');
    }

    final payload = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
    if (payload['version'] != 1) {
      throw StateError(
        'Unsupported sync format version: ${payload['version']}',
      );
    }

    // Apply (LWW merge on top of local data)
    await applyDelta(payload);

    final toTimestamp = payload['toTimestamp'] ?? payload['timestamp'];
    if (toTimestamp != null) {
      await _db.syncMetaDao.set('last_sync_timestamp', toTimestamp as String);
    }
    AppLogger.info('Restore from Drive completed');
  }

  Future<void> deleteRemoteData() async {
    AppLogger.info('Deleting sync data from Google Drive');
    final token = await _getAccessToken();

    final deltaId = await _findFileId(_deltaFileName);
    if (deltaId != null) {
      await _dio.delete(
        'https://www.googleapis.com/drive/v3/files/$deltaId',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          validateStatus: (s) => s == 200 || s == 404 || s == 401,
        ),
      );
    }

    final fullId = await _findFileId(_fullFileName);
    if (fullId != null) {
      await _dio.delete(
        'https://www.googleapis.com/drive/v3/files/$fullId',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          validateStatus: (s) => s == 200 || s == 404 || s == 401,
        ),
      );
    }
  }

  Future<Map<String, dynamic>> extractDelta(DateTime? since) async {
    final sinceStr = since?.toUtc().toIso8601String();
    final tablesData = <String, Map<String, dynamic>>{};

    final query = _db.select;

    Future<List<Map<String, dynamic>>> queryTableSince(
      TableInfo<Table, dynamic> table,
      Expression<bool> Function(dynamic t)? whereClause,
    ) async {
      final selectQuery = query(table);
      if (whereClause != null) {
        selectQuery.where(whereClause);
      }
      final rows = await selectQuery.get();
      return rows.map<Map<String, dynamic>>((r) => r.toJson()).toList();
    }

    tablesData['library_items'] = {
      'inserts': await queryTableSince(
        _db.libraryItems,
        (sinceStr != null)
            ? (t) => t.updatedAt.isBiggerThan(Constant(sinceStr))
            : null,
      ),
      'updates': <Map<String, dynamic>>[],
      'deletes': await _getDeletesForTable('library_items', since),
    };

    tablesData['library_read_logs'] = {
      'inserts': await queryTableSince(
        _db.libraryReadLogs,
        (sinceStr != null)
            ? (t) => t.createdAt.isBiggerThan(Constant(sinceStr))
            : null,
      ),
      'updates': <Map<String, dynamic>>[],
      'deletes': await _getDeletesForTable('library_read_logs', since),
    };

    tablesData['pull_list_entries'] = {
      'inserts': await queryTableSince(
        _db.pullListEntries,
        (sinceStr != null)
            ? (t) => t.updatedAt.isBiggerThan(Constant(sinceStr))
            : null,
      ),
      'updates': <Map<String, dynamic>>[],
      'deletes': await _getDeletesForTable('pull_list_entries', since),
    };

    tablesData['series_subscriptions'] = {
      'inserts': await queryTableSince(
        _db.seriesSubscriptions,
        (sinceStr != null)
            ? (t) => t.updatedAt.isBiggerThan(Constant(sinceStr))
            : null,
      ),
      'updates': <Map<String, dynamic>>[],
      'deletes': await _getDeletesForTable('series_subscriptions', since),
    };

    tablesData['activity_events'] = {
      'inserts': await queryTableSince(
        _db.activityEvents,
        (sinceStr != null)
            ? (t) => t.timestamp.isBiggerThan(Constant(sinceStr))
            : null,
      ),
      'updates': <Map<String, dynamic>>[],
      'deletes': await _getDeletesForTable('activity_events', since),
    };

    tablesData['reading_lists'] = {
      'inserts': await queryTableSince(
        _db.readingLists,
        (sinceStr != null)
            ? (t) => t.updatedAt.isBiggerThan(Constant(sinceStr))
            : null,
      ),
      'updates': <Map<String, dynamic>>[],
      'deletes': await _getDeletesForTable('reading_lists', since),
    };

    // reading_list_items
    List<ReadingListItem> listItems;
    if (sinceStr != null) {
      final updatedLists = await (query(
        _db.readingLists,
      )..where((t) => t.updatedAt.isBiggerThan(Constant(sinceStr)))).get();
      final updatedListIds = updatedLists.map((l) => l.id).toList();
      if (updatedListIds.isNotEmpty) {
        listItems = await (query(
          _db.readingListItems,
        )..where((t) => t.listId.isIn(updatedListIds))).get();
      } else {
        listItems = [];
      }
    } else {
      listItems = await query(_db.readingListItems).get();
    }
    tablesData['reading_list_items'] = {
      'inserts': listItems.map((r) => r.toJson()).toList(),
      'updates': <Map<String, dynamic>>[],
      'deletes': await _getDeletesForTable('reading_list_items', since),
    };

    tablesData['favorite_series'] = {
      'inserts': await queryTableSince(
        _db.favoriteSeries,
        (sinceStr != null)
            ? (t) => t.updatedAt.isBiggerThan(Constant(sinceStr))
            : null,
      ),
      'updates': <Map<String, dynamic>>[],
      'deletes': await _getDeletesForTable('favorite_series', since),
    };

    tablesData['favorite_issues'] = {
      'inserts': await queryTableSince(
        _db.favoriteIssues,
        (sinceStr != null)
            ? (t) => t.updatedAt.isBiggerThan(Constant(sinceStr))
            : null,
      ),
      'updates': <Map<String, dynamic>>[],
      'deletes': await _getDeletesForTable('favorite_issues', since),
    };

    tablesData['favorite_characters'] = {
      'inserts': await queryTableSince(
        _db.favoriteCharacters,
        (sinceStr != null)
            ? (t) => t.updatedAt.isBiggerThan(Constant(sinceStr))
            : null,
      ),
      'updates': <Map<String, dynamic>>[],
      'deletes': await _getDeletesForTable('favorite_characters', since),
    };

    tablesData['favorite_creators'] = {
      'inserts': await queryTableSince(
        _db.favoriteCreators,
        (sinceStr != null)
            ? (t) => t.updatedAt.isBiggerThan(Constant(sinceStr))
            : null,
      ),
      'updates': <Map<String, dynamic>>[],
      'deletes': await _getDeletesForTable('favorite_creators', since),
    };

    tablesData['favorite_reading_lists'] = {
      'inserts': await queryTableSince(
        _db.favoriteReadingLists,
        (sinceStr != null)
            ? (t) => t.updatedAt.isBiggerThan(Constant(sinceStr))
            : null,
      ),
      'updates': <Map<String, dynamic>>[],
      'deletes': await _getDeletesForTable('favorite_reading_lists', since),
    };

    return {
      'version': 1,
      'deviceId': await _getDeviceId(),
      'fromTimestamp': sinceStr,
      'toTimestamp': DateTime.now().toUtc().toIso8601String(),
      'tables': tablesData,
    };
  }

  Future<List<String>> _getDeletesForTable(
    String tableName,
    DateTime? since,
  ) async {
    final allMeta = await _db.syncMetaDao.getAll();
    final deletes = <String>[];
    final prefix = 'delete:$tableName:';

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

  Future<void> _pruneDeletedRows(DateTime cutoff) async {
    final allMeta = await _db.syncMetaDao.getAll();
    for (final entry in allMeta.entries) {
      if (entry.key.startsWith('delete:')) {
        final timestamp = DateTime.tryParse(entry.value);
        if (timestamp != null && timestamp.isBefore(cutoff)) {
          await _db.syncMetaDao.deleteByKey(entry.key);
        }
      }
    }
  }

  Future<String> _getDeviceId() async {
    final existingId = await _db.syncMetaDao.get('local_device_id');
    if (existingId == null) {
      final newId = _generateUuid();
      await _db.syncMetaDao.set('local_device_id', newId);
      return newId;
    }
    return existingId;
  }

  String _generateUuid() {
    final r = math.Random();
    final parts = [
      _hex(r, 8),
      _hex(r, 4),
      '4${_hex(r, 3)}',
      (8 + r.nextInt(4)).toRadixString(16) + _hex(r, 3),
      _hex(r, 12),
    ];
    return parts.join('-');
  }

  String _hex(math.Random r, int len) {
    final codes = List.generate(len, (_) => r.nextInt(16).toRadixString(16));
    return codes.join();
  }

  // --- Delta Application Logic ---
  Future<void> applyDelta(Map<String, dynamic> payload) async {
    final tables = payload['tables'] as Map<String, dynamic>? ?? {};

    await _db.transaction(() async {
      for (final tableEntry in tables.entries) {
        final tableName = tableEntry.key;
        final tableData = tableEntry.value as Map<String, dynamic>;

        // Skip unknown tables gracefully
        if (!_knownTableNames.contains(tableName)) {
          AppLogger.warning('Unknown table in sync payload: $tableName');
          continue;
        }

        final inserts = tableData['inserts'] as List<dynamic>? ?? [];
        final updates = tableData['updates'] as List<dynamic>? ?? [];
        final deletes = tableData['deletes'] as List<dynamic>? ?? [];

        final rowsToUpsert = [
          ...inserts,
          ...updates,
        ].cast<Map<String, dynamic>>();

        for (final row in rowsToUpsert) {
          try {
            await _upsertTableRow(tableName, row);
          } catch (e) {
            AppLogger.error(
              'Failed to upsert row in $tableName (PK: ${row[_getPrimaryKeyName(tableName)]})',
              error: e,
            );
          }
        }

        for (final pk in deletes) {
          try {
            await _deleteTableRow(tableName, pk.toString());
          } catch (e) {
            AppLogger.error(
              'Failed to delete row $pk from $tableName',
              error: e,
            );
          }
        }
      }
    });
  }

  static const _knownTableNames = [
    'library_items',
    'library_read_logs',
    'pull_list_entries',
    'series_subscriptions',
    'activity_events',
    'reading_lists',
    'reading_list_items',
    'favorite_series',
    'favorite_issues',
    'favorite_characters',
    'favorite_creators',
    'favorite_reading_lists',
  ];

  TableInfo<Table, dynamic> _getTable(String tableName) {
    switch (tableName) {
      case 'library_items':
        return _db.libraryItems;
      case 'library_read_logs':
        return _db.libraryReadLogs;
      case 'pull_list_entries':
        return _db.pullListEntries;
      case 'series_subscriptions':
        return _db.seriesSubscriptions;
      case 'activity_events':
        return _db.activityEvents;
      case 'reading_lists':
        return _db.readingLists;
      case 'reading_list_items':
        return _db.readingListItems;
      case 'favorite_series':
        return _db.favoriteSeries;
      case 'favorite_issues':
        return _db.favoriteIssues;
      case 'favorite_characters':
        return _db.favoriteCharacters;
      case 'favorite_creators':
        return _db.favoriteCreators;
      case 'favorite_reading_lists':
        return _db.favoriteReadingLists;
      default:
        throw ArgumentError('Unknown table name: $tableName');
    }
  }

  Insertable<dynamic> _rowToCompanion(
    String tableName,
    Map<String, dynamic> json,
  ) {
    switch (tableName) {
      case 'library_items':
        return LibraryItem.fromJson(json);
      case 'library_read_logs':
        return LibraryReadLog.fromJson(json);
      case 'pull_list_entries':
        return PullListEntry.fromJson(json);
      case 'series_subscriptions':
        return SeriesSubscription.fromJson(json);
      case 'activity_events':
        return ActivityEvent.fromJson(json);
      case 'reading_lists':
        return ReadingList.fromJson(json);
      case 'reading_list_items':
        return ReadingListItem.fromJson(json);
      case 'favorite_series':
        return FavoriteSery.fromJson(json);
      case 'favorite_issues':
        return FavoriteIssue.fromJson(json);
      case 'favorite_characters':
        return FavoriteCharacter.fromJson(json);
      case 'favorite_creators':
        return FavoriteCreator.fromJson(json);
      case 'favorite_reading_lists':
        return FavoriteReadingList.fromJson(json);
      default:
        throw ArgumentError('Unknown table name: $tableName');
    }
  }

  String _getPrimaryKeyName(String tableName) {
    switch (tableName) {
      case 'library_items':
      case 'library_read_logs':
      case 'pull_list_entries':
      case 'series_subscriptions':
      case 'activity_events':
      case 'reading_lists':
      case 'reading_list_items':
        return 'id';
      case 'favorite_series':
        return 'metronSeriesId';
      case 'favorite_issues':
        return 'metronIssueId';
      case 'favorite_characters':
        return 'metronCharacterId';
      case 'favorite_creators':
        return 'metronCreatorId';
      case 'favorite_reading_lists':
        return 'readingListId';
      default:
        throw ArgumentError('Unknown table name: $tableName');
    }
  }

  String? _getTimestampFieldName(String tableName) {
    switch (tableName) {
      case 'library_items':
      case 'pull_list_entries':
      case 'series_subscriptions':
      case 'reading_lists':
      case 'favorite_series':
      case 'favorite_issues':
      case 'favorite_characters':
      case 'favorite_creators':
      case 'favorite_reading_lists':
        return 'updatedAt';
      case 'library_read_logs':
        return 'createdAt';
      case 'activity_events':
        return 'timestamp';
      case 'reading_list_items':
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
      AppLogger.warning('Missing primary key value for table $tableName');
      return;
    }

    final tsFieldName = _getTimestampFieldName(tableName);
    String pkSqlName = pkName;
    if (pkName == 'metronSeriesId') {
      pkSqlName = 'metron_series_id';
    } else if (pkName == 'metronIssueId') {
      pkSqlName = 'metron_issue_id';
    } else if (pkName == 'metronCharacterId') {
      pkSqlName = 'metron_character_id';
    } else if (pkName == 'metronCreatorId') {
      pkSqlName = 'metron_creator_id';
    } else if (pkName == 'readingListId') {
      pkSqlName = 'reading_list_id';
    }

    if (tsFieldName != null) {
      String tsSqlName = tsFieldName;
      if (tsFieldName == 'updatedAt') {
        tsSqlName = 'updated_at';
      } else if (tsFieldName == 'createdAt') {
        tsSqlName = 'created_at';
      }

      final existing = await _db
          .customSelect(
            'SELECT $tsSqlName FROM $tableName WHERE $pkSqlName = ?',
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
            if (remoteTs.isBefore(localTs) ||
                remoteTs.isAtSameMomentAs(localTs)) {
              // Local is newer or same — skip remote row (LWW)
              return;
            }
          }
        }
      }
    } else {
      // No timestamp field (e.g. reading_list_items) — local wins if exists
      final existing = await _db
          .customSelect(
            'SELECT $pkSqlName FROM $tableName WHERE $pkSqlName = ?',
            variables: [Variable(pkValue)],
          )
          .getSingleOrNull();
      if (existing != null) {
        return;
      }
    }

    await _db.into(table).insertOnConflictUpdate(row);
  }

  Future<void> _deleteTableRow(String tableName, String pkValue) async {
    final pkName = _getPrimaryKeyName(tableName);

    String pkSqlName = pkName;
    if (pkName == 'metronSeriesId') {
      pkSqlName = 'metron_series_id';
    } else if (pkName == 'metronIssueId') {
      pkSqlName = 'metron_issue_id';
    } else if (pkName == 'metronCharacterId') {
      pkSqlName = 'metron_character_id';
    } else if (pkName == 'metronCreatorId') {
      pkSqlName = 'metron_creator_id';
    } else if (pkName == 'readingListId') {
      pkSqlName = 'reading_list_id';
    }

    dynamic parsedPk = pkValue;
    if (pkName.startsWith('metron')) {
      parsedPk = int.tryParse(pkValue) ?? pkValue;
    }

    await _db.customStatement('DELETE FROM $tableName WHERE $pkSqlName = ?', [
      parsedPk,
    ]);
  }
}
