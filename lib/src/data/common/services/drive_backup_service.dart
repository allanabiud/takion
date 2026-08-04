import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:drift/drift.dart';
import 'package:takion/src/core/logging/app_logger.dart';
import 'package:takion/src/core/storage/drift_database_provider.dart';
import 'package:takion/src/core/sync/sync_diagnostics.dart';
import 'package:takion/src/data/common/drift/database.dart';

final driveSyncServiceProvider = Provider<DriveSyncService>((ref) {
  final db = ref.watch(driftDatabaseProvider);
  return DriveSyncService(db);
});

class _TransientDriveError implements Exception {
  const _TransientDriveError(this.status);
  final int? status;

  @override
  String toString() => 'HTTP ${status ?? 'unknown'}';
}

class DriveSyncService {
  static const _driveScope = 'https://www.googleapis.com/auth/drive.file';
  static const _appFolderName = 'Takion';
  static const _deltaFileName = 'takion_delta_v1.json';
  static const _fullFileName = 'takion_full_v1.json';

  final AppDatabase _db;
  final Dio _dio;
  final GoogleSignIn _googleSignIn;
  String? _appFolderIdCache;

  DriveSyncService(this._db)
    : _dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      ),
      _googleSignIn = GoogleSignIn(scopes: [_driveScope]) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.extra['_start'] = DateTime.now();
          handler.next(options);
        },
        onResponse: (response, handler) {
          final start = response.requestOptions.extra['_start'] as DateTime?;
          final ms = start == null
              ? null
              : DateTime.now().difference(start).inMilliseconds;
          AppLogger.info(
            'Drive ${response.requestOptions.method} '
            '${response.requestOptions.uri} -> ${response.statusCode}'
            '${ms == null ? '' : ' (${ms}ms)'}',
          );
          handler.next(response);
        },
        onError: (error, handler) {
          final start = error.requestOptions.extra['_start'] as DateTime?;
          final ms = start == null
              ? null
              : DateTime.now().difference(start).inMilliseconds;
          AppLogger.warning(
            'Drive ${error.requestOptions.method} '
            '${error.requestOptions.uri} failed'
            '${ms == null ? '' : ' (${ms}ms)'}: '
            '${error.type} ${error.response?.statusCode}',
            error: error,
          );
          handler.next(error);
        },
      ),
    );
  }

  GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;
  bool get isSignedIn => _googleSignIn.currentUser != null;

  Future<GoogleSignInAccount?> signIn() async {
    return await _googleSignIn.signIn();
  }

  Future<GoogleSignInAccount?> signInSilently({
    bool reAuthenticate = false,
  }) async {
    if (reAuthenticate) {
      _appFolderIdCache = null;
    }
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
    _appFolderIdCache = null;
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
      AppLogger.warning('Google Drive authentication failed', error: e);
      user = await signInSilently(reAuthenticate: true);
      if (user == null) {
        AppLogger.warning('Not signed in to Google Drive');
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
      AppLogger.warning(
        'Google Drive access token is empty, please re-authenticate',
      );
      throw StateError(
        'Google Drive access token is empty, please re-authenticate',
      );
    }
    return token;
  }

  bool _isRetryable(Object error) {
    if (error is _TransientDriveError) return true;
    if (error is DioException) {
      final status = error.response?.statusCode;
      if (status == 429 || status == 403) return true;
      if (status != null && status >= 500 && status < 600) return true;
      return error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.receiveTimeout;
    }
    if (error is TimeoutException) return true;
    return false;
  }

  Future<T> _retry<T>(
    String operation,
    Future<T> Function() action, {
    int maxRetries = 3,
  }) async {
    var attempt = 0;
    while (true) {
      try {
        return await action();
      } catch (error) {
        if (!_isRetryable(error) || attempt >= maxRetries) rethrow;
        final delay = Duration(
          seconds: math.min(math.pow(2, attempt).toInt(), 60),
        );
        AppLogger.warning(
          '$operation failed ($error), retrying in ${delay.inSeconds}s '
          '(attempt ${attempt + 1})',
          error: error,
        );
        await Future.delayed(delay);
        attempt++;
      }
    }
  }

  Future<Response> _driveGet(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool isRetry = false,
  }) async {
    final token = await _getAccessToken();
    final response = await _retry(
      'GET $path',
      () async {
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
                status == 403 ||
                (status != null && status >= 500),
          ),
        );
        final status = response.statusCode;
        if (status == 429 || status == 403 || (status != null && status >= 500)) {
          throw _TransientDriveError(status);
        }
        return response;
      },
    );
    if (response.statusCode == 401 && !isRetry) {
      AppLogger.info(
        'Drive GET request returned 401, attempting silent token refresh...',
      );
      await signInSilently(reAuthenticate: true);
      return _driveGet(path, queryParameters: queryParameters, isRetry: true);
    }
    return response;
  }

  Future<Response> _drivePost(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    bool isRetry = false,
  }) async {
    final token = await _getAccessToken();
    final response = await _retry(
      'POST $path',
      () async {
        final response = await _dio.post(
          path,
          data: data,
          queryParameters: queryParameters,
          options: Options(
            headers: {'Authorization': 'Bearer $token'},
            validateStatus: (status) =>
                status == 200 ||
                status == 201 ||
                status == 401 ||
                status == 404 ||
                status == 409 ||
                status == 429 ||
                status == 403 ||
                (status != null && status >= 500),
          ),
        );
        final status = response.statusCode;
        if (status == 429 || status == 403 || (status != null && status >= 500)) {
          throw _TransientDriveError(status);
        }
        return response;
      },
    );
    if (response.statusCode == 401 && !isRetry) {
      AppLogger.info(
        'Drive POST request returned 401, attempting silent token refresh...',
      );
      await signInSilently(reAuthenticate: true);
      return _drivePost(
        path,
        data: data,
        queryParameters: queryParameters,
        isRetry: true,
      );
    }
    return response;
  }

  Future<Response> _driveDelete(String path, {bool isRetry = false}) async {
    final token = await _getAccessToken();
    final response = await _retry(
      'DELETE $path',
      () async {
        final response = await _dio.delete(
          path,
          options: Options(
            headers: {'Authorization': 'Bearer $token'},
            validateStatus: (status) =>
                status == 200 ||
                status == 204 ||
                status == 401 ||
                status == 404 ||
                status == 429 ||
                status == 403 ||
                (status != null && status >= 500),
          ),
        );
        final status = response.statusCode;
        if (status == 429 || status == 403 || (status != null && status >= 500)) {
          throw _TransientDriveError(status);
        }
        return response;
      },
    );
    if (response.statusCode == 401 && !isRetry) {
      AppLogger.info(
        'Drive DELETE request returned 401, attempting silent token refresh...',
      );
      await signInSilently(reAuthenticate: true);
      return _driveDelete(path, isRetry: true);
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
    if (response.statusCode != 200) {
      throw StateError(
        'Failed to get app folder ID (HTTP ${response.statusCode})',
      );
    }
    final data = response.data as Map<String, dynamic>?;
    if (data == null) return null;
    final files = data['files'] as List<dynamic>? ?? [];
    if (files.isEmpty) return null;
    return (files.first as Map<String, dynamic>)['id'] as String?;
  }

  Future<String> _ensureAppFolderId() async {
    final cached = _appFolderIdCache;
    if (cached != null) return cached;

    final existingId = await _getAppFolderId();
    if (existingId != null) {
      _appFolderIdCache = existingId;
      return existingId;
    }

    final response = await _drivePost(
      'https://www.googleapis.com/drive/v3/files',
      data: {
        'name': _appFolderName,
        'mimeType': 'application/vnd.google-apps.folder',
      },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.data as Map<String, dynamic>;
      final id = data['id'] as String;
      _appFolderIdCache = id;
      return id;
    }
    if (response.statusCode == 409) {
      AppLogger.info(
        'Folder create returned 409, fetching existing folder id',
      );
      final reFound = await _getAppFolderId();
      if (reFound != null) {
        _appFolderIdCache = reFound;
        return reFound;
      }
      throw StateError(
        'Failed to create Drive folder (HTTP 409): ${response.data}',
      );
    }
    throw StateError(
      'Failed to create Drive folder (HTTP ${response.statusCode}): ${response.data}',
    );
  }

  Future<String?> _findFileId(String fileName) async {
    try {
      final folderId = await _ensureAppFolderId();
      final response = await _driveGet(
        'https://www.googleapis.com/drive/v3/files',
        queryParameters: {
          'q': "'$folderId' in parents and name='$fileName' and trashed=false",
          'fields': 'files(id,name)',
        },
      );
      if (response.statusCode != 200) return null;
      final data = response.data as Map<String, dynamic>?;
      if (data == null) return null;
      final files = data['files'] as List<dynamic>? ?? [];
      if (files.isEmpty) return null;
      return (files.first as Map<String, dynamic>)['id'] as String?;
    } catch (e) {
      AppLogger.warning('Failed to find file ID for $fileName', error: e);
      rethrow;
    }
  }

  Future<DateTime?> _getFileModificationTime(String fileId) async {
    final response = await _driveGet(
      'https://www.googleapis.com/drive/v3/files/$fileId',
      queryParameters: {'fields': 'modifiedTime'},
    );
    if (response.statusCode != 200) return null;
    final data = response.data as Map<String, dynamic>?;
    if (data == null) return null;
    final timeStr = data['modifiedTime'] as String?;
    if (timeStr == null) return null;
    return DateTime.parse(timeStr);
  }

  Future<Uint8List?> _downloadFile(
    String fileId, {
    bool isRetry = false,
  }) async {
    final token = await _getAccessToken();
    final response = await _retry(
      'DOWNLOAD $fileId',
      () async {
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
                status == 403 ||
                (status != null && status >= 500),
          ),
        );
        final status = response.statusCode;
        if (status == 429 || status == 403 || (status != null && status >= 500)) {
          throw _TransientDriveError(status);
        }
        return response;
      },
    );
    if (response.statusCode == 401 && !isRetry) {
      AppLogger.info(
        'Drive download returned 401, attempting silent token refresh...',
      );
      await signInSilently(reAuthenticate: true);
      return _downloadFile(fileId, isRetry: true);
    }
    if (response.statusCode != 200) return null;
    return response.data as Uint8List?;
  }

  Future<String> _uploadFile(
    String fileName,
    Uint8List fileData, {
    bool isRetry = false,
  }) async {
    final token = await _getAccessToken();
    final folderId = await _ensureAppFolderId();
    final existingId = await _findFileId(fileName);

    final metadata = jsonEncode({
      'name': fileName,
      if (existingId == null) 'parents': [folderId],
    });

    final boundary = 'boundary_${DateTime.now().millisecondsSinceEpoch}';
    final bodyBytes = _multipartRelatedBody(metadata, fileData, boundary);
    final uri = existingId != null
        ? Uri.parse(
            'https://www.googleapis.com/upload/drive/v3/files/$existingId?uploadType=multipart',
          )
        : Uri.parse(
            'https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart',
          );

    final stopwatch = Stopwatch()..start();
    final response = await _retry(
      'UPLOAD $fileName',
      () async {
        final request = http.Request(existingId != null ? 'PATCH' : 'POST', uri);
        request.headers['Authorization'] = 'Bearer $token';
        request.headers['Content-Type'] =
            'multipart/related; boundary=$boundary';
        request.bodyBytes = bodyBytes;

        final streamed = await request
            .send()
            .timeout(const Duration(seconds: 60));
        final response = await http.Response.fromStream(streamed).timeout(
          const Duration(seconds: 60),
        );
        AppLogger.info(
          'Drive upload ${existingId != null ? 'PATCH' : 'POST'} $uri '
          '-> ${response.statusCode} (${stopwatch.elapsedMilliseconds}ms, '
          '${fileData.length} bytes)',
        );
        if (response.statusCode == 429 ||
            response.statusCode == 403 ||
            response.statusCode >= 500) {
          throw _TransientDriveError(response.statusCode);
        }
        return response;
      },
    );
    stopwatch.stop();

    if (response.statusCode == 401 && !isRetry) {
      AppLogger.info(
        'Drive upload returned 401, attempting silent token refresh...',
      );
      await signInSilently(reAuthenticate: true);
      return _uploadFile(fileName, fileData, isRetry: true);
    }

    if (response.statusCode != 200 && response.statusCode != 201) {
      AppLogger.error(
        'Drive upload failed (HTTP ${response.statusCode}): ${response.body}',
      );
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
    String boundary,
  ) {
    final bytes = <int>[];
    bytes.addAll(utf8.encode('--$boundary\r\n'));
    bytes.addAll(
      utf8.encode(
        'Content-Type: application/json; charset=UTF-8\r\n\r\n'
        '$metadata\r\n',
      ),
    );
    bytes.addAll(utf8.encode('--$boundary\r\n'));
    bytes.addAll(
      utf8.encode('Content-Type: application/json; charset=UTF-8\r\n\r\n'),
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

  Future<void> _record({
    required String phase,
    required bool success,
    String? error,
    String? detail,
    int? elapsedMs,
  }) async {
    try {
      await recordSyncAttempt(
        _db.syncMetaDao,
        phase: phase,
        success: success,
        error: error,
        detail: detail,
        elapsedMs: elapsedMs,
      );
    } catch (e) {
      AppLogger.warning('Failed to record sync attempt for $phase', error: e);
    }
  }

  /// Public wrapper so the WorkManager background isolate (which builds its
  /// own [DriveSyncService]) can persist sync outcomes outside [triggerSync].
  Future<void> recordSyncOutcome({
    required String phase,
    required bool success,
    Object? error,
    int? elapsedMs,
  }) {
    return _record(
      phase: phase,
      success: success,
      error: error?.toString(),
      detail: error == null ? null : _describeError(error),
      elapsedMs: elapsedMs,
    );
  }

  String _describeError(Object error) {
    if (error is DioException) {
      return 'DioException(${error.type}) HTTP ${error.response?.statusCode}';
    }
    if (error is StateError) return 'StateError: ${error.message}';
    if (error is FormatException) return 'FormatException: ${error.message}';
    return '${error.runtimeType}';
  }

  Future<T> _guarded<T>(
    String phase,
    Future<T> Function() action,
  ) async {
    final stopwatch = Stopwatch()..start();
    try {
      final result = await action();
      await _record(
        phase: phase,
        success: true,
        elapsedMs: stopwatch.elapsedMilliseconds,
      );
      return result;
    } catch (error) {
      await _record(
        phase: phase,
        success: false,
        error: error.toString(),
        detail: _describeError(error),
        elapsedMs: stopwatch.elapsedMilliseconds,
      );
      rethrow;
    }
  }

  Future<void> triggerSync({bool ignoreThrottle = false}) async {
    AppLogger.info('Drive sync triggered (ignoreThrottle: $ignoreThrottle)');

    final lockRaw = await _db.syncMetaDao.get('sync_in_progress');
    if (lockRaw != null) {
      final lockTime = DateTime.tryParse(lockRaw);
      final isStale = lockTime != null &&
          DateTime.now().difference(lockTime) > const Duration(minutes: 10);
      if (!isStale) {
        AppLogger.info('Sync skipped: another sync is already in progress');
        return;
      }
      AppLogger.warning(
        'Stale sync lock detected, clearing before proceeding',
      );
    }
    await _db.syncMetaDao.set(
      'sync_in_progress',
      DateTime.now().toUtc().toIso8601String(),
    );

    try {
      await _triggerSync(ignoreThrottle: ignoreThrottle);
    } finally {
      await _db.syncMetaDao.deleteByKey('sync_in_progress');
    }
  }

  Future<void> _triggerSync({required bool ignoreThrottle}) async {
    if (!ignoreThrottle) {
      final lastAttempt = await _db.syncMetaDao.get('last_sync_attempt');
      if (lastAttempt != null) {
        final lastAttemptTime = DateTime.tryParse(lastAttempt);
        if (lastAttemptTime != null &&
            DateTime.now().difference(lastAttemptTime) <
                const Duration(minutes: 5)) {
          AppLogger.info('Sync skipped: throttled');
          return;
        }
      }
    }
    await _db.syncMetaDao.set(
      'last_sync_attempt',
      DateTime.now().toUtc().toIso8601String(),
    );

    final deltaFileId = await _guarded('folder', () => _findFileId(_deltaFileName));
    final lastSyncTime = await getLastSyncTime();
    final lastUploadedRaw = await _db.syncMetaDao.get('last_uploaded_timestamp');
    final lastUploaded = lastUploadedRaw == null
        ? null
        : DateTime.tryParse(lastUploadedRaw);
    final localDeviceId = await _getDeviceId();
    bool remoteChangesApplied = false;
    String? remoteToTimestamp;

    if (deltaFileId != null) {
      final remoteModified = await _guarded(
        'meta',
        () => _getFileModificationTime(deltaFileId),
      );
      final remoteIsNewer =
          remoteModified != null &&
          (lastSyncTime == null || remoteModified.isAfter(lastSyncTime)) &&
          (lastUploaded == null || remoteModified.isAfter(lastUploaded));
      if (remoteIsNewer) {
        AppLogger.info(
          'Remote sync data is available, downloading and checking',
        );
        final bytes = await _guarded(
          'download',
          () => _downloadFile(deltaFileId),
        );
        if (bytes != null) {
          final payload = await _guarded(
            'parse',
            () async => jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>,
          );
          if (_isSupportedVersion(payload['version'])) {
            final remoteDeviceId = payload['deviceId'] as String?;
            if (remoteDeviceId != localDeviceId) {
              await _guarded('apply', () => applyDelta(payload));
              remoteChangesApplied = true;
              remoteToTimestamp = payload['toTimestamp'] as String?;
            } else {
              AppLogger.info(
                'Remote sync file was created by this device ($localDeviceId); skipping remote apply',
              );
            }
          }
        }
      }
    } else {
      final fullFileId = await _guarded(
        'folder',
        () => _findFileId(_fullFileName),
      );
      if (fullFileId != null && lastSyncTime == null) {
        AppLogger.info(
          'No delta but full file exists and no local sync, downloading full',
        );
        final bytes = await _guarded(
          'download',
          () => _downloadFile(fullFileId),
        );
        if (bytes != null) {
          final payload = await _guarded(
            'parse',
            () async => jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>,
          );
          if (_isSupportedVersion(payload['version'])) {
            final remoteDeviceId = payload['deviceId'] as String?;
            if (remoteDeviceId != localDeviceId) {
              await _guarded('apply', () => applyDelta(payload));
              remoteChangesApplied = true;
              remoteToTimestamp = payload['toTimestamp'] as String?;
            } else {
              AppLogger.info(
                'Full sync file was created by this device; skipping remote apply',
              );
            }
          }
        }
      }
    }

    final localChangesDelta = await _guarded(
      'extract',
      () => extractDelta(lastUploaded),
    );

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

    final shouldUpload =
        hasLocalChanges || deltaFileId == null || lastSyncTime == null;

    if (shouldUpload) {
      final insertCount = _countChanges(localChangesDelta, 'inserts');
      final deleteCount = _countChanges(localChangesDelta, 'deletes');
      AppLogger.info(
        'Uploading local sync data ($insertCount inserts, $deleteCount deletes)',
      );

      final deltaPayload = await _guarded(
        'extract',
        () => extractDelta(lastUploaded),
      );
      final jsonBytes = utf8.encode(jsonEncode(deltaPayload));

      await _guarded(
        'upload',
        () => _uploadFile(_deltaFileName, Uint8List.fromList(jsonBytes)),
      );

      final nowStr = deltaPayload['toTimestamp'] as String;
      await _db.syncMetaDao.set('last_sync_timestamp', nowStr);
      await _db.syncMetaDao.set('last_uploaded_timestamp', nowStr);

      final now = DateTime.parse(nowStr);
      await _guarded('prune', () => _pruneDeletedRows(now.subtract(const Duration(days: 30))));
    } else if (remoteChangesApplied && remoteToTimestamp != null) {
      await _db.syncMetaDao.set('last_sync_timestamp', remoteToTimestamp);
      AppLogger.info(
        'Remote changes were applied from $remoteToTimestamp, no local changes to upload',
      );
    } else {
      AppLogger.info('No changes to sync');
    }
  }

  int _countChanges(Map<String, dynamic> delta, String kind) {
    final tables = delta['tables'] as Map<String, dynamic>? ?? {};
    var count = 0;
    for (final table in tables.values) {
      final items = (table as Map<String, dynamic>)[kind] as List?;
      if (items != null) count += items.length;
    }
    return count;
  }

  Future<void> forceSync() async {
    AppLogger.info('Forcing full sync snapshot upload');
    final delta = await _guarded('extract', () => extractDelta(null));
    final jsonBytes = utf8.encode(jsonEncode(delta));
    await _guarded(
      'upload',
      () => _uploadFile(_fullFileName, Uint8List.fromList(jsonBytes)),
    );

    await _guarded(
      'upload',
      () => _uploadFile(_deltaFileName, Uint8List.fromList(jsonBytes)),
    );

    final nowStr = delta['toTimestamp'] as String;
    await _db.syncMetaDao.set('last_sync_timestamp', nowStr);
    await _db.syncMetaDao.set('last_uploaded_timestamp', nowStr);

    final now = DateTime.parse(nowStr);
    await _guarded('prune', () => _pruneDeletedRows(now.subtract(const Duration(days: 30))));
  }

  Future<void> restoreFromDrive() async {
    AppLogger.info('Restore from Drive started');

    String? fileId = await _guarded('folder', () => _findFileId(_deltaFileName));
    fileId ??= await _guarded('folder', () => _findFileId(_fullFileName));

    if (fileId == null) {
      throw StateError('No sync data found on Google Drive');
    }
    final safeFileId = fileId;

    final bytes = await _guarded('download', () => _downloadFile(safeFileId));
    if (bytes == null) {
      throw StateError('Failed to download sync data');
    }

    final payload = await _guarded(
      'parse',
      () async => jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>,
    );
    if (!_isSupportedVersion(payload['version'])) {
      throw StateError(
        'Unsupported sync format version: ${payload['version']}',
      );
    }

    await _guarded('apply', () => applyDelta(payload));

    final toTimestamp = payload['toTimestamp'] ?? payload['timestamp'];
    if (toTimestamp != null) {
      final timestamp = toTimestamp as String;
      await _db.syncMetaDao.set('last_sync_timestamp', timestamp);
      await _db.syncMetaDao.set('last_uploaded_timestamp', timestamp);
    }
    await _record(phase: 'restore', success: true);
    AppLogger.info('Restore from Drive completed');
  }

  Future<void> deleteRemoteData() async {
    AppLogger.info('Deleting sync data from Google Drive');

    final deltaId = await _findFileId(_deltaFileName);
    if (deltaId != null) {
      await _driveDelete('https://www.googleapis.com/drive/v3/files/$deltaId');
    }

    final fullId = await _findFileId(_fullFileName);
    if (fullId != null) {
      await _driveDelete('https://www.googleapis.com/drive/v3/files/$fullId');
    }
  }

  Future<Map<String, dynamic>> extractDelta(DateTime? since) async {
    final sinceStr = since?.toUtc().toIso8601String();
    final tablesData = <String, Map<String, dynamic>>{};
    final allMeta = await _db.syncMetaDao.getAll();

    List<String> getDeletesForTable(String tableName) {
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

    tablesData['library_items'] = {
      'inserts': await queryTableSince(
        _db.libraryItems,
        (sinceStr != null)
            ? (LibraryItems t) => t.updatedAt.isBiggerThan(Constant(sinceStr))
            : null,
      ),
      'updates': <Map<String, dynamic>>[],
      'deletes': getDeletesForTable('library_items'),
    };

    tablesData['library_read_logs'] = {
      'inserts': await queryTableSince(
        _db.libraryReadLogs,
        (sinceStr != null)
            ? (LibraryReadLogs t) =>
                  t.createdAt.isBiggerThan(Constant(sinceStr))
            : null,
      ),
      'updates': <Map<String, dynamic>>[],
      'deletes': getDeletesForTable('library_read_logs'),
    };

    tablesData['pull_list_entries'] = {
      'inserts': await queryTableSince(
        _db.pullListEntries,
        (sinceStr != null)
            ? (PullListEntries t) =>
                  t.updatedAt.isBiggerThan(Constant(sinceStr))
            : null,
      ),
      'updates': <Map<String, dynamic>>[],
      'deletes': getDeletesForTable('pull_list_entries'),
    };

    tablesData['series_subscriptions'] = {
      'inserts': await queryTableSince(
        _db.seriesSubscriptions,
        (sinceStr != null)
            ? (SeriesSubscriptions t) =>
                  t.updatedAt.isBiggerThan(Constant(sinceStr))
            : null,
      ),
      'updates': <Map<String, dynamic>>[],
      'deletes': getDeletesForTable('series_subscriptions'),
    };

    tablesData['activity_events'] = {
      'inserts': await queryTableSince(
        _db.activityEvents,
        (sinceStr != null)
            ? (ActivityEvents t) =>
                  t.timestamp.isBiggerThan(Constant(sinceStr))
            : null,
      ),
      'updates': <Map<String, dynamic>>[],
      'deletes': getDeletesForTable('activity_events'),
    };

    tablesData['reading_lists'] = {
      'inserts': await queryTableSince(
        _db.readingLists,
        (sinceStr != null)
            ? (ReadingLists t) => t.updatedAt.isBiggerThan(Constant(sinceStr))
            : null,
      ),
      'updates': <Map<String, dynamic>>[],
      'deletes': getDeletesForTable('reading_lists'),
    };

    List<ReadingListItem> listItems = await query(_db.readingListItems).get();
    tablesData['reading_list_items'] = {
      'inserts': listItems.map((r) => r.toJson()).toList(),
      'updates': <Map<String, dynamic>>[],
      'deletes': getDeletesForTable('reading_list_items'),
    };

    tablesData['favorite_series'] = {
      'inserts': await queryTableSince(
        _db.favoriteSeries,
        (sinceStr != null)
            ? (FavoriteSeries t) =>
                  t.updatedAt.isBiggerThan(Constant(sinceStr))
            : null,
      ),
      'updates': <Map<String, dynamic>>[],
      'deletes': getDeletesForTable('favorite_series'),
    };

    tablesData['favorite_issues'] = {
      'inserts': await queryTableSince(
        _db.favoriteIssues,
        (sinceStr != null)
            ? (FavoriteIssues t) =>
                  t.updatedAt.isBiggerThan(Constant(sinceStr))
            : null,
      ),
      'updates': <Map<String, dynamic>>[],
      'deletes': getDeletesForTable('favorite_issues'),
    };

    tablesData['favorite_characters'] = {
      'inserts': await queryTableSince(
        _db.favoriteCharacters,
        (sinceStr != null)
            ? (FavoriteCharacters t) =>
                  t.updatedAt.isBiggerThan(Constant(sinceStr))
            : null,
      ),
      'updates': <Map<String, dynamic>>[],
      'deletes': getDeletesForTable('favorite_characters'),
    };

    tablesData['favorite_creators'] = {
      'inserts': await queryTableSince(
        _db.favoriteCreators,
        (sinceStr != null)
            ? (FavoriteCreators t) =>
                  t.updatedAt.isBiggerThan(Constant(sinceStr))
            : null,
      ),
      'updates': <Map<String, dynamic>>[],
      'deletes': getDeletesForTable('favorite_creators'),
    };

    tablesData['favorite_reading_lists'] = {
      'inserts': await queryTableSince(
        _db.favoriteReadingLists,
        (sinceStr != null)
            ? (FavoriteReadingLists t) =>
                  t.updatedAt.isBiggerThan(Constant(sinceStr))
            : null,
      ),
      'updates': <Map<String, dynamic>>[],
      'deletes': getDeletesForTable('favorite_reading_lists'),
    };

    return {
      'version': 2,
      'deviceId': await _getDeviceId(),
      'fromTimestamp': sinceStr,
      'toTimestamp': DateTime.now().toUtc().toIso8601String(),
      'tables': tablesData,
    };
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
  static bool _isSupportedVersion(Object? version) =>
      version == 1 || version == 2;

  Future<void> applyDelta(Map<String, dynamic> payload) async {
    final version = payload['version'];
    final remoteDeviceId = payload['deviceId'] as String?;
    final fromTimestamp = payload['fromTimestamp'] as String?;
    final remoteToTimestamp = payload['toTimestamp'] as String?;

    // v1 payloads are full snapshots: always apply.
    // v2 with fromTimestamp == null are full snapshots: always apply.
    // v2 with fromTimestamp != null are real deltas: skip if already applied.
    final isDelta = version == 2 && fromTimestamp != null;
    if (isDelta && remoteDeviceId != null && remoteToTimestamp != null) {
      final watermark = await _getRemoteWatermark(remoteDeviceId);
      final wm = watermark == null ? null : DateTime.tryParse(watermark);
      final to = DateTime.tryParse(remoteToTimestamp);
      if (wm != null && to != null && !to.isAfter(wm)) {
        AppLogger.info(
          'Skipping already-applied delta from $remoteDeviceId '
          '(to $remoteToTimestamp <= watermark $watermark)',
        );
        return;
      }
    }

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

        // Tables without per-row timestamps (reading_list_items) are gated by
        // a per-device table watermark so the remote delta is authoritative
        // without ever being re-applied once already handled.
        final usesTableWatermark = tableName == 'reading_list_items';
        if (usesTableWatermark &&
            isDelta &&
            remoteDeviceId != null &&
            remoteToTimestamp != null) {
          final watermark = await _getTableWatermark(tableName, remoteDeviceId);
          final wm = watermark == null ? null : DateTime.tryParse(watermark);
          final to = DateTime.tryParse(remoteToTimestamp);
          if (wm != null && to != null && !to.isAfter(wm)) {
            AppLogger.info(
              'Skipping already-applied $tableName delta from $remoteDeviceId',
            );
            continue;
          }
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
            await _deleteTableRow(
              tableName,
              pk.toString(),
              remoteToTimestamp: remoteToTimestamp,
            );
          } catch (e) {
            AppLogger.error(
              'Failed to delete row $pk from $tableName',
              error: e,
            );
          }
        }

        if (usesTableWatermark &&
            remoteDeviceId != null &&
            remoteToTimestamp != null) {
          await _advanceTableWatermark(
            tableName,
            remoteDeviceId,
            remoteToTimestamp,
          );
        }
      }
    });

    if (remoteDeviceId != null && remoteToTimestamp != null) {
      await _advanceRemoteWatermark(remoteDeviceId, remoteToTimestamp);
    }
  }

  Future<String?> _getRemoteWatermark(String deviceId) =>
      _db.syncMetaDao.get('remote_watermark:$deviceId');

  Future<void> _advanceRemoteWatermark(
    String deviceId,
    String timestamp,
  ) async {
    final existing = await _getRemoteWatermark(deviceId);
    final newTs = DateTime.tryParse(timestamp);
    final oldTs = existing == null ? null : DateTime.tryParse(existing);
    if (newTs != null && (oldTs == null || newTs.isAfter(oldTs))) {
      await _db.syncMetaDao.set('remote_watermark:$deviceId', timestamp);
    }
  }

  Future<String?> _getTableWatermark(String tableName, String deviceId) =>
      _db.syncMetaDao.get('table_watermark:$tableName:$deviceId');

  Future<void> _advanceTableWatermark(
    String tableName,
    String deviceId,
    String timestamp,
  ) async {
    final existing = await _getTableWatermark(tableName, deviceId);
    final newTs = DateTime.tryParse(timestamp);
    final oldTs = existing == null ? null : DateTime.tryParse(existing);
    if (newTs != null && (oldTs == null || newTs.isAfter(oldTs))) {
      await _db.syncMetaDao.set(
        'table_watermark:$tableName:$deviceId',
        timestamp,
      );
    }
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

    // Timestamp guard: if the local row has a newer timestamp than the
    // remote snapshot, skip the delete (local re-insert wins over stale delete).
    if (remoteToTimestamp != null) {
      final tsFieldName = _getTimestampFieldName(tableName);
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
              variables: [Variable(parsedPk)],
            )
            .getSingleOrNull();
        if (existing != null) {
          final localTs = DateTime.tryParse(existing.read<String>(tsSqlName));
          final remoteTs = DateTime.tryParse(remoteToTimestamp);
          if (localTs != null &&
              remoteTs != null &&
              localTs.isAfter(remoteTs)) {
            // Local row has a newer timestamp — keep it
            return;
          }
        }
      }
    }

    await _db.customStatement('DELETE FROM $tableName WHERE $pkSqlName = ?', [
      parsedPk,
    ]);
  }
}
