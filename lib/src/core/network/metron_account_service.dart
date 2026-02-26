import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/storage/hive_service.dart';

final metronAccountServiceProvider = Provider<MetronAccountService>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return MetronAccountService(hiveService);
});

class MetronAccountConnection {
  final String username;

  const MetronAccountConnection({required this.username});
}

enum MetronConnectionStatus {
  valid,
  missing,
  invalid,
  unreachable,
}

class MetronAccountService {
  final HiveService _hiveService;

  static const String _boxName = 'metron_account_box';
  static const String _usernameKey = 'username';
  static const String _passwordKey = 'password';

  MetronAccountService(this._hiveService);

  Future<bool> verifyCredentials(String username, String password) async {
    final dio = Dio(BaseOptions(baseUrl: 'https://metron.cloud/api/'));
    final auth = 'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    try {
      await dio.get(
        'issue/',
        queryParameters: {'limit': 1},
        options: Options(headers: {'Authorization': auth}),
      );
      return true;
    } on DioException catch (error) {
      if (error.response?.statusCode == 401) {
        return false;
      }
      rethrow;
    }
  }

  Future<bool> connect(String username, String password) async {
    final trimmedUsername = username.trim();
    final trimmedPassword = password.trim();
    final isValid = await verifyCredentials(trimmedUsername, trimmedPassword);
    if (!isValid) return false;

    final box = await _hiveService.openBox<String>(_boxName);
    await box.put(_usernameKey, trimmedUsername);
    await box.put(_passwordKey, trimmedPassword);
    return true;
  }

  Future<Map<String, String>?> getApiCredentials() async {
    final box = await _hiveService.openBox<String>(_boxName);
    final username = box.get(_usernameKey)?.trim();
    final password = box.get(_passwordKey)?.trim();

    if (username != null &&
        username.isNotEmpty &&
        password != null &&
        password.isNotEmpty) {
      return {'username': username, 'password': password};
    }

    return null;
  }

  Future<MetronAccountConnection?> getConnection() async {
    final creds = await getApiCredentials();
    if (creds == null) return null;
    return MetronAccountConnection(username: creds['username']!);
  }

  Future<void> disconnect() async {
    final box = await _hiveService.openBox<String>(_boxName);
    await box.clear();
  }

  Future<MetronConnectionStatus> validateStoredConnection() async {
    final creds = await getApiCredentials();
    if (creds == null) {
      return MetronConnectionStatus.missing;
    }

    try {
      final isValid = await verifyCredentials(
        creds['username']!,
        creds['password']!,
      );

      return isValid
          ? MetronConnectionStatus.valid
          : MetronConnectionStatus.invalid;
    } on DioException {
      return MetronConnectionStatus.unreachable;
    }
  }
}