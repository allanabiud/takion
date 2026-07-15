import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:path_provider/path_provider.dart';
import 'package:takion/src/core/backup/backup_service.dart';
import 'package:takion/src/core/storage/hive_service.dart';

final driveBackupServiceProvider = Provider<DriveBackupService>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return DriveBackupService(hiveService);
});

class DriveBackupService {
  static const _driveScope = 'https://www.googleapis.com/auth/drive.file';
  static const _appFolderName = 'Takion';
  static const _backupFileName = 'takion_backup.tkbk';

  static bool _googleInitialized = false;

  final HiveService _hiveService;
  final Dio _dio;
  GoogleSignInAccount? _currentUser;

  DriveBackupService(this._hiveService)
      : _dio = Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
          ),
        );

  Future<void> _ensureInitialized() async {
    if (!_googleInitialized) {
      await GoogleSignIn.instance.initialize();
      _googleInitialized = true;
    }
  }

  GoogleSignInAccount? get currentUser => _currentUser;

  bool get isSignedIn => _currentUser != null;

  Future<GoogleSignInAccount?> signIn() async {
    await _ensureInitialized();
    final account = await GoogleSignIn.instance.authenticate(scopeHint: [_driveScope]);
    _currentUser = account;
    return account;
  }

  Future<GoogleSignInAccount?> signInSilently() async {
    await _ensureInitialized();
    final account = await GoogleSignIn.instance.attemptLightweightAuthentication();
    if (account != null) {
      _currentUser = account;
    }
    return account;
  }

  Future<void> signOut() async {
    await _ensureInitialized();
    await GoogleSignIn.instance.signOut();
    _currentUser = null;
  }

  Future<String> _getAccessToken() async {
    final user = _currentUser;
    if (user == null) throw StateError('Not signed in to Google Drive');
    final authz = await user.authorizationClient.authorizeScopes([_driveScope]);
    final token = authz.accessToken;
    if (token.isEmpty) {
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
    } catch (_) {
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
    final fileId = await _findBackupFileId();
    if (fileId == null) return null;
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
    if (response.statusCode == 404) return null;
    return response.data as Uint8List;
  }

  Future<void> restoreFromDrive() async {
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
      await _hiveService.resetSyncTimestamps();
    } finally {
      try {
        await tempFile.delete();
      } catch (_) {}
    }
  }

  Future<String> uploadBackup({DateTime? lastSyncTime, int retryCount = 0}) async {
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
    if (lastSyncTime != null) {
      final existingBytes = await downloadBackup();
      if (existingBytes != null) {
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
        if (existingId != null) return existingId;
        data = await backupService.createBackupData(boxNames: allBoxNames);
      }
    } else {
      data = await backupService.createBackupData(boxNames: allBoxNames);
    }

    if (retryCount < 3) {
      final remoteModified = await _getBackupModificationTime();
      if (remoteModified != null && remoteModified.isAfter(downloadTime)) {
        return uploadBackup(
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

    final formData = FormData.fromMap({
      'metadata': MultipartFile.fromString(
        metadata,
        contentType: DioMediaType('application', 'json'),
      ),
      'file': MultipartFile.fromBytes(
        data,
        filename: _backupFileName,
        contentType: DioMediaType('application', 'octet-stream'),
      ),
    });

    final url = existingId != null
        ? 'https://www.googleapis.com/upload/drive/v3/files/$existingId'
        : 'https://www.googleapis.com/upload/drive/v3/files';

    final Response response;
    if (existingId != null) {
      response = await _dio.patch(
        url,
        queryParameters: {'uploadType': 'multipart'},
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } else {
      response = await _dio.post(
        url,
        queryParameters: {'uploadType': 'multipart'},
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    }

    final result = response.data as Map<String, dynamic>;
    await _hiveService.clearDeleteTimestamps();
    return result['id'] as String;
  }

  Future<Map<String, List<Map<String, dynamic>>>> _mergeAndResolve(
    Uint8List existingBytes,
    Map<String, int> changedKeys,
    Map<String, int> deletedKeys,
    Set<String> allBoxNames,
  ) async {
    final tempDir = await getTemporaryDirectory();
    final tempPath = '${tempDir.path}/$_backupFileName.merge.tmp';
    final tempFile = await File(tempPath).writeAsBytes(existingBytes.toList());

    try {
      final backupService = BackupService(_hiveService);
      final driveData = await backupService.readBackupData(filePath: tempPath);

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
      } catch (_) {}
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
