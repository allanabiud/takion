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
    return service.getCurrentProfile();
  }

  Future<void> refresh() async {
    final service = ref.read(supabaseProfileServiceProvider);
    // ignore: invalid_use_of_internal_member
    state = const AsyncLoading<Map<String, dynamic>?>().copyWithPrevious(state);
    state = await AsyncValue.guard(() {
      return service.getCurrentProfile(forceRefresh: true);
    });
  }

  Future<void> saveProfile({
    String? displayName,
    String? avatarUrl,
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
      return updated ?? await service.getCurrentProfile(forceRefresh: true);
    });
  }
}
