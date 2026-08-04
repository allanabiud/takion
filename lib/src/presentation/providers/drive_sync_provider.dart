import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/logging/app_logger.dart';
import 'package:takion/src/core/storage/drift_database_provider.dart';
import 'package:takion/src/core/sync/periodic_sync_manager.dart';
import 'package:takion/src/core/sync/sync_diagnostics.dart';

enum SyncInterval {
  hours1(Duration(hours: 1), '1 hr'),
  hours3(Duration(hours: 3), '3 hrs'),
  hours24(Duration(hours: 24), '24 hrs');

  final Duration duration;
  final String label;

  const SyncInterval(this.duration, this.label);

  static SyncInterval fromString(String? value) {
    switch (value) {
      case '1 hr':
      case '1h':
      case '1_hr':
      case 'hours1':
        return SyncInterval.hours1;
      case '3 hrs':
      case '3h':
      case '3_hrs':
      case 'hours3':
        return SyncInterval.hours3;
      case '24 hrs':
      case '24h':
      case '24_hrs':
      case 'hours24':
        return SyncInterval.hours24;
      default:
        return SyncInterval.hours1;
    }
  }
}

class DriveSyncState {
  final bool isInitialized;
  final bool enabled;
  final String? email;
  final DateTime? lastSync;
  final bool isSyncing;
  final String? lastError;
  final DateTime? lastErrorTime;
  final SyncInterval syncInterval;
  final bool syncIntervalEnabled;

  const DriveSyncState({
    this.isInitialized = false,
    this.enabled = false,
    this.email,
    this.lastSync,
    this.isSyncing = false,
    this.lastError,
    this.lastErrorTime,
    this.syncInterval = SyncInterval.hours1,
    this.syncIntervalEnabled = false,
  });

  DriveSyncState copyWith({
    bool? isInitialized,
    bool? enabled,
    String? email,
    DateTime? lastSync,
    bool? isSyncing,
    String? lastError,
    DateTime? lastErrorTime,
    SyncInterval? syncInterval,
    bool? syncIntervalEnabled,
  }) {
    return DriveSyncState(
      isInitialized: isInitialized ?? this.isInitialized,
      enabled: enabled ?? this.enabled,
      email: email ?? this.email,
      lastSync: lastSync ?? this.lastSync,
      isSyncing: isSyncing ?? this.isSyncing,
      lastError: lastError ?? this.lastError,
      lastErrorTime: lastErrorTime ?? this.lastErrorTime,
      syncInterval: syncInterval ?? this.syncInterval,
      syncIntervalEnabled: syncIntervalEnabled ?? this.syncIntervalEnabled,
    );
  }
}

final driveSyncProvider = NotifierProvider<DriveSyncNotifier, DriveSyncState>(
  DriveSyncNotifier.new,
);

final syncDiagnosticsProvider = FutureProvider<SyncDiagnostics>((ref) async {
  final db = ref.watch(driftDatabaseProvider);
  return loadSyncDiagnostics(db.syncMetaDao);
});

class DriveSyncNotifier extends Notifier<DriveSyncState> {
  static const _enabledKey = 'drive_sync_enabled';
  static const _emailKey = 'drive_sync_email';
  static const _intervalKey = 'drive_sync_interval';
  static const _intervalEnabledKey = 'drive_sync_interval_enabled';

  late final Future<void> _initFuture = _loadSettings();

  @override
  DriveSyncState build() {
    _initFuture;
    return const DriveSyncState();
  }

  Future<void> ensureInitialized() => _initFuture;

