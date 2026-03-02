import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:takion/src/core/cache/cache_policy.dart';
import 'package:takion/src/core/storage/hive_service.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final supabaseProfileServiceProvider = Provider<SupabaseProfileService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final hive = ref.watch(hiveServiceProvider);
  return SupabaseProfileService(client, hive);
});

class SupabaseProfileService {
  final SupabaseClient _client;
  final HiveService _hiveService;
  static const _profileBox = 'supabase_profile_box';
  static const _profileKey = 'current_profile';
  static const _authBox = 'supabase_auth_box';
  static const _authEmailKey = 'email';
  static const _authPasswordKey = 'password';
  static const _avatarBucket = 'user-profile-pictures';
  static const _avatarSignedUrlExpirySeconds = 60 * 60 * 24 * 30;

  SupabaseProfileService(this._client, this._hiveService);

  Future<void> ensureProfile({required User user, String? displayName}) async {
    final trimmedDisplayName = displayName?.trim();
    final emailPrefix = user.email?.split('@').first.trim();
    final fallbackDisplayName = (emailPrefix != null && emailPrefix.isNotEmpty)
        ? emailPrefix
        : 'Takion Reader';

    await _client.from('profiles').upsert({
      'id': user.id,
      'email': user.email,
      'display_name':
          (trimmedDisplayName != null && trimmedDisplayName.isNotEmpty)
          ? trimmedDisplayName
          : fallbackDisplayName,
      'notification_preferences': const {'email_pulls': false},
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }, onConflict: 'id');
  }

