import 'dart:ui' show ImageFilter;

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/domain/entities/issue_details.dart';
import 'package:takion/src/domain/entities/reading_list.dart';
import 'package:takion/src/core/sharing/reading_list_sharing_service.dart';
import 'package:takion/src/presentation/features/reading_lists/providers/reading_list_details_provider.dart';
import 'package:takion/src/presentation/features/reading_lists/providers/reading_lists_provider.dart';
import 'package:takion/src/presentation/features/reading_lists/add_reading_list_items_bottom_sheet.dart';
import 'package:takion/src/presentation/features/reading_lists/reading_list_cover.dart';
import 'package:takion/src/presentation/features/reading_lists/reading_list_grid_item.dart';
import 'package:takion/src/presentation/common/takion_alerts.dart';
import 'package:takion/src/presentation/common/empty_content_state.dart';
import 'package:takion/src/presentation/features/library/providers/favorites_provider.dart';
import 'package:takion/src/presentation/features/reading_lists/providers/reading_list_item_metadata_provider.dart';
import 'package:takion/src/presentation/features/reading_lists/providers/reading_list_item_status_provider.dart';
import 'package:takion/src/presentation/features/reading_lists/reading_list_timeline_tile.dart';
import 'package:takion/src/presentation/features/series/providers/series_cover_provider.dart';
import 'package:takion/src/presentation/providers/repository_providers.dart';

@RoutePage()
class ReadingListDetailsScreen extends ConsumerStatefulWidget {
  final String listId;

  const ReadingListDetailsScreen({
    super.key,
    @PathParam('listId') required this.listId,
  });

  @override
  ConsumerState<ReadingListDetailsScreen> createState() =>
      _ReadingListDetailsScreenState();
}

enum _ReadingListDetailsMenuAction { edit, share, delete }

