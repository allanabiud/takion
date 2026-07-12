import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:takion/src/core/storage/hive_service.dart';
import 'package:takion/src/core/sync/sync_watcher.dart';
import 'package:takion/src/core/sync/cloud_sync_transport.dart';
import 'package:takion/src/core/sync/sync_service.dart';
import 'package:takion/src/core/backup/backup_service.dart';
import 'package:takion/src/presentation/providers/connectivity_provider.dart';

final syncWatcherProvider = Provider<SyncWatcher>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  final watcher = SyncWatcher(hiveService);
  ref.onDispose(() {
    watcher.dispose();
  });
  return watcher;
});

final syncTransportProvider = Provider<CloudSyncTransport>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  final backupService = BackupService(hiveService);
  return CloudSyncTransport(backupService);
});

final googleSignInAccountProvider = StreamProvider<GoogleSignInAccount?>((ref) {
  final transport = ref.watch(syncTransportProvider);
  return transport.onCurrentUserChanged;
});

final syncServiceProvider = Provider<SyncEngine>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  final watcher = ref.watch(syncWatcherProvider);
  final transport = ref.watch(syncTransportProvider);
  final connectivity = ref.watch(connectivityProvider);
  final engine = SyncEngine(hiveService, watcher, transport, connectivity);
  
  // Initialize from settings box last sync timestamp
  engine.init();
  
  ref.onDispose(() {
    engine.dispose();
  });
  return engine;
});

class SyncStatusNotifier extends Notifier<SyncStatus> {
  @override
  SyncStatus build() {
    final engine = ref.watch(syncServiceProvider);
    
    void listener() {
      state = engine.status;
    }
    
    engine.addListener(listener);
    ref.onDispose(() {
      engine.removeListener(listener);
    });
    
    return engine.status;
  }
}

final syncStatusProvider = NotifierProvider<SyncStatusNotifier, SyncStatus>(SyncStatusNotifier.new);

class AutoSyncEnabledNotifier extends Notifier<bool> {
  static const _boxName = 'settings_box';
  static const _key = 'auto_sync_enabled';

  @override
  bool build() {
    final hive = ref.watch(hiveServiceProvider);
    final box = hive.getBoxIfOpen(_boxName);
    return box?.get(_key, defaultValue: true) as bool? ?? true;
  }

  Future<void> setEnabled(bool value) async {
    final hive = ref.read(hiveServiceProvider);
    final box = await hive.openBox(_boxName);
    await box.put(_key, value);
    state = value;
  }
}

final autoSyncEnabledProvider = NotifierProvider<AutoSyncEnabledNotifier, bool>(AutoSyncEnabledNotifier.new);
