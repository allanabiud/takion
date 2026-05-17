import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities/reading_list.dart';
import 'package:takion/src/data/repositories/reading_list_repository_impl.dart';
import 'package:takion/src/presentation/components/takion_bottom_sheet.dart';
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

  Future<void> _addItems() async {
    setState(() => _isAdding = true);
    try {
      final repository = ref.read(readingListRepositoryProvider);
      for (final listId in _selectedListIds) {
        await repository.addItemToList(
          listId,
          ReadingListItem(
            targetId: widget.targetId,
            isSeries: widget.isSeries,
            role: ItemRole.standard,
            isRead: false,
          ),
        );
      }
      ref.invalidate(readingListsProvider);
      if (mounted) {
        TakionAlerts.success(context, 'Successfully added to reading list(s)');
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
    final contentType =
        widget.isSeries ? ListContentType.series : ListContentType.issue;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          onChanged: (value) => setState(() => _searchQuery = value),
          decoration: InputDecoration(
            hintText: 'Search reading lists',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            filled: true,
          ),
        ),
        const SizedBox(height: 16),
        readingListsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Text('Error: $err'),
          data: (lists) {
            final filteredLists = lists
                .where((list) => list.contentType == contentType)
                .where((list) => list.title
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()))
                .toList();

            if (filteredLists.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text('No matching lists found'),
                ),
              );
            }

            return ConstrainedBox(
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
                  return ReadingListCard(
                    list: list,
                    compact: true,
                    flat: true,
                    onTap: () {
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
            );
          },
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.bottomRight,
          child: FilledButton(
            onPressed: _isAdding || _selectedListIds.isEmpty ? null : _addItems,
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
  }
}
