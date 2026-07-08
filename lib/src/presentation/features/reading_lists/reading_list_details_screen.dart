import 'dart:ui' show ImageFilter;

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/cache/entity_image_cache.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/domain/entities/issue_details.dart';
import 'package:takion/src/domain/entities/reading_list.dart';
import 'package:takion/src/domain/entities/series_details.dart';
import 'package:takion/src/core/sharing/reading_list_sharing_service.dart';
import 'package:takion/src/presentation/features/reading_lists/providers/reading_list_details_provider.dart';
import 'package:takion/src/presentation/features/reading_lists/providers/reading_list_item_cached_metadata_provider.dart';
import 'package:takion/src/presentation/features/reading_lists/providers/reading_lists_provider.dart';
import 'package:takion/src/presentation/features/reading_lists/add_reading_list_items_bottom_sheet.dart';
import 'package:takion/src/presentation/features/reading_lists/reading_list_cover.dart';
import 'package:takion/src/presentation/features/reading_lists/reading_list_details_sheet.dart';
import 'package:takion/src/presentation/features/reading_lists/reading_list_grid_item.dart';
import 'package:takion/src/presentation/components/detail_screen_skeleton.dart';
import 'package:takion/src/presentation/components/section_header.dart';
import 'package:takion/src/presentation/components/shimmer_widget.dart';
import 'package:takion/src/presentation/components/skeleton.dart';
import 'package:takion/src/presentation/common/takion_alerts.dart';
import 'package:takion/src/presentation/common/empty_content_state.dart';
import 'package:takion/src/presentation/features/library/providers/favorites_provider.dart';
import 'package:takion/src/presentation/features/reading_lists/providers/reading_list_item_status_provider.dart';
import 'package:takion/src/presentation/features/reading_lists/reading_list_timeline_tile.dart';
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
        final added = !isFavorite;
        (added ? TakionAlerts.successWithUndo : TakionAlerts.infoWithUndo)(
          context,
          added ? 'Added to Favourites' : 'Removed from Favourites',
          icon: Icons.favorite,
          actionLabel: 'Undo',
          onUndo: () async {
            await repository.toggleReadingListFavorite(list.id);
            ref.invalidate(isReadingListFavoriteProvider(list.id));
            ref.invalidate(favoriteReadingListsListProvider);
          },
        );
      }
    } catch (e) {
      if (context.mounted) {
        TakionAlerts.error(context, 'Failed to update favourites');
      }
    }
  }

  Future<void> _confirmDelete(BuildContext context, ReadingList list) async {
    final isMetron = list.metronSourceId != null;
    final titleText = isMetron ? 'Remove from Library' : 'Delete Reading List';
    final contentText = isMetron
        ? 'Are you sure you want to remove "${list.title}" from your library?'
        : 'Are you sure you want to delete "${list.title}"?';
    final actionText = isMetron ? 'Remove' : 'Delete';
    final successText = isMetron
        ? 'Removed from Library'
        : 'Reading List Deleted';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(titleText),
        content: Text(contentText),
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
            label: Text(actionText),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      ref.read(readingListsProvider.notifier).deleteList(list.id);
      if (context.mounted) {
        TakionAlerts.success(context, successText);
        context.router.pop();
      }
    }
  }

  Widget _buildActionRow(ReadingList list) {
    final theme = Theme.of(context);
    final isMetron = list.metronSourceId != null;
    final isFavoriteAsync = ref.watch(isReadingListFavoriteProvider(list.id));
    final isFavorite = isFavoriteAsync.value ?? false;

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              textStyle: theme.textTheme.titleMedium,
              backgroundColor: isMetron
                  ? theme.colorScheme.errorContainer
                  : null,
              foregroundColor: isMetron
                  ? theme.colorScheme.onErrorContainer
                  : null,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: isMetron
                ? () => _confirmDelete(context, list)
                : () => AddReadingListItemsBottomSheet.show(context, list),
            icon: Icon(
              isMetron ? Icons.delete_outline : Icons.add,
              size: 22,
            ),
            label: Text(isMetron ? 'Remove' : 'Add Items'),
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
            onPressed: () =>
                ref.read(readingListSharingServiceProvider).shareReadingList(list),
            child: const Icon(Icons.share),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(ReadingList list) {
    final theme = Theme.of(context);

    String? firstCoverUrl = list.metronImageUrl;
    if ((firstCoverUrl == null || firstCoverUrl.isEmpty) &&
        list.items.isNotEmpty) {
      ref.watch(entityImageVersionProvider);
      final cache = ref.read(entityImageCacheProvider);
      final firstItem = list.items.first;
      final id =
          int.tryParse(firstItem.targetId.replaceAll(RegExp(r'\D'), '')) ?? 0;
      firstCoverUrl = cache.getCached(
        firstItem.isSeries ? 'series' : 'issue',
        id,
      );

      if (firstCoverUrl == null || firstCoverUrl.isEmpty) {
        final cachedMetadata = ref.watch(
          readingListItemCachedMetadataProvider((
            targetId: firstItem.targetId,
            isSeries: firstItem.isSeries,
          )),
        );
        final cached = cachedMetadata.asData?.value;
        if (cached is IssueDetails) {
          firstCoverUrl = cached.image?.trim();
        } else if (cached is SeriesDetails) {
          firstCoverUrl = cached.image?.trim();
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
                  itemBuilder: (context) => [
                    if (list.metronSourceId == null)
                      const PopupMenuItem(
                        value: _ReadingListDetailsMenuAction.edit,
                        child: Text('Edit'),
                      ),
                    const PopupMenuItem(
                      value: _ReadingListDetailsMenuAction.share,
                      child: Text('Share'),
                    ),
                    PopupMenuItem(
                      value: _ReadingListDetailsMenuAction.delete,
                      child: Text(
                        list.metronSourceId != null
                            ? 'Remove from Library'
                            : 'Delete',
                      ),
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
                    child: ReadingListCover(
                      list: list,
                      width: 140,
                      height: 210,
                      peekOffset: 35,
                      allowRemoteCoverFetch: false,
                    ),
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
      loading: () => DetailScreenSkeleton(
        initialChildSize: 0.65,
        header: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            Positioned(
              top: 56,
              left: 0,
              right: 0,
              child: Center(
                child: SizedBox(
                  width: 140,
                  height: 210,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: List.generate(
                        3,
                        (i) => Positioned(
                          top: i * 20.0,
                          left: i * 10.0,
                          child: SkeletonBox(
                            width: 120,
                            height: 180,
                            borderRadius: 8,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: ShimmerWidget(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SkeletonBox(height: 26, width: 280, borderRadius: 4),
              const SizedBox(height: 8),
              const SkeletonBox(height: 14, width: 160, borderRadius: 4),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Expanded(
                    child: SkeletonBox(height: 14, borderRadius: 4),
                  ),
                  const SizedBox(width: 8),
                  const SkeletonBox(width: 40, height: 14, borderRadius: 4),
                ],
              ),
              const SizedBox(height: 8),
              const SkeletonBox(
                height: 8,
                width: double.infinity,
                borderRadius: 4,
              ),
              const SizedBox(height: 20),
              Row(
                children: const [
                  Expanded(
                    flex: 3,
                    child: SkeletonBox(height: 48, borderRadius: 12),
                  ),
                  SizedBox(width: 6),
                  Expanded(
                    flex: 1,
                    child: SkeletonBox(height: 48, borderRadius: 12),
                  ),
                  SizedBox(width: 6),
                  Expanded(
                    flex: 1,
                    child: SkeletonBox(height: 48, borderRadius: 12),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const SkeletonBox(width: 60, height: 18, borderRadius: 4),
              const SizedBox(height: 16),
              ...List.generate(
                4,
                (_) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      const SkeletonBox(
                        width: 24,
                        height: 24,
                        borderRadius: 12,
                      ),
                      const SizedBox(width: 12),
                      const SkeletonBox(
                        width: 60,
                        height: 85,
                        borderRadius: 6,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SkeletonBox(
                              height: 14,
                              width: 200,
                              borderRadius: 4,
                            ),
                            const SizedBox(height: 6),
                            const SkeletonBox(
                              height: 12,
                              width: 140,
                              borderRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $e')),
      ),
      data: (list) {
        if (list == null) {
          return const Scaffold(body: Center(child: Text('List not found')));
        }

        final displayItems = list.items;
        final statusAsync = ref.watch(readingListEffectiveStatusProvider(list));
        final status =
            statusAsync.value ??
            (readCount: 0, totalCount: displayItems.length, progress: 0.0);

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
          SliverToBoxAdapter(
            child: ReadingListDetailsSheetHeader(
              list: list,
              progress: progress,
              readCount: readCount,
              totalCount: totalCount,
              actions: _buildActionRow(list),
            ),
          ),
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
          child: ReadingListDetailsSheetHeader(
            list: list,
            progress: progress,
            readCount: readCount,
            totalCount: totalCount,
            actions: _buildActionRow(list),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
            child: SectionHeader(
              title: list.contentType == ListContentType.series ? 'SERIES' : 'ISSUES',
              count: items.length,
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final item = items[index];
            final roleColor = _getRoleColor(context, item.role);

            return ReadingListTimelineTile(
              list: list.copyWith(items: items),
              index: index + 1,
              item: item,
              roleColor: roleColor,
              isEditing: false,
              allowRemoteHydration: true,
            );
          }, childCount: items.length),
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
            child: ReadingListDetailsSheetHeader(
              list: list,
              progress: progress,
              readCount: readCount,
              totalCount: totalCount,
              actions: _buildActionRow(list),
            ),
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
          child: ReadingListDetailsSheetHeader(
            list: list,
            progress: progress,
            readCount: readCount,
            totalCount: totalCount,
            actions: _buildActionRow(list),
          ),
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
                allowRemoteHydration: true,
                onRemove: null,
              );
            }, childCount: items.length),
          ),
        ),
      ],
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
