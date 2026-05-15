import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities/reading_list.dart';
import 'package:takion/src/presentation/widgets/takion_alerts.dart';
import 'package:takion/src/presentation/providers/reading_lists_provider.dart';
import 'package:uuid/uuid.dart';

class CreateReadingListBottomSheet extends ConsumerStatefulWidget {
  const CreateReadingListBottomSheet({super.key});

  @override
  ConsumerState<CreateReadingListBottomSheet> createState() => _CreateReadingListBottomSheetState();
}

class _CreateReadingListBottomSheetState extends ConsumerState<CreateReadingListBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  
  bool _isOrdered = true;
  ListContentType _contentType = ListContentType.series;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submit() {
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
    TakionAlerts.success(context, 'Reading list created successfully');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 24,
        left: 24,
        right: 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create Reading List',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  hintText: 'e.g. Batman: Knightfall',
                  border: OutlineInputBorder(borderSide: BorderSide(color: primaryColor)),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: primaryColor)),
                ),
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'Optional summary...',
                  border: OutlineInputBorder(borderSide: BorderSide(color: primaryColor)),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: primaryColor)),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              const Text('Content Type', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<ListContentType>(
                  segments: const [
                    ButtonSegment(value: ListContentType.series, label: Text('SERIES')),
                    ButtonSegment(value: ListContentType.issue, label: Text('ISSUES')),
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
              const SizedBox(height: 12),

              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: _submit,
                  child: const Text('Create List'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
