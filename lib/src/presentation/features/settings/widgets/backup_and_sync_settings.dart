import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/constants/date_formatter.dart';
import 'package:takion/src/data/common/services/drive_backup_service.dart';
import 'package:takion/src/data/common/services/local_backup_service.dart';
import 'package:takion/src/presentation/shared/alerts/takion_alerts.dart';
import 'package:takion/src/presentation/shared/widgets/components.dart';
import 'package:takion/src/presentation/features/settings/providers/settings_provider.dart';
import 'package:takion/src/presentation/features/settings/widgets/settings_helpers.dart';
import 'package:takion/src/presentation/providers/providers.dart';

void showBackupAndSyncSettings(BuildContext context, WidgetRef ref) {
  TakionBottomSheet.show(
    context: context,
    title: 'Backup & Sync',
    child: const _BackupAndSyncContent(),
  );
}

enum _BackupSyncMode { backup, sync }

class _BackupAndSyncContent extends ConsumerStatefulWidget {
  const _BackupAndSyncContent();

  @override
  ConsumerState<_BackupAndSyncContent> createState() =>
      _BackupAndSyncContentState();
}

class _BackupAndSyncContentState extends ConsumerState<_BackupAndSyncContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _syncAnimController;
  late final Animation<double> _syncRotation;
  _BackupSyncMode _mode = _BackupSyncMode.backup;
  bool _isBackingUp = false;
  bool _isRestoring = false;

  @override
  void initState() {
    super.initState();
    _syncAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _syncRotation = Tween<double>(begin: 0, end: -1).animate(
      CurvedAnimation(parent: _syncAnimController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _syncAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(driveSyncProvider, (_, next) {
      if (!mounted) return;
      if (next.isSyncing) {
        _syncAnimController.repeat();
      } else {
        _syncAnimController.reset();
      }
    });

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<_BackupSyncMode>(
              segments: const [
                ButtonSegment(
                  value: _BackupSyncMode.backup,
                  icon: Icon(Icons.backup),
                  label: Text('BACKUP'),
                ),
                ButtonSegment(
                  value: _BackupSyncMode.sync,
                  icon: Icon(Icons.sync),
                  label: Text('SYNC'),
                ),
              ],
              selected: {_mode},
              onSelectionChanged: (selected) =>
                  setState(() => _mode = selected.first),
            ),
          ),
          const SizedBox(height: 16),
          if (_mode == _BackupSyncMode.backup) _buildBackupSection(),
          if (_mode == _BackupSyncMode.sync) _buildSyncSection(),
        ],
      ),
    );
  }

  Widget _buildSyncSection() {
    final syncState = ref.watch(driveSyncProvider);
    final driveService = ref.read(driveSyncServiceProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        buildSettingsGroup(context, 'Google Drive Sync', [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Google Drive Sync',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              syncState.enabled
                  ? (syncState.email ?? 'Syncing to Google Drive')
                  : 'Off',
            ),
            value: syncState.enabled,
            onChanged: (value) async {
              if (value) {
                final account = await driveService.signIn();
                if (account != null) {
                  await ref
                      .read(driveSyncProvider.notifier)
                      .enable(email: account.email);
                  if (!mounted) return;
                  _syncNow();
                }
              } else {
                await driveService.signOut();
                await ref.read(driveSyncProvider.notifier).disable();
              }
            },
          ),
        ]),
        if (syncState.enabled) ...[
          if (syncState.lastError != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 18,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sync Error',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color:
                                Theme.of(context).colorScheme.onErrorContainer,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          syncState.lastError!,
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                Theme.of(context).colorScheme.onErrorContainer,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          buildSettingsGroup(context, 'Synchronization Settings', [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sync Interval',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<SyncInterval>(
                      segments: const [
                        ButtonSegment<SyncInterval>(
                          value: SyncInterval.minutes30,
                          label: Text('30 min'),
                        ),
                        ButtonSegment<SyncInterval>(
                          value: SyncInterval.hours1,
                          label: Text('1 hr'),
                        ),
                        ButtonSegment<SyncInterval>(
                          value: SyncInterval.hours3,
                          label: Text('3 hrs'),
                        ),
                      ],
                      selected: {syncState.syncInterval},
                      onSelectionChanged: (selected) {
                        ref
                            .read(driveSyncProvider.notifier)
                            .updateSyncInterval(selected.first);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: syncState.isSyncing
                  ? RotationTransition(
                      turns: _syncRotation,
                      child: Icon(
                        Icons.sync,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    )
                  : Icon(
                      Icons.sync,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              title: Text(
                syncState.isSyncing ? 'Syncing...' : 'Sync Now',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                syncState.isSyncing
                    ? 'Please wait'
                    : syncState.lastSync != null
                    ? 'Last sync: ${DateFormatter.relativeShort(syncState.lastSync!)}'
                    : 'Never synced',
              ),
              onTap: syncState.isSyncing ? null : () => _syncNow(),
            ),
            const Divider(height: 1),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.delete_outline,
                color: Theme.of(context).colorScheme.error,
              ),
              title: const Text(
                'Delete Backup from Drive',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text('Remove backup file from Google Drive'),
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Delete Backup'),
                    content: const Text(
                      'Are you sure you want to delete the backup file '
                      'from Google Drive? This cannot be undone.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
                if (confirm != true) return;
                try {
                  await driveService.deleteRemoteData();
                  if (!mounted) return;
                  TakionAlerts.success(context, 'Backup deleted from Drive');
                } catch (e) {
                  if (!mounted) return;
                  TakionAlerts.safeError(
                    context,
                    e,
                    userMessage: 'Failed to delete backup',
                  );
                }
              },
            ),
          ]),
        ],
      ],
    );
  }

  Widget _buildBackupSection() {
    return buildSettingsGroup(context, 'Local Backup', [
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(
          Icons.backup,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: const Text(
          'Create Local Backup',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: const Text('Save a .tkbk file of your data'),
        onTap: _isBackingUp ? null : _createLocalBackup,
        enabled: !_isBackingUp,
      ),
      const Divider(height: 1),
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(
          Icons.restore_page,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: const Text(
          'Restore from Backup',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: const Text('Import data from a .tkbk file'),
        onTap: _isRestoring ? null : _restoreFromBackup,
        enabled: !_isRestoring,
      ),
    ]);
  }

  Future<void> _createLocalBackup() async {
    setState(() => _isBackingUp = true);
    try {
      final service = ref.read(localBackupServiceProvider);
      final bytes = await service.exportBackupData();

      final today = DateTime.now();
      final dateStr =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final result = await FilePicker.saveFile(
        fileName: 'takion_backup_$dateStr.tkbk',
        bytes: bytes,
      );
      if (result != null) {
        final outputFile = File(result);
        if (!await outputFile.exists() || (await outputFile.length()) == 0) {
          await outputFile.writeAsBytes(bytes);
        }
        if (mounted) {
          TakionAlerts.success(context, 'Backup saved successfully');
        }
      }
    } catch (e) {
      if (mounted) {
        TakionAlerts.safeError(
          context,
          e,
          userMessage: 'Failed to create backup',
        );
      }
    } finally {
      if (mounted) setState(() => _isBackingUp = false);
    }
  }

  Future<void> _restoreFromBackup() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restore Backup'),
        content: const Text(
          'This will merge the backup data into your current data. '
          'Existing records will be kept if they are newer.\n\n'
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Restore'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _isRestoring = true);
    try {
      final result = await FilePicker.pickFiles(type: FileType.any);
      if (result == null || result.files.isEmpty) {
        if (mounted) setState(() => _isRestoring = false);
        return;
      }

      final file = result.files.single;
      Uint8List bytes = await file.readAsBytes();
      if (bytes.isEmpty) {
        throw StateError('Unable to read content from selected backup file');
      }

      final service = ref.read(localBackupServiceProvider);
      await service.importBackupData(bytes);

      invalidateCacheBackedProviders((p) => ref.invalidate(p));
      await Future<void>.delayed(Duration.zero);
      if (mounted) {
        TakionAlerts.success(context, 'Backup restored successfully');
      }
    } catch (e) {
      if (mounted) {
        TakionAlerts.safeError(
          context,
          e,
          userMessage: 'Failed to restore backup',
        );
      }
    } finally {
      if (mounted) setState(() => _isRestoring = false);
    }
  }

  Future<void> _syncNow() async {
    final driveService = ref.read(driveSyncServiceProvider);
    final syncNotifier = ref.read(driveSyncProvider.notifier);
    final container = ProviderScope.containerOf(context, listen: false);

    syncNotifier.clearError();
    syncNotifier.setSyncing(true);
    try {
      await driveService.triggerSync(ignoreThrottle: true);
      await syncNotifier.updateLastSync();
      invalidateCacheBackedProviders((p) => container.invalidate(p));
      await Future<void>.delayed(Duration.zero);
      if (mounted) TakionAlerts.success(context, 'Synced to Drive');
    } catch (e) {
      if (mounted) {
        syncNotifier.setError(e.toString());
        TakionAlerts.safeError(context, e, userMessage: 'Sync failed');
      }
    } finally {
      syncNotifier.setSyncing(false);
    }
  }
}
