import "dart:convert";
import "dart:typed_data";

import "package:dio/dio.dart";
import "package:drift/native.dart";
import "package:flutter_test/flutter_test.dart";
import "package:http/http.dart" as http;
import "package:takion/src/data/common/drift/database.dart";
import "package:takion/src/data/common/services/drive_backup_service.dart";

const _fullFileName = "takion_full_v1.json";
const _deltaFileName = "takion_delta_v1.json";

class _FakeDriveFile {
  _FakeDriveFile({
    required this.id,
    required this.name,
    required this.content,
    required this.modifiedTime,
  });

  final String id;
  final String name;
  Uint8List content;
  DateTime modifiedTime;
}

class _FakeDriveStore {
  final Map<String, _FakeDriveFile> files = {};
  String? appFolderId;
  int _idCounter = 0;
  int uploadCount = 0;
  final List<String> uploadedNames = [];

  String _nextId() => "file-${_idCounter++}";

  _FakeDriveFile? findByName(String name) {
    for (final file in files.values) {
      if (file.name == name) return file;
    }
    return null;
  }

  String upsertFile(String name, Uint8List content, DateTime modifiedTime) {
    final existing = findByName(name);
    if (existing != null) {
      existing.content = content;
      existing.modifiedTime = modifiedTime;
      return existing.id;
    }
    final id = _nextId();
    files[id] = _FakeDriveFile(
      id: id,
      name: name,
      content: content,
      modifiedTime: modifiedTime,
    );
    return id;
  }

  Map<String, dynamic>? fileJsonByName(String name) {
    final file = findByName(name);
    if (file == null) return null;
    return jsonDecode(utf8.decode(file.content)) as Map<String, dynamic>;
  }
}

/// Extracts all top-level JSON objects from a multipart/related body.
List<Map<String, dynamic>> _extractJsonObjects(List<int> body) {
  final text = utf8.decode(body);
  final results = <Map<String, dynamic>>[];
  var i = 0;
  while (i < text.length) {
    if (text[i] == "{") {
      var depth = 0;
      var inString = false;
      var j = i;
      while (j < text.length) {
        final c = text[j];
        if (c == '"') inString = !inString;
        if (!inString) {
          if (c == "{") {
            depth++;
          } else if (c == "}") {
            depth--;
            if (depth == 0) break;
          }
        }
        j++;
      }
      final candidate = text.substring(i, j + 1);
      try {
        final decoded = jsonDecode(candidate);
        if (decoded is Map<String, dynamic>) results.add(decoded);
      } catch (_) {}
      i = j + 1;
    } else {
      i++;
    }
  }
  return results;
}

class _FakeDriveHttpClient extends http.BaseClient {
  _FakeDriveHttpClient(this.store);

  final _FakeDriveStore store;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final body = await request.finalize().toBytes();
    final objects = _extractJsonObjects(body);
    if (objects.isEmpty) {
      return http.StreamedResponse(const Stream.empty(), 400);
    }
    final metadata = objects.first;
    final fileName = metadata["name"] as String?;
    if (fileName == null) {
      return http.StreamedResponse(const Stream.empty(), 400);
    }
    final payload = objects.length > 1 ? objects[1] : objects.first;
    final content = Uint8List.fromList(utf8.encode(jsonEncode(payload)));
    final toTimestamp = payload["toTimestamp"] as String?;
    final modifiedTime =
        DateTime.tryParse(toTimestamp ?? "") ?? DateTime.now().toUtc();
    final id = store.upsertFile(fileName, content, modifiedTime);
    store.uploadCount++;
    store.uploadedNames.add(fileName);
    return http.StreamedResponse(
      Stream.value(utf8.encode(jsonEncode({"id": id}))),
      200,
      request: request,
    );
  }
}

