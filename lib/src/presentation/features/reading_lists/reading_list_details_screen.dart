import "dart:math" as math;
import "dart:ui" show ImageFilter;

import "package:auto_route/auto_route.dart";
import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/core/router/app_router.gr.dart";
import "package:takion/src/core/sharing/reading_list_sharing_service.dart";
import "package:takion/src/domain/entities.dart";
import "package:takion/src/presentation/features/issues/providers/issue_collection_status_provider.dart";
import "package:takion/src/presentation/features/issues/scrobble_sheet.dart";
import "package:takion/src/presentation/features/library/providers/favorites_provider.dart";
import "package:takion/src/presentation/features/reading_lists/add_local_reading_list_items_bottom_sheet.dart";
import "package:takion/src/presentation/features/reading_lists/local_reading_list_details_sheet.dart";
import "package:takion/src/presentation/features/reading_lists/providers/local_reading_lists_provider.dart";
import "package:takion/src/presentation/features/reading_lists/providers/metron_reading_lists_provider.dart";
import "package:takion/src/presentation/features/reading_lists/providers/reading_list_item_cached_metadata_provider.dart";
import "package:takion/src/presentation/features/reading_lists/providers/reading_list_item_status_provider.dart";
import "package:takion/src/presentation/features/reading_lists/reading_list_cover.dart";
import "package:takion/src/presentation/features/reading_lists/reading_list_grid_item.dart";
import "package:takion/src/presentation/features/reading_lists/reading_list_timeline_tile.dart";
import "package:takion/src/presentation/providers/providers.dart";
import "package:takion/src/presentation/shared/alerts/takion_alerts.dart";
import "package:takion/src/presentation/shared/favorite_toggle_actions.dart";
import "package:takion/src/presentation/shared/resource_url_actions.dart";
import "package:takion/src/presentation/shared/widgets/components.dart";
import "package:takion/src/presentation/shared/widgets/empty_content_state.dart";
import "package:url_launcher/url_launcher.dart";
import "package:uuid/uuid.dart";

@RoutePage()
class ReadingListDetailsScreen extends ConsumerStatefulWidget {
  final String? listId;
  final int? id;

  const ReadingListDetailsScreen({
    super.key,
    @PathParam("listId") this.listId,
    @PathParam("id") this.id,
  });

  @override
  ConsumerState<ReadingListDetailsScreen> createState() =>
      _ReadingListDetailsScreenState();
}

enum _ReadingListMenuAction { edit, share, browser, refresh, delete }

