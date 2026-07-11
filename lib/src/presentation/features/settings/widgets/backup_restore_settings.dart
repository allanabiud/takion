import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/backup/cloud_backup_providers.dart';
import 'package:takion/src/presentation/components/takion_bottom_sheet.dart';
import 'package:takion/src/presentation/features/settings/widgets/backup_sheet.dart';
import 'package:takion/src/presentation/features/settings/widgets/cloud_backup_sheet.dart';
import 'package:takion/src/presentation/features/settings/widgets/restore_sheet.dart';
import 'package:intl/intl.dart';

enum _BackupMode { local, cloud }

void showBackupRestoreSettings(BuildContext context, WidgetRef ref) {
  TakionBottomSheet.show(
    context: context,
    title: 'Backup & Restore',
    child: Consumer(
      builder: (context, ref, _) {
        return _BackupRestoreContent(ref: ref);
      },
    ),
  );
}

class _BackupRestoreContent extends ConsumerStatefulWidget {
  final WidgetRef ref;

  const _BackupRestoreContent({required this.ref});

  @override
  ConsumerState<_BackupRestoreContent> createState() =>
      _BackupRestoreContentState();
}

class _BackupRestoreContentState extends ConsumerState<_BackupRestoreContent> {
  _BackupMode _mode = _BackupMode.local;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<_BackupMode>(
              segments: const [
                ButtonSegment(
                  value: _BackupMode.local,
                  icon: Icon(Icons.phone_android_outlined),
                  label: Text('LOCAL'),
                ),
                ButtonSegment(
                  value: _BackupMode.cloud,
                  icon: Icon(Icons.cloud_outlined),
                  label: Text('CLOUD'),
                ),
              ],
              selected: {_mode},
              onSelectionChanged: (selected) =>
                  setState(() => _mode = selected.first),
            ),
          ),
          const SizedBox(height: 16),
          if (_mode == _BackupMode.local) _buildLocalSection(),
          if (_mode == _BackupMode.cloud) _buildCloudSection(),
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
            'Save your local app data to a backup file',
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
          subtitle: const Text('Restore local app data from a backup file'),
          onTap: () => showRestoreBackupSheet(context, widget.ref),
        ),
      ],
    );
  }

  Widget _buildCloudSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _googleStatusRow(context, widget.ref),
        const Divider(),
        _backupToDriveTile(context, widget.ref),
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
          onTap: () => showCloudRestoreSheet(context, widget.ref),
        ),
      ],
    );
  }

  Widget _googleStatusRow(BuildContext context, WidgetRef ref) {
    final account = ref.watch(googleSignInAccountProvider).value;
    if (account != null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
        child: Row(
          children: [
            Icon(
              Icons.check_circle,
              size: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
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
                icon: Icon(
                  Icons.logout,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
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
          Icon(
            Icons.info_outline,
            size: 18,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => showCloudBackupSheet(context, ref),
            child: Text(
              'Not signed in to Google',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
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
      onTap: () => showCloudBackupSheet(context, widget.ref),
    );
  }
}


