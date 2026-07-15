import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/backup/backup_service.dart';
import 'package:takion/src/core/storage/hive_service.dart';
import 'package:takion/src/presentation/common/takion_alerts.dart';
import 'package:takion/src/presentation/components/components.dart';

Future<void> showCreateBackupSheet(BuildContext context, WidgetRef ref) {
  return TakionBottomSheet.show(
    context: context,
    title: 'Create Backup',
    child: _CreateBackupSheet(ref: ref),
  );
}

class _CreateBackupSheet extends ConsumerStatefulWidget {
  final WidgetRef ref;

  const _CreateBackupSheet({required this.ref});

  @override
  ConsumerState<_CreateBackupSheet> createState() => _CreateBackupSheetState();
}

class _CreateBackupSheetState extends ConsumerState<_CreateBackupSheet> {
  late Map<String, bool> _selections;
  bool _loading = false;
  double _progress = 0;

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

  static const _sensitiveGroups = {'User Profile'};

  @override
  void initState() {
    super.initState();
    _selections = {
      for (final group in BackupService.backupGroups.keys) group: true,
    };
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
              'Select the data to include in your backup.',
              style: Theme.of(context).textTheme.bodyMedium,
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
                        : 'Saving...',
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
                  onPressed: _loading ? null : _createBackup,
                  icon: const Icon(Icons.backup_outlined),
                  label: const Text('Create Backup'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _createBackup() async {
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

      final hiveService = widget.ref.read(hiveServiceProvider);
      final service = BackupService(hiveService);

      final data = await service.createBackupData(
        boxNames: boxNames,
      );

      if (!mounted) return;
      setState(() => _progress = 1);

      final date = DateTime.now();
      final fileName =
          'takion_backup_${date.year}-${_pad(date.month)}-${_pad(date.day)}.tkbk';

      final savedPath = await FilePicker.saveFile(
        fileName: fileName,
        bytes: data,
      );

      if (savedPath != null && mounted) {
        TakionAlerts.success(context, 'Backup saved to $savedPath');
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        TakionAlerts.error(context, 'Backup failed: $e');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _pad(int n) => n.toString().padLeft(2, '0');
}
