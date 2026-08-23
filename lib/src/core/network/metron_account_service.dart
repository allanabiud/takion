import "package:dio/dio.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/core/constants/durations.dart";
import "package:takion/src/core/constants/settings_keys.dart";
import "package:takion/src/core/logging/app_logger.dart";
import "package:takion/src/core/network/dio_client.dart";
import "package:takion/src/core/storage/drift_database_provider.dart";
import "package:takion/src/data/common/drift/daos/settings_dao.dart";

final metronAccountServiceProvider = Provider<MetronAccountService>((ref) {
  final db = ref.watch(driftDatabaseProvider);
  final dio = ref.watch(dioProvider);
  return MetronAccountService(db.settingsDao, dio);
});

enum MetronConnectionStatus { valid, missing, invalid, unreachable }

class MetronAccountService {
  final SettingsDao _settingsDao;
  final Dio _dio;

  static const String _apiTokenKey = SettingsKeys.metronApiToken;
  static const Duration _cacheDuration = AppDurations.defaultKeepAlive;

  MetronConnectionStatus? _cachedStatus;
  DateTime? _cachedAt;

  MetronAccountService(this._settingsDao, this._dio);

  Future<bool> verifyToken(String token) async {
    final trimmedToken = token.trim();
    if (trimmedToken.isEmpty) return false;

    try {
      await _dio.get(
        "issue/",
        queryParameters: {"limit": 1},
        options: Options(headers: {"Authorization": "Bearer $trimmedToken"}),
      );
      return true;
    } on DioException catch (error) {
      if (error.response?.statusCode == 401) {
        return false;
      }
      rethrow;
    }
  }

  Future<bool> connect(String token) async {
    final trimmedToken = token.trim();
    if (trimmedToken.isEmpty) {
      AppLogger.warning("Metron connect failed: empty token");
      return false;
    }

    AppLogger.info("Metron connect started");
    final isValid = await verifyToken(trimmedToken);
    if (!isValid) {
      AppLogger.warning("Metron connect failed: invalid token");
      return false;
    }

    await _settingsDao.setString(_apiTokenKey, trimmedToken);
    invalidateCachedStatus();
    AppLogger.info("Metron connected");
    return true;
  }

  Future<String?> getStoredToken() async {
    final token = await _settingsDao.getString(_apiTokenKey);
    final trimmed = token?.trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      return trimmed;
    }
    return null;
  }

  Future<bool> getConnection() async {
    final token = await getStoredToken();
    return token != null;
  }

  Future<void> disconnect() async {
    await _settingsDao.deleteByKey(_apiTokenKey);
    invalidateCachedStatus();
    AppLogger.info("Metron disconnected");
  }

  Future<MetronConnectionStatus> validateStoredConnection() async {
    if (_cachedStatus != null &&
        _cachedAt != null &&
        DateTime.now().difference(_cachedAt!) < _cacheDuration) {
      AppLogger.debug("Metron validation using cached status: $_cachedStatus");
      return _cachedStatus!;
    }

    final token = await getStoredToken();
    if (token == null) {
      _cachedStatus = MetronConnectionStatus.missing;
      _cachedAt = DateTime.now();
      AppLogger.info("Metron validation: no stored token");
      return _cachedStatus!;
    }

    try {
      final isValid = await verifyToken(token);

      _cachedStatus = isValid
          ? MetronConnectionStatus.valid
          : MetronConnectionStatus.invalid;
      _cachedAt = DateTime.now();
      AppLogger.info("Metron validation result: $_cachedStatus");
      return _cachedStatus!;
    } on DioException catch (e) {
      _cachedStatus = MetronConnectionStatus.unreachable;
      _cachedAt = DateTime.now();
      AppLogger.warning(
        "Metron validation failed: server unreachable",
        error: e,
      );
      return _cachedStatus!;
    }
  }

  void invalidateCachedStatus() {
    _cachedStatus = null;
    _cachedAt = null;
  }
}
