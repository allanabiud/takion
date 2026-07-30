import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/logging/app_logger.dart';
import 'package:takion/src/core/storage/drift_database_provider.dart';
import 'package:takion/src/core/sync/periodic_sync_manager.dart';

enum SyncInterval {
  minutes30(Duration(minutes: 30), '30 min'),
  hours1(Duration(hours: 1), '1 hr'),
  hours3(Duration(hours: 3), '3 hrs');

  final Duration duration;
  final String label;

  const SyncInterval(this.duration, this.label);

  static SyncInterval fromString(String? value) {
    switch (value) {
      case '30 min':
      case '30m':
      case '30_min':
      case 'minutes30':
        return SyncInterval.minutes30;
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

  const DriveSyncState({
    this.isInitialized = false,
    this.enabled = false,
    this.email,
    this.lastSync,
    this.isSyncing = false,
    this.lastError,
    this.lastErrorTime,
    this.syncInterval = SyncInterval.hours1,
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
    );
  }
}

final driveSyncProvider = NotifierProvider<DriveSyncNotifier, DriveSyncState>(
  DriveSyncNotifier.new,
);

class DriveSyncNotifier extends Notifier<DriveSyncState> {
  static const _enabledKey = 'drive_sync_enabled';
  static const _emailKey = 'drive_sync_email';
  static const _intervalKey = 'drive_sync_interval';

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
    );

    if (enabled) {
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
    await PeriodicSyncManager.instance.schedulePeriodicSync(state.syncInterval);
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
    if (state.enabled) {
      await PeriodicSyncManager.instance.schedulePeriodicSync(interval);
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
  }

  void setSyncing(bool value) {
    AppLogger.info('Sync state: $value');
    state = state.copyWith(isSyncing: value);
  }

  void setError(String error) {
    AppLogger.error('Drive sync error', error: error);
    state = state.copyWith(lastError: error, lastErrorTime: DateTime.now());
  }

  void clearError() {
    state = state.copyWith(lastError: null, lastErrorTime: null);
  }
}
