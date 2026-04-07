import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/network/supabase_service.dart';

final userProfileProvider =
    AsyncNotifierProvider<UserProfileNotifier, Map<String, dynamic>?>(
      UserProfileNotifier.new,
    );

class UserProfileNotifier extends AsyncNotifier<Map<String, dynamic>?> {
  @override
  Future<Map<String, dynamic>?> build() async {
    final service = ref.watch(supabaseProfileServiceProvider);
    final profile = await service.getCurrentProfile();
    return _withBackdrop(profile, await service.getLocalBackdropPath());
  }

  Future<void> refresh() async {
    final service = ref.read(supabaseProfileServiceProvider);
    // ignore: invalid_use_of_internal_member
    state = const AsyncLoading<Map<String, dynamic>?>().copyWithPrevious(state);
    state = await AsyncValue.guard(() {
      return _loadWithBackdrop(service, forceRefresh: true);
    });
  }

  Future<void> saveProfile({
    String? displayName,
    String? avatarUrl,
    String? backdropImagePath,
    String? bio,
    String? location,
    DateTime? collectingSince,
    Map<String, dynamic>? notificationPreferences,
  }) async {
    final service = ref.read(supabaseProfileServiceProvider);
    // ignore: invalid_use_of_internal_member
    state = const AsyncLoading<Map<String, dynamic>?>().copyWithPrevious(state);
    state = await AsyncValue.guard(() async {
      final updated = await service.updateCurrentProfile(
        displayName: displayName,
        avatarUrl: avatarUrl,
        bio: bio,
        location: location,
        collectingSince: collectingSince,
        notificationPreferences: notificationPreferences,
      );
      if (backdropImagePath != null) {
        await service.storeLocalBackdropPath(backdropImagePath);
      }
      final backdropPath = await service.getLocalBackdropPath();
      final resolved =
          updated ?? await service.getCurrentProfile(forceRefresh: true);
      return _withBackdrop(resolved, backdropPath);
    });
  }

  Future<Map<String, dynamic>?> _loadWithBackdrop(
    SupabaseProfileService service, {
    required bool forceRefresh,
  }) async {
    final profile = await service.getCurrentProfile(forceRefresh: forceRefresh);
    return _withBackdrop(profile, await service.getLocalBackdropPath());
  }

  Map<String, dynamic>? _withBackdrop(
    Map<String, dynamic>? profile,
    String backdropPath,
  ) {
    if (profile == null) return null;
    final merged = Map<String, dynamic>.from(profile);
    merged['backdrop_image_path'] = backdropPath;
    return merged;
  }
}
