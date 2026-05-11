import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/storage/hive_service.dart';

final localProfileServiceProvider = Provider<LocalProfileService>((ref) {
  return LocalProfileService(ref.watch(hiveServiceProvider));
});

class LocalProfileService {
  LocalProfileService(this._hiveService);

  static const _localUserId = 'local-user';
  static const _profileBox = 'local_profile_box';
  static const _profileKey = 'current_profile';
  static const _authBox = 'local_auth_box';
  static const _authEmailKey = 'email';
  static const _authPasswordKey = 'password';
  static const _profileUiBox = 'profile_ui_box';
  static const _backdropPathKey = 'backdrop_image_path';

  final HiveService _hiveService;

  Future<Map<String, dynamic>> _defaultProfile() async {
    final nowIso = DateTime.now().toUtc().toIso8601String();
    return {
      'id': _localUserId,
      'email': '',
      'display_name': 'Takion Reader',
      'avatar_url': '',
      'avatar_storage_path': '',
      'bio': '',
      'location': '',
      'collecting_since': null,
      'notification_preferences': {'email_pulls': false},
      'created_at': nowIso,
      'updated_at': nowIso,
    };
  }

  Future<Map<String, dynamic>?> getCurrentProfile({
    bool forceRefresh = false,
  }) async {
    final box = await _hiveService.openBox<Map>(_profileBox);
    final existing = box.get(_profileKey);
    if (existing == null) {
      final created = await _defaultProfile();
      await box.put(_profileKey, created);
      return created;
    }
    return Map<String, dynamic>.from(existing.cast<String, dynamic>());
  }

  Future<Map<String, dynamic>?> updateCurrentProfile({
    String? displayName,
    String? avatarUrl,
    String? bio,
    String? location,
    DateTime? collectingSince,
    Map<String, dynamic>? notificationPreferences,
  }) async {
    final current = await getCurrentProfile() ?? await _defaultProfile();
    final updated = Map<String, dynamic>.from(current);

    if (displayName != null) updated['display_name'] = displayName.trim();
    if (avatarUrl != null) {
      final normalized = avatarUrl.trim();
      updated['avatar_url'] = normalized;
      updated['avatar_storage_path'] = normalized;
    }
    if (bio != null) updated['bio'] = bio.trim();
    if (location != null) updated['location'] = location.trim();
    if (collectingSince != null) {
      updated['collecting_since'] = collectingSince
          .toUtc()
          .toIso8601String()
          .split('T')
          .first;
    }
    if (notificationPreferences != null) {
      updated['notification_preferences'] = {
        'email_pulls':
            (notificationPreferences['email_pulls'] as bool?) ?? false,
      };
    }
    updated['updated_at'] = DateTime.now().toUtc().toIso8601String();

    final box = await _hiveService.openBox<Map>(_profileBox);
    await box.put(_profileKey, updated);
    return updated;
  }

  Future<void> storeLocalBackdropPath(String path) async {
    final box = await _hiveService.openBox<String>(_profileUiBox);
    await box.put(_backdropPathKey, path.trim());
  }

  Future<String> getLocalBackdropPath() async {
    final box = await _hiveService.openBox<String>(_profileUiBox);
    return (box.get(_backdropPathKey) ?? '').trim();
  }

  Future<void> storeAuthCredentials({
    required String email,
    required String password,
  }) async {
    final box = await _hiveService.openBox<String>(_authBox);
    await box.put(_authEmailKey, email.trim());
    await box.put(_authPasswordKey, password.trim());
  }

  Future<void> updateStoredPassword(String password) async {
    final box = await _hiveService.openBox<String>(_authBox);
    await box.put(_authPasswordKey, password.trim());
  }

  Future<void> deleteCurrentAccount() async {
    final profileBox = await _hiveService.openBox<Map>(_profileBox);
    await profileBox.delete(_profileKey);

    final authBox = await _hiveService.openBox<String>(_authBox);
    await authBox.delete(_authEmailKey);
    await authBox.delete(_authPasswordKey);

    final uiBox = await _hiveService.openBox<String>(_profileUiBox);
    await uiBox.delete(_backdropPathKey);
  }
}
