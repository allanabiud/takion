import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:takion/src/core/backup/backup_service.dart';
import 'package:takion/src/core/logging/app_logger.dart';
import 'package:takion/src/core/storage/hive_service.dart';

final driveBackupServiceProvider = Provider<DriveBackupService>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return DriveBackupService(hiveService);
});

class DriveBackupService {
  static const _driveScope = 'https://www.googleapis.com/auth/drive.file';
  static const _appFolderName = 'Takion';
  static const _backupFileName = 'takion_backup.tkbk';

  final HiveService _hiveService;
  final Dio _dio;
  final GoogleSignIn _googleSignIn;

  DriveBackupService(this._hiveService)
      : _dio = Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
          ),
        ),
        _googleSignIn = GoogleSignIn(scopes: [_driveScope]);

  GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;

  bool get isSignedIn => _googleSignIn.currentUser != null;

  Future<GoogleSignInAccount?> signIn() async {
    final account = await _googleSignIn.signIn();
    return account;
  }

  Future<GoogleSignInAccount?> signInSilently() async {
    final account = await _googleSignIn.signInSilently();
    return account;
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  Future<String> _getAccessToken() async {
    final user = _googleSignIn.currentUser;
    if (user == null) throw StateError('Not signed in to Google Drive');
    final auth = await user.authentication;
    final token = auth.accessToken;
    if (token == null || token.isEmpty) {
      throw StateError('Google Drive access token is empty, please re-authenticate');
    }
    return token;
  }

  Future<Response> _driveGet(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final token = await _getAccessToken();
    return _dio.get(
      path,
      queryParameters: queryParameters,
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
        validateStatus: (status) => status == 200 || status == 404,
      ),
    );
  }

  Future<String?> _getAppFolderId() async {
    final response = await _driveGet(
      'https://www.googleapis.com/drive/v3/files',
      queryParameters: {
        'q': "name='$_appFolderName' and mimeType='application/vnd.google-apps.folder' and trashed=false",
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

  Future<String?> _findBackupFileId() async {
    final folderId = await _ensureAppFolderId();
    final response = await _driveGet(
      'https://www.googleapis.com/drive/v3/files',
      queryParameters: {
        'q': "'$folderId' in parents and name='$_backupFileName' and trashed=false",
        'fields': 'files(id,name)',
      },
    );
    if (response.statusCode == 404) return null;
    final data = response.data as Map<String, dynamic>;
    final files = data['files'] as List<dynamic>? ?? [];
    if (files.isEmpty) return null;
    return (files.first as Map<String, dynamic>)['id'] as String;
  }

  Future<DateTime?> getLastBackupTime() async {
    try {
      final fileId = await _findBackupFileId();
      if (fileId == null) return null;
      final response = await _driveGet(
        'https://www.googleapis.com/drive/v3/files/$fileId',
        queryParameters: {'fields': 'createdTime'},
      );
      if (response.statusCode != 200) return null;
      final data = response.data as Map<String, dynamic>;
      final timeStr = data['createdTime'] as String?;
      if (timeStr == null) return null;
      return DateTime.parse(timeStr).toLocal();
    } catch (e) {
      AppLogger.warning('Failed to get backup modification time', error: e);
      return null;
    }
  }

  Future<DateTime?> _getBackupModificationTime() async {
    final fileId = await _findBackupFileId();
    if (fileId == null) return null;
    final response = await _driveGet(
      'https://www.googleapis.com/drive/v3/files/$fileId',
      queryParameters: {'fields': 'modifiedTime'},
    );
    if (response.statusCode != 200) return null;
    final data = response.data as Map<String, dynamic>;
    final timeStr = data['modifiedTime'] as String?;
    if (timeStr == null) return null;
    return DateTime.parse(timeStr).toLocal();
  }

  Future<Uint8List?> downloadBackup() async {
    AppLogger.info('Backup download started');
    final fileId = await _findBackupFileId();
    if (fileId == null) {
      return null;
    }
    final token = await _getAccessToken();
    final response = await _dio.get(
      'https://www.googleapis.com/drive/v3/files/$fileId',
      queryParameters: {'alt': 'media'},
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
        responseType: ResponseType.bytes,
        validateStatus: (status) => status == 200 || status == 404,
      ),
    );
    if (response.statusCode == 404) {
      return null;
    }
    final bytes = response.data as Uint8List;
    AppLogger.info('Backup download completed');
    return bytes;
  }

  Future<void> restoreFromDrive() async {
    AppLogger.info('Drive restore started');
    final bytes = await downloadBackup();
    if (bytes == null) throw StateError('No backup found on Drive');

    final tempDir = await getTemporaryDirectory();
    final tempPath = '${tempDir.path}/$_backupFileName.tmp';
    final tempFile = await File(tempPath).writeAsBytes(bytes.toList());

    try {
      final backupService = BackupService(_hiveService);
      BackupManifest manifest;
      Map<String, List<Map<String, dynamic>>> data;
      try {
        manifest = await backupService.loadManifest(filePath: tempPath);
        data = await backupService.readBackupData(filePath: tempPath);
      } on FormatException {
        await deleteBackup();
        throw StateError(
          'The backup on Drive was corrupt and has been deleted. '
          'Sync again to create a fresh backup.',
        );
      }

      final boxNames = BackupService.backupGroups.values
          .expand((boxes) => boxes)
          .where((b) => manifest.boxNames.contains(b))
          .toSet();

      await backupService.restoreBoxes(data: data, boxNames: boxNames);
      AppLogger.info('Drive restore completed');
    } finally {
      try {
        await tempFile.delete();
      } catch (e) {
        AppLogger.warning('Failed to delete temp file', error: e);
      }
    }
  }

  Future<String>? _currentBackupUpload;

  Future<String> uploadBackup({DateTime? lastSyncTime, int retryCount = 0}) async {
    if (_currentBackupUpload != null) {
      return _currentBackupUpload!;
    }

    AppLogger.info('Backup upload started');
    _currentBackupUpload = _performUpload(
      lastSyncTime: lastSyncTime,
      retryCount: retryCount,
    );
    try {
      final result = await _currentBackupUpload!;
      AppLogger.info('Backup upload completed');
      return result;
    } finally {
      _currentBackupUpload = null;
    }
  }

  Future<String> _performUpload({DateTime? lastSyncTime, int retryCount = 0}) async {
    final token = await _getAccessToken();
    final folderId = await _ensureAppFolderId();

    final backupService = BackupService(_hiveService);
    final allBoxNames = BackupService.backupGroups.values
        .expand((boxes) => boxes)
        .toSet();

    Map<String, int> changedKeys = {};
    Map<String, int> deletedKeys = {};
    if (lastSyncTime != null) {
      changedKeys = await _hiveService.getChangedKeysSince(lastSyncTime);
      deletedKeys = await _hiveService.getDeletedKeysSince(lastSyncTime);
    }

    final downloadTime = DateTime.now();
    Uint8List data;

    final existingBytes = await downloadBackup();
    if (existingBytes != null) {
      if (lastSyncTime == null) {
        final allTimestamps = await _hiveService.getAllTimestamps();
        changedKeys = Map.fromEntries(allTimestamps.entries);
      }
      final mergedData = await _mergeAndResolve(
        existingBytes,
        changedKeys,
        deletedKeys,
        allBoxNames,
      );
      data = await backupService.createBackupData(
        boxNames: allBoxNames,
        boxes: mergedData,
      );
    } else if (changedKeys.isNotEmpty || deletedKeys.isNotEmpty) {
      data = await backupService.createBackupData(boxNames: allBoxNames);
    } else {
      final existingId = await _findBackupFileId();
      if (existingId != null) {
        return existingId;
      }
      data = await backupService.createBackupData(boxNames: allBoxNames);
    }

    if (retryCount < 3) {
      final remoteModified = await _getBackupModificationTime();
      if (remoteModified != null && remoteModified.isAfter(downloadTime)) {
        AppLogger.info('Backup upload conflict detected, retry ${retryCount + 1}');
        return _performUpload(
          lastSyncTime: lastSyncTime,
          retryCount: retryCount + 1,
        );
      }
    }

    final existingId = await _findBackupFileId();
    final metadata = jsonEncode({
      'name': _backupFileName,
      if (existingId == null) 'parents': [folderId],
    });

    final boundary = 'boundary_${DateTime.now().millisecondsSinceEpoch}';
    final bodyBytes = _multipartRelatedBody(metadata, data, boundary);
    final uri = existingId != null
        ? Uri.parse(
            'https://www.googleapis.com/upload/drive/v3/files/$existingId?uploadType=multipart')
        : Uri.parse(
            'https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart');

    final request = http.Request(
      existingId != null ? 'PATCH' : 'POST',
      uri,
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Content-Type'] = 'multipart/related; boundary=$boundary';
    request.bodyBytes = bodyBytes;

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode != 200) {
      throw StateError(
        'Upload failed (HTTP ${response.statusCode}): ${response.body}',
      );
    }

    final result = jsonDecode(response.body) as Map<String, dynamic>;
    await _hiveService.clearDeleteTimestamps();
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
        'Content-Disposition: form-data; name="metadata"\r\n'
        'Content-Type: application/json; charset=UTF-8\r\n\r\n'
        '$metadata\r\n',
      ),
    );
    bytes.addAll(utf8.encode('--$boundary\r\n'));
    bytes.addAll(
      utf8.encode(
        'Content-Disposition: form-data; name="file"; '
        'filename="$_backupFileName"\r\n'
        'Content-Type: application/octet-stream\r\n\r\n',
      ),
    );
    bytes.addAll(fileData);
    bytes.addAll(utf8.encode('\r\n--$boundary--\r\n'));
    return bytes;
  }

  Future<Map<String, List<Map<String, dynamic>>>> _mergeAndResolve(
    Uint8List existingBytes,
    Map<String, int> changedKeys,
    Map<String, int> deletedKeys,
    Set<String> allBoxNames,
  ) async {
    AppLogger.info('Backup merge started');
    final tempDir = await getTemporaryDirectory();
    final tempPath = '${tempDir.path}/$_backupFileName.merge.tmp';
    final tempFile = await File(tempPath).writeAsBytes(existingBytes.toList());

    try {
      final backupService = BackupService(_hiveService);
      final driveData = await backupService.readBackupData(filePath: tempPath);

      // Phase 1: Process local changes (changedKeys)
      for (final entry in changedKeys.entries) {
        final compositeKey = entry.key;
        final colonIdx = compositeKey.indexOf(':');
        if (colonIdx == -1) continue;
        final boxName = compositeKey.substring(0, colonIdx);
        final key = compositeKey.substring(colonIdx + 1);

        if (!allBoxNames.contains(boxName)) continue;
        if (!driveData.containsKey(boxName)) {
          driveData[boxName] = [];
        }

        final localTs = entry.value;
        final entries = driveData[boxName]!;
        final driveIdx = entries.indexWhere((e) => e['k'] == key);
        final driveTs = driveIdx >= 0
            ? (entries[driveIdx]['t'] as int?)
            : null;

        if (driveTs != null && driveTs > localTs) {
          final driveEntry = entries[driveIdx];
          await _hiveService.putEntry(
            boxName,
            driveEntry['k'] as String,
            driveEntry['v'],
          );
          await _hiveService.recordTimestamp(boxName, key);
          continue;
        }

        final currentValue = await _hiveService.readEntry(boxName, key);
        if (currentValue != null) {
          if (driveIdx >= 0) {
            entries[driveIdx] = {'k': key, 'v': currentValue, 't': localTs};
          } else {
            entries.add({'k': key, 'v': currentValue, 't': localTs});
          }
        } else {
          if (driveIdx >= 0) {
            entries.removeAt(driveIdx);
          }
        }
      }

      // Phase 2: Apply newer Drive entries to local
      final allLocalTimestamps = await _hiveService.getAllTimestamps();
      for (final boxName in driveData.keys) {
        if (!allBoxNames.contains(boxName)) continue;
        final entries = driveData[boxName]!;
        for (final entry in entries) {
          final key = entry['k'] as String;
          final driveTs = entry['t'] as int?;
          if (driveTs == null) continue;
          final compositeKey = '$boxName:$key';
          if (changedKeys.containsKey(compositeKey)) continue;
          final localTs = allLocalTimestamps[compositeKey];
          if (localTs == null || driveTs > localTs) {
            if (entry['v'] == null) {
              await _hiveService.deleteEntry(boxName, key);
            } else {
              await _hiveService.putEntry(boxName, key, entry['v']);
              await _hiveService.recordTimestamp(boxName, key);
            }
          }
        }
      }

      // Phase 3: Process local deletions
      for (final entry in deletedKeys.entries) {
        final compositeKey = entry.key;
        final colonIdx = compositeKey.indexOf(':');
        if (colonIdx == -1) continue;
        final boxName = compositeKey.substring(0, colonIdx);
        final key = compositeKey.substring(colonIdx + 1);

        if (!allBoxNames.contains(boxName)) continue;
        if (!driveData.containsKey(boxName)) continue;

        final localDeleteTs = entry.value;
        final entries = driveData[boxName]!;
        final driveIdx = entries.indexWhere((e) => e['k'] == key);

        if (driveIdx >= 0) {
          final driveEntry = entries[driveIdx];
          final driveTs = driveEntry['t'] as int?;
          if (driveTs != null && driveTs > localDeleteTs) {
            await _hiveService.putEntry(boxName, key, driveEntry['v']);
            await _hiveService.recordTimestamp(boxName, key);
          } else {
            entries[driveIdx] = {'k': key, 'v': null, 't': localDeleteTs};
          }
        }
      }

      return driveData;
    } finally {
      try {
        await tempFile.delete();
        AppLogger.info('Backup merge completed');
      } catch (e) {
        AppLogger.warning('Failed to delete temp file', error: e);
      }
    }
  }

  Future<void> deleteBackup() async {
    final token = await _getAccessToken();
    final fileId = await _findBackupFileId();
    if (fileId == null) return;
    await _dio.delete(
      'https://www.googleapis.com/drive/v3/files/$fileId',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

}
