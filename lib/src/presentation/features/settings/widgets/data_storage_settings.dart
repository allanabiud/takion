import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/presentation/components/takion_bottom_sheet.dart';
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
        ref.listen<AppSettings>(settingsProvider, (previous, next) {
          if (!context.mounted) return;
          final justFinishedSync =
              (previous?.isSyncing ?? false) && !next.isSyncing;
          if (!justFinishedSync) return;

          final message = next.lastSyncMessage?.trim();
          if (message == null || message.isEmpty) return;

          final normalized = message.toLowerCase();
          if (normalized.contains('failed')) {
            TakionAlerts.error(context, message);
            return;
          }
          if (normalized.contains('completed')) {
            TakionAlerts.success(context, message);
          }
        });

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (appSettings.isSyncing)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              appSettings.lastSyncMessage
                                          ?.trim()
                                          .isNotEmpty ==
                                      true
                                  ? appSettings.lastSyncMessage!.trim()
                                  : 'Sync in progress...',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const LinearProgressIndicator(minHeight: 4),
                    ],
                  ),
                ),
              buildSettingsGroup(context, 'Sync Options', [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  enabled: !appSettings.isSyncing,
                  leading: Icon(
                    Icons.sync_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: const Text(
                    'Full Sync',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    appSettings.isSyncing
                        ? 'Sync currently running...'
                        : 'Update all app data from Metron',
                  ),
                  trailing: appSettings.isSyncing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.chevron_right_rounded),
                  onTap: appSettings.isSyncing
                      ? null
                      : () => ref
                            .read(settingsProvider.notifier)
                            .triggerFullSync(),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  enabled: !appSettings.isSyncing,
                  leading: Icon(
                    Icons.sync_problem_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: const Text(
                    'Quick Sync',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    appSettings.isSyncing
                        ? 'Sync currently running...'
                        : 'Update modified data only',
                  ),
                  trailing: appSettings.isSyncing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.chevron_right_rounded),
                  onTap: appSettings.isSyncing
                      ? null
                      : () => ref
                            .read(settingsProvider.notifier)
                            .triggerQuickSync(),
                ),
              ]),
              const SizedBox(height: 16),
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
                    'Save your local app data to a backup file (coming soon)',
                  ),
                  onTap: () => TakionAlerts.info(
                    context,
                    'Local backup coming soon',
                  ),
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
                    'Restore local app data from a backup file (coming soon)',
                  ),
                  onTap: () => TakionAlerts.info(
                    context,
                    'Backup restore coming soon',
                  ),
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