Dio _buildFakeDio(_FakeDriveStore store) {
  final dio = Dio();
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final uri = options.uri;
        final path = uri.path;

        if (path == "/drive/v3/files") {
          if (options.method == "GET") {
            final q = uri.queryParameters["q"] ?? "";
            final isFolderSearch = q.contains(
              "mimeType='application/vnd.google-apps.folder'",
            );
            List<Map<String, String>> matches;
            if (isFolderSearch) {
              matches = store.appFolderId == null
                  ? const []
                  : [
                      {"id": store.appFolderId!, "name": "Takion"},
                    ];
            } else {
              final nameMatch = RegExp(r"name='([^']*)'").firstMatch(q);
              final name = nameMatch?.group(1);
              matches = [
                for (final file in store.files.values)
                  if (name == null || file.name == name)
                    {"id": file.id, "name": file.name},
              ];
            }
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {"files": matches},
              ),
            );
            return;
          }
          if (options.method == "POST") {
            final data = (options.data as Map?) ?? const {};
            if (data["mimeType"] == "application/vnd.google-apps.folder") {
              store.appFolderId ??= store._nextId();
              handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {"id": store.appFolderId},
                ),
              );
            } else {
              handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {"id": store._nextId()},
                ),
              );
            }
            return;
          }
        }

        if (path.startsWith("/drive/v3/files/")) {
          final fileId = path.split("/").last;
          final file = store.files[fileId];
          if (options.method == "GET") {
            final isDownload = uri.queryParameters["alt"] == "media";
            if (file == null) {
              handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: isDownload ? Uint8List(0) : {"modifiedTime": null},
                ),
              );
              return;
            }
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: isDownload
                    ? file.content
                    : {
                        "modifiedTime": file.modifiedTime
                            .toUtc()
                            .toIso8601String(),
                      },
              ),
            );
            return;
          }
          if (options.method == "DELETE") {
            store.files.remove(fileId);
            handler.resolve(Response(requestOptions: options, statusCode: 204));
            return;
          }
        }

        handler.reject(
          DioException(
            requestOptions: options,
            type: DioExceptionType.unknown,
            response: Response(
              requestOptions: options,
              statusCode: 404,
              data: {"error": "unhandled request $path"},
            ),
          ),
        );
      },
    ),
  );
  return dio;
}

DriveSyncService _buildService(AppDatabase db, _FakeDriveStore store) {
  return DriveSyncService(
    db,
    dio: _buildFakeDio(store),
    httpClient: _FakeDriveHttpClient(store),
    accessTokenProvider: () async => "test-token",
  );
}

Future<AppDatabase> _freshDb() async {
  return AppDatabase.forTesting(NativeDatabase.memory());
}

