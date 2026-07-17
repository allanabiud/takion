import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/constants/date_formatter.dart';
import 'package:takion/src/data/services/drive_backup_service.dart';
import 'package:takion/src/presentation/common/takion_alerts.dart';
import 'package:takion/src/presentation/components/components.dart';
import 'package:takion/src/presentation/features/settings/widgets/backup_sheet.dart';
import 'package:takion/src/presentation/features/settings/widgets/restore_sheet.dart';
import 'package:takion/src/presentation/features/settings/providers/settings_provider.dart';
import 'package:takion/src/presentation/features/settings/widgets/settings_helpers.dart';
import 'package:takion/src/presentation/providers/providers.dart';

enum _BackupSyncMode { backup, sync }

void showBackupAndSyncSettings(BuildContext context, WidgetRef ref) {
  TakionBottomSheet.show(
    context: context,
    title: 'Backup & Sync',
    child: const _BackupAndSyncContent(),
  );
}

class _BackupAndSyncContent extends ConsumerStatefulWidget {
  const _BackupAndSyncContent();

  @override
  ConsumerState<_BackupAndSyncContent> createState() =>
      _BackupAndSyncContentState();
}

class _BackupAndSyncContentState extends ConsumerState<_BackupAndSyncContent>
    with SingleTickerProviderStateMixin {
  _BackupSyncMode _mode = _BackupSyncMode.backup;
  late final AnimationController _syncAnimController;
  late final Animation<double> _syncRotation;

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
    // Drive the rotation from the live provider value so the visible tile
    // always reflects the syncing state, even if _syncNow captured a stale
    // element (e.g. after the tree rebuilds on enable()).
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
                  icon: Icon(Icons.phone_android_outlined),
                  label: Text('BACKUP'),
                ),
                ButtonSegment(
                  value: _BackupSyncMode.sync,
                  icon: Icon(Icons.sync_outlined),
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

  Widget _buildBackupSection() {
    return buildSettingsGroup(context, 'Local Backup', [
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(
          Icons.file_upload_outlined,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: const Text(
          'Create Local Backup',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: const Text(
          'Save your local app data to a backup file (.tkbk)',
        ),
        onTap: () => showCreateBackupSheet(context, ref),
      ),
      const Divider(height: 1),
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(
          Icons.file_download_outlined,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: const Text(
          'Restore from Backup',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: const Text(
          'Restore local app data from a backup file (.tkbk)',
        ),
        onTap: () => showRestoreBackupSheet(context, ref),
      ),
    ]);
  }

  Widget _buildSyncSection() {
    final syncState = ref.watch(driveSyncProvider);
    final driveService = ref.read(driveBackupServiceProvider);

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
          const SizedBox(height: 16),
          buildSettingsGroup(context, 'Synchronization Settings', [
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
                  await driveService.deleteBackup();
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

  Future<void> _syncNow() async {
    final driveService = ref.read(driveBackupServiceProvider);
    final syncState = ref.read(driveSyncProvider);
    final syncNotifier = ref.read(driveSyncProvider.notifier);
    final container = ProviderScope.containerOf(context, listen: false);

    syncNotifier.setSyncing(true);
    try {
      await driveService.uploadBackup(lastSyncTime: syncState.lastSync);
      await syncNotifier.updateLastSync();
      invalidateCacheBackedProviders((p) => container.invalidate(p));
      // Ensure syncing state is rendered for at least one frame
      await Future<void>.delayed(Duration.zero);
      if (mounted) TakionAlerts.success(context, 'Synced to Drive');
    } catch (e) {
      if (mounted) {
        TakionAlerts.safeError(context, e, userMessage: 'Sync failed');
      }
    } finally {
      syncNotifier.setSyncing(false);
    }
  }
}
