import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:takion/src/core/cache/cache_policy.dart';
import 'package:takion/src/core/storage/hive_service.dart';
import 'package:takion/src/presentation/providers/issue_search_provider.dart';
import 'package:takion/src/presentation/providers/issues_provider.dart';
import 'package:takion/src/presentation/providers/series_list_provider.dart';
import 'package:takion/src/presentation/providers/series_search_provider.dart';
import 'package:takion/src/presentation/providers/repository_providers.dart';

part 'settings_provider.freezed.dart';
part 'settings_provider.g.dart';

enum SyncType { full, quick }

@freezed
abstract class AppSettings with _$AppSettings {
  const factory AppSettings({
    @Default(false) bool isSyncing,
    String? lastSyncMessage,
  }) = _AppSettings;
}

@riverpod
class SettingsNotifier extends _$SettingsNotifier {
  @override
  AppSettings build() => const AppSettings();

  DateTime _weekStart(DateTime date) {
    final offset = date.weekday % 7;
    return DateTime(
      date.year,
      date.month,
      date.day,
    ).subtract(Duration(days: offset));
  }

  DateTime? _parseWeekKey(Object? key) {
    if (key is! String) return null;
    final parts = key.split('-');
    if (parts.length != 3) return null;

    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);

    if (year == null || month == null || day == null) return null;
    return DateTime(year, month, day);
  }

  Future<Set<DateTime>> _syncTargetWeeks() async {
    final hive = ref.read(hiveServiceProvider);
    final selectedWeek = ref.read(selectedWeekProvider);
    final nowWeek = _weekStart(DateTime.now());
    final selectedWeekStart = _weekStart(selectedWeek);

    final weeklyBox = await hive.openBox<List>('weekly_releases_box');
    final cachedWeeks = weeklyBox.keys
        .map(_parseWeekKey)
        .whereType<DateTime>()
        .map(_weekStart)
        .toSet();

    return {
      ...cachedWeeks,
      nowWeek,
      selectedWeekStart,
    };
  }

  void _invalidateReleaseProviders() {
    ref.invalidate(currentWeeklyReleasesProvider);
    ref.invalidate(weeklyReleasesProvider);
  }

  void _invalidateCacheBackedProviders() {
    _invalidateReleaseProviders();
    ref.invalidate(issueDetailsProvider);
    ref.invalidate(issueSearchResultsProvider);
    ref.invalidate(seriesListProvider);
    ref.invalidate(currentSeriesListProvider);
    ref.invalidate(seriesSearchResultsProvider);
  }

  Future<void> triggerFullSync() async {
    if (state.isSyncing) return;

    state = state.copyWith(
      isSyncing: true,
      lastSyncMessage: 'Starting full sync...',
    );

    final repository = ref.read(metronRepositoryProvider);

    try {
      final weeks = await _syncTargetWeeks();
      var synced = 0;

      for (final week in weeks) {
        await repository.getWeeklyReleasesForDate(week, forceRefresh: true);
        synced++;
      }

      _invalidateCacheBackedProviders();
      state = state.copyWith(
        isSyncing: false,
        lastSyncMessage: 'Full sync completed ($synced week(s) refreshed)',
      );
    } catch (e) {
      state = state.copyWith(
        isSyncing: false,
        lastSyncMessage: 'Full sync failed: $e',
      );
    }
  }

  Future<void> triggerQuickSync() async {
    if (state.isSyncing) return;

    state = state.copyWith(
      isSyncing: true,
      lastSyncMessage: 'Starting quick sync...',
    );

    final repository = ref.read(metronRepositoryProvider);
    final localDataSource = ref.read(metronLocalDataSourceProvider);
    final now = DateTime.now();

    try {
      final weeks = await _syncTargetWeeks();
      var synced = 0;

      for (final week in weeks) {
        final cachedAt = await localDataSource.getWeeklyReleasesCachedAt(week);
        final isFresh = cachedAt != null &&
            MetronCachePolicies.weeklyReleases.isFresh(cachedAt, now);

        if (!isFresh) {
          await repository.getWeeklyReleasesForDate(week);
          synced++;
        }
      }

      _invalidateCacheBackedProviders();
      state = state.copyWith(
        isSyncing: false,
        lastSyncMessage: 'Quick sync completed ($synced stale/missing week(s) refreshed)',
      );
    } catch (e) {
      state = state.copyWith(
        isSyncing: false,
        lastSyncMessage: 'Quick sync failed: $e',
      );
    }
  }

  Future<void> clearCache() async {
    if (state.isSyncing) return;

    state = state.copyWith(
      isSyncing: true,
      lastSyncMessage: 'Clearing local cache and metadata...',
    );
    final hive = ref.read(hiveServiceProvider);
    
    try {
      await hive.clearLocalCache();
      _invalidateCacheBackedProviders();
      state = state.copyWith(
        isSyncing: false,
        lastSyncMessage: 'Cache and metadata cleared successfully',
      );
    } catch (e) {
      state = state.copyWith(isSyncing: false, lastSyncMessage: 'Failed to clear cache: $e');
    }
  }
}
