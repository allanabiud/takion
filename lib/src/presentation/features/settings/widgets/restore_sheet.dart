import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/backup/backup_service.dart';
import 'package:takion/src/core/storage/hive_service.dart';
import 'package:takion/src/presentation/common/takion_alerts.dart';
import 'package:takion/src/presentation/components/takion_bottom_sheet.dart';
import 'package:takion/src/presentation/features/library/providers/collection_stats_provider.dart';
import 'package:takion/src/presentation/features/library/providers/pulls_provider.dart';
import 'package:takion/src/presentation/features/series/providers/subscriptions_provider.dart';
import 'package:takion/src/presentation/features/settings/providers/settings_provider.dart';

Future<bool?> showRestoreBackupSheet(BuildContext context, WidgetRef ref) async {
  final result = await FilePicker.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['tkbk'],
  );

  if (result == null || result.files.isEmpty) return null;
  final filePath = result.files.single.path;
  if (filePath == null) return null;

  if (!context.mounted) return null;

  final hiveService = ref.read(hiveServiceProvider);
  final service = BackupService(hiveService);

  return TakionBottomSheet.show<bool>(
    context: context,
    title: 'Restore from Backup',
    child: _RestoreSheet(
      ref: ref,
      service: service,
      filePath: filePath,
    ),
  );
}

class _RestoreSheet extends ConsumerStatefulWidget {
  final WidgetRef ref;
  final BackupService service;
  final String filePath;

  const _RestoreSheet({
    required this.ref,
    required this.service,
    required this.filePath,
  });

  @override
  ConsumerState<_RestoreSheet> createState() => _RestoreSheetState();
}

class _RestoreSheetState extends ConsumerState<_RestoreSheet> {
  _RestorePhase _phase = _RestorePhase.loading;
  String _loadError = '';
  BackupManifest? _manifest;
  Map<String, List<Map<String, dynamic>>>? _data;
  late Map<String, bool> _selections;
  bool _restoring = false;
  String _statusText = '';
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  List<MapEntry<String, List<String>>> get _sortedEntries {
    if (_manifest == null) return [];
    final availableGroups = <String>{};
    for (final boxName in _manifest!.boxNames) {
      availableGroups.add(BackupService.groupForBox(boxName));
    }
    final entries = BackupService.backupGroups.entries
        .where((e) => availableGroups.contains(e.key))
        .toList()
      ..sort((a, b) {
        return 0;
      });
    return entries;
  }

  Future<void> _load() async {
    try {
      final manifest = await widget.service.loadManifest(
        filePath: widget.filePath,
      );
      final data = await widget.service.readBackupData(
        filePath: widget.filePath,
      );

      if (!mounted) return;

      final availableGroups = <String>{};
      for (final boxName in manifest.boxNames) {
        availableGroups.add(BackupService.groupForBox(boxName));
      }

      setState(() {
        _manifest = manifest;
        _data = data;
        _selections = {for (final g in availableGroups) g: true};
        _phase = _RestorePhase.selecting;
      });
    } catch (e) {
      if (!mounted) return;
      final message = e is FormatException
          ? 'Invalid backup file'
          : 'Failed to read backup: $e';
      setState(() {
        _loadError = message;
        _phase = _RestorePhase.error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (_phase) {
      case _RestorePhase.loading:
        return _buildLoading();
      case _RestorePhase.error:
        return _buildError();
      case _RestorePhase.selecting:
        return _buildSelecting();
    }
  }

  Widget _buildLoading() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Reading backup...'),
          ],
        ),
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
                _loadError,
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

  Widget _buildSelecting() {
    final manifest = _manifest!;
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Backup from ${_formatDate(manifest.createdAt)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
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
          .where((b) => _manifest!.boxNames.contains(b))
          .toSet();

      await widget.service.restoreBoxes(
        data: _data!,
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

  String _formatDate(DateTime date) {
    return '${date.year}-${_pad(date.month)}-${_pad(date.day)}';
  }

  String _pad(int n) => n.toString().padLeft(2, '0');
}

enum _RestorePhase { loading, error, selecting }
