import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities/reading_list.dart';
import 'package:takion/src/presentation/providers/repository_providers.dart';
import 'package:takion/src/presentation/components/takion_bottom_sheet.dart';
import 'package:takion/src/presentation/features/reading_lists/create_or_import_reading_list_sheet.dart';
import 'package:takion/src/presentation/features/reading_lists/reading_list_card.dart';
import 'package:takion/src/presentation/features/reading_lists/providers/reading_lists_provider.dart';
import 'package:takion/src/presentation/common/takion_alerts.dart';

class AddToReadingListBottomSheet extends ConsumerStatefulWidget {
  final String targetId;
  final bool isSeries;

  const AddToReadingListBottomSheet({
    super.key,
    required this.targetId,
    required this.isSeries,
  });

  static Future<void> show({
    required BuildContext context,
    required String targetId,
    required bool isSeries,
  }) {
    return TakionBottomSheet.show<void>(
      context: context,
      title: 'Add to reading list',
      child: AddToReadingListBottomSheet(
        targetId: targetId,
        isSeries: isSeries,
      ),
    );
  }

  @override
  ConsumerState<AddToReadingListBottomSheet> createState() =>
      _AddToReadingListBottomSheetState();
}

class _AddToReadingListBottomSheetState
    extends ConsumerState<AddToReadingListBottomSheet> {
  String _searchQuery = '';
  final Set<String> _selectedListIds = {};
  bool _isAdding = false;

  String get _normalizedTargetId {
    final normalized = widget.targetId.trim().toLowerCase();
    final expectedPrefix = widget.isSeries ? 'series-' : 'issue-';
    if (normalized.startsWith(expectedPrefix)) return normalized;

    final alternatePrefix = widget.isSeries ? 'issue-' : 'series-';
    if (normalized.startsWith(alternatePrefix)) {
      return '$expectedPrefix${normalized.substring(alternatePrefix.length)}';
    }

    return '$expectedPrefix$normalized';
  }

  Future<void> _addItems() async {
    setState(() => _isAdding = true);
    try {
      final repository = ref.read(readingListRepositoryProvider);
      int addedCount = 0;
      int skippedCount = 0;

      for (final listId in _selectedListIds) {
        final alreadyExists = await repository.isItemInList(
          listId,
          _normalizedTargetId,
        );
        if (alreadyExists) {
          skippedCount++;
          continue;
        }

        await repository.addItemToList(
          listId,
          ReadingListItem(
            targetId: _normalizedTargetId,
            isSeries: widget.isSeries,
            role: ItemRole.standard,
            isRead: false,
          ),
        );
        addedCount++;
      }

      ref.invalidate(readingListsProvider);
      if (mounted) {
        if (addedCount == 0 && skippedCount > 0) {
          TakionAlerts.info(
            context,
            'Already in all selected lists',
          );
          Navigator.of(context).pop();
          return;
        }

        if (skippedCount > 0) {
          TakionAlerts.success(
            context,
            'Added to $addedCount List(s)',
          );
        } else {
          TakionAlerts.success(
            context,
            'Added to Reading List(s)',
          );
        }
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        TakionAlerts.error(context, 'Failed to add to reading list: $e');
      }
    } finally {
      if (mounted) setState(() => _isAdding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final readingListsAsync = ref.watch(readingListsProvider);
    final contentType = widget.isSeries
        ? ListContentType.series
        : ListContentType.issue;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        readingListsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Text('Error: $err'),
          data: (lists) {
            final contentTypeLists = lists
                .where((list) => list.contentType == contentType)
                .toList();

            if (contentTypeLists.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.list_alt_outlined,
                      size: 56,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Reading Lists yet.',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create one to get started.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {
                          CreateOrImportReadingListSheet.showCreateOnly(
                            context,
                            initialContentType: contentType,
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Create Reading List'),
                      ),
                    ),
                  ],
                ),
              );
            }

            final filteredLists = contentTypeLists
                .where(
                  (list) => list.title.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ),
                )
                .toList();

            if (_searchQuery.isNotEmpty && filteredLists.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'No matching lists found',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              );
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: const InputDecoration(
                    hintText: 'Search reading lists',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
                const SizedBox(height: 16),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.4,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: filteredLists.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final list = filteredLists[index];
                      final isSelected = _selectedListIds.contains(list.id);
                      final alreadyExists = list.items.any(
                        (item) => item.targetId == _normalizedTargetId,
                      );

                      return ReadingListCard(
                        list: list,
                        compact: true,
                        flat: true,
                        alreadyExists: alreadyExists,
                        onTap: () {
                          if (alreadyExists) {
                            TakionAlerts.info(
                              context,
                              'Already in this list',
                            );
                            return;
                          }
                          setState(() {
                            if (isSelected) {
                              _selectedListIds.remove(list.id);
                            } else {
                              _selectedListIds.add(list.id);
                            }
                          });
                        },
                        isSelected: isSelected,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed:
                        _isAdding || _selectedListIds.isEmpty ? null : _addItems,
                    child: _isAdding
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Add'),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
