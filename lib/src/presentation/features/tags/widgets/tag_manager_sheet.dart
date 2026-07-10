import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities/tag.dart';
import 'package:takion/src/presentation/features/tags/providers/tag_provider.dart';
import 'package:takion/src/presentation/components/takion_bottom_sheet.dart';

void showTagManagerSheet(BuildContext context, WidgetRef ref) {
  final colors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.indigo,
    Colors.blue,
    Colors.teal,
    Colors.green,
    Colors.lime,
    Colors.orange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
  ];

  TakionBottomSheet.show<void>(
    context: context,
    title: 'Manage Tags',
    child: Consumer(
      builder: (context, ref, _) {
        final tagsAsync = ref.watch(allTagsProvider);

        return tagsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('$error')),
          data: (tags) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (tags.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Text('No tags yet. Create your first tag below.'),
                    )
                  else
                    ...tags.map(
                      (tag) => ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Color(tag.colorValue),
                          radius: 14,
                          child: Text(
                            tag.name[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(tag.name),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20),
                          onPressed: () async {
                            final ops = ref.read(tagOperationsProvider);
                            await ops.deleteTag(tag.id);
                          },
                        ),
                        onTap: () {
                          Navigator.of(context).pop();
                          _showRenameTagSheet(context, ref, tag);
                        },
                      ),
                    ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.add),
                    title: const Text('Add New Tag'),
                    onTap: () {
                      _showCreateTagSheet(context, ref, colors);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    ),
  );
}

void _showCreateTagSheet(
    BuildContext context, WidgetRef ref, List<Color> colors) {
  var nameController = TextEditingController();
  var selectedColor = colors[0];

  TakionBottomSheet.show<void>(
    context: context,
    title: 'New Tag',
    child: StatefulBuilder(
      builder: (context, setModalState) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Tag name',
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              Text(
                'Color',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: colors.map((color) {
                  final isSelected = color.toARGB32() == selectedColor.toARGB32();
                  return GestureDetector(
                    onTap: () => setModalState(() => selectedColor = color),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(
                                color: Theme.of(context).colorScheme.onSurface,
                                width: 2,
                              )
                            : null,
                      ),
                      child: isSelected
                          ? Icon(
                              Icons.check,
                              size: 18,
                              color: color.computeLuminance() > 0.5
                                  ? Colors.black
                                  : Colors.white,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    if (name.isEmpty) return;
                    final ops = ref.read(tagOperationsProvider);
                    await ops.createTag(name, selectedColor.toARGB32());
                    if (context.mounted) Navigator.of(context).pop();
                  },
                  child: const Text('Create'),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}

void _showRenameTagSheet(BuildContext context, WidgetRef ref, Tag tag) {
  var nameController = TextEditingController(text: tag.name);

  TakionBottomSheet.show<void>(
    context: context,
    title: 'Rename Tag',
    child: Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Tag name',
            ),
            autofocus: true,
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) return;
                final ops = ref.read(tagOperationsProvider);
                await ops.renameTag(tag.id, name);
                if (context.mounted) Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ),
        ],
      ),
    ),
  );
}
