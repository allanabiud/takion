import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:takion/src/core/backup/backup_service.dart';
import 'package:takion/src/core/backup/cloud_backup_service.dart';
import 'package:takion/src/core/backup/cloud_backup_providers.dart';
import 'package:takion/src/core/storage/hive_service.dart';
import 'package:takion/src/presentation/common/takion_alerts.dart';
import 'package:takion/src/presentation/components/takion_bottom_sheet.dart';
import 'package:takion/src/presentation/features/library/providers/collection_stats_provider.dart';
import 'package:takion/src/presentation/features/library/providers/pulls_provider.dart';
import 'package:takion/src/presentation/features/series/providers/subscriptions_provider.dart';
import 'package:takion/src/presentation/features/settings/providers/settings_provider.dart';

Future<void> showCloudBackupSheet(BuildContext context, WidgetRef ref) {
  return TakionBottomSheet.show(
    context: context,
    title: 'Backup to Google Drive',
    child: _CloudBackupSheet(ref: ref),
  );
}

class _CloudBackupSheet extends ConsumerStatefulWidget {
  final WidgetRef ref;

  const _CloudBackupSheet({required this.ref});

  @override
  ConsumerState<_CloudBackupSheet> createState() => _CloudBackupSheetState();
}

class _CloudBackupSheetState extends ConsumerState<_CloudBackupSheet> {
  static const _sensitiveGroups = {'User Profile'};
  late Map<String, bool> _selections;
  bool _loading = false;
  double _progress = 0;
  bool _signedIn = false;

  List<MapEntry<String, List<String>>> get _sortedEntries {
    final entries = BackupService.backupGroups.entries.toList()
      ..sort((a, b) {
        final aSensitive = _sensitiveGroups.contains(a.key);
        final bSensitive = _sensitiveGroups.contains(b.key);
        if (aSensitive && !bSensitive) return 1;
        if (!aSensitive && bSensitive) return -1;
        return 0;
      });
    return entries;
  }

  @override
  void initState() {
    super.initState();
    _selections = {
      for (final group in BackupService.backupGroups.keys) group: true,
    };
    _checkSignIn();
  }

  Future<void> _checkSignIn() async {
    final service = widget.ref.read(cloudBackupServiceProvider);
    final signedIn = service.isSignedIn;
    if (mounted) setState(() => _signedIn = signedIn);
  }

