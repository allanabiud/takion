import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:takion/src/core/storage/hive_service.dart';

class BackupManifest {
  final DateTime createdAt;
  final String appVersion;
  final Map<String, int> boxEntryCounts;

  BackupManifest({
    required this.createdAt,
    required this.appVersion,
    required this.boxEntryCounts,
  });

  Set<String> get boxNames => boxEntryCounts.keys.toSet();
}

class BackupService {
  final HiveService _hiveService;

  BackupService(this._hiveService);

  static const _magic = <int>[0x54, 0x4B, 0x42, 0x46];
  static const _version = <int>[0x01];
  static const _pbkdf2Iterations = 100000;
  static const _saltLength = 16;
  static const _nonceLength = 12;
  static const _tagLength = 16;

  static const Map<String, List<String>> backupGroups = {
    'App Settings': ['settings_box'],
    'Pull List': ['local_pull_list_box'],
    'Subscriptions': ['local_subscriptions_box'],
    'Collection': [
      'local_library_items_box',
      'local_library_read_logs_box',
    ],
    'Reading Lists': ['reading_lists_box'],
    'Favorites': [
      'local_favorite_series_box',
      'local_favorite_issues_box',
      'local_favorite_reading_lists_box',
      'local_favorite_characters_box',
      'local_favorite_creators_box',
    ],
    'User Profile': [
      'local_profile_box',
      'local_auth_box',
      'profile_ui_box',
    ],
  };

  static Set<String> allBoxNames() =>
      backupGroups.values.expand((b) => b).toSet();

  static String groupForBox(String boxName) {
    for (final entry in backupGroups.entries) {
      if (entry.value.contains(boxName)) return entry.key;
    }
    return 'Other';
  }

  Future<Uint8List> createBackupData({
    required Set<String> boxNames,
    required String password,
  }) async {
    final boxes = <String, List<Map<String, dynamic>>>{};
    for (final boxName in boxNames) {
      final entries = await _readBox(boxName);
      boxes[boxName] = entries;
    }

    final info = await PackageInfo.fromPlatform();
    final payload = {
      'v': 1,
      't': DateTime.now().toUtc().toIso8601String(),
      'a': '${info.version}+${info.buildNumber}',
      'b': boxes,
    };

    final jsonString = jsonEncode(payload);
    final plaintext = utf8.encode(jsonString);

    final random = Random.secure();
    final salt = Uint8List.fromList(
      List<int>.generate(_saltLength, (_) => random.nextInt(256)),
    );
    final nonce = Uint8List.fromList(
      List<int>.generate(_nonceLength, (_) => random.nextInt(256)),
    );

    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: _pbkdf2Iterations,
      bits: 256,
    );
    final key = await pbkdf2.deriveKeyFromPassword(
      password: password,
      nonce: salt,
    );

    final aesGcm = AesGcm.with256bits();
    final secretBox = await aesGcm.encrypt(
      plaintext,
      secretKey: key,
      nonce: nonce,
    );

    final ciphertext = secretBox.cipherText;
    final tag = secretBox.mac.bytes;

    final totalLen = _magic.length +
        _version.length +
        salt.length +
        nonce.length +
        4 +
        ciphertext.length +
        tag.length;

    final header = Uint8List(totalLen);

    var offset = 0;
    header.setAll(offset, _magic);
    offset += _magic.length;
    header.setAll(offset, _version);
    offset += _version.length;
    header.setAll(offset, salt);
    offset += salt.length;
    header.setAll(offset, nonce);
    offset += nonce.length;

    final ctLen = ciphertext.length;
    header[offset] = ctLen & 0xFF;
    header[offset + 1] = (ctLen >> 8) & 0xFF;
    header[offset + 2] = (ctLen >> 16) & 0xFF;
    header[offset + 3] = (ctLen >> 24) & 0xFF;
    offset += 4;

    header.setAll(offset, ciphertext);
    offset += ciphertext.length;
    header.setAll(offset, tag);

    return header;
  }

  Future<BackupManifest> loadManifest({
    required String filePath,
    required String password,
  }) async {
    final payload = await _decryptFile(filePath, password);
    final boxes = payload['b'] as Map<String, dynamic>;
    final counts = <String, int>{};
    for (final entry in boxes.entries) {
      final list = entry.value as List;
      counts[entry.key] = list.length;
    }
    return BackupManifest(
      createdAt: DateTime.parse(payload['t'] as String),
      appVersion: payload['a'] as String,
      boxEntryCounts: counts,
    );
  }

  Future<Map<String, List<Map<String, dynamic>>>> readBackupData({
    required String filePath,
    required String password,
  }) async {
    final payload = await _decryptFile(filePath, password);
    final boxes = payload['b'] as Map<String, dynamic>;
    return boxes.map(
      (key, value) => MapEntry(
        key,
        (value as List).cast<Map<String, dynamic>>(),
      ),
    );
  }

  Future<void> restoreBoxes({
    required Map<String, List<Map<String, dynamic>>> data,
    required Set<String> boxNames,
    void Function(String boxName, int current, int total)? onProgress,
  }) async {
    for (final boxName in boxNames) {
      final entries = data[boxName];
      if (entries == null || entries.isEmpty) continue;

      final total = entries.length;
      onProgress?.call(boxName, 0, total);

      for (var i = 0; i < entries.length; i++) {
        final entry = entries[i];
        final key = entry['k'] as String;
        final value = entry['v'];
        await _hiveService.putEntry(boxName, key, value);
        onProgress?.call(boxName, i + 1, total);
      }
    }
  }

  Future<Map<String, dynamic>> _decryptFile(
    String filePath,
    String password,
  ) async {
    final file = File(filePath);
    final bytes = await file.readAsBytes();
    final data = Uint8List.fromList(bytes);

    var offset = 0;

    final magic = data.sublist(offset, offset + _magic.length);
    offset += _magic.length;
    if (!_listEquals(magic, _magic)) {
      throw FormatException('Invalid backup file');
    }

    offset += _version.length;

    final salt = data.sublist(offset, offset + _saltLength);
    offset += _saltLength;

    final nonce = data.sublist(offset, offset + _nonceLength);
    offset += _nonceLength;

    final ctLen = data[offset] |
        (data[offset + 1] << 8) |
        (data[offset + 2] << 16) |
        (data[offset + 3] << 24);
    offset += 4;

    final ciphertext = data.sublist(offset, offset + ctLen);
    offset += ctLen;

    final tag = data.sublist(offset, offset + _tagLength);

    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: _pbkdf2Iterations,
      bits: 256,
    );
    final key = await pbkdf2.deriveKeyFromPassword(
      password: password,
      nonce: salt,
    );

    final aesGcm = AesGcm.with256bits();
    final secretBox = SecretBox(
      ciphertext,
      nonce: nonce,
      mac: Mac(tag),
    );

    final plaintext = await aesGcm.decrypt(
      secretBox,
      secretKey: key,
    );

    final jsonString = utf8.decode(plaintext);
    final payload = jsonDecode(jsonString) as Map<String, dynamic>;
    return payload;
  }

  Future<List<Map<String, dynamic>>> _readBox(String boxName) async {
    return _hiveService.readAllEntries(boxName);
  }

  bool _listEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
