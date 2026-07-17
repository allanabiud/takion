import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/storage/hive_service.dart';
import 'package:takion/src/core/logging/app_logger.dart';

final localProfileServiceProvider = Provider<LocalProfileService>((ref) {
  return LocalProfileService(ref.watch(hiveServiceProvider));
});

class LocalProfileService {
  LocalProfileService(this._hiveService);

  static const _profileBox = 'local_profile_box';
  static const _profileKey = 'current_profile';
  static const _backdropPathKey = 'backdrop_image_path';

  final HiveService _hiveService;

  Future<Map<String, dynamic>> _defaultProfile() async {
    return {
      'display_name': 'Takion Reader',
      'avatar_url': '',
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
      await _hiveService.recordTimestamp(_profileBox, _profileKey);
      return created;
    }
    return Map<String, dynamic>.from(existing.cast<String, dynamic>());
  }

  Future<Map<String, dynamic>?> updateCurrentProfile({
    String? displayName,
    String? avatarUrl,
    String? backdropImagePath,
  }) async {
    final current = await getCurrentProfile() ?? await _defaultProfile();
    final updated = Map<String, dynamic>.from(current);

    if (displayName != null) updated['display_name'] = displayName.trim();
    if (avatarUrl != null) {
      updated['avatar_url'] = await _convertToBase64IfNeeded(avatarUrl);
    }
    if (backdropImagePath != null) {
      updated[_backdropPathKey] = await _convertToBase64IfNeeded(backdropImagePath);
    }

    final box = await _hiveService.openBox<Map>(_profileBox);
    await box.put(_profileKey, updated);
    await _hiveService.recordTimestamp(_profileBox, _profileKey);
    return updated;
  }

  Future<String> _convertToBase64IfNeeded(String path) async {
    final normalized = path.trim();
    if (normalized.isEmpty) return '';
    if (normalized.startsWith('http://') ||
        normalized.startsWith('https://') ||
        normalized.startsWith('data:')) {
      return normalized;
    }
    final file = File(normalized);
    if (await file.exists()) {
      try {
        final bytes = await file.readAsBytes();
        final base64Str = base64Encode(bytes);
        String mimeType = 'image/jpeg';
        if (normalized.toLowerCase().endsWith('.png')) {
          mimeType = 'image/png';
        } else if (normalized.toLowerCase().endsWith('.gif')) {
          mimeType = 'image/gif';
        } else if (normalized.toLowerCase().endsWith('.webp')) {
          mimeType = 'image/webp';
        }
        return 'data:$mimeType;base64,$base64Str';
      } catch (e) {
        AppLogger.warning('Failed to read profile image', error: e);
      }
    }
    return normalized;
  }
}
