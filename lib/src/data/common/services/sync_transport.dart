import "dart:typed_data";
import "package:google_sign_in/google_sign_in.dart";
import "package:takion/src/data/common/services/drive_rest_client.dart";

/// Pluggable remote transport interface for cloud synchronization.
abstract class SyncTransport {
  GoogleSignInAccount? get currentUser;
  bool get isSignedIn;

  Future<GoogleSignInAccount?> signIn();
  Future<GoogleSignInAccount?> signInSilently({bool reAuthenticate = false});
  Future<void> signOut();

  Future<String?> findFileId(String fileName);
  Future<DateTime?> getFileModificationTime(String fileId);
  Future<Uint8List?> downloadFile(String fileId);
  Future<void> uploadFile(String fileName, Uint8List content);
  Future<void> deleteAllSyncFiles();
}

/// Google Drive implementation of [SyncTransport] backed by [DriveRestClient].
class DriveSyncTransport implements SyncTransport {
  final DriveRestClient _client;

  DriveSyncTransport(this._client);

  @override
  GoogleSignInAccount? get currentUser => _client.currentUser;

  @override
  bool get isSignedIn => _client.isSignedIn;

  @override
  Future<GoogleSignInAccount?> signIn() => _client.signIn();

  @override
  Future<GoogleSignInAccount?> signInSilently({bool reAuthenticate = false}) =>
      _client.signInSilently(reAuthenticate: reAuthenticate);

  @override
  Future<void> signOut() => _client.signOut();

  @override
  Future<String?> findFileId(String fileName) => _client.findFileId(fileName);

  @override
  Future<DateTime?> getFileModificationTime(String fileId) =>
      _client.getFileModificationTime(fileId);

  @override
  Future<Uint8List?> downloadFile(String fileId) => _client.downloadFile(fileId);

  @override
  Future<void> uploadFile(String fileName, Uint8List content) =>
      _client.uploadFile(fileName, content);

  @override
  Future<void> deleteAllSyncFiles() => _client.deleteAllSyncFiles();
}
