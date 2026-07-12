import 'dart:convert';
import 'dart:io' as io;

import 'package:flutter/foundation.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:path_provider/path_provider.dart';
import 'package:takion/src/core/backup/backup_service.dart';

class BackupFileInfo {
  final String id;
  final String name;
  final DateTime? createdTime;
  final int? size;

  BackupFileInfo({
    required this.id,
    required this.name,
    this.createdTime,
    this.size,
  });
}

class CloudSyncTransport {
  final BackupService _backupService;
  final GoogleSignIn _googleSignIn;
  DriveApi? _driveApi;
  String? _syncFolderId;
  String? _backupFolderId;

  CloudSyncTransport(this._backupService)
      : _googleSignIn = GoogleSignIn(scopes: [DriveApi.driveFileScope]);

  GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;
  bool get isSignedIn => _googleSignIn.currentUser != null;
  Stream<GoogleSignInAccount?> get onCurrentUserChanged =>
      _googleSignIn.onCurrentUserChanged;

  Future<GoogleSignInAccount?> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account != null) {
        final client = await _googleSignIn.authenticatedClient();
        if (client != null) _driveApi = DriveApi(client);
      }
      return account;
    } catch (e) {
      throw Exception('Google sign in failed: $e');
    }
  }

  Future<GoogleSignInAccount?> signInSilently() async {
    try {
      final account = await _googleSignIn.signInSilently();
      if (account != null) {
        final client = await _googleSignIn.authenticatedClient();
        if (client != null) _driveApi = DriveApi(client);
      } else {
        debugPrint('CloudSyncTransport: signInSilently returned null');
      }
      return account;
    } catch (e) {
      debugPrint('CloudSyncTransport: signInSilently failed: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    _driveApi = null;
    _syncFolderId = null;
    _backupFolderId = null;
    await _googleSignIn.signOut();
  }

  Future<void> _ensureApi() async {
    if (_driveApi != null) return;
    final client = await _googleSignIn.authenticatedClient();
    if (client == null) throw Exception('Not signed in to Google');
    _driveApi = DriveApi(client);
  }

  Future<String> _ensureFolder(String folderName, {required bool isSync}) async {
    if (isSync && _syncFolderId != null) return _syncFolderId!;
    if (!isSync && _backupFolderId != null) return _backupFolderId!;
    
    await _ensureApi();

    final existing = await _driveApi!.files.list(
      q: "name='$folderName' and mimeType='application/vnd.google-apps.folder' and trashed=false",
      spaces: 'drive',
    );

    if (existing.files != null && existing.files!.isNotEmpty) {
      final folderId = existing.files!.first.id!;
      if (isSync) {
        _syncFolderId = folderId;
      } else {
        _backupFolderId = folderId;
      }
      return folderId;
    }

    final folder = await _driveApi!.files.create(
      File(
        name: folderName,
        mimeType: 'application/vnd.google-apps.folder',
      ),
    );
    final folderId = folder.id!;
    if (isSync) {
      _syncFolderId = folderId;
    } else {
      _backupFolderId = folderId;
    }
    return folderId;
  }

  Future<String> _ensureSyncFolder() => _ensureFolder('Takion Sync', isSync: true);
  Future<String> _ensureBackupFolder() => _ensureFolder('Takion Backups', isSync: false);

  Future<String?> _findSyncFile(String folderId) async {
    await _ensureApi();
    final existing = await _driveApi!.files.list(
      q: "'$folderId' in parents and name='sync_data.json' and trashed=false",
      spaces: 'drive',
    );
    if (existing.files != null && existing.files!.isNotEmpty) {
      return existing.files!.first.id;
    }
    return null;
  }

  Future<String?> downloadSyncData() async {
    await _ensureApi();
    final folderId = await _ensureSyncFolder();
    final fileId = await _findSyncFile(folderId);

    if (fileId == null) {
      debugPrint('CloudSyncTransport: sync_data.json not found on Drive');
      return null;
    }

    try {
      final response = await _driveApi!.files.get(
        fileId,
        downloadOptions: DownloadOptions.fullMedia,
      );
      
      final media = response as Media;
      final bytes = await media.stream.toList().then(
        (chunks) => chunks.expand((c) => c).toList(),
      );
      
      return utf8.decode(bytes);
    } catch (e) {
      debugPrint('CloudSyncTransport: Failed to download sync data: $e');
      return null;
    }
  }

  Future<void> uploadSyncData(String jsonString) async {
    await _ensureApi();
    final folderId = await _ensureSyncFolder();
    final fileId = await _findSyncFile(folderId);

    final bytes = utf8.encode(jsonString);
    final mediaStream = Stream.fromIterable([bytes]);
    final uploadMedia = Media(mediaStream, bytes.length);

    if (fileId != null) {
      // Overwrite existing file
      await _driveApi!.files.update(
        File(),
        fileId,
        uploadMedia: uploadMedia,
      );
      debugPrint('CloudSyncTransport: Overwrote sync_data.json on Drive');
    } else {
      // Create new file
      final driveFile = File(
        name: 'sync_data.json',
        parents: [folderId],
      );
      await _driveApi!.files.create(
        driveFile,
        uploadMedia: uploadMedia,
      );
      debugPrint('CloudSyncTransport: Created sync_data.json on Drive');
    }
  }

  Future<void> deleteSyncData() async {
    await _ensureApi();
    final folderId = await _ensureSyncFolder();
    final fileId = await _findSyncFile(folderId);
    if (fileId != null) {
      await _driveApi!.files.delete(fileId);
      debugPrint('CloudSyncTransport: Deleted sync_data.json from Drive');
    }
  }

  // --- Legacy Cloud Backup Methods (for Migration/Restore support) ---

  Future<List<BackupFileInfo>> listBackups() async {
    await _ensureApi();
    final folderId = await _ensureBackupFolder();

    final result = await _driveApi!.files.list(
      q: "'$folderId' in parents and trashed=false",
      spaces: 'drive',
      orderBy: 'createdTime desc',
      pageSize: 20,
      $fields: 'files(id, name, createdTime, size)',
    );

    final files = result.files ?? [];
    return files.map((f) {
      return BackupFileInfo(
        id: f.id ?? '',
        name: f.name ?? 'unknown',
        createdTime: f.createdTime,
        size: f.size != null ? int.tryParse(f.size!) : null,
      );
    }).toList();
  }

  Future<Map<String, List<Map<String, dynamic>>>> downloadBackup({
    required String fileId,
  }) async {
    await _ensureApi();

    final tempDir = await getTemporaryDirectory();
    final tempPath = '${tempDir.path}/takion_restore_temp.tkbk';
    final tempFile = io.File(tempPath);

    final response = await _driveApi!.files.get(
      fileId,
      downloadOptions: DownloadOptions.fullMedia,
    );
    final media = response as Media;
    final bytes = await media.stream.toList().then(
      (chunks) => chunks.expand((c) => c).toList(),
    );
    await tempFile.writeAsBytes(bytes);

    final result = await _backupService.readBackupData(
      filePath: tempPath,
    );

    await tempFile.delete();
    return result;
  }

  Future<void> deleteBackup(String fileId) async {
    await _ensureApi();
    await _driveApi!.files.delete(fileId);
  }
}
