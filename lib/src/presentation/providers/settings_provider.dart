import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:takion/src/core/storage/hive_service.dart';

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

  Future<void> triggerFullSync() async {
    state = state.copyWith(isSyncing: true, lastSyncMessage: 'Starting full sync...');
    // TODO: Implement actual full sync logic
    await Future.delayed(const Duration(seconds: 2)); // Mock delay
    state = state.copyWith(isSyncing: false, lastSyncMessage: 'Full sync completed');
  }

  Future<void> triggerQuickSync() async {
    state = state.copyWith(isSyncing: true, lastSyncMessage: 'Starting quick sync...');
    // TODO: Implement actual quick sync logic
    await Future.delayed(const Duration(seconds: 1)); // Mock delay
    state = state.copyWith(isSyncing: false, lastSyncMessage: 'Quick sync completed');
  }

  Future<void> clearCache() async {
    state = state.copyWith(isSyncing: true, lastSyncMessage: 'Clearing local cache...');
    final hive = ref.read(hiveServiceProvider);
    
    try {
      await hive.clearLocalCache();
      state = state.copyWith(isSyncing: false, lastSyncMessage: 'Cache cleared successfully');
    } catch (e) {
      state = state.copyWith(isSyncing: false, lastSyncMessage: 'Failed to clear cache: $e');
    }
  }
}
