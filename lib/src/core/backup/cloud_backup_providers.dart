import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:takion/src/core/backup/backup_service.dart';
import 'package:takion/src/core/backup/cloud_backup_service.dart';
import 'package:takion/src/core/storage/hive_service.dart';

final cloudBackupServiceProvider = Provider<CloudBackupService>((ref) {
  final hiveService = ref.read(hiveServiceProvider);
  final backupService = BackupService(hiveService);
  return CloudBackupService(backupService);
});

final googleSignInAccountProvider = Provider<GoogleSignInAccount?>((ref) {
  final service = ref.watch(cloudBackupServiceProvider);
  return service.currentUser;
});

final cloudBackupListProvider = FutureProvider<List<BackupFileInfo>>((ref) {
  final service = ref.watch(cloudBackupServiceProvider);
  return service.listBackups();
});

const _settingsBox = 'settings_box';
const _autoBackupKey = 'auto_cloud_backup';
const _lastBackupKey = 'last_cloud_backup';
const _autoBackupPasswordKey = 'auto_cloud_backup_password';

final cloudAutoBackupProvider = AsyncNotifierProvider<CloudAutoBackupNotifier, bool>(
  CloudAutoBackupNotifier.new,
);

class CloudAutoBackupNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final hive = ref.read(hiveServiceProvider);
    final box = await hive.openBox(_settingsBox);
    return box.get(_autoBackupKey, defaultValue: false) as bool;
  }

  Future<void> setEnabled(bool value) async {
    final hive = ref.read(hiveServiceProvider);
    final box = await hive.openBox(_settingsBox);
    await box.put(_autoBackupKey, value);
    state = AsyncValue.data(value);
  }
}

final cloudLastBackupProvider =
    AsyncNotifierProvider<CloudLastBackupNotifier, DateTime?>(
  CloudLastBackupNotifier.new,
);

class CloudLastBackupNotifier extends AsyncNotifier<DateTime?> {
  @override
  Future<DateTime?> build() async {
    final hive = ref.read(hiveServiceProvider);
    final box = await hive.openBox(_settingsBox);
    final raw = box.get(_lastBackupKey) as String?;
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  Future<void> setLastBackup(DateTime dateTime) async {
    final hive = ref.read(hiveServiceProvider);
    final box = await hive.openBox(_settingsBox);
    await box.put(_lastBackupKey, dateTime.toUtc().toIso8601String());
    state = AsyncValue.data(dateTime);
  }
}

final cloudAutoBackupPasswordProvider =
    AsyncNotifierProvider<CloudAutoBackupPasswordNotifier, String>(
  CloudAutoBackupPasswordNotifier.new,
);

class CloudAutoBackupPasswordNotifier extends AsyncNotifier<String> {
  @override
  Future<String> build() async {
    final hive = ref.read(hiveServiceProvider);
    final box = await hive.openBox(_settingsBox);
    final stored = box.get(_autoBackupPasswordKey) as String?;
    if (stored != null && stored.isNotEmpty) return stored;
    final generated = _generatePassword();
    await box.put(_autoBackupPasswordKey, generated);
    return generated;
  }

  String _generatePassword() {
    final random = Random.secure();
    final chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#%^&*()-_=+';
    return List.generate(32, (_) => chars[random.nextInt(chars.length)]).join();
  }
}

class CloudBackupRunningNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void start() => state = true;
  void stop() => state = false;
}

final cloudBackupRunningProvider = NotifierProvider<CloudBackupRunningNotifier, bool>(CloudBackupRunningNotifier.new);
