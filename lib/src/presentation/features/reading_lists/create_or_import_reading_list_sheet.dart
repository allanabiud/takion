import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/sharing/reading_list_sharing_service.dart';
import 'package:takion/src/domain/entities/entities.dart';
import 'package:takion/src/presentation/common/takion_alerts.dart';
import 'package:takion/src/presentation/components/components.dart';
import 'package:takion/src/presentation/features/reading_lists/providers/reading_lists_provider.dart';
import 'package:uuid/uuid.dart';

enum _CreateOrImportMode { create, import }

class CreateOrImportReadingListSheet extends ConsumerStatefulWidget {
  final ListContentType? initialContentType;
  final bool showModeToggle;

  const CreateOrImportReadingListSheet({
    super.key,
    this.initialContentType,
    this.showModeToggle = true,
  });

  static Future<void> show(BuildContext context) {
    return TakionBottomSheet.show<void>(
      context: context,
      title: 'Create/Import Reading List',
      child: CreateOrImportReadingListSheet(showModeToggle: true),
    );
  }

  static Future<void> showCreateOnly(
    BuildContext context, {
    ListContentType? initialContentType,
  }) {
    return TakionBottomSheet.show<void>(
      context: context,
      title: 'Create Reading List',
      child: CreateOrImportReadingListSheet(
        showModeToggle: false,
        initialContentType: initialContentType,
      ),
    );
  }

  @override
  ConsumerState<CreateOrImportReadingListSheet> createState() =>
      _CreateOrImportReadingListSheetState();
}

class _CreateOrImportReadingListSheetState
    extends ConsumerState<CreateOrImportReadingListSheet> {
  _CreateOrImportMode _mode = _CreateOrImportMode.create;

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  bool _isOrdered = true;
  late ListContentType _contentType;

  @override
  void initState() {
    super.initState();
    _contentType = widget.initialContentType ?? ListContentType.issue;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submitCreate() {
    if (!_formKey.currentState!.validate()) return;

    final newList = ReadingList(
      id: const Uuid().v4(),
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      isOrdered: _isOrdered,
      contentType: _contentType,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      items: [],
    );

    ref.read(readingListsProvider.notifier).addList(newList);
    TakionAlerts.success(context, 'Reading List Created');
    Navigator.pop(context);
  }

  Future<void> _importFile() async {
    final list = await ref
        .read(readingListSharingServiceProvider)
        .importReadingList();
    if (list != null) {
      final existingLists = ref.read(readingListsProvider).value ?? [];
      if (existingLists.any((l) => l.id == list.id)) {
        if (mounted) {
          TakionAlerts.error(context, 'Reading list already exists');
        }
        return;
      }
      await ref.read(readingListsProvider.notifier).addList(list);
      if (mounted) {
        TakionAlerts.success(context, 'Reading List Imported');
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        TakionAlerts.error(context, 'Failed to import reading list');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final showToggle = widget.showModeToggle;

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showToggle) ...[
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<_CreateOrImportMode>(
                segments: const [
                  ButtonSegment(
                    value: _CreateOrImportMode.create,
                    label: Text('Create'),
                  ),
                  ButtonSegment(
                    value: _CreateOrImportMode.import,
                    label: Text('Import'),
                  ),
                ],
                selected: {_mode},
                onSelectionChanged: (v) => setState(() => _mode = v.first),
              ),
            ),
            const SizedBox(height: 24),
          ],
          if (_mode == _CreateOrImportMode.create) _buildCreateForm(),
          if (_mode == _CreateOrImportMode.import) _buildImportSection(),
        ],
      ),
    );
  }

  Widget _buildCreateForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Title',
              hintText: 'e.g. Batman: Knightfall',
            ),
            validator: (v) => v?.isEmpty == true ? 'Required' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descController,
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'Optional summary...',
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          const Text(
            'Content Type',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<ListContentType>(
              segments: const [
                ButtonSegment(
                  value: ListContentType.issue,
                  label: Text('ISSUES'),
                ),
                ButtonSegment(
                  value: ListContentType.series,
                  label: Text('SERIES'),
                ),
              ],
              selected: {_contentType},
              onSelectionChanged: (newSelection) =>
                  setState(() => _contentType = newSelection.first),
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Ordered List'),
            value: _isOrdered,
            onChanged: (v) => setState(() => _isOrdered = v),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _submitCreate,
              child: const Text('Create List'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImportSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _importFile,
            icon: const Icon(Icons.file_upload_outlined),
            label: const Text('Select File'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Import a .takion reading list file',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
