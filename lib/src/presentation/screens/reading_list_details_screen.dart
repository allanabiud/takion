import 'dart:ui';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities/reading_list.dart';
import 'package:takion/src/core/sharing/reading_list_sharing_service.dart';
import 'package:takion/src/presentation/providers/reading_list_details_provider.dart';
import 'package:takion/src/presentation/providers/reading_lists_provider.dart';
import 'package:takion/src/presentation/widgets/add_reading_list_items_bottom_sheet.dart';
import 'package:takion/src/presentation/widgets/reading_list_cover.dart';
import 'package:takion/src/presentation/widgets/reading_list_grid_item.dart';
import 'package:takion/src/presentation/widgets/takion_alerts.dart';
import 'package:takion/src/presentation/providers/favorites_provider.dart';
import 'package:takion/src/presentation/providers/reading_list_item_status_provider.dart';
import 'package:takion/src/presentation/providers/repository_providers.dart';
import 'package:takion/src/presentation/providers/scrobble_issue_provider.dart';
import 'package:takion/src/presentation/providers/bulk_scrobble_provider.dart';
import 'package:takion/src/presentation/widgets/reading_list_timeline_tile.dart';
import 'package:takion/src/presentation/widgets/timeline_item_tile.dart';

@RoutePage()
class ReadingListDetailsScreen extends ConsumerStatefulWidget {
  final String listId;

  const ReadingListDetailsScreen({
    super.key,
    @PathParam('listId') required this.listId,
  });

  @override
  ConsumerState<ReadingListDetailsScreen> createState() => _ReadingListDetailsScreenState();
}

