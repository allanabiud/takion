import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/storage/hive_service.dart';
import 'package:takion/src/presentation/sorting/content_sorting.dart';

class SortPreferencesNotifier extends Notifier<Map<String, ContentSortOption>> {
  static const _settingsBoxName = 'settings_box';
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
    final hive = ref.read(hiveServiceProvider);
    final settingsBox = await hive.openBox<dynamic>(_settingsBoxName);
    final rawMap = settingsBox.get(_sortPreferencesKey);
    if (rawMap is! Map) return;

    final next = <String, ContentSortOption>{};
    for (final entry in rawMap.entries) {
      final key = entry.key?.toString();
      final value = entry.value?.toString();
      if (key == null || value == null || key.trim().isEmpty) continue;
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
    final hive = ref.read(hiveServiceProvider);
    final settingsBox = await hive.openBox<dynamic>(_settingsBoxName);
    final serialized = state.map((key, value) => MapEntry(key, value.name));
    await settingsBox.put(_sortPreferencesKey, serialized);
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
