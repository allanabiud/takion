import 'dart:ui' show ImageFilter;

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:takion/src/domain/entities.dart';
import 'package:takion/src/presentation/shared/widgets/async_state_panel.dart';
import 'package:takion/src/presentation/shared/alerts/takion_alerts.dart';
import 'package:takion/src/presentation/shared/widgets/empty_content_state.dart';
import 'package:takion/src/presentation/shared/widgets/components.dart';
import 'package:takion/src/presentation/features/reading_lists/metron_reading_list_timeline_tile.dart';
import 'package:takion/src/presentation/features/reading_lists/providers/metron_reading_lists_provider.dart';
import 'package:takion/src/presentation/features/reading_lists/providers/local_reading_lists_provider.dart';
import 'package:takion/src/presentation/features/reading_lists/providers/reading_list_item_status_provider.dart';
import 'package:takion/src/presentation/features/reading_lists/reading_list_cover.dart';
import 'package:takion/src/presentation/features/reading_lists/local_reading_list_details_sheet.dart';
import 'package:takion/src/presentation/providers/providers.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

@RoutePage()
class MetronReadingListDetailScreen extends ConsumerStatefulWidget {
  const MetronReadingListDetailScreen({super.key, @pathParam required this.id});

  final int id;

  @override
  ConsumerState<MetronReadingListDetailScreen> createState() =>
      _MetronReadingListDetailScreenState();
}

