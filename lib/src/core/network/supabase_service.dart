import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:takion/src/domain/entities/issue_list.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final supabaseProfileServiceProvider = Provider<SupabaseProfileService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseProfileService(client);
});

final supabaseCatalogReleaseServiceProvider =
    Provider<SupabaseCatalogReleaseService>((ref) {
      final client = ref.watch(supabaseClientProvider);
      return SupabaseCatalogReleaseService(client);
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

class SupabaseCatalogReleaseService {
  SupabaseCatalogReleaseService(this._client);

  final SupabaseClient _client;

  Future<int> upsertWeeklyIssues(List<IssueList> issues) async {
    final rows = <Map<String, dynamic>>[];

    for (final issue in issues) {
      final issueId = issue.id;
      final seriesId = issue.series?.id;
      final releaseDate = issue.storeDate ?? issue.coverDate;

      if (issueId == null || issueId <= 0) continue;
      if (seriesId == null || seriesId <= 0) continue;
      if (releaseDate == null) continue;

      rows.add({
        'metron_issue_id': issueId,
        'metron_series_id': seriesId,
        'issue_number': issue.number,
        'title': issue.name,
        'release_date': releaseDate.toUtc().toIso8601String().split('T').first,
        'cover_image_url': issue.image,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
    }

    if (rows.isEmpty) return 0;

    await _client.from('catalog_issue_releases').upsert(
      rows,
      onConflict: 'metron_issue_id',
    );

    return rows.length;
  }
}