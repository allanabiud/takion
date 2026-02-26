import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final supabaseProfileServiceProvider = Provider<SupabaseProfileService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseProfileService(client);
});

class SupabaseProfileService {
  final SupabaseClient _client;

  SupabaseProfileService(this._client);

  Future<void> ensureProfile({
    required User user,
    String? displayName,
  }) async {
    final trimmedDisplayName = displayName?.trim();
    final emailPrefix = user.email?.split('@').first.trim();
    final fallbackDisplayName =
        (emailPrefix != null && emailPrefix.isNotEmpty)
            ? emailPrefix
            : 'Takion Reader';

    await _client.from('profiles').upsert({
      'id': user.id,
      'email': user.email,
      'display_name':
          (trimmedDisplayName != null && trimmedDisplayName.isNotEmpty)
              ? trimmedDisplayName
              : fallbackDisplayName,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }, onConflict: 'id');
  }

  Future<Map<String, dynamic>?> getCurrentProfile() async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) return null;

    return await _client
        .from('profiles')
        .select('id, email, display_name, created_at, updated_at')
        .eq('id', currentUser.id)
        .maybeSingle();
  }
}