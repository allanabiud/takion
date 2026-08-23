import "package:dio/dio.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/core/constants/settings_keys.dart";
import "package:takion/src/core/logging/app_logger.dart";
import "package:takion/src/core/network/superhero_dio_provider.dart";
import "package:takion/src/core/storage/drift_database_provider.dart";
import "package:takion/src/data/common/drift/daos/settings_dao.dart";

final superheroAccountServiceProvider = Provider<SuperHeroAccountService>((
  ref,
) {
  final db = ref.watch(driftDatabaseProvider);
  final dio = ref.watch(superheroDioProvider);
  return SuperHeroAccountService(db.settingsDao, dio);
});

enum SuperHeroConnectionStatus { valid, missing, invalid, unreachable }

class SuperHeroAccountService {
  final SettingsDao _settingsDao;
  final Dio _dio;

  static const String _apiTokenKey = SettingsKeys.superheroApiToken;

  SuperHeroAccountService(this._settingsDao, this._dio);

  Future<bool> verifyToken(String token) async {
    final trimmedToken = token.trim();
    if (trimmedToken.isEmpty) return false;

    try {
      final response = await _dio.get("$trimmedToken/search/batman");
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data["response"] == "success";
      }
      return false;
    } on DioException catch (error) {
      AppLogger.warning("SuperHero token verification failed", error: error);
      return false;
    }
  }

  Future<bool> connect(String token) async {
    final trimmedToken = token.trim();
    if (trimmedToken.isEmpty) {
      AppLogger.warning("SuperHero connect failed: empty token");
      return false;
    }

    final isValid = await verifyToken(trimmedToken);
    if (!isValid) {
      AppLogger.warning("SuperHero connect failed: invalid token");
      return false;
    }

    await _settingsDao.setString(_apiTokenKey, trimmedToken);
    await _settingsDao.setBool(SettingsKeys.superheroIntegrationEnabled, true);
    AppLogger.info("SuperHero connected and integration enabled");
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

  Future<void> disconnect() async {
    await _settingsDao.deleteByKey(_apiTokenKey);
    await _settingsDao.setBool(SettingsKeys.superheroIntegrationEnabled, false);
    AppLogger.info("SuperHero disconnected and integration disabled");
  }

  Future<SuperHeroConnectionStatus> validateStoredConnection() async {
    final token = await getStoredToken();
    if (token == null) return SuperHeroConnectionStatus.missing;

    try {
      final isValid = await verifyToken(token);
      return isValid
          ? SuperHeroConnectionStatus.valid
          : SuperHeroConnectionStatus.invalid;
    } on DioException catch (e) {
      AppLogger.warning(
        "SuperHero validation failed: server unreachable",
        error: e,
      );
      return SuperHeroConnectionStatus.unreachable;
    }
  }
}
