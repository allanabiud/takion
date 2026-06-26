import 'dart:ui';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities/reading_list.dart';
import 'package:takion/src/presentation/features/reading_lists/providers/reading_list_details_provider.dart';
import 'package:takion/src/presentation/features/reading_lists/providers/reading_lists_provider.dart';
import 'package:takion/src/presentation/features/reading_lists/reading_list_grid_item.dart';
import 'package:takion/src/presentation/features/reading_lists/reading_list_timeline_tile.dart';
import 'package:takion/src/presentation/common/takion_alerts.dart';
import 'package:takion/src/presentation/components/takion_bottom_sheet.dart';
import 'package:takion/src/presentation/features/issues/providers/bulk_scrobble_provider.dart';
import 'package:takion/src/presentation/providers/repository_providers.dart';

@RoutePage()
class ReadingListEditScreen extends ConsumerStatefulWidget {
  final String listId;

  const ReadingListEditScreen({
    super.key,
    @PathParam('listId') required this.listId,
  });

  @override
  ConsumerState<ReadingListEditScreen> createState() =>
      _ReadingListEditScreenState();
}

class _ReadingListEditScreenState extends ConsumerState<ReadingListEditScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  List<ReadingListItem>? _editingItems;
  final Set<String> _selectedIds = {};
  bool _isUpdating = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _titleController.addListener(() => setState(() {}));
    _descriptionController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  Future<void> _deleteSelected() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Selected Items'),
        content: Text(
          'Are you sure you want to remove ${_selectedIds.length} items?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
              foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        if (_editingItems != null) {
          _editingItems!.removeWhere(
            (item) => _selectedIds.contains(item.targetId),
          );
        }
        _selectedIds.clear();
      });
      if (mounted) {
        TakionAlerts.success(context, 'Items removed from list');
      }
    }
  }

  void _markSelectedRead(bool read) async {
    final listValue = ref.read(readingListDetailsProvider(widget.listId));
    final list = listValue.value;
    if (list == null) return;

    setState(() => _isUpdating = true);

    try {
      if (_editingItems != null) {
        final updatedItems = List<ReadingListItem>.from(_editingItems!);
        final metronRepo = ref.read(metronRepositoryProvider);
        final allIssueIdsToUpdate = <int>{};

        for (int i = 0; i < updatedItems.length; i++) {
          final item = updatedItems[i];
          if (_selectedIds.contains(item.targetId)) {
            final idString = item.targetId.replaceAll(RegExp(r'^.*-'), '');
            final id = int.tryParse(idString) ?? 0;

            if (item.isSeries) {
              if (id > 0) {
                int currentPage = 1;
                bool hasNext = true;
                while (hasNext) {
                  final page = await metronRepo.getSeriesIssueList(
                    id,
                    page: currentPage,
                  );
                  for (final issue in page.results) {
                    if (issue.id != null) allIssueIdsToUpdate.add(issue.id!);
                  }
                  hasNext = page.next != null;
                  currentPage++;
                  if (currentPage > 20) break;
                }
              }
            } else {
              if (id > 0) {
                allIssueIdsToUpdate.add(id);
              }
            }
            updatedItems[i] = item.copyWith(isRead: read);
          }
        }

        if (allIssueIdsToUpdate.isNotEmpty) {
          await ref
              .read(bulkScrobbleProvider.notifier)
              .scrobbleIssues(
                issueIds: allIssueIdsToUpdate.toList(),
                markAsRead: read,
              );
        }

        setState(() {
          _editingItems = updatedItems;
          _selectedIds.clear();
        });

        if (mounted) {
          TakionAlerts.success(
            context,
            read ? 'Marked as read' : 'Marked as unread',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        TakionAlerts.error(context, 'Failed to update read status: $e');
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  void _changeSelectedRole(ItemRole role) {
    setState(() {
      if (_editingItems != null) {
        _editingItems = _editingItems!.map((item) {
          if (_selectedIds.contains(item.targetId)) {
            return item.copyWith(role: role);
          }
          return item;
        }).toList();
      }
      _selectedIds.clear();
    });
    TakionAlerts.success(context, 'Role updated for selected items');
  }

  void _showBulkActions(BuildContext context) {
    TakionBottomSheet.show(
      context: context,
      title: 'Bulk Actions (${_selectedIds.length} items)',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.bookmark_added_outlined),
            title: const Text('Mark as Read'),
            onTap: () {
              Navigator.pop(context);
              _markSelectedRead(true);
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.bookmark_remove_outlined),
            title: const Text('Mark as Unread'),
            onTap: () {
              Navigator.pop(context);
              _markSelectedRead(false);
            },
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Change Role',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ItemRole.values.map((role) {
              String label = role.name.toUpperCase();
              if (role == ItemRole.tieIn) label = 'TIE-IN';

              return ActionChip(
                label: Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                backgroundColor: _getRoleColor(context, role)
                    .withValues(alpha: 0.1),
                side: BorderSide(color: _getRoleColor(context, role)),
                onPressed: () {
                  Navigator.pop(context);
                  _changeSelectedRole(role);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(BuildContext context, ItemRole role) {
    final theme = Theme.of(context);
    switch (role) {
      case ItemRole.core:
        return Colors.red;
      case ItemRole.prologue:
        return Colors.orange;
      case ItemRole.tieIn:
        return Colors.blue;
      case ItemRole.epilogue:
        return Colors.purple;
      case ItemRole.standard:
        return theme.colorScheme.primary;
    }
  }

  Widget _buildEditHeader(ReadingList list) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'List Title',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
            ),
            maxLines: null,
            minLines: 2,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final listValue = ref.watch(readingListDetailsProvider(widget.listId));
    final theme = Theme.of(context);

    return listValue.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (list) {
        if (list == null) {
          return const Scaffold(body: Center(child: Text('List not found')));
        }

        if (!_initialized) {
          _titleController.text = list.title;
          _descriptionController.text = list.description;
          _editingItems ??= List.from(list.items);
          _initialized = true;
        }

        final displayItems = _editingItems!;
        final hasSelection = _selectedIds.isNotEmpty;

        return PopScope(
          canPop: !hasSelection,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) {
              setState(() => _selectedIds.clear());
            }
          },
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: hasSelection
                  ? theme.colorScheme.secondaryContainer
                  : theme.colorScheme.primaryContainer,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: hasSelection
                    ? () => setState(() => _selectedIds.clear())
                    : () => context.router.maybePop(),
              ),
              title: hasSelection
                  ? Text(
                      '${_selectedIds.length} Selected',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                    )
                  : Column(
                      children: [
                        Text(
                          'Editing List',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                        Text(
                          list.title,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer
                                .withValues(alpha: 0.7),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
              centerTitle: true,
              actions: [
                if (hasSelection)
                  IconButton(
                    icon: Icon(
                      _selectedIds.length == displayItems.length
                          ? Icons.deselect_rounded
                          : Icons.select_all_rounded,
                    ),
                    onPressed: () {
                      if (_selectedIds.length == displayItems.length) {
                        _selectedIds.clear();
                      } else {
                        _selectedIds
                          ..clear()
                          ..addAll(
                            displayItems.map((item) => item.targetId),
                          );
                      }
                      setState(() {});
                    },
                    tooltip: _selectedIds.length == displayItems.length
                        ? 'Deselect all'
                        : 'Select all',
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.select_all_rounded),
                    onPressed: () {
                      _selectedIds
                        ..clear()
                        ..addAll(
                          displayItems.map((item) => item.targetId),
                        );
                      setState(() {});
                    },
                    tooltip: 'Select all items',
                  ),
              ],
            ),
            body: Stack(
              children: [
                list.isOrdered
                    ? _buildOrderedBody(displayItems, list)
                    : _buildUnorderedBody(displayItems, list),
                if (_isUpdating)
                  Container(
                    color: Colors.black.withValues(alpha: 0.3),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
            floatingActionButton: AnimatedSlide(
              offset: hasSelection ? const Offset(0, 2) : Offset.zero,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: AnimatedOpacity(
                opacity: hasSelection ? 0 : 1,
                duration: const Duration(milliseconds: 250),
                child: IgnorePointer(
                  ignoring: hasSelection,
                  child: FloatingActionButton.extended(
                    elevation: 0,
                    onPressed: () async {
                      final updatedList = list.copyWith(
                        title: _titleController.text,
                        description: _descriptionController.text,
                        items: _editingItems ?? list.items,
                        updatedAt: DateTime.now(),
                      );
                      await ref
                          .read(readingListsProvider.notifier)
                          .updateList(updatedList);
                      ref.invalidate(
                        readingListDetailsProvider(widget.listId),
                      );
                      if (context.mounted) {
                        TakionAlerts.success(context, 'Changes saved');
                        context.router.maybePop();
                      }
                    },
                    icon: const Icon(Icons.save_rounded),
                    label: const Text('Save'),
                  ),
                ),
              ),
            ),
            bottomNavigationBar: AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: hasSelection
                  ? BottomAppBar(
                      height: 72,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton.icon(
                            onPressed: _deleteSelected,
                            icon: Icon(Icons.delete_outline, size: 20, color: theme.colorScheme.error),
                            label: Text('Delete Selected', style: TextStyle(color: theme.colorScheme.error)),
                            style: TextButton.styleFrom(
                              backgroundColor: theme.colorScheme.errorContainer.withValues(alpha: 0.5),
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          TextButton.icon(
                            onPressed: () => _showBulkActions(context),
                            icon: Icon(Icons.playlist_add_check_rounded, size: 20, color: theme.colorScheme.primary),
                            label: Text('Bulk Actions', style: TextStyle(color: theme.colorScheme.primary)),
                            style: TextButton.styleFrom(
                              backgroundColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox(height: 0),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrderedBody(
    List<ReadingListItem> items,
    ReadingList list,
  ) {
    return ReorderableListView.builder(
      header: _buildEditHeader(list),
      itemCount: items.length,
      buildDefaultDragHandles: false,
      proxyDecorator: (Widget child, int index, Animation<double> animation) {
        return AnimatedBuilder(
          animation: animation,
          builder: (BuildContext context, Widget? child) {
            final double animValue = Curves.easeInOut.transform(
              animation.value,
            );
            final double elevation = lerpDouble(0, 8, animValue)!;
            final theme = Theme.of(context);
            return Theme(
              data: theme.copyWith(
                colorScheme: theme.colorScheme.copyWith(
                  surfaceContainer: theme.colorScheme.primaryContainer,
                ),
              ),
              child: Material(
                elevation: elevation,
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                child: child,
              ),
            );
          },
          child: child,
        );
      },
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) newIndex--;
          final item = _editingItems!.removeAt(oldIndex);
          _editingItems!.insert(newIndex, item);
        });
      },
      itemBuilder: (context, index) {
        final item = items[index];
        final roleColor = _getRoleColor(context, item.role);
        final isSelected = _selectedIds.contains(item.targetId);
        return ReadingListTimelineTile(
          key: ValueKey(item.targetId),
          list: list.copyWith(items: items),
          index: index + 1,
          item: item,
          roleColor: roleColor,
          isEditing: true,
          isSelected: isSelected,
          onSelected: () => _toggleSelection(item.targetId),
          onRemove: () {
            setState(() {
              if (_editingItems != null) {
                _editingItems!.removeAt(index);
              }
            });
          },
        );
      },
    );
  }

  Widget _buildUnorderedBody(
    List<ReadingListItem> items,
    ReadingList list,
  ) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _buildEditHeader(list),
        ),
        if (items.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: Text('This reading list is empty.')),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.45,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final item = items[index];
                final isSelected = _selectedIds.contains(item.targetId);
                return ReadingListGridItem(
                  item: item,
                  onTap: () => _toggleSelection(item.targetId),
                  isEditing: true,
                  isSelected: isSelected,
                  onRemove: () {
                    setState(() {
                      if (_editingItems != null) {
                        _editingItems!.removeAt(index);
                      }
                    });
                  },
                );
              }, childCount: items.length),
            ),
          ),
      ],
    );
  }
}
