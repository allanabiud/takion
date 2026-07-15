import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/storage/local_profile_service.dart';

final userProfileProvider =
    AsyncNotifierProvider<UserProfileNotifier, Map<String, dynamic>?>(
      UserProfileNotifier.new,
    );

class UserProfileNotifier extends AsyncNotifier<Map<String, dynamic>?> {
  @override
  Future<Map<String, dynamic>?> build() async {
    final service = ref.watch(localProfileServiceProvider);
    return service.getCurrentProfile();
  }

  Future<void> refresh() async {
    final service = ref.read(localProfileServiceProvider);
    // ignore: invalid_use_of_internal_member
    state = const AsyncLoading<Map<String, dynamic>?>().copyWithPrevious(state);
    state = await AsyncValue.guard(() {
      return service.getCurrentProfile(forceRefresh: true);
    });
  }

  Future<void> saveProfile({
    String? displayName,
    String? avatarUrl,
    String? backdropImagePath,
  }) async {
    final service = ref.read(localProfileServiceProvider);
    // ignore: invalid_use_of_internal_member
    state = const AsyncLoading<Map<String, dynamic>?>().copyWithPrevious(state);
    state = await AsyncValue.guard(() async {
      return service.updateCurrentProfile(
        displayName: displayName,
        avatarUrl: avatarUrl,
        backdropImagePath: backdropImagePath,
      );
    });
  }
}