class _ReadingListDetailsScreenState extends ConsumerState<ReadingListDetailsScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  List<ReadingListItem>? _editingItems;
  final Set<String> _selectedIds = {};
  bool _isUpdating = false;
  String? _initialTitle;
  String? _initialDescription;
  List<ReadingListItem>? _initialItems;

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
        content: Text('Are you sure you want to remove ${_selectedIds.length} items?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        if (_editingItems != null) {
          _editingItems!.removeWhere((item) => _selectedIds.contains(item.targetId));
        }
        _selectedIds.clear();
      });
    }
  }

  void _markSelectedRead(bool read) async {
    final listValue = ref.read(readingListDetailsProvider(widget.listId));
    final list = listValue.value;
    if (list == null) return;

    setState(() {
      _isUpdating = true;
    });

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
                  final page = await metronRepo.getSeriesIssueList(id, page: currentPage);
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
          await ref.read(bulkScrobbleProvider.notifier).scrobbleIssues(
            issueIds: allIssueIdsToUpdate.toList(),
            markAsRead: read,
          );
        }

        setState(() {
          _editingItems = updatedItems;
          _selectedIds.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        TakionAlerts.error(context, 'Failed to update read status: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
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
  }

  void _showBulkActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Bulk Actions (${_selectedIds.length} items)',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.bookmark_added_outlined),
              title: const Text('Mark as Read'),
              onTap: () {
                Navigator.pop(context);
                _markSelectedRead(true);
              },
            ),
            ListTile(
              leading: const Icon(Icons.bookmark_remove_outlined),
              title: const Text('Mark as Unread'),
              onTap: () {
                Navigator.pop(context);
                _markSelectedRead(false);
              },
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  backgroundColor: _getRoleColor(context, role).withOpacity(0.1),
                  side: BorderSide(color: _getRoleColor(context, role)),
                  onPressed: () {
                    Navigator.pop(context);
                    _changeSelectedRole(role);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleFavorite(BuildContext context, WidgetRef ref, ReadingList list) async {
    try {
      final repository = ref.read(favoritesRepositoryProvider);
      final isFavorite = await repository.isReadingListFavorite(list.id);
      await repository.toggleReadingListFavorite(list.id);
      ref.invalidate(isReadingListFavoriteProvider(list.id));
      ref.invalidate(favoriteReadingListsListProvider);
      if (context.mounted) {
        TakionAlerts.success(
          context,
          !isFavorite ? 'Added to favorites' : 'Removed from favorites',
        );
      }
    } catch (e) {
      if (context.mounted) {
        TakionAlerts.error(context, 'Failed to update favorites: $e');
      }
    }
  }

  Color _getRoleColor(BuildContext context, ItemRole role) {
    final theme = Theme.of(context);
    switch (role) {
      case ItemRole.core: return Colors.red;
      case ItemRole.prologue: return Colors.orange;
      case ItemRole.tieIn: return Colors.blue;
      case ItemRole.epilogue: return Colors.purple;
      case ItemRole.standard: return theme.colorScheme.primary;
    }
  }

  Future<void> _confirmDelete(BuildContext context, ReadingList list) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reading List'),
        content: Text('Are you sure you want to delete "${list.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      ref.read(readingListsProvider.notifier).deleteList(list.id);
      if (context.mounted) {
        TakionAlerts.success(context, 'Reading list deleted');
        context.router.pop();
      }
    }
  }

  Widget buildHeader(BuildContext context, ReadingList list, double progress, int readCount, int totalCount, bool isEditing) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ReadingListCover(list: list, width: 100, height: 150),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isEditing) ...[
                      TextField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          hintText: 'Title',
                          isDense: true,
                          labelText: 'Title',
                        ),
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          hintText: 'Description',
                          isDense: true,
                          labelText: 'Description',
                        ),
                        style: theme.textTheme.bodyMedium,
                        maxLines: null,
                        minLines: 3,
                      ),
                    ] else ...[
                      Text(list.title, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                      if (list.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(list.description, style: theme.textTheme.bodyMedium),
                      ],
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$readCount / $totalCount ${list.contentType == ListContentType.series ? 'Series' : 'Issues'} Read', style: theme.textTheme.bodySmall),
              Text('${(progress * 100).toInt()}% Complete', style: theme.textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final listValue = ref.watch(readingListDetailsProvider(widget.listId));
    final isEditing = ref.watch(readingListEditModeProvider(widget.listId));
    final theme = Theme.of(context);

    return listValue.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (list) {
        if (list == null) return const Scaffold(body: Center(child: Text('List not found')));
        
        final displayItems = isEditing ? (_editingItems ?? list.items) : list.items;
        
        final statusAsync = ref.watch(readingListEffectiveStatusProvider(list));
        final status = statusAsync.value ?? (readCount: 0, totalCount: displayItems.length, progress: 0.0);
        
        final hasSelection = _selectedIds.isNotEmpty;

        return PopScope(
          canPop: !isEditing,
          onPopInvokedWithResult: (didPop, result) {
            if (isEditing && !didPop) {
              ref.read(readingListEditModeProvider(widget.listId).notifier).set(false);
              _editingItems = null;
            }
          },
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: isEditing ? theme.colorScheme.primaryContainer : null,
              leading: hasSelection 
                ? IconButton(
                    icon: const Icon(Icons.close), 
                    onPressed: () => setState(() => _selectedIds.clear())
                  )
                : null,
              title: hasSelection ? Text('${_selectedIds.length} selected') : (isEditing ? const Text('Editing List') : null),
              actions: [
                if (hasSelection) ...[
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () => _showBulkActions(context),
                    tooltip: 'Bulk actions',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: _deleteSelected,
                    color: theme.colorScheme.error,
                    tooltip: 'Remove from list',
                  ),
                ] else if (isEditing) ...[
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _confirmDelete(context, list),
                    color: theme.colorScheme.error,
                  ),
                ] else ...[
                  IconButton(
                    icon: const Icon(Icons.share_outlined),
                    onPressed: () => ref.read(readingListSharingServiceProvider).shareReadingList(list),
                  ),
                ],
              ],
            ),
            body: Stack(
              children: [
                list.isOrdered 
                  ? buildOrderedBody(context, list, displayItems, status.progress, status.readCount, status.totalCount, isEditing) 
                  : buildUnorderedBody(context, list, displayItems, status.progress, status.readCount, status.totalCount, isEditing),
                if (_isUpdating)
                  Container(
                    color: Colors.black.withOpacity(0.3),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
            bottomNavigationBar: BottomAppBar(
              child: Row(
                children: [
                  IconButton(
                    iconSize: 28,
                    style: isEditing 
                        ? IconButton.styleFrom(
                            backgroundColor: theme.colorScheme.secondaryContainer,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          )
                        : null,
                    icon: Icon(isEditing ? Icons.edit : Icons.edit_outlined),
                    color: isEditing ? theme.colorScheme.onSecondaryContainer : null,
                    onPressed: () {
                      if (!isEditing) {
                        _titleController.text = list.title;
                        _initialTitle = list.title;
                        _descriptionController.text = list.description;
                        _initialDescription = list.description;
                        _editingItems = List.from(list.items);
                        _initialItems = List.from(list.items);
                      } else {
                        _editingItems = null;
                        _initialItems = null;
                        _initialTitle = null;
                        _initialDescription = null;
                      }
                      ref.read(readingListEditModeProvider(widget.listId).notifier).toggle();
                    },
                  ),
                  if (!isEditing) ...[
                    Consumer(
                      builder: (context, ref, _) {
                        final isFavoriteAsync = ref.watch(isReadingListFavoriteProvider(list.id));
                        return IconButton(
                          iconSize: 28,
                          icon: isFavoriteAsync.when(
                            data: (isFavorite) => Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: isFavorite ? Colors.red : null,
                            ),
                            loading: () => const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            error: (_, __) => const Icon(Icons.favorite_border),
                          ),
                          onPressed: () => _toggleFavorite(context, ref, list),
                        );
                      },
                    ),
                  ],
                  const Spacer(),
                  isEditing
                      ? FloatingActionButton.extended(
                          onPressed: () async {
                            final updatedList = list.copyWith(
                              title: _titleController.text,
                              description: _descriptionController.text,
                              items: _editingItems ?? list.items,
                              updatedAt: DateTime.now(),
                            );
                            await ref.read(readingListsProvider.notifier).updateList(updatedList);
                            ref.invalidate(readingListDetailsProvider(widget.listId));
                            ref.read(readingListEditModeProvider(widget.listId).notifier).set(false);
                            _editingItems = null;
                            setState(() => _selectedIds.clear());
                            if (context.mounted) {
                              TakionAlerts.success(context, 'Reading list updated');
                            }
                          },
                          icon: const Icon(Icons.check),
                          label: const Text('Save'),
                        )
                      : FloatingActionButton(                          onPressed: () => showModalBottomSheet(
                              context: context, 
                              isScrollControlled: true, 
                              builder: (_) => AddReadingListItemsBottomSheet(list: list)
                            ),
                          child: const Icon(Icons.add),
                        ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildOrderedBody(BuildContext context, ReadingList list, List<ReadingListItem> items, double progress, int readCount, int totalCount, bool isEditing) {
    if (isEditing) {
      return ReorderableListView.builder(
        header: buildHeader(context, list, progress, readCount, totalCount, isEditing),
        itemCount: items.length,
        buildDefaultDragHandles: false,
        proxyDecorator: (Widget child, int index, Animation<double> animation) {
          return AnimatedBuilder(
            animation: animation,
            builder: (BuildContext context, Widget? child) {
              final double animValue = Curves.easeInOut.transform(animation.value);
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
            isEditing: isEditing,
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

    return ListView.builder(
      itemCount: items.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) return buildHeader(context, list, progress, readCount, totalCount, isEditing);
        final item = items[index - 1];
        final roleColor = _getRoleColor(context, item.role);
        final isSelected = _selectedIds.contains(item.targetId);

        return ReadingListTimelineTile(
          list: list.copyWith(items: items),
          index: index,
          item: item,
          roleColor: roleColor,
          isEditing: isEditing,
          isSelected: isSelected,
          onSelected: () => _toggleSelection(item.targetId),
          onRemove: () {
            setState(() {
              if (_editingItems != null) {
                _editingItems!.removeAt(index - 1);
              }
            });
          },
        );
      },
    );
  }

  Widget buildUnorderedBody(BuildContext context, ReadingList list, List<ReadingListItem> items, double progress, int readCount, int totalCount, bool isEditing) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: buildHeader(context, list, progress, readCount, totalCount, isEditing)),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, 
              childAspectRatio: 0.45, 
              crossAxisSpacing: 12, 
              mainAxisSpacing: 12
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = items[index];
                final isSelected = _selectedIds.contains(item.targetId);
                return ReadingListGridItem(
                  item: item, 
                  onTap: () {
                    if (isEditing) {
                      _toggleSelection(item.targetId);
                    }
                  },
                  isEditing: isEditing,
                  isSelected: isSelected,
                  onRemove: () {
                    setState(() {
                      if (_editingItems != null) {
                        _editingItems!.removeAt(index);
                      }
                    });
                  },
                );
              }, 
              childCount: items.length
            ),
          ),
        ),
      ],
    );
  }
}
