import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:takion/src/core/backup/cloud_backup_providers.dart';
import 'package:takion/src/presentation/components/takion_bottom_sheet.dart';
import 'package:takion/src/presentation/features/settings/widgets/backup_sheet.dart';
import 'package:takion/src/presentation/features/settings/widgets/cloud_backup_sheet.dart';
import 'package:takion/src/presentation/features/settings/widgets/restore_sheet.dart';
import 'package:takion/src/presentation/features/settings/widgets/settings_helpers.dart';
import 'package:takion/src/presentation/features/settings/providers/settings_provider.dart';
import 'package:takion/src/presentation/common/takion_alerts.dart';

void showDataStorageSettings(BuildContext context, WidgetRef ref) {
  TakionBottomSheet.show(
    context: context,
    title: 'Data and Storage',
    child: Consumer(
      builder: (context, ref, _) {
        final appSettings = ref.watch(settingsProvider);

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              buildSettingsGroup(context, 'Backup and Restore', [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.backup_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: const Text(
                    'Create Local Backup',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    'Save your local app data to an encrypted backup file',
                  ),
                  onTap: () => showCreateBackupSheet(context, ref),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.restore_page_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: const Text(
                    'Restore from Backup',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    'Restore local app data from an encrypted backup file',
                  ),
                  onTap: () => showRestoreBackupSheet(context, ref),
                ),
              ]),
              const SizedBox(height: 16),
              buildSettingsGroup(context, 'Cloud Backup', [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: Icon(
                    Icons.cloud_sync_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: const Text(
                    'Auto Backup to Drive',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    ref.watch(cloudAutoBackupProvider).value == true
                        ? 'Backup on every app open'
                        : 'Off',
                  ),
                  value: ref.watch(cloudAutoBackupProvider).value ?? false,
                  onChanged: (v) {
                    ref.read(cloudAutoBackupProvider.notifier).setEnabled(v);
                  },
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Icon(
                      Icons.schedule_outlined,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    'Last backup',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  subtitle: Text(
                    _formatLastBackup(ref.watch(cloudLastBackupProvider).value),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.cloud_upload_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: const Text(
                    'Backup to Google Drive',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    'Upload your data to Google Drive',
                  ),
                  onTap: () => showCloudBackupSheet(context, ref),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.cloud_download_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: const Text(
                    'Restore from Google Drive',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    'Download and restore from Google Drive',
                  ),
                  onTap: () => showCloudRestoreSheet(context, ref),
                ),
              ]),
              const SizedBox(height: 16),
              buildSettingsGroup(context, 'Local Cache', [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.delete_sweep_rounded,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  title: const Text(
                    'Clear Local Cache',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                  subtitle: const Text(
                    'Remove all cached metadata and images',
                  ),
                  onTap: appSettings.isSyncing
                      ? null
                      : () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Clear Cache?'),
                              content: const Text(
                                'This will remove fetched cached local data. Your account and preferences remain.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: const Text('Clear'),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await ref
                                .read(settingsProvider.notifier)
                                .clearCache();
                            if (context.mounted) {
                              TakionAlerts.success(
                                context,
                                'Cache Cleared',
                              );
                            }
                          }
                        },
                ),
              ]),
            ],
          ),
        );
      },
    ),
  );
}

String _formatLastBackup(DateTime? dateTime) {
  if (dateTime == null) return 'Never';
  return DateFormat.yMd().add_jm().format(dateTime.toLocal());
}
