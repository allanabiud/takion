import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/backup/cloud_backup_providers.dart';
import 'package:takion/src/presentation/components/takion_bottom_sheet.dart';
import 'package:takion/src/presentation/features/settings/widgets/backup_sheet.dart';
import 'package:takion/src/presentation/features/settings/widgets/cloud_backup_sheet.dart';
import 'package:takion/src/presentation/features/settings/widgets/restore_sheet.dart';
import 'package:intl/intl.dart';
import 'package:takion/src/presentation/features/settings/widgets/settings_helpers.dart';
import 'package:takion/src/presentation/common/password_dialog.dart';
import 'package:takion/src/presentation/common/takion_alerts.dart';

void showBackupRestoreSettings(BuildContext context, WidgetRef ref) {
  TakionBottomSheet.show(
    context: context,
    title: 'Backup and Restore',
    child: Consumer(
      builder: (context, ref, _) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              buildSettingsGroup(context, 'LOCAL', [
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
              buildSettingsGroup(context, 'CLOUD', [
                _googleStatusRow(context, ref),
                const Divider(),
                _backupToDriveTile(context, ref),
                const Divider(),
                _masterPasswordTile(context, ref),
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
                  subtitle: const Text('Download and restore from Google Drive'),
                  onTap: () => showCloudRestoreSheet(context, ref),
                ),
              ]),
            ],
          ),
        );
      },
    ),
  );
}

Widget _googleStatusRow(BuildContext context, WidgetRef ref) {
  final account = ref.watch(googleSignInAccountProvider).value;
  if (account != null) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                text: 'Signed in as ',
                style: Theme.of(context).textTheme.bodySmall,
                children: [
                  TextSpan(
                    text: account.email,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 32,
            width: 32,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(Icons.logout, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
              onPressed: () => ref.read(cloudBackupServiceProvider).signOut(),
              tooltip: 'Sign out',
            ),
          ),
        ],
      ),
    );
  }
  return Padding(
    padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
    child: Row(
      children: [
        Icon(Icons.info_outline, size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => showCloudBackupSheet(context, ref),
          child: Text(
            'Not signed in to Google',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _backupToDriveTile(BuildContext context, WidgetRef ref) {
  final lastBackupAsync = ref.watch(cloudLastBackupProvider);
  final lastBackup = lastBackupAsync.value;
  return ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(
      Icons.cloud_upload_outlined,
      color: Theme.of(context).colorScheme.primary,
    ),
    title: const Text(
      'Backup to Google Drive',
      style: TextStyle(fontWeight: FontWeight.w600),
    ),
    subtitle: Text(
      lastBackup != null
          ? 'Last Backup: ${DateFormat.yMMMd().add_jm().format(lastBackup.toLocal())}'
          : 'No backup yet',
    ),
    onTap: () => showCloudBackupSheet(context, ref),
  );
}

Widget _masterPasswordTile(BuildContext context, WidgetRef ref) {
  final passwordAsync = ref.watch(cloudAutoBackupPasswordProvider);
  final password = passwordAsync.value;
  final isSet = password != null && password.isNotEmpty;

  return ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(
      isSet ? Icons.lock_outline : Icons.lock_open_outlined,
      color: Theme.of(context).colorScheme.primary,
    ),
    title: const Text(
      'Master Backup Password',
      style: TextStyle(fontWeight: FontWeight.w600),
    ),
    subtitle: Text(
      isSet
          ? 'Configured (Required for automatic cloud backups)'
          : 'Not configured (Required for automatic cloud backups)',
    ),
    trailing: isSet
        ? IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Remove Password',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Remove Master Password'),
                  content: const Text(
                    'This will disable automatic cloud backups. Are you sure?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Remove'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await ref
                    .read(cloudAutoBackupPasswordProvider.notifier)
                    .clearPassword();
                if (context.mounted) {
                  TakionAlerts.success(context, 'Master password removed');
                }
              }
            },
          )
        : const Icon(Icons.chevron_right),
    onTap: () async {
      final newPassword = await showPasswordDialog(
        context: context,
        mode: PasswordDialogMode.master,
      );
      if (newPassword != null && newPassword.isNotEmpty) {
        await ref
            .read(cloudAutoBackupPasswordProvider.notifier)
            .setPassword(newPassword);
        if (context.mounted) {
          TakionAlerts.success(context, 'Master password updated');
        }
      }
    },
  );
}
