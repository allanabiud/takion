import "dart:async";
import "dart:convert";
import "dart:math" as math;
import "dart:typed_data";

import "package:dio/dio.dart";
import "package:google_sign_in/google_sign_in.dart";
import "package:http/http.dart" as http;
import "package:takion/src/core/logging/app_logger.dart";

class _TransientDriveError implements Exception {
  const _TransientDriveError(this.status);
  final int? status;

  @override
  String toString() => 'HTTP ${status ?? 'unknown'}';
}

/// Thin HTTP wrapper over the Google Drive REST + upload APIs.
///
/// Owns the GoogleSignIn/access-token plumbing, retry policy, the app
/// folder lookup/create cache, and file upload/download. Higher-level
/// sync orchestration lives in [DriveSyncService].
class DriveRestClient {
  static const driveScope = "https://www.googleapis.com/auth/drive.file";
  static const appFolderName = "Takion";
  static const deltaFileName = "takion_delta_v1.json";
  static const fullFileName = "takion_full_v1.json";

  final Dio _dio;
  final http.Client _httpClient;
  final GoogleSignIn _googleSignIn;
  final Future<String> Function()? _accessTokenProvider;
  String? _appFolderIdCache;

  DriveRestClient({
    Dio? dio,
    http.Client? httpClient,
    Future<String> Function()? accessTokenProvider,
  })  : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 30),
                sendTimeout: const Duration(seconds: 30),
              ),
            ),
        _httpClient = httpClient ?? http.Client(),
        _googleSignIn = GoogleSignIn(scopes: [driveScope]),
        _accessTokenProvider = accessTokenProvider {
    if (dio == null) {
      _dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            options.extra["_start"] = DateTime.now();
            handler.next(options);
          },
          onResponse: (response, handler) {
            final start = response.requestOptions.extra["_start"] as DateTime?;
            final ms = start == null
                ? null
                : DateTime.now().difference(start).inMilliseconds;
            AppLogger.info(
              "Drive ${response.requestOptions.method} "
              "${response.requestOptions.uri} -> ${response.statusCode}"
              '${ms == null ? '' : ' (${ms}ms)'}',
            );
            handler.next(response);
          },
          onError: (error, handler) {
            final start = error.requestOptions.extra["_start"] as DateTime?;
            final ms = start == null
                ? null
                : DateTime.now().difference(start).inMilliseconds;
            AppLogger.warning(
              "Drive ${error.requestOptions.method} "
              "${error.requestOptions.uri} failed"
              '${ms == null ? '' : ' (${ms}ms)'}: '
              "${error.type} ${error.response?.statusCode}",
              error: error,
            );
            handler.next(error);
          },
        ),
      );
    }
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
      AppLogger.warning("Google signInSilently failed", error: e);
      return _googleSignIn.currentUser;
    }
  }

  Future<void> signOut() async {
    _appFolderIdCache = null;
    await _googleSignIn.signOut();
  }

  Future<String> _getAccessToken() async {
    final provider = _accessTokenProvider;
    if (provider != null) return provider();

    var user = _googleSignIn.currentUser;
    user ??= await signInSilently();
    if (user == null) {
      throw StateError("Not signed in to Google Drive");
    }

    GoogleSignInAuthentication auth;
    try {
      auth = await user.authentication;
    } catch (e) {
      AppLogger.warning("Google Drive authentication failed", error: e);
      user = await signInSilently(reAuthenticate: true);
      if (user == null) {
        AppLogger.warning("Not signed in to Google Drive");
        throw StateError("Not signed in to Google Drive");
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
        "Google Drive access token is empty, please re-authenticate",
      );
      throw StateError(
        "Google Drive access token is empty, please re-authenticate",
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
          "$operation failed ($error), retrying in ${delay.inSeconds}s "
          "(attempt ${attempt + 1})",
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
    final response = await _retry("GET $path", () async {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: Options(
          headers: {"Authorization": "Bearer $token"},
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
    });
    if (response.statusCode == 401 && !isRetry) {
      AppLogger.info(
        "Drive GET request returned 401, attempting silent token refresh...",
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
    final response = await _retry("POST $path", () async {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(
          headers: {"Authorization": "Bearer $token"},
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
    });
    if (response.statusCode == 401 && !isRetry) {
      AppLogger.info(
        "Drive POST request returned 401, attempting silent token refresh...",
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
    final response = await _retry("DELETE $path", () async {
      final response = await _dio.delete(
        path,
        options: Options(
          headers: {"Authorization": "Bearer $token"},
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
    });
    if (response.statusCode == 401 && !isRetry) {
      AppLogger.info(
        "Drive DELETE request returned 401, attempting silent token refresh...",
      );
      await signInSilently(reAuthenticate: true);
      return _driveDelete(path, isRetry: true);
    }
    return response;
  }

  Future<String?> _getAppFolderId() async {
    final response = await _driveGet(
      "https://www.googleapis.com/drive/v3/files",
      queryParameters: {
        "q":
            "name='$appFolderName' and mimeType='application/vnd.google-apps.folder' and trashed=false",
        "fields": "files(id,name)",
      },
    );
    if (response.statusCode == 404) return null;
    if (response.statusCode != 200) {
      throw StateError(
        "Failed to get app folder ID (HTTP ${response.statusCode})",
      );
    }
    final data = response.data as Map<String, dynamic>?;
    if (data == null) return null;
    final files = data["files"] as List<dynamic>? ?? [];
    if (files.isEmpty) return null;
    return (files.first as Map<String, dynamic>)["id"] as String?;
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
      "https://www.googleapis.com/drive/v3/files",
      data: {
        "name": appFolderName,
        "mimeType": "application/vnd.google-apps.folder",
      },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.data as Map<String, dynamic>;
      final id = data["id"] as String;
      _appFolderIdCache = id;
      return id;
    }
    if (response.statusCode == 409) {
      AppLogger.info("Folder create returned 409, fetching existing folder id");
      final reFound = await _getAppFolderId();
      if (reFound != null) {
        _appFolderIdCache = reFound;
        return reFound;
      }
      throw StateError(
        "Failed to create Drive folder (HTTP 409): ${response.data}",
      );
    }
    throw StateError(
      "Failed to create Drive folder (HTTP ${response.statusCode}): ${response.data}",
    );
  }

  Future<String?> findFileId(String fileName) async {
    try {
      final folderId = await _ensureAppFolderId();
      final response = await _driveGet(
        "https://www.googleapis.com/drive/v3/files",
        queryParameters: {
          "q": "'$folderId' in parents and name='$fileName' and trashed=false",
          "fields": "files(id,name)",
        },
      );
      if (response.statusCode != 200) return null;
      final data = response.data as Map<String, dynamic>?;
      if (data == null) return null;
      final files = data["files"] as List<dynamic>? ?? [];
      if (files.isEmpty) return null;
      return (files.first as Map<String, dynamic>)["id"] as String?;
    } catch (e) {
      AppLogger.warning("Failed to find file ID for $fileName", error: e);
      rethrow;
    }
  }

  Future<DateTime?> getFileModificationTime(String fileId) async {
    final response = await _driveGet(
      "https://www.googleapis.com/drive/v3/files/$fileId",
      queryParameters: {"fields": "modifiedTime"},
    );
    if (response.statusCode != 200) return null;
    final data = response.data as Map<String, dynamic>?;
    if (data == null) return null;
    final timeStr = data["modifiedTime"] as String?;
    if (timeStr == null) return null;
    return DateTime.parse(timeStr);
  }

  Future<Uint8List?> downloadFile(
    String fileId, {
    bool isRetry = false,
  }) async {
    final token = await _getAccessToken();
    final response = await _retry("DOWNLOAD $fileId", () async {
      final response = await _dio.get(
        "https://www.googleapis.com/drive/v3/files/$fileId",
        queryParameters: {"alt": "media"},
        options: Options(
          headers: {"Authorization": "Bearer $token"},
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
    });
    if (response.statusCode == 401 && !isRetry) {
      AppLogger.info(
        "Drive download returned 401, attempting silent token refresh...",
      );
      await signInSilently(reAuthenticate: true);
      return downloadFile(fileId, isRetry: true);
    }
    if (response.statusCode != 200) return null;
    return response.data as Uint8List?;
  }

  Future<String> uploadFile(
    String fileName,
    Uint8List fileData, {
    bool isRetry = false,
  }) async {
    final token = await _getAccessToken();
    final folderId = await _ensureAppFolderId();
    final existingId = await findFileId(fileName);

    final metadata = jsonEncode({
      "name": fileName,
      if (existingId == null) "parents": [folderId],
    });

    final boundary = "boundary_${DateTime.now().millisecondsSinceEpoch}";
    final bodyBytes = _multipartRelatedBody(metadata, fileData, boundary);
    final uri = existingId != null
        ? Uri.parse(
            "https://www.googleapis.com/upload/drive/v3/files/$existingId?uploadType=multipart",
          )
        : Uri.parse(
            "https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart",
          );

    final stopwatch = Stopwatch()..start();
    final response = await _retry("UPLOAD $fileName", () async {
      final request = http.Request(existingId != null ? "PATCH" : "POST", uri);
      request.headers["Authorization"] = "Bearer $token";
      request.headers["Content-Type"] = "multipart/related; boundary=$boundary";
      request.bodyBytes = bodyBytes;

      final streamed = await _httpClient.send(request).timeout(
        const Duration(seconds: 60),
      );
      final response = await http.Response.fromStream(
        streamed,
      ).timeout(const Duration(seconds: 60));
      AppLogger.info(
        'Drive upload ${existingId != null ? 'PATCH' : 'POST'} $uri '
        "-> ${response.statusCode} (${stopwatch.elapsedMilliseconds}ms, "
        "${fileData.length} bytes)",
      );
      if (response.statusCode == 429 ||
          response.statusCode == 403 ||
          response.statusCode >= 500) {
        throw _TransientDriveError(response.statusCode);
      }
      return response;
    });
    stopwatch.stop();

    if (response.statusCode == 401 && !isRetry) {
      AppLogger.info(
        "Drive upload returned 401, attempting silent token refresh...",
      );
      await signInSilently(reAuthenticate: true);
      return uploadFile(fileName, fileData, isRetry: true);
    }

    if (response.statusCode != 200 && response.statusCode != 201) {
      AppLogger.error(
        "Drive upload failed (HTTP ${response.statusCode}): ${response.body}",
      );
      throw StateError(
        "Upload failed (HTTP ${response.statusCode}): ${response.body}",
      );
    }

    final result = jsonDecode(response.body) as Map<String, dynamic>;
    return result["id"] as String;
  }

  List<int> _multipartRelatedBody(
    String metadata,
    Uint8List fileData,
    String boundary,
  ) {
    final bytes = <int>[];
    bytes.addAll(utf8.encode("--$boundary\r\n"));
    bytes.addAll(
      utf8.encode(
        "Content-Type: application/json; charset=UTF-8\r\n\r\n"
        "$metadata\r\n",
      ),
    );
    bytes.addAll(utf8.encode("--$boundary\r\n"));
    bytes.addAll(
      utf8.encode("Content-Type: application/json; charset=UTF-8\r\n\r\n"),
    );
    bytes.addAll(fileData);
    bytes.addAll(utf8.encode("\r\n--$boundary--\r\n"));
    return bytes;
  }

  /// Deletes the delta and full sync files from the app folder.
  Future<void> deleteAllSyncFiles() async {
    for (final fileName in [deltaFileName, fullFileName]) {
      final fileId = await findFileId(fileName);
      if (fileId != null) {
        await _driveDelete(
          "https://www.googleapis.com/drive/v3/files/$fileId",
        );
      }
    }
  }
}