  Future<void> _signIn() async {
    final service = widget.ref.read(cloudBackupServiceProvider);
    try {
      final account = await service.signIn();
      if (mounted) setState(() => _signedIn = account != null);
    } catch (e) {
      if (mounted) TakionAlerts.error(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!_signedIn) _buildSignInPrompt(),
          if (_signedIn) _buildBackupForm(),
        ],
      ),
    );
  }

  Widget _buildSignInPrompt() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Icon(
            Icons.cloud_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Sign in with Google to backup your data to Google Drive.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _signIn,
            icon: const Icon(Icons.login),
            label: const Text('Sign in with Google'),
          ),
        ],
      ),
    );
  }

  Widget _buildBackupForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            'Select the data to backup to Google Drive.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        if (ref.watch(cloudLastBackupProvider).value case final lastBackup?)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Icon(
                  Icons.schedule_outlined,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  'Last backup: ${DateFormat.yMd().add_jm().format(lastBackup.toLocal())}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ..._sortedEntries.map(
          (entry) {
            final group = entry.key;

            return SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _selections[group] ?? false,
              onChanged: _loading
                  ? null
                  : (v) => setState(() => _selections[group] = v),
              title: Text(
                group,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            );
          },
        ),
        const Divider(),
        if (_loading)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                LinearProgressIndicator(
                    value: _progress > 0 ? _progress : null),
                const SizedBox(height: 8),
                Text(
                  _progress > 0
                      ? '${(_progress * 100).toInt()}%'
                      : 'Uploading...',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed:
                    _loading ? null : () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: FilledButton.icon(
                onPressed: _loading ? null : _uploadBackup,
                icon: const Icon(Icons.cloud_upload_outlined),
                label: const Text('Backup'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _uploadBackup() async {
    final selectedGroups = _selections.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    if (selectedGroups.isEmpty) {
      TakionAlerts.info(context, 'Select at least one data type');
      return;
    }

    if (!mounted) return;
    setState(() => _loading = true);

    try {
      final boxNames = selectedGroups
          .expand((g) => BackupService.backupGroups[g]!)
          .toSet();

      final service = widget.ref.read(cloudBackupServiceProvider);
      await service.uploadBackup(
        boxNames: boxNames,
      );

      if (!mounted) return;
      setState(() => _progress = 1);

      TakionAlerts.success(context, 'Backup uploaded to Google Drive');
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        final message = e.toString().contains('Sign in')
            ? 'Please sign in with Google first'
            : 'Backup failed: $e';
        TakionAlerts.error(context, message);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}

Future<bool?> showCloudRestoreSheet(BuildContext context, WidgetRef ref) async {
  return TakionBottomSheet.show<bool>(
    context: context,
    title: 'Restore from Google Drive',
    child: _CloudRestoreSheet(ref: ref),
  );
}

class _CloudRestoreSheet extends ConsumerStatefulWidget {
  final WidgetRef ref;

  const _CloudRestoreSheet({required this.ref});

  @override
  ConsumerState<_CloudRestoreSheet> createState() => _CloudRestoreSheetState();
}

class _CloudRestoreSheetState extends ConsumerState<_CloudRestoreSheet> {
  bool _signedIn = false;
  List<BackupFileInfo>? _files;
  bool _loading = true;
  String? _error;
  bool _downloading = false;
  String _downloadStatus = '';

  @override
  void initState() {
    super.initState();
    _checkSignIn();
  }

  Future<void> _checkSignIn() async {
    final service = widget.ref.read(cloudBackupServiceProvider);
    final signedIn = service.isSignedIn;
    if (mounted) {
      setState(() => _signedIn = signedIn);
      if (signedIn) _loadFiles();
    }
  }

  Future<void> _signIn() async {
    final service = widget.ref.read(cloudBackupServiceProvider);
    try {
      final account = await service.signIn();
      if (mounted) {
        setState(() {
          _signedIn = account != null;
          if (account != null) {
            _loading = true;
            _loadFiles();
          }
        });
      }
    } catch (e) {
      if (mounted) TakionAlerts.error(context, e.toString());
    }
  }

  Future<void> _loadFiles() async {
    try {
      final service = widget.ref.read(cloudBackupServiceProvider);
      final files = await service.listBackups();
      if (mounted) {
        setState(() {
          _files = files;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_signedIn) return _buildSignInPrompt();
    if (_loading) {
      return const SizedBox(
        height: 120,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading backups...'),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return _buildError();
    }

    if (_files == null || _files!.isEmpty) {
      return _buildEmpty();
    }

    return _buildFileList();
  }

  Widget _buildSignInPrompt() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 12),
          Text(
            'Sign in with Google to restore your backup from Google Drive.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _signIn,
            icon: const Icon(Icons.login),
            label: const Text('Sign in with Google'),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            children: [
              Icon(Icons.error_outline,
                  size: 48, color: Theme.of(context).colorScheme.error),
              const SizedBox(height: 16),
              Text(
                'Failed to load backups: $_error',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        Row(
          children: [
            Expanded(
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(Icons.cloud_off_outlined,
              size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(height: 16),
          Text(
            'No backups found',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Upload a backup first using "Backup to Google Drive"',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildFileList() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...List.generate(_files!.length, (i) {
            final file = _files![i];
            final displayName = file.name.replaceAll('.tkbk', '');
            final size = file.size != null
                ? _formatSize(file.size!)
                : '';
            final date = file.createdTime != null
                ? DateFormat.yMMMd().format(file.createdTime!)
                : null;

            final subtitleParts = [date, size]
                .where((s) => s != null && s.isNotEmpty)
                .join(' · ');

            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: subtitleParts.isNotEmpty ? Text(subtitleParts) : null,
              trailing: IconButton(
                icon: const Icon(Icons.download_outlined),
                onPressed: _downloading
                    ? null
                    : () => _startRestore(file),
              ),
            );
          }),
          if (_downloading)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  const LinearProgressIndicator(),
                  const SizedBox(height: 8),
                  Text(
                    _downloadStatus,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _startRestore(BackupFileInfo file) async {
    if (!mounted) return;
    setState(() => _downloading = true);

    try {
      final service = widget.ref.read(cloudBackupServiceProvider);

      setState(() => _downloadStatus = 'Downloading...');
      final data = await service.downloadBackup(
        fileId: file.id,
      );

      if (!mounted) return;
      setState(() => _downloadStatus = 'Processing...');

      if (!mounted) return;

      final availableGroups = <String>{};
      for (final boxName in data.keys) {
        availableGroups.add(BackupService.groupForBox(boxName));
      }

      if (!mounted) return;

      final restored = await _showRestoreSheet(context, data, availableGroups);
      if (restored == true && mounted && context.mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        TakionAlerts.error(context, 'Restore failed: $e');
        setState(() => _downloading = false);
      }
    }
  }

  Future<bool?> _showRestoreSheet(
    BuildContext context,
    Map<String, List<Map<String, dynamic>>> data,
    Set<String> availableGroups,
  ) async {
    if (!context.mounted) return null;

    return TakionBottomSheet.show<bool>(
      context: context,
      title: 'Select Data to Restore',
      child: _CloudRestoreSelectSheet(
        ref: widget.ref,
        data: data,
        availableGroups: availableGroups,
      ),
    );
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

 }

class _CloudRestoreSelectSheet extends ConsumerStatefulWidget {
  final WidgetRef ref;
  final Map<String, List<Map<String, dynamic>>> data;
  final Set<String> availableGroups;

  const _CloudRestoreSelectSheet({
    required this.ref,
    required this.data,
    required this.availableGroups,
  });

  @override
  ConsumerState<_CloudRestoreSelectSheet> createState() =>
      _CloudRestoreSelectSheetState();
}

class _CloudRestoreSelectSheetState
    extends ConsumerState<_CloudRestoreSelectSheet> {
  static const _sensitiveGroups = {'User Profile'};
  late Map<String, bool> _selections;
  bool _restoring = false;
  String _statusText = '';
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _selections = {for (final g in widget.availableGroups) g: true};
  }

  List<MapEntry<String, List<String>>> get _sortedEntries {
    final entries = BackupService.backupGroups.entries
        .where((e) => widget.availableGroups.contains(e.key))
        .toList()
      ..sort((a, b) {
        final aSensitive = _sensitiveGroups.contains(a.key);
        final bSensitive = _sensitiveGroups.contains(b.key);
        if (aSensitive && !bSensitive) return 1;
        if (!aSensitive && bSensitive) return -1;
        return 0;
      });
    return entries;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              'Select the data to restore. Current data will be overwritten.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          ..._sortedEntries.map(
            (entry) {
              final group = entry.key;

              return SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _selections[group] ?? false,
                onChanged: _restoring
                    ? null
                    : (v) => setState(() => _selections[group] = v),
                title: Text(
                  group,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              );
            },
          ),
          const Divider(),
          if (_restoring) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  LinearProgressIndicator(
                      value: _progress > 0 ? _progress : null),
                  const SizedBox(height: 8),
                  Text(
                    _statusText,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed:
                      _restoring ? null : () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: _restoring ? null : _restore,
                  icon: const Icon(Icons.restore_page_outlined),
                  label: const Text('Restore'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _restore() async {
    final selectedGroups = _selections.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    if (selectedGroups.isEmpty) {
      TakionAlerts.info(context, 'Select at least one data type');
      return;
    }

    setState(() => _restoring = true);

    try {
      final boxNames = selectedGroups
          .expand((g) => BackupService.backupGroups[g]!)
          .where((b) => widget.data.containsKey(b))
          .toSet();

      final backupService = BackupService(
        widget.ref.read(hiveServiceProvider),
      );

      await backupService.restoreBoxes(
        data: widget.data,
        boxNames: boxNames,
        onProgress: (boxName, current, total) {
          if (mounted) {
            setState(() {
              _statusText =
                  '${BackupService.groupForBox(boxName)}: $current / $total';
              _progress = current / total;
            });
          }
        },
      );

      _invalidateProviders(boxNames);

      if (mounted) {
        final needsRestart = boxNames.contains('settings_box');

        if (needsRestart) {
          TakionAlerts.info(context,
              'Restore complete. Some restored settings will take effect after restarting the app.');
        } else {
          TakionAlerts.success(context, 'Backup restored successfully');
        }

        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        TakionAlerts.error(context, 'Restore failed: $e');
        setState(() => _restoring = false);
      }
    }
  }

  void _invalidateProviders(Set<String> boxNames) {
    for (final boxName in boxNames) {
      switch (boxName) {
        case 'settings_box':
          widget.ref.invalidate(settingsProvider);
          break;
        case 'local_pull_list_box':
          widget.ref.invalidate(currentWeekPullsProvider);
          break;
        case 'local_subscriptions_box':
          widget.ref.invalidate(activeSubscriptionsProvider);
          break;
        case 'local_library_items_box':
        case 'local_library_read_logs_box':
          widget.ref.invalidate(collectionStatsProvider);
          break;
      }
    }
  }
}
