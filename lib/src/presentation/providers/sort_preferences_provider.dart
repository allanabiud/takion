import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/common/content_sorting.dart';
import 'package:takion/src/core/storage/drift_database_provider.dart';

class SortPreferencesNotifier extends Notifier<Map<String, ContentSortOption>> {
  static const _sortPreferencesKey = 'sort_preferences';

  bool _hydrated = false;

  @override
  Map<String, ContentSortOption> build() {
    if (!_hydrated) {
      _hydrated = true;
      Future.microtask(_hydrateFromStorage);
    }
    return const {};
  }

  Future<void> _hydrateFromStorage() async {
    final dao = ref.read(driftDatabaseProvider).settingsDao;
    final rawMap = await dao.getString(_sortPreferencesKey);
    if (rawMap == null) return;

    Map<String, dynamic> decoded;
    try {
      decoded = Map<String, dynamic>.from(jsonDecode(rawMap) as Map);
    } on FormatException {
      return;
    }

    final next = <String, ContentSortOption>{};
    for (final entry in decoded.entries) {
      final key = entry.key;
      final value = entry.value as String?;
      if (value == null || key.trim().isEmpty) continue;
      final parsed = ContentSortOption.values.where(
        (item) => item.name == value,
      );
      if (parsed.isNotEmpty) {
        next[key] = parsed.first;
      }
    }
    state = next;
  }

  Future<void> _persist() async {
    final dao = ref.read(driftDatabaseProvider).settingsDao;
    final serialized = state.map((key, value) => MapEntry(key, value.name));
    await dao.setString(_sortPreferencesKey, jsonEncode(serialized));
  }

  void setPreference(
    SortPreferenceContext context,
    ContentSortOption sortOption,
  ) {
    state = {...state, context.storageKey: sortOption};
    _persist();
  }
}

final sortPreferencesProvider =
    NotifierProvider<SortPreferencesNotifier, Map<String, ContentSortOption>>(
      SortPreferencesNotifier.new,
    );

final sortPreferenceForContextProvider =
    Provider.family<ContentSortOption, SortPreferenceContext>((ref, context) {
      final preferences = ref.watch(sortPreferencesProvider);
      return preferences[context.storageKey] ?? context.defaultOption;
    });
