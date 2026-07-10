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

class CloudBackupService {
  final BackupService _backupService;
  final GoogleSignIn _googleSignIn;

  DriveApi? _driveApi;
  String? _appFolderId;

  CloudBackupService(this._backupService)
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
        debugPrint('CloudBackupService: signInSilently returned null');
      }
      return account;
    } catch (e) {
      debugPrint('CloudBackupService: signInSilently failed: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    _driveApi = null;
    _appFolderId = null;
    await _googleSignIn.signOut();
  }

  Future<void> _ensureApi() async {
    if (_driveApi != null) return;
    final client = await _googleSignIn.authenticatedClient();
    if (client == null) throw Exception('Not signed in to Google');
    _driveApi = DriveApi(client);
  }

  Future<String> _ensureAppFolder() async {
    if (_appFolderId != null) return _appFolderId!;
    await _ensureApi();

    final existing = await _driveApi!.files.list(
      q: "name='Takion Backups' and mimeType='application/vnd.google-apps.folder' and trashed=false",
      spaces: 'drive',
    );

    if (existing.files != null && existing.files!.isNotEmpty) {
      _appFolderId = existing.files!.first.id;
      return _appFolderId!;
    }

    final folder = await _driveApi!.files.create(
      File(
        name: 'Takion Backups',
        mimeType: 'application/vnd.google-apps.folder',
      ),
    );
    _appFolderId = folder.id;
    return _appFolderId!;
  }
  Future<void> uploadBackup({
    required Set<String> boxNames,
    required String password,
  }) async {
    await _ensureApi();
    final folderId = await _ensureAppFolder();

    final data = await _backupService.createBackupData(
      boxNames: boxNames,
      password: password,
    );

    final now = DateTime.now();
    final fileName =
        'Backup-${now.year}-${_pad(now.month)}-${_pad(now.day)}-${_pad(now.hour)}${_pad(now.minute)}.tkbk';

    final stream = Stream.fromIterable([data]);
    final driveFile = File(name: fileName, parents: [folderId]);

    await _driveApi!.files.create(
      driveFile,
      uploadMedia: Media(stream, data.length),
    );

    final existing = await listBackups();
    for (final backup in existing) {
      if (backup.name != fileName) {
        await deleteBackup(backup.id);
      }
    }
  }
  Future<List<BackupFileInfo>> listBackups() async {
    await _ensureApi();
    final folderId = await _ensureAppFolder();

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
    required String password,
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
      password: password,
    );

    await tempFile.delete();
    return result;
  }

  Future<BackupFileInfo> loadManifest({
    required String fileId,
    required String password,
  }) async {
    await _ensureApi();

    final tempDir = await getTemporaryDirectory();
    final tempPath = '${tempDir.path}/takion_manifest_temp.tkbk';
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

    final manifest = await _backupService.loadManifest(
      filePath: tempPath,
      password: password,
    );

    await tempFile.delete();

    return BackupFileInfo(
      id: fileId,
      name: '',
      createdTime: manifest.createdAt,
      size: null,
    );
  }

  Future<void> deleteBackup(String fileId) async {
    await _ensureApi();
    await _driveApi!.files.delete(fileId);
  }

  String _pad(int n) => n.toString().padLeft(2, '0');
}
