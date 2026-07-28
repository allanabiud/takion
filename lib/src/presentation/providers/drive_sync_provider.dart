import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/logging/app_logger.dart';
import 'package:takion/src/core/storage/drift_database_provider.dart';

class DriveSyncState {
  final bool isInitialized;
  final bool enabled;
  final String? email;
  final DateTime? lastSync;
  final bool isSyncing;

  const DriveSyncState({
    this.isInitialized = false,
    this.enabled = false,
    this.email,
    this.lastSync,
    this.isSyncing = false,
  });

  DriveSyncState copyWith({
    bool? isInitialized,
    bool? enabled,
    String? email,
    DateTime? lastSync,
    bool? isSyncing,
  }) {
    return DriveSyncState(
      isInitialized: isInitialized ?? this.isInitialized,
      enabled: enabled ?? this.enabled,
      email: email ?? this.email,
      lastSync: lastSync ?? this.lastSync,
      isSyncing: isSyncing ?? this.isSyncing,
    );
  }
}

final driveSyncProvider = NotifierProvider<DriveSyncNotifier, DriveSyncState>(
  DriveSyncNotifier.new,
);

class DriveSyncNotifier extends Notifier<DriveSyncState> {
  static const _enabledKey = 'drive_sync_enabled';
  static const _emailKey = 'drive_sync_email';

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
    );
  }

  Future<void> enable({required String email}) async {
    await ensureInitialized();
    AppLogger.info('Drive sync enabled for $email');
    final db = ref.read(driftDatabaseProvider);
    await db.settingsDao.setBool(_enabledKey, true);
    await db.settingsDao.setString(_emailKey, email);
    state = state.copyWith(isInitialized: true, enabled: true, email: email);
  }

  Future<void> disable() async {
    await ensureInitialized();
    AppLogger.info('Drive sync disabled');
    final db = ref.read(driftDatabaseProvider);
    await db.settingsDao.setBool(_enabledKey, false);
    await db.settingsDao.deleteByKey(_emailKey);
    state = const DriveSyncState(isInitialized: true);
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
}