  Future<void> _loadSettings() async {
    final db = ref.read(driftDatabaseProvider);
    final enabled = await db.settingsDao.getBool(
      _enabledKey,
      defaultValue: false,
    );
    final email = await db.settingsDao.getString(_emailKey);
    final intervalRaw = await db.settingsDao.getString(_intervalKey);
    final interval = SyncInterval.fromString(intervalRaw);
    final intervalEnabled = await db.settingsDao.getBool(
      _intervalEnabledKey,
      defaultValue: false,
    );

    final lastSyncRaw = await db.syncMetaDao.get('last_sync_timestamp');
    DateTime? lastSync;
    if (lastSyncRaw != null) {
      lastSync = DateTime.tryParse(lastSyncRaw);
    }
    state = DriveSyncState(
      isInitialized: true,
      enabled: enabled,
      email: email,
      lastSync: lastSync,
      syncInterval: interval,
      syncIntervalEnabled: intervalEnabled,
    );

    if (enabled && intervalEnabled) {
      await PeriodicSyncManager.instance.schedulePeriodicSync(interval);
    }
  }

  Future<void> enable({required String email}) async {
    await ensureInitialized();
    AppLogger.info('Drive sync enabled for $email');
    final db = ref.read(driftDatabaseProvider);
    await db.settingsDao.setBool(_enabledKey, true);
    await db.settingsDao.setString(_emailKey, email);
    state = state.copyWith(isInitialized: true, enabled: true, email: email);
    if (state.syncIntervalEnabled) {
      await PeriodicSyncManager.instance.schedulePeriodicSync(
        state.syncInterval,
      );
    }
  }

  Future<void> disable() async {
    await ensureInitialized();
    AppLogger.info('Drive sync disabled');
    final db = ref.read(driftDatabaseProvider);
    await db.settingsDao.setBool(_enabledKey, false);
    await db.settingsDao.deleteByKey(_emailKey);
    state = const DriveSyncState(isInitialized: true);
    await PeriodicSyncManager.instance.cancelPeriodicSync();
  }

  Future<void> updateSyncInterval(SyncInterval interval) async {
    await ensureInitialized();
    AppLogger.info('Drive sync interval changed to ${interval.label}');
    final db = ref.read(driftDatabaseProvider);
    await db.settingsDao.setString(_intervalKey, interval.label);
    state = state.copyWith(syncInterval: interval);
    if (state.enabled && state.syncIntervalEnabled) {
      await PeriodicSyncManager.instance.schedulePeriodicSync(interval);
    }
  }

  Future<void> updateSyncIntervalEnabled(bool value) async {
    await ensureInitialized();
    AppLogger.info(
      'Drive sync interval ${value ? 'enabled' : 'disabled'}',
    );
    final db = ref.read(driftDatabaseProvider);
    await db.settingsDao.setBool(_intervalEnabledKey, value);
    state = state.copyWith(syncIntervalEnabled: value);
    if (state.enabled) {
      if (value) {
        await PeriodicSyncManager.instance.schedulePeriodicSync(
          state.syncInterval,
        );
      } else {
        await PeriodicSyncManager.instance.cancelPeriodicSync();
      }
    }
  }

  Future<void> updateLastSync() async {
    await ensureInitialized();
    AppLogger.info('Last sync timestamp updated');
    final db = ref.read(driftDatabaseProvider);
    final lastSyncRaw = await db.syncMetaDao.get('last_sync_timestamp');
    DateTime? lastSync;
    if (lastSyncRaw != null) {
      lastSync = DateTime.tryParse(lastSyncRaw);
    }
    state = state.copyWith(isInitialized: true, lastSync: lastSync);
    ref.invalidate(syncDiagnosticsProvider);
  }

  void setSyncing(bool value) {
    AppLogger.info('Sync state: $value');
    state = state.copyWith(isSyncing: value);
  }

  void setError(String error) {
    AppLogger.error('Drive sync error', error: error);
    state = state.copyWith(lastError: error, lastErrorTime: DateTime.now());
    ref.invalidate(syncDiagnosticsProvider);
  }

  void clearError() {
    state = state.copyWith(lastError: null, lastErrorTime: null);
    ref.invalidate(syncDiagnosticsProvider);
  }
}
