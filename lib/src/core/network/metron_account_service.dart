import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/logging/app_logger.dart';
import 'package:takion/src/core/network/dio_client.dart';
import 'package:takion/src/core/storage/hive_service.dart';

final metronAccountServiceProvider = Provider<MetronAccountService>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  final dio = ref.watch(dioProvider);
  return MetronAccountService(hiveService, dio);
});

class MetronAccountConnection {
  final String username;

  const MetronAccountConnection({required this.username});
}

enum MetronConnectionStatus { valid, missing, invalid, unreachable }

class MetronAccountService {
  final HiveService _hiveService;
  final Dio _dio;

  static const String _boxName = 'metron_account_box';
  static const String _usernameKey = 'username';
  static const String _passwordKey = 'password';
  static const Duration _cacheDuration = Duration(minutes: 5);

  MetronConnectionStatus? _cachedStatus;
  DateTime? _cachedAt;

  MetronAccountService(this._hiveService, this._dio);

  Future<bool> verifyCredentials(String username, String password) async {
    final auth = 'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    try {
      await _dio.get(
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
    AppLogger.info('Metron connect started for $trimmedUsername');
    final isValid = await verifyCredentials(trimmedUsername, trimmedPassword);
    if (!isValid) {
      AppLogger.warning('Metron connect failed: invalid credentials for $trimmedUsername');
      return false;
    }

    final box = await _hiveService.openBox<String>(_boxName);
    await box.put(_usernameKey, trimmedUsername);
    await box.put(_passwordKey, trimmedPassword);
    invalidateCachedStatus();
    AppLogger.info('Metron connected: $trimmedUsername');
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
    invalidateCachedStatus();
    AppLogger.info('Metron disconnected');
  }

  Future<MetronConnectionStatus> validateStoredConnection() async {
    if (_cachedStatus != null &&
        _cachedAt != null &&
        DateTime.now().difference(_cachedAt!) < _cacheDuration) {
      AppLogger.debug('Metron validation using cached status: $_cachedStatus');
      return _cachedStatus!;
    }

    final creds = await getApiCredentials();
    if (creds == null) {
      _cachedStatus = MetronConnectionStatus.missing;
      _cachedAt = DateTime.now();
      AppLogger.info('Metron validation: no stored credentials');
      return _cachedStatus!;
    }

    try {
      final isValid = await verifyCredentials(
        creds['username']!,
        creds['password']!,
      );

      _cachedStatus =
          isValid ? MetronConnectionStatus.valid : MetronConnectionStatus.invalid;
      _cachedAt = DateTime.now();
      AppLogger.info('Metron validation result: $_cachedStatus for ${creds['username']}');
      return _cachedStatus!;
    } on DioException catch (e) {
      _cachedStatus = MetronConnectionStatus.unreachable;
      _cachedAt = DateTime.now();
      AppLogger.warning('Metron validation failed: server unreachable', error: e);
      return _cachedStatus!;
    }
  }

  void invalidateCachedStatus() {
    _cachedStatus = null;
    _cachedAt = null;
  }
}