  Future<Map<String, dynamic>?> updateCurrentProfile({
    String? displayName,
    String? avatarUrl,
    String? bio,
    String? location,
    DateTime? collectingSince,
    Map<String, dynamic>? notificationPreferences,
  }) async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) return null;
    final previousProfile = await _client
        .from('profiles')
        .select('avatar_url')
        .eq('id', currentUser.id)
        .maybeSingle();
    final previousAvatarPath = (previousProfile?['avatar_url'] as String?)
        ?.trim();

    final payload = <String, dynamic>{
      'id': currentUser.id,
      'email': currentUser.email,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };

    if (displayName != null) payload['display_name'] = displayName.trim();
    if (avatarUrl != null) {
      final normalizedAvatar = avatarUrl.trim();
      if (normalizedAvatar.isEmpty) {
        payload['avatar_url'] = null;
      } else if (normalizedAvatar.startsWith('http://') ||
          normalizedAvatar.startsWith('https://')) {
        payload['avatar_url'] = normalizedAvatar;
      } else {
        payload['avatar_url'] = await _uploadAvatarIfLocalFile(
          normalizedAvatar,
          currentUser.id,
        );
      }
    }
    if (bio != null) payload['bio'] = bio.trim();
    if (location != null) payload['location'] = location.trim();
    if (collectingSince != null) {
      payload['collecting_since'] = collectingSince
          .toUtc()
          .toIso8601String()
          .split('T')
          .first;
    }
    if (notificationPreferences != null) {
      payload['notification_preferences'] = {
        'email_pulls':
            (notificationPreferences['email_pulls'] as bool?) ?? false,
      };
    }

    final profile = await _client
        .from('profiles')
        .upsert(payload, onConflict: 'id')
        .select(
          'id, email, display_name, avatar_url, bio, location, collecting_since, notification_preferences, created_at, updated_at',
        )
        .single();
    final nextAvatarPath = (profile['avatar_url'] as String?)?.trim();
    if (_isStorageAvatarPath(previousAvatarPath) &&
        previousAvatarPath != nextAvatarPath) {
      await _deleteAvatarObject(previousAvatarPath!);
    }

    await _cacheProfile(profile);
    return _decorateProfile(profile);
  }

  Future<Map<String, dynamic>?> getCurrentProfile({
    bool forceRefresh = false,
  }) async {
    final now = DateTime.now();
    final cached = await _getCachedProfile();
    if (!forceRefresh && cached != null) {
      final cachedAtRaw = cached['cached_at'] as int?;
      if (cachedAtRaw != null) {
        final cachedAt = DateTime.fromMillisecondsSinceEpoch(cachedAtRaw);
        if (SupabaseCachePolicies.profile.isFresh(cachedAt, now)) {
          return _decorateProfile(
            (cached['profile'] as Map).cast<String, dynamic>(),
          );
        }
      }
    }

    final currentUser = _client.auth.currentUser;
    if (currentUser == null) {
      await _clearCachedProfile();
      return null;
    }

    try {
      final profile = await _client
          .from('profiles')
          .select(
            'id, email, display_name, avatar_url, bio, location, collecting_since, notification_preferences, created_at, updated_at',
          )
          .eq('id', currentUser.id)
          .maybeSingle();

      await _cacheProfile(profile);
      return _decorateProfile(profile);
    } catch (_) {
      if (cached != null) {
        return _decorateProfile(
          (cached['profile'] as Map?)?.cast<String, dynamic>(),
        );
      }
      rethrow;
    }
  }

  Future<String> _uploadAvatarIfLocalFile(String value, String userId) async {
    final file = File(value);
    if (!file.existsSync()) return value;

    final ext = value.contains('.')
        ? value.split('.').last.toLowerCase()
        : 'jpg';
    final safeExt = ext.isEmpty ? 'jpg' : ext;
    final objectPath =
        '$userId/avatar_${DateTime.now().millisecondsSinceEpoch}.$safeExt';
    final bytes = await file.readAsBytes();
    final contentType = switch (safeExt) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      'gif' => 'image/gif',
      _ => 'image/jpeg',
    };

    await _client.storage
        .from(_avatarBucket)
        .uploadBinary(
          objectPath,
          bytes,
          fileOptions: FileOptions(upsert: true, contentType: contentType),
        );

    return objectPath;
  }

  bool _isStorageAvatarPath(String? value) {
    if (value == null || value.isEmpty) return false;
    return !value.startsWith('http://') && !value.startsWith('https://');
  }

  Future<void> _deleteAvatarObject(String path) async {
    await _client.storage.from(_avatarBucket).remove([path]);
  }

  Future<Map<String, dynamic>?> _decorateProfile(
    Map<String, dynamic>? profile,
  ) async {
    if (profile == null) return null;

    final decorated = Map<String, dynamic>.from(profile);
    final rawAvatar = (decorated['avatar_url'] as String?)?.trim();
    decorated['avatar_storage_path'] = rawAvatar ?? '';

    if (rawAvatar == null || rawAvatar.isEmpty) {
      decorated['avatar_url'] = '';
      return decorated;
    }

    if (rawAvatar.startsWith('http://') || rawAvatar.startsWith('https://')) {
      decorated['avatar_url'] = rawAvatar;
      return decorated;
    }

    try {
      final signedUrl = await _client.storage
          .from(_avatarBucket)
          .createSignedUrl(rawAvatar, _avatarSignedUrlExpirySeconds);
      decorated['avatar_url'] = signedUrl;
    } catch (_) {
      decorated['avatar_url'] = '';
    }

    return decorated;
  }

  Future<Map?> _getCachedProfile() async {
    final box = await _hiveService.openBox<Map>(_profileBox);
    return box.get(_profileKey);
  }

  Future<void> _cacheProfile(Map<String, dynamic>? profile) async {
    final box = await _hiveService.openBox<Map>(_profileBox);
    await box.put(_profileKey, {
      'profile': profile,
      'cached_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> _clearCachedProfile() async {
    final box = await _hiveService.openBox<Map>(_profileBox);
    await box.delete(_profileKey);
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
    if (!box.containsKey(_authEmailKey)) return;
    await box.put(_authPasswordKey, password.trim());
  }

  Future<void> _clearStoredAuthCredentials() async {
    final box = await _hiveService.openBox<String>(_authBox);
    await box.delete(_authEmailKey);
    await box.delete(_authPasswordKey);
  }

  Future<void> deleteCurrentAccount() async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) {
      throw StateError('No authenticated user found.');
    }
    final userId = currentUser.id;

    await _client.from('collection_read_logs').delete().eq('user_id', userId);
    await _client.from('collection_items').delete().eq('user_id', userId);
    await _client.from('pull_list_entries').delete().eq('user_id', userId);
    await _client.from('series_subscriptions').delete().eq('user_id', userId);
    await _client.from('profiles').delete().eq('id', userId);

    await _clearCachedProfile();
    await _clearStoredAuthCredentials();
    await _client.auth.signOut();
  }
}