class _MetronReadingListDetailScreenState
    extends ConsumerState<MetronReadingListDetailScreen> {
  LocalReadingList? _localList;
  bool _isLoadingImport = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkImportStatus());
  }

  Future<void> _checkImportStatus() async {
    final repo = ref.read(localReadingListRepositoryProvider);
    final local = await repo.findByMetronSourceId(widget.id);
    if (mounted) {
      setState(() => _localList = local);
    }
  }

  Future<void> _import() async {
    setState(() => _isLoadingImport = true);
    try {
      final data = await ref.read(
        metronReadingListDetailProvider(widget.id).future,
      );
      final detail = data.detail;
      final items = data.items;

      final readingListItems = items.map((item) {
        return LocalReadingListItem(
          targetId: 'issue-${item.issueId}',
          isSeries: false,
          role: ItemRole.standard,
          isRead: false,
          seriesName: item.seriesName,
          seriesVolume: item.seriesVolume,
          issueNumber: item.issueNumber,
        );
      }).toList();

      final now = DateTime.now().toUtc();
      final list = LocalReadingList(
        id: const Uuid().v4(),
        title: detail.name,
        description: detail.desc ?? '',
        isOrdered: true,
        contentType: ListContentType.issue,
        createdAt: now,
        updatedAt: now,
        items: readingListItems,
        metronSourceId: widget.id,
        metronAttributionSource: detail.attributionSource,
        metronAttributionUrl: detail.attributionUrl,
        metronImageUrl: detail.image,
        metronListType: detail.listType,
        lastSyncedAt: now,
      );

      await ref.read(localReadingListsProvider.notifier).addList(list);

      if (mounted) {
        TakionAlerts.success(context, 'Reading List Imported');
        setState(() => _localList = list);
      }
    } catch (e) {
      if (mounted) {
        TakionAlerts.safeError(
          context,
          e,
          userMessage: 'Failed to import reading list',
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingImport = false);
    }
  }

  Future<void> _removeFromLibrary() async {
    if (_localList == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove from Library'),
        content: Text(
          'Are you sure you want to remove "${_localList!.title}" from your library?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
              foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            icon: const Icon(Icons.delete_outline, size: 22),
            label: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final repo = ref.read(localReadingListRepositoryProvider);
    await repo.deleteList(_localList!.id);

    if (mounted) {
      TakionAlerts.success(context, 'Removed from Library');
      setState(() => _localList = null);
    }
  }

  Uri? _resourceUri(MetronReadingListDetail detail) {
    final resourceUrl = detail.resourceUrl?.trim();
    if (resourceUrl != null && resourceUrl.isNotEmpty) {
      return Uri.tryParse(resourceUrl);
    }

    final attributionUrl = detail.attributionUrl?.trim();
    if (attributionUrl != null && attributionUrl.isNotEmpty) {
      return Uri.tryParse(attributionUrl);
    }
    return null;
  }

  Future<void> _shareResourceUrl(MetronReadingListDetail detail) async {
    final uri = _resourceUri(detail);
    if (uri == null) {
      TakionAlerts.noShareUrl(context, 'reading list');
      return;
    }

    await SharePlus.instance.share(
      ShareParams(text: uri.toString(), subject: detail.name),
    );
  }

  Future<void> _openResourceUrlInBrowser(MetronReadingListDetail detail) async {
    final uri = _resourceUri(detail);
    if (uri == null) {
      TakionAlerts.noBrowserUrl(context, 'reading list');
      return;
    }

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      TakionAlerts.couldNotOpenInBrowser(context, 'reading list');
    }
  }

  Future<void> _refreshMetronReadingListData() async {
    try {
      final newDetail = await ref
          .read(catalogRepositoryProvider)
          .getReadingListDetail(widget.id, forceRefresh: true);
      final newItems = await ref
          .read(catalogRepositoryProvider)
          .getReadingListItems(widget.id);
      final newData = MetronReadingListDetailData(
        detail: newDetail,
        items: newItems,
      );
      final currentData = ref
          .read(metronReadingListDetailProvider(widget.id))
          .asData
          ?.value;
      if (currentData != newData) {
        ref.invalidate(metronReadingListDetailProvider(widget.id));
      }
      if (mounted) {
        TakionAlerts.success(context, 'Reading list refreshed');
      }
    } catch (e) {
      if (mounted) {
        TakionAlerts.error(context, 'Failed to refresh reading list');
      }
    }
  }

  Widget _buildActionRow(
    LocalReadingList list,
    MetronReadingListDetail detail,
  ) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: _localList != null
              ? FilledButton.icon(
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: theme.textTheme.titleMedium,
                    backgroundColor: theme.colorScheme.errorContainer,
                    foregroundColor: theme.colorScheme.onErrorContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _removeFromLibrary,
                  icon: const Icon(Icons.delete_outline, size: 22),
                  label: const Text('Remove'),
                )
              : FilledButton.icon(
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: theme.textTheme.titleMedium,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isLoadingImport ? null : _import,
                  icon: _isLoadingImport
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.add, size: 22),
                  label: const Text('Add to Library'),
                ),
        ),
        if (detail.attributionUrl != null &&
            detail.attributionUrl!.isNotEmpty) ...[
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
              onPressed: () async {
                final uri = Uri.tryParse(detail.attributionUrl!);
                if (uri != null) {
                  await launchUrl(uri);
                }
              },
              child: const Icon(Icons.open_in_browser),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildHeader(LocalReadingList list, MetronReadingListDetail detail) {
    final theme = Theme.of(context);
    final firstCoverUrl = list.metronImageUrl;

    return SizedBox(
      height: 350,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (firstCoverUrl != null && firstCoverUrl.isNotEmpty)
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
                EntityDetailActions(
                  onRefresh: _refreshMetronReadingListData,
                  onShare: () => _shareResourceUrl(detail),
                  onOpenInBrowser: () => _openResourceUrlInBrowser(detail),
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

  Widget _buildOrderedSheet(
    BuildContext context,
    LocalReadingList list,
    List<MetronReadingListItem> items,
    double progress,
    int readCount,
    int totalCount,
    ScrollController scrollController,
    MetronReadingListDetail detail,
  ) {
    if (items.isEmpty) {
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
              actions: _buildActionRow(list, detail),
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
          child: LocalReadingListDetailsSheetHeader(
            list: list,
            metronDetail: detail,
            progress: progress,
            readCount: readCount,
            totalCount: totalCount,
            actions: _buildActionRow(list, detail),
          ),
        ),
        SliverList(
          delegate: SliverChildListDelegate.fixed([
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
              child: SectionHeader(title: 'ISSUES', count: items.length),
            ),
          ]),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final item = items[index];
            return MetronReadingListTimelineTile(
              item: item,
              index: index + 1,
              isFirst: index == 0,
              isLast: index == items.length - 1,
              previousIssueId: index > 0 ? items[index - 1].issueId : null,
            );
          }, childCount: items.length),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final dataAsync = ref.watch(metronReadingListDetailProvider(widget.id));
    final theme = Theme.of(context);

    return dataAsync.when(
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
              Row(
                children: [
                  const SkeletonBox(width: 80, height: 24, borderRadius: 12),
                  const SizedBox(width: 8),
                  const SkeletonBox(width: 100, height: 24, borderRadius: 12),
                ],
              ),
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
                      const SkeletonBox(width: 60, height: 85, borderRadius: 6),
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
      error: (error, _) => Scaffold(
        appBar: AppBar(),
        body: AsyncStatePanel.error(
          errorMessage: 'Failed to load reading list',
        ),
      ),
      data: (data) {
        final detail = data.detail;
        final items = data.items;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          ref
              .read(metronListPreviewItemsProvider.notifier)
              .setPreviewItems(widget.id, items.take(3).toList());
        });

        final readingListItems = items.map((item) {
          return LocalReadingListItem(
            targetId: 'issue-${item.issueId}',
            isSeries: false,
            role: ItemRole.standard,
            isRead: false,
            seriesName: item.seriesName,
            seriesVolume: item.seriesVolume,
            issueNumber: item.issueNumber,
          );
        }).toList();

        final list = LocalReadingList(
          id: _localList?.id ?? 'temp-${widget.id}',
          title: detail.name,
          description: detail.desc ?? '',
          isOrdered: true,
          contentType: ListContentType.issue,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          items: readingListItems,
          metronSourceId: widget.id,
          metronAttributionSource: detail.attributionSource,
          metronAttributionUrl: detail.attributionUrl,
          metronImageUrl: detail.image,
          metronListType: detail.listType,
          lastSyncedAt: DateTime.now(),
        );

        final status = _localList != null
            ? (ref
                      .watch(readingListEffectiveStatusProvider(_localList!))
                      .value ??
                  (
                    readCount: 0,
                    totalCount: readingListItems.length,
                    progress: 0.0,
                  ))
            : (
                readCount: 0,
                totalCount: readingListItems.length,
                progress: 0.0,
              );

        return Scaffold(
          body: Stack(
            children: [
              _buildHeader(list, detail),
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
                      context,
                      list,
                      items,
                      status.progress,
                      status.readCount,
                      status.totalCount,
                      scrollController,
                      detail,
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
}
