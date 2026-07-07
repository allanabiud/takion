import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/presentation/components/takion_bottom_sheet.dart';
import 'package:takion/src/presentation/features/settings/widgets/backup_sheet.dart';
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