class _ReadingListDetailsScreenState
    extends ConsumerState<ReadingListDetailsScreen>
    with FavoriteToggleActions, ResourceUrlActions<MetronReadingListDetail> {
  bool _isLoadingFollow = false;
  bool _isAddingMissingToWishlist = false;

  int? get _resolvedMetronId {
    if (widget.id != null) return widget.id;
    if (widget.listId != null) {
      if (widget.listId!.startsWith("metron-")) {
        return int.tryParse(widget.listId!.replaceFirst("metron-", ""));
      }
      return int.tryParse(widget.listId!);
    }
    return null;
  }

  @override
  String? resourceUrlOf(MetronReadingListDetail details) {
    final resourceUrl = details.resourceUrl?.trim();
    if (resourceUrl != null && resourceUrl.isNotEmpty) return resourceUrl;
    return details.attributionUrl?.trim();
  }

  @override
  String get resourceLabel => "reading list";

  @override
  String shareSubjectOf(MetronReadingListDetail details) => details.name;

  void _openItemDetails(LocalReadingListItem item) {
    final idString = item.targetId.replaceAll(RegExp(r"^.*-"), "");
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
    LocalReadingList list,
  ) {
    final repository = ref.read(favoritesRepositoryProvider);
    return toggleFavoriteWithUndo(
      context,
      isFavorite: repository.isReadingListFavorite(list.id),
      toggle: () => repository.toggleReadingListFavorite(list.id),
    );
  }

  Future<void> _followMetronList(MetronReadingListDetailData data) async {
    setState(() => _isLoadingFollow = true);
    try {
      final detail = data.detail;
      final items = data.items;

      final readingListItems = items.map((item) {
        return LocalReadingListItem(
          targetId: "issue-${item.issueId}",
          isSeries: false,
          role: ItemRole.standard,
          isRead: false,
          seriesName: item.seriesName,
          seriesVolume: item.seriesVolume,
          issueNumber: item.issueNumber,
          seriesId: item.seriesId,
          yearBegan: item.yearBegan,
          coverDate: item.coverDate,
          storeDate: item.storeDate,
        );
      }).toList();

      final now = DateTime.now().toUtc();
      final list = LocalReadingList(
        id: const Uuid().v4(),
        title: detail.name,
        description: detail.desc ?? "",
        isOrdered: true,
        contentType: ListContentType.issue,
        createdAt: now,
        updatedAt: now,
        items: readingListItems,
        metronSourceId: _resolvedMetronId,
        metronAttributionSource: detail.attributionSource,
        metronAttributionUrl: detail.attributionUrl,
        metronImageUrl: detail.image,
        metronListType: detail.listType,
        lastSyncedAt: now,
      );

      await ref.read(localReadingListsProvider.notifier).addList(list);

      if (mounted) {
        TakionAlerts.success(context, "Reading List Followed & Cached Offline");
      }
    } catch (e) {
      if (mounted) {
        TakionAlerts.safeError(
          context,
          e,
          userMessage: "Failed to follow reading list",
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingFollow = false);
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    LocalReadingList list,
  ) async {
    final isMetron = list.isMetronImported;
    final titleText = isMetron ? "Remove from Library" : "Delete Reading List";
    final contentText = isMetron
        ? 'Are you sure you want to remove "${list.title}" from your library?'
        : 'Are you sure you want to delete "${list.title}"?';
    final actionText = isMetron ? "Remove" : "Delete";
    final successText = isMetron
        ? "Removed from Library"
        : "Reading List Deleted";

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(titleText),
        content: Text(contentText),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
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
      await ref.read(localReadingListsProvider.notifier).deleteList(list.id);
      if (context.mounted) {
        TakionAlerts.success(context, successText);
        context.router.pop();
      }
    }
  }

  Future<void> _addMissingIssuesToWishlist(
    List<LocalReadingListItem> items,
  ) async {
    setState(() => _isAddingMissingToWishlist = true);
    try {
      final statusMap = await ref.read(collectionIssueStatusMapProvider.future);
      final wishlistRepo = ref.read(localWishlistRepositoryProvider);

      final missingIssueIds = <int>[];
      for (final item in items) {
        if (item.isSeries) continue;
        final id = int.tryParse(item.targetId.replaceAll(RegExp(r"^.*-"), ""));
        if (id == null || id <= 0) continue;

        final status = statusMap[id];
        final isCollected =
            status != null && (status.isCollected || status.isRead);
        final isWishlisted = status != null && status.isWishlisted;

        if (!isCollected && !isWishlisted) {
          missingIssueIds.add(id);
        }
      }

      if (missingIssueIds.isEmpty) {
        if (mounted) {
          TakionAlerts.info(
            context,
            "All issues are already in your collection or wishlist!",
          );
        }
        return;
      }

      int addedCount = 0;
      for (final issueId in missingIssueIds) {
        await wishlistRepo.addToWishList(issueId: issueId);
        addedCount++;
      }

      if (mounted) {
        TakionAlerts.success(
          context,
          "Added $addedCount missing ${addedCount == 1 ? 'issue' : 'issues'} to Wishlist",
        );
      }
    } catch (e) {
      if (mounted) {
        TakionAlerts.safeError(
          context,
          e,
          userMessage: "Failed to add missing issues to wishlist",
        );
      }
    } finally {
      if (mounted) setState(() => _isAddingMissingToWishlist = false);
    }
  }

  Future<void> _refreshMetronReadingListData(int metronId) async {
    try {
      final newDetail = await ref
          .read(catalogRepositoryProvider)
          .getReadingListDetail(metronId, forceRefresh: true);
      final newItems = await ref
          .read(catalogRepositoryProvider)
          .getReadingListItems(metronId);
      final newData = MetronReadingListDetailData(
        detail: newDetail,
        items: newItems,
      );
      final currentData = ref
          .read(metronReadingListDetailProvider(metronId))
          .asData
          ?.value;
      if (currentData != newData) {
        ref.invalidate(metronReadingListDetailProvider(metronId));
      }
      if (mounted) {
        TakionAlerts.success(context, "Reading list refreshed");
      }
    } catch (e) {
      if (mounted) {
        TakionAlerts.error(context, "Failed to refresh reading list");
      }
    }
  }

  Widget _buildActionRow({
    required LocalReadingList list,
    LocalReadingList? localList,
    MetronReadingListDetailData? metronData,
  }) {
    final theme = Theme.of(context);
    final isMetron = list.isMetronImported || metronData != null;
    final isLocal = localList != null || !isMetron;

    if (!isLocal && metronData != null) {
      return Row(
        children: [
          Expanded(
            flex: 3,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: theme.textTheme.titleMedium,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _isLoadingFollow
                  ? null
                  : () => _followMetronList(metronData),
              icon: _isLoadingFollow
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.bookmark_add_outlined, size: 22),
              label: const Text("Follow List"),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: FilledButton.tonalIcon(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _isAddingMissingToWishlist
                  ? null
                  : () => _addMissingIssuesToWishlist(list.items),
              icon: _isAddingMissingToWishlist
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.playlist_add_check, size: 20),
              label: const Text("Wishlist Missing"),
            ),
          ),
        ],
      );
    }

    final isFavoriteAsync = ref.watch(isReadingListFavoriteProvider(list.id));
    final isFavorite = isFavoriteAsync.value ?? false;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 3,
              child: list.isMetronImported
                  ? FilledButton.tonalIcon(
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: theme.textTheme.titleMedium,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _isAddingMissingToWishlist
                          ? null
                          : () => _addMissingIssuesToWishlist(list.items),
                      icon: _isAddingMissingToWishlist
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.playlist_add_check, size: 20),
                      label: const Text("Wishlist Missing"),
                    )
                  : FilledButton.icon(
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: theme.textTheme.titleMedium,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => AddLocalReadingListItemsBottomSheet.show(
                        context,
                        list,
                      ),
                      icon: const Icon(Icons.add, size: 22),
                      label: const Text("Add Items"),
                    ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 1,
              child: isFavorite
                  ? FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.colorScheme.primaryContainer,
                        foregroundColor: theme.colorScheme.onPrimaryContainer,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        iconSize: 26,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => _toggleFavorite(context, ref, list),
                      child: const Icon(Icons.favorite),
                    )
                  : FilledButton.tonal(
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        iconSize: 26,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => _toggleFavorite(context, ref, list),
                      child: const Icon(Icons.favorite_border),
                    ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 1,
              child: FilledButton.tonal(
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  iconSize: 26,
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
      ],
    );
  }

  Widget _buildUpNextHeroCard({
    required LocalReadingList list,
    required List<LocalReadingListItem> items,
  }) {
    LocalReadingListItem? nextItem;
    int nextIndex = -1;

    for (int i = 0; i < items.length; i++) {
      final it = items[i];
      final readAsync = ref.watch(
        readingListItemEffectiveReadStatusProvider(it),
      );
      final isRead = readAsync.value ?? it.isRead;
      if (!isRead) {
        nextItem = it;
        nextIndex = i + 1;
        break;
      }
    }

    if (nextItem == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final idString = nextItem.targetId.replaceAll(RegExp(r"^.*-"), "");
    final issueId = int.tryParse(idString) ?? 0;

    final cachedMetadataAsync = ref.watch(
      readingListItemCachedMetadataProvider((
        targetId: nextItem.targetId,
        isSeries: nextItem.isSeries,
      )),
    );
    final cached = cachedMetadataAsync.asData?.value;
    String? coverUrl;
    String title = nextItem.seriesName ?? "Issue";
    String subtitle = nextItem.issueNumber != null
        ? "#${nextItem.issueNumber}"
        : "";

    if (cached is IssueDetails) {
      coverUrl = cached.image;
      if (cached.series?.name != null) title = cached.series!.name;
      if (cached.number.isNotEmpty) subtitle = "#${cached.number}";
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Material(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _openItemDetails(nextItem!),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                if (coverUrl != null && coverUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: coverUrl,
                      width: 48,
                      height: 72,
                      fit: BoxFit.cover,
                      memCacheWidth: 120,
                      memCacheHeight: 180,
                    ),
                  )
                else
                  Container(
                    width: 48,
                    height: 72,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        "#$nextIndex",
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.play_circle_fill_rounded,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "UP NEXT (#$nextIndex)",
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitle.isNotEmpty)
                        Text(
                          subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.tonalIcon(
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    if (issueId > 0) {
                      showScrobbleSheet(
                        context: context,
                        ref: ref,
                        issueId: issueId,
                      );
                    }
                  },
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text("Mark Read"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(LocalReadingList list, MetronReadingListDetail? detail) {
    final theme = Theme.of(context);
    final String? firstCoverUrl = list.metronImageUrl ?? detail?.image;

    final screenHeight = MediaQuery.sizeOf(context).height;
    final sheetTop = screenHeight * (1.0 - 0.65);
    final headerBackdropHeight = math.max(350.0, sheetTop + 48);

    return SizedBox(
      height: headerBackdropHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (firstCoverUrl != null && firstCoverUrl.isNotEmpty)
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: CachedNetworkImage(
                imageUrl: firstCoverUrl,
                fit: BoxFit.cover,
                memCacheWidth: 720,
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
              leading: Center(
                child: BackButton(style: detailHeaderIconButtonStyle(theme)),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Center(
                    child: PopupMenuButton<_ReadingListMenuAction>(
                      tooltip: "More options",
                      style: detailHeaderIconButtonStyle(theme),
                      onSelected: (action) async {
                        switch (action) {
                          case _ReadingListMenuAction.edit:
                            context.pushRoute(
                              LocalReadingListEditRoute(listId: list.id),
                            );
                          case _ReadingListMenuAction.share:
                            if (detail != null) {
                              shareResourceUrl(context, detail);
                            } else {
                              ref
                                  .read(readingListSharingServiceProvider)
                                  .shareReadingList(list);
                            }
                          case _ReadingListMenuAction.browser:
                            final url =
                                detail?.attributionUrl ??
                                list.metronAttributionUrl;
                            if (url != null) {
                              final uri = Uri.tryParse(url);
                              if (uri != null) await launchUrl(uri);
                            }
                          case _ReadingListMenuAction.refresh:
                            final mId = _resolvedMetronId;
                            if (mId != null) {
                              await _refreshMetronReadingListData(mId);
                            }
                          case _ReadingListMenuAction.delete:
                            _confirmDelete(context, list);
                        }
                      },
                      itemBuilder: (context) => [
                        if (!list.isMetronImported && detail == null)
                          const PopupMenuItem(
                            value: _ReadingListMenuAction.edit,
                            child: Text("Edit"),
                          ),
                        const PopupMenuItem(
                          value: _ReadingListMenuAction.share,
                          child: Text("Share"),
                        ),
                        if (detail?.attributionUrl != null ||
                            list.metronAttributionUrl != null)
                          const PopupMenuItem(
                            value: _ReadingListMenuAction.browser,
                            child: Text("Open in Browser"),
                          ),
                        if (_resolvedMetronId != null)
                          const PopupMenuItem(
                            value: _ReadingListMenuAction.refresh,
                            child: Text("Refresh from Metron"),
                          ),
                        if (list.id.isNotEmpty && !list.id.startsWith("temp-"))
                          PopupMenuItem(
                            value: _ReadingListMenuAction.delete,
                            child: Text(
                              list.isMetronImported
                                  ? "Remove from Library"
                                  : "Delete",
                            ),
                          ),
                      ],
                    ),
                  ),
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

  Widget _buildOrderedSheet({
    required BuildContext context,
    required LocalReadingList list,
    required List<LocalReadingListItem> items,
    required double progress,
    required int readCount,
    required int totalCount,
    required ScrollController scrollController,
    MetronReadingListDetail? detail,
    LocalReadingList? localList,
    MetronReadingListDetailData? metronData,
  }) {
    return CustomScrollView(
      controller: scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: LocalReadingListDetailsSheetHeader(
            list: list,
            metronDetail: detail,
            progress: progress,
            readCount: readCount,
            totalCount: totalCount,
            actions: _buildActionRow(
              list: list,
              localList: localList,
              metronData: metronData,
            ),
          ),
        ),
        if (items.isNotEmpty && progress < 1.0)
          SliverToBoxAdapter(
            child: _buildUpNextHeroCard(list: list, items: items),
          ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
            child: SectionHeader(
              title: list.contentType == ListContentType.series
                  ? "SERIES"
                  : "ISSUES",
              count: items.length,
            ),
          ),
        ),
        if (items.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyContentState(
              icon: Icons.list_alt_rounded,
              message: "This reading list is empty.",
            ),
          )
        else
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
                allowRemoteHydration: !_hasStoredDisplayData(item),
              );
            }, childCount: items.length),
          ),
      ],
    );
  }

  Widget _buildUnorderedSheet({
    required BuildContext context,
    required LocalReadingList list,
    required List<LocalReadingListItem> items,
    required double progress,
    required int readCount,
    required int totalCount,
    required ScrollController scrollController,
    LocalReadingList? localList,
    MetronReadingListDetailData? metronData,
  }) {
    return CustomScrollView(
      controller: scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: LocalReadingListDetailsSheetHeader(
            list: list,
            progress: progress,
            readCount: readCount,
            totalCount: totalCount,
            actions: _buildActionRow(
              list: list,
              localList: localList,
              metronData: metronData,
            ),
          ),
        ),
        if (items.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyContentState(
              icon: Icons.grid_view_rounded,
              message: "This reading list is empty.",
            ),
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
                return ReadingListGridItem(
                  item: item,
                  onTap: () => _openItemDetails(item),
                  isEditing: false,
                  isSelected: false,
                  allowRemoteHydration: !_hasStoredDisplayData(item),
                  onRemove: null,
                );
              }, childCount: items.length),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allLocalLists =
        ref.watch(localReadingListsProvider).value ??
        const <LocalReadingList>[];

    LocalReadingList? localList;
    if (widget.listId != null) {
      localList = allLocalLists.cast<LocalReadingList?>().firstWhere(
        (l) => l?.id == widget.listId,
        orElse: () => null,
      );
    }
    if (localList == null && _resolvedMetronId != null) {
      localList = allLocalLists.cast<LocalReadingList?>().firstWhere(
        (l) => l?.metronSourceId == _resolvedMetronId,
        orElse: () => null,
      );
    }

    if (localList != null) {
      final displayItems = localList.items;
      final statusAsync = ref.watch(
        readingListEffectiveStatusProvider(localList),
      );
      final status =
          statusAsync.value ??
          (readCount: 0, totalCount: displayItems.length, progress: 0.0);

      return Scaffold(
        body: Stack(
          children: [
            _buildHeader(localList, null),
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
                  child: localList!.isOrdered
                      ? _buildOrderedSheet(
                          context: context,
                          list: localList,
                          items: displayItems,
                          progress: status.progress,
                          readCount: status.readCount,
                          totalCount: status.totalCount,
                          scrollController: scrollController,
                          localList: localList,
                        )
                      : _buildUnorderedSheet(
                          context: context,
                          list: localList,
                          items: displayItems,
                          progress: status.progress,
                          readCount: status.readCount,
                          totalCount: status.totalCount,
                          scrollController: scrollController,
                          localList: localList,
                        ),
                );
              },
            ),
          ],
        ),
      );
    }

    final metronId = _resolvedMetronId;
    if (metronId == null) {
      return const Scaffold(
        body: Center(child: Text("Reading list not found")),
      );
    }

    final metronAsync = ref.watch(metronReadingListDetailProvider(metronId));

    return metronAsync.when(
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
                          child: const SkeletonBox(
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
              const Row(
                children: [
                  SkeletonBox(width: 80, height: 24, borderRadius: 12),
                  SizedBox(width: 8),
                  SkeletonBox(width: 100, height: 24, borderRadius: 12),
                ],
              ),
              const SizedBox(height: 20),
              const Row(
                children: [
                  Expanded(child: SkeletonBox(height: 14, borderRadius: 4)),
                  SizedBox(width: 8),
                  SkeletonBox(width: 40, height: 14, borderRadius: 4),
                ],
              ),
              const SizedBox(height: 8),
              const SkeletonBox(
                height: 8,
                width: double.infinity,
                borderRadius: 4,
              ),
              const SizedBox(height: 20),
              const Row(
                children: [
                  Expanded(
                    flex: 3,
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
                (_) => const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      SkeletonBox(width: 24, height: 24, borderRadius: 12),
                      SizedBox(width: 12),
                      SkeletonBox(width: 60, height: 85, borderRadius: 6),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SkeletonBox(
                              height: 14,
                              width: 200,
                              borderRadius: 4,
                            ),
                            SizedBox(height: 6),
                            SkeletonBox(
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
      error: (error, _) => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Text(
            TakionAlerts.cleanError(
              error,
              fallback: "Failed to load reading list",
            ),
          ),
        ),
      ),
      data: (data) {
        final detail = data.detail;
        final items = data.items;

        final readingListItems = items.map((item) {
          return LocalReadingListItem(
            targetId: "issue-${item.issueId}",
            isSeries: false,
            role: ItemRole.standard,
            isRead: false,
            seriesName: item.seriesName,
            seriesVolume: item.seriesVolume,
            issueNumber: item.issueNumber,
            seriesId: item.seriesId,
            yearBegan: item.yearBegan,
            coverDate: item.coverDate,
            storeDate: item.storeDate,
          );
        }).toList();

        final syntheticList = LocalReadingList(
          id: "metron-$metronId",
          title: detail.name,
          description: detail.desc ?? "",
          isOrdered: true,
          contentType: ListContentType.issue,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          items: readingListItems,
          metronSourceId: metronId,
          metronAttributionSource: detail.attributionSource,
          metronAttributionUrl: detail.attributionUrl,
          metronImageUrl: detail.image,
          metronListType: detail.listType,
          lastSyncedAt: DateTime.now(),
        );

        final statusAsync = ref.watch(
          readingListEffectiveStatusProvider(syntheticList),
        );
        final status =
            statusAsync.value ??
            (readCount: 0, totalCount: readingListItems.length, progress: 0.0);

        return Scaffold(
          body: Stack(
            children: [
              _buildHeader(syntheticList, detail),
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
                    child: _buildOrderedSheet(
                      context: context,
                      list: syntheticList,
                      items: readingListItems,
                      progress: status.progress,
                      readCount: status.readCount,
                      totalCount: status.totalCount,
                      scrollController: scrollController,
                      detail: detail,
                      metronData: data,
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

  bool _hasStoredDisplayData(LocalReadingListItem item) {
    return item.seriesName?.trim().isNotEmpty == true ||
        item.issueNumber?.trim().isNotEmpty == true;
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