class _ReadingListDetailsScreenState
    extends ConsumerState<ReadingListDetailsScreen> {
  bool _isDescriptionExpanded = false;

  void _openReadingListItemDetails(ReadingListItem item) {
    final idString = item.targetId.replaceAll(RegExp(r'^.*-'), '');
    final id = int.tryParse(idString);
    if (id == null || id <= 0) return;

    if (item.isSeries) {
      context.pushRoute(SeriesDetailsRoute(seriesId: id));
      return;
    }
    context.pushRoute(IssueDetailsRoute(issueId: id));
  }

  Future<void> _toggleFavorite(
    BuildContext context,
    WidgetRef ref,
    ReadingList list,
  ) async {
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

  Future<void> _confirmDelete(BuildContext context, ReadingList list) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reading List'),
        content: Text('Are you sure you want to delete "${list.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
              foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
            ),
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.delete_outline, size: 22),
            label: const Text('Delete'),
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

  Widget _buildSheetHeader(
    ReadingList list,
    double progress,
    int readCount,
    int totalCount,
  ) {
    final theme = Theme.of(context);
    final hasDescription = list.description.trim().isNotEmpty;
    final isFavoriteAsync = ref.watch(isReadingListFavoriteProvider(list.id));
    final isFavorite = isFavoriteAsync.value ?? false;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildDragHandle(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                list.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (hasDescription) ...[
                const SizedBox(height: 6),
                AnimatedSize(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  alignment: Alignment.topCenter,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_isDescriptionExpanded)
                        Text(
                          list.description,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      GestureDetector(
                        onTap: () => setState(() {
                          _isDescriptionExpanded = !_isDescriptionExpanded;
                        }),
                        child: Text(
                          _isDescriptionExpanded
                              ? 'Hide description'
                              : 'Show description',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$readCount / $totalCount ${list.contentType == ListContentType.series ? 'Series' : 'Issues'} Read',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progress == 1.0 ? Colors.green : theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: Theme.of(context).textTheme.titleMedium,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () =>
                          AddReadingListItemsBottomSheet.show(context, list),
                      icon: const Icon(Icons.add, size: 22),
                      label: const Text('Add Items'),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    flex: 1,
                    child: FilledButton.tonal(
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        iconSize: 28,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => _toggleFavorite(context, ref, list),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    flex: 1,
                    child: FilledButton.tonal(
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        iconSize: 28,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => ref
                          .read(readingListSharingServiceProvider)
                          .shareReadingList(list),
                      child: const Icon(Icons.share),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(ReadingList list) {
    final theme = Theme.of(context);

    String? firstCoverUrl;
    if (list.items.isNotEmpty) {
      final firstItem = list.items.first;
      if (firstItem.isSeries) {
        final id = int.tryParse(firstItem.targetId.replaceAll(RegExp(r'\D'), '')) ?? 0;
        final coverAsync = ref.watch(
          seriesCoverImageProvider((seriesId: id, allowRemoteFetch: true)),
        );
        firstCoverUrl = coverAsync.value;
      } else {
        final metadataAsync = ref.watch(
          readingListItemMetadataProvider((
            targetId: firstItem.targetId,
            isSeries: firstItem.isSeries,
          )),
        );
        final metadata = metadataAsync.value;
        if (metadata is IssueDetails) {
          firstCoverUrl = metadata.image;
        }
      }
    }

    return SizedBox(
      height: 350,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (firstCoverUrl != null)
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: CachedNetworkImage(
                imageUrl: firstCoverUrl,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(color: theme.colorScheme.surfaceContainerHighest),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.colorScheme.surface.withValues(alpha: 0.75),
                  Colors.transparent,
                  theme.colorScheme.surface.withValues(alpha: 0.75),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: [
                PopupMenuButton<_ReadingListDetailsMenuAction>(
                  tooltip: 'More options',
                  onSelected: (action) {
                    switch (action) {
                      case _ReadingListDetailsMenuAction.edit:
                        context.pushRoute(
                          ReadingListEditRoute(listId: widget.listId),
                        );
                      case _ReadingListDetailsMenuAction.share:
                        ref
                            .read(readingListSharingServiceProvider)
                            .shareReadingList(list);
                      case _ReadingListDetailsMenuAction.delete:
                        _confirmDelete(context, list);
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: _ReadingListDetailsMenuAction.edit,
                      child: Text('Edit'),
                    ),
                    PopupMenuItem(
                      value: _ReadingListDetailsMenuAction.share,
                      child: Text('Share'),
                    ),
                    PopupMenuItem(
                      value: _ReadingListDetailsMenuAction.delete,
                      child: Text('Delete'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 56,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: ReadingListCover(list: list, width: 140, height: 210, peekOffset: 35),
                    ),
                  ],
              ),
            ),
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
      loading: () => const _ReadingListDetailsSkeleton(),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $e')),
      ),
      data: (list) {
        if (list == null) {
          return const Scaffold(body: Center(child: Text('List not found')));
        }

        final displayItems = list.items;
        final statusAsync = ref.watch(
          readingListEffectiveStatusProvider(list),
        );
        final status = statusAsync.value ?? (
          readCount: 0,
          totalCount: displayItems.length,
          progress: 0.0,
        );

        return Scaffold(
          body: Stack(
            children: [
               _buildHeader(list),
              DraggableScrollableSheet(
                initialChildSize: 0.65,
                minChildSize: 0.65,
                maxChildSize: 0.9,
                snap: true,
                snapSizes: const [0.65, 0.9],
                builder: (context, scrollController) {
                  return DecoratedBox(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    child: list.isOrdered
                        ? _buildOrderedSheet(
                            context,
                            list,
                            displayItems,
                            status.progress,
                            status.readCount,
                            status.totalCount,
                            scrollController,
                          )
                        : _buildUnorderedSheet(
                            context,
                            list,
                            displayItems,
                            scrollController,
                            progress: status.progress,
                            readCount: status.readCount,
                            totalCount: status.totalCount,
                          ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrderedSheet(
    BuildContext context,
    ReadingList list,
    List<ReadingListItem> items,
    double progress,
    int readCount,
    int totalCount,
    ScrollController scrollController,
  ) {
    if (items.isEmpty) {
      return CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverToBoxAdapter(child: _buildSheetHeader(list, progress, readCount, totalCount)),
          const SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyContentState(
              icon: Icons.list_alt_rounded,
              message: 'This reading list is empty.',
            ),
          ),
        ],
      );
    }

    return CustomScrollView(
      controller: scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: _buildSheetHeader(list, progress, readCount, totalCount),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final item = items[index];
              final roleColor = _getRoleColor(context, item.role);

              return GestureDetector(
                onTap: () => _openReadingListItemDetails(item),
                child: ReadingListTimelineTile(
                  list: list.copyWith(items: items),
                  index: index + 1,
                  item: item,
                  roleColor: roleColor,
                  isEditing: false,
                ),
              );
            },
            childCount: items.length,
          ),
        ),
      ],
    );
  }

  Widget _buildUnorderedSheet(
    BuildContext context,
    ReadingList list,
    List<ReadingListItem> items,
    ScrollController scrollController, {
    required double progress,
    required int readCount,
    required int totalCount,
  }) {
    if (items.isEmpty) {
      return CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: _buildSheetHeader(list, progress, readCount, totalCount),
          ),
          const SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyContentState(
              icon: Icons.grid_view_rounded,
              message: 'This reading list is empty.',
            ),
          ),
        ],
      );
    }

    return CustomScrollView(
      controller: scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: _buildSheetHeader(list, progress, readCount, totalCount),
        ),
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
              return ReadingListGridItem(
                item: item,
                onTap: () => _openReadingListItemDetails(item),
                isEditing: false,
                isSelected: false,
                onRemove: null,
              );
            }, childCount: items.length),
          ),
        ),
      ],
    );
  }

  Widget _buildDragHandle() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 8),
        child: Container(
          width: 32,
          height: 4,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onSurfaceVariant
                .withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
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
}

class _ReadingListDetailsSkeleton extends StatelessWidget {
  const _ReadingListDetailsSkeleton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            height: 350,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ColoredBox(
                  color: theme.colorScheme.surfaceContainerHighest,
                ),
              ],
            ),
          ),
          DraggableScrollableSheet(
                initialChildSize: 0.65,
                minChildSize: 0.65,
                maxChildSize: 0.9,
                snap: true,
                snapSizes: const [0.65, 0.9],
            builder: (context, scrollController) => DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: CustomScrollView(
                controller: scrollController,
                slivers: [
                  _SkeletonDragHandle(),
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonDragHandle extends StatelessWidget {
  const _SkeletonDragHandle();

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 8),
          child: Container(
            width: 32,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurfaceVariant
                  .withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }
}
