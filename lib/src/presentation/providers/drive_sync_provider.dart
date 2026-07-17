import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/logging/app_logger.dart';
import 'package:takion/src/core/storage/hive_service.dart';

class DriveSyncState {
  final bool enabled;
  final String? email;
  final DateTime? lastSync;
  final bool isSyncing;

  const DriveSyncState({
    this.enabled = false,
    this.email,
    this.lastSync,
    this.isSyncing = false,
  });

  DriveSyncState copyWith({
    bool? enabled,
    String? email,
    DateTime? lastSync,
    bool? isSyncing,
  }) {
    return DriveSyncState(
      enabled: enabled ?? this.enabled,
      email: email ?? this.email,
      lastSync: lastSync ?? this.lastSync,
      isSyncing: isSyncing ?? this.isSyncing,
    );
  }
}

final driveSyncProvider =
    NotifierProvider<DriveSyncNotifier, DriveSyncState>(
      DriveSyncNotifier.new,
    );

class DriveSyncNotifier extends Notifier<DriveSyncState> {
  static const _boxName = 'settings_box';
  static const _enabledKey = 'drive_sync_enabled';
  static const _emailKey = 'drive_sync_email';
  static const _lastSyncKey = 'drive_sync_last_sync';

  @override
  DriveSyncState build() {
    final hive = ref.read(hiveServiceProvider);
    final box = hive.getBoxIfOpen(_boxName);
    if (box == null) return const DriveSyncState();

    final enabled = box.get(_enabledKey, defaultValue: false) as bool;
    final email = box.get(_emailKey) as String?;
    final lastSyncRaw = box.get(_lastSyncKey) as String?;
    DateTime? lastSync;
    if (lastSyncRaw != null) {
      lastSync = DateTime.tryParse(lastSyncRaw);
    }

    return DriveSyncState(enabled: enabled, email: email, lastSync: lastSync);
  }

  Future<void> enable({required String email}) async {
    AppLogger.info('Drive sync enabled for $email');
    final hive = ref.read(hiveServiceProvider);
    final box = await hive.openBox(_boxName);
    await box.put(_enabledKey, true);
    await box.put(_emailKey, email);
    state = state.copyWith(enabled: true, email: email);
  }

  Future<void> disable() async {
    AppLogger.info('Drive sync disabled');
    final hive = ref.read(hiveServiceProvider);
    final box = await hive.openBox(_boxName);
    await box.put(_enabledKey, false);
    await box.delete(_emailKey);
    state = const DriveSyncState();
  }

  Future<void> updateLastSync() async {
    final now = DateTime.now();
    AppLogger.info('Last sync timestamp updated');
    final hive = ref.read(hiveServiceProvider);
    final box = await hive.openBox(_boxName);
    await box.put(_lastSyncKey, now.toIso8601String());
    state = state.copyWith(lastSync: now);
  }

  void setSyncing(bool value) {
    AppLogger.info('Sync state: $value');
    state = state.copyWith(isSyncing: value);
  }
}