void main() {
  group("Drive sync flow", () {
    test(
      "first sync seeds a full snapshot when none exists on Drive",
      () async {
        final store = _FakeDriveStore();
        final dbA = await _freshDb();
        addTearDown(dbA.close);
        final serviceA = _buildService(dbA, store);

        await dbA.favoriteDao.toggleCreator(101);
        await dbA.favoriteDao.toggleCreator(102);

        await serviceA.triggerSync(ignoreThrottle: true);

        final full = store.fileJsonByName(_fullFileName);
        expect(full, isNotNull);
        final creators =
            ((full!["tables"] as Map)["favorite_creators"]["inserts"] as List);
        expect(creators, hasLength(2));
        expect(store.fileJsonByName(_deltaFileName), isNotNull);
      },
    );

    test(
      "new device first sync fetches existing full snapshot and keeps local data",
      () async {
        final store = _FakeDriveStore();
        final dbA = await _freshDb();
        addTearDown(dbA.close);
        final serviceA = _buildService(dbA, store);

        await dbA.favoriteDao.toggleCreator(101);
        await serviceA.triggerSync(ignoreThrottle: true);

        final dbB = await _freshDb();
        addTearDown(dbB.close);
        final serviceB = _buildService(dbB, store);

        await dbB.favoriteDao.toggleCreator(202);
        await serviceB.triggerSync(ignoreThrottle: true);

        final creators = (await dbB.favoriteDao.getAllCreators())
            .map((c) => c.metronCreatorId)
            .toSet();
        expect(creators, {101, 202});
      },
    );

    test(
      "subsequent sync uploads incremental delta and refreshes full snapshot",
      () async {
        final store = _FakeDriveStore();
        final dbA = await _freshDb();
        addTearDown(dbA.close);
        final serviceA = _buildService(dbA, store);

        await dbA.favoriteDao.toggleCreator(101);
        await serviceA.triggerSync(ignoreThrottle: true);

        await dbA.favoriteDao.toggleCreator(303);
        await serviceA.triggerSync(ignoreThrottle: true);

        final delta = store.fileJsonByName(_deltaFileName)!;
        final deltaInserts =
            ((delta["tables"] as Map)["favorite_creators"]["inserts"] as List);
        expect(deltaInserts, hasLength(1));
        expect(deltaInserts.first["metronCreatorId"], 303);

        final full = store.fileJsonByName(_fullFileName)!;
        final fullInserts =
            ((full["tables"] as Map)["favorite_creators"]["inserts"] as List);
        expect(fullInserts.map((r) => r["metronCreatorId"]).toSet(), {
          101,
          303,
        });
      },
    );

    test("no-op sync does not re-upload when nothing changed", () async {
      final store = _FakeDriveStore();
      final dbA = await _freshDb();
      addTearDown(dbA.close);
      final serviceA = _buildService(dbA, store);

      await dbA.favoriteDao.toggleCreator(101);
      await serviceA.triggerSync(ignoreThrottle: true);
      final uploadsAfterFirst = store.uploadCount;

      await serviceA.triggerSync(ignoreThrottle: true);
      expect(store.uploadCount, uploadsAfterFirst);
    });

    test("device with a delta gap applies the full snapshot instead", () async {
      final store = _FakeDriveStore();
      final dbA = await _freshDb();
      addTearDown(dbA.close);
      final serviceA = _buildService(dbA, store);

      await dbA.favoriteDao.toggleCreator(101);
      await serviceA.triggerSync(ignoreThrottle: true);

      final dbB = await _freshDb();
      addTearDown(dbB.close);
      final serviceB = _buildService(dbB, store);
      await serviceB.triggerSync(ignoreThrottle: true);

      await Future<void>.delayed(const Duration(milliseconds: 5));

      // Device A makes two batches of changes, syncing in between so the
      // delta file is overwritten with only the second batch.
      await dbA.favoriteDao.toggleCreator(202);
      await serviceA.triggerSync(ignoreThrottle: true);
      await Future<void>.delayed(const Duration(milliseconds: 5));
      await dbA.favoriteDao.toggleCreator(303);
      await serviceA.triggerSync(ignoreThrottle: true);

      // The delta file now only holds 303, but gap detection should pull the
      // full snapshot containing 202 too.
      await serviceB.triggerSync(ignoreThrottle: true);

      final creators = (await dbB.favoriteDao.getAllCreators())
          .map((c) => c.metronCreatorId)
          .toSet();
      expect(creators, {101, 202, 303});
    });

    test("restoreFromDrive restores the complete full snapshot", () async {
      final store = _FakeDriveStore();
      final dbA = await _freshDb();
      addTearDown(dbA.close);
      final serviceA = _buildService(dbA, store);

      await dbA.favoriteDao.toggleCreator(101);
      await dbA.favoriteDao.toggleCreator(102);
      await serviceA.triggerSync(ignoreThrottle: true);

      final dbC = await _freshDb();
      addTearDown(dbC.close);
      final serviceC = _buildService(dbC, store);

      await serviceC.restoreFromDrive();

      final creators = (await dbC.favoriteDao.getAllCreators())
          .map((c) => c.metronCreatorId)
          .toSet();
      expect(creators, {101, 102});
    });

    test("restoreFromDrive throws when only a legacy delta exists", () async {
      final store = _FakeDriveStore();
      final dbA = await _freshDb();
      addTearDown(dbA.close);
      final serviceA = _buildService(dbA, store);

      await dbA.favoriteDao.toggleCreator(101);
      final delta = await serviceA.extractDelta(null);
      store.upsertFile(
        _deltaFileName,
        Uint8List.fromList(utf8.encode(jsonEncode(delta))),
        DateTime.now().toUtc(),
      );

      final dbC = await _freshDb();
      addTearDown(dbC.close);
      final serviceC = _buildService(dbC, store);

      await expectLater(serviceC.restoreFromDrive(), throwsStateError);
    });
  });
}
