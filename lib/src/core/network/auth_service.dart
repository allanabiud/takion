import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/storage/hive_service.dart';
import 'dart:convert';

final authServiceProvider = Provider<AuthService>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return AuthService(hiveService);
});

class AuthService {
  final HiveService _hiveService;
  static const String _boxName = 'auth_box';
  static const String _usernameKey = 'username';
  static const String _passwordKey = 'password';

  AuthService(this._hiveService);

  Future<bool> verifyCredentials(String username, String password) async {
    final dio = Dio(BaseOptions(baseUrl: 'https://metron.cloud/api/'));
    final auth = 'Basic ${base64Encode(utf8.encode('$username:$password'))}';
    
    try {
      // Make a minimal request to verify credentials
      // Use query parameter to limit response size
      await dio.get('issue/', 
        queryParameters: {'limit': 1}, 
        options: Options(headers: {'Authorization': auth}),
      );
      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return false;
      }
      rethrow;
    }
  }

  Future<void> saveCredentials(String username, String password) async {
    final box = await _hiveService.openBox(_boxName);
    await box.put(_usernameKey, username);
    await box.put(_passwordKey, password);
  }

  Future<Map<String, String>?> getCredentials() async {
    final box = await _hiveService.openBox(_boxName);
    final username = box.get(_usernameKey);
    final password = box.get(_passwordKey);
    if (username != null && password != null) {
      return {'username': username, 'password': password};
    }
    return null;
  }

  Future<void> clearCredentials() async {
    final box = await _hiveService.openBox(_boxName);
    await box.clear();
  }
}
