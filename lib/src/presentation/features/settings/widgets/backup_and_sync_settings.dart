import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/sync/sync_providers.dart';
import 'package:takion/src/core/sync/sync_service.dart';
import 'package:takion/src/presentation/components/takion_bottom_sheet.dart';
import 'package:takion/src/presentation/features/settings/widgets/backup_sheet.dart';
import 'package:takion/src/presentation/features/settings/widgets/restore_sheet.dart';
import 'package:intl/intl.dart';

enum _BackupSyncMode { local, sync }

void showBackupAndSyncSettings(BuildContext context, WidgetRef ref) {
  TakionBottomSheet.show(
    context: context,
    title: 'Backup & Sync',
    child: Consumer(
      builder: (context, ref, _) {
        return _BackupAndSyncContent(ref: ref);
      },
    ),
  );
}

class _BackupAndSyncContent extends ConsumerStatefulWidget {
  final WidgetRef ref;

  const _BackupAndSyncContent({required this.ref});

  @override
  ConsumerState<_BackupAndSyncContent> createState() =>
      _BackupAndSyncContentState();
}

class _BackupAndSyncContentState extends ConsumerState<_BackupAndSyncContent> {
  _BackupSyncMode _mode = _BackupSyncMode.local;

  @override
  void initState() {
    super.initState();
  }

  void _showSyncedCategoriesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Synced Data'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'The following data is synced across your devices:',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),
            _SyncCategoryRow(icon: Icons.shopping_bag_outlined, label: 'Pull List'),
            SizedBox(height: 10),
            _SyncCategoryRow(icon: Icons.notifications_outlined, label: 'Subscriptions'),
            SizedBox(height: 10),
            _SyncCategoryRow(icon: Icons.inventory_2_outlined, label: 'Comic Library'),
            SizedBox(height: 10),
            _SyncCategoryRow(icon: Icons.bookmark_added_outlined, label: 'Reading Logs'),
            SizedBox(height: 10),
            _SyncCategoryRow(icon: Icons.favorite_outline, label: 'Favorites (Series, Issues, Characters, Creators, Reading Lists)'),
            SizedBox(height: 10),
            _SyncCategoryRow(icon: Icons.list_alt_outlined, label: 'Reading Lists'),
            SizedBox(height: 10),
            _SyncCategoryRow(icon: Icons.person_outline, label: 'User Profile'),
            SizedBox(height: 16),
            Text(
              'App settings are per-device and not synced.',
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  value: _BackupSyncMode.local,
                  icon: Icon(Icons.phone_android_outlined),
                  label: Text('LOCAL'),
                ),
                ButtonSegment(
                  value: _BackupSyncMode.sync,
                  icon: Icon(Icons.sync_outlined),
                  label: Text('CLOUD SYNC'),
                ),
              ],
              selected: {_mode},
              onSelectionChanged: (selected) =>
                  setState(() => _mode = selected.first),
            ),
          ),
          const SizedBox(height: 16),
          if (_mode == _BackupSyncMode.local) _buildLocalSection(),
          if (_mode == _BackupSyncMode.sync) _buildSyncSection(),
        ],
      ),
    );
  }

  Widget _buildLocalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
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
          onTap: () => showCreateBackupSheet(context, widget.ref),
        ),
        const Divider(),
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
          subtitle: const Text('Restore local app data from a backup file (.tkbk)'),
          onTap: () => showRestoreBackupSheet(context, widget.ref),
        ),
      ],
    );
  }

  Widget _buildSyncSection() {
    final account = ref.watch(googleSignInAccountProvider).value;
    final syncStatus = ref.watch(syncStatusProvider);
    final autoSyncEnabled = ref.watch(autoSyncEnabledProvider);

    if (account == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          Icon(
            Icons.sync_disabled_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'Cloud Sync is Disabled',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Sign in with Google to securely sync your comic library, reading logs, pull list, and favorites across all your devices.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.tonalIcon(
            icon: const Icon(Icons.login),
            label: const Text('Sign in with Google'),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
              foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () async {
              try {
                await ref.read(syncTransportProvider).signIn();
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Sign in failed: $e')),
                );
              }
            },
          ),
          const SizedBox(height: 16),
        ],
      );
    }

    final isSyncing = syncStatus.state == SyncState.syncing;
    final lastSyncText = syncStatus.lastSyncAt != null
        ? DateFormat.yMMMd().add_jm().format(syncStatus.lastSyncAt!.toLocal())
        : 'Never';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Connection Info
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.check_circle,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Connected',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      account.email,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => ref.read(syncTransportProvider).signOut(),
                child: Text(
                  'Sign out',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Auto Sync Toggle
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Auto Sync', style: TextStyle(fontWeight: FontWeight.w600)),
          subtitle: const Text('Sync automatically when the app starts'),
          value: autoSyncEnabled,
          onChanged: (val) {
            ref.read(autoSyncEnabledProvider.notifier).setEnabled(val);
          },
        ),
        const Divider(),

        // Sync Status
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Sync Status',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () => _showSyncedCategoriesDialog(),
                  child: Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Last synced: $lastSyncText',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            if (syncStatus.message != null) ...[
              const SizedBox(height: 2),
              Text(
                syncStatus.message!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: syncStatus.state == SyncState.error
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: isSyncing
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  : FilledButton.tonalIcon(
                      icon: const Icon(Icons.sync, size: 16),
                      label: const Text('Sync Now'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                        foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      onPressed: () {
                        ref.read(syncServiceProvider).syncAll();
                      },
                    ),
            ),
          ],
        ),

        const SizedBox(height: 16),
      ],
    );
  }
}

class _SyncCategoryRow extends StatelessWidget {
  const _SyncCategoryRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}
