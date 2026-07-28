import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/domain/entities.dart';
import 'package:takion/src/presentation/shared/alerts/takion_alerts.dart';
import 'package:takion/src/presentation/features/issues/issue_list_tile.dart';
import 'package:takion/src/presentation/features/library/providers/category_series_providers.dart';
import 'package:takion/src/presentation/features/series/providers/series_cover_provider.dart';
import 'package:takion/src/presentation/features/series/providers/series_details_provider.dart';
import 'package:takion/src/presentation/shared/widgets/components.dart';
import 'package:takion/src/presentation/providers/providers.dart';

@RoutePage()
class LibrarySeriesScreen extends ConsumerWidget {
  const LibrarySeriesScreen({
    super.key,
    @pathParam required this.seriesId,
    @pathParam required this.category,
    @pathParam this.seriesName,
  });

  final int seriesId;
  final String category;
  final String? seriesName;

  String get _categoryLabel {
    switch (category) {
      case 'collected':
        return 'Collected';
      case 'read':
        return 'Read';
      case 'wishlist':
        return 'Wishlisted';
      case 'unread':
        return 'Unread';
      case 'unrated':
        return 'Unrated';
      default:
        return category;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailsAsync = ref.watch(seriesDetailsProvider(seriesId));
    final categorySeriesAsync = ref.watch(seriesByCategoryProvider(category));
    final coverImageAsync = ref.watch(seriesCoverImageProvider(seriesId));

    return DetailScreenShell<SeriesDetails>(
      asyncValue: detailsAsync,
      entityType: 'series',
      initialChildSize: 0.60,
      headerHeight: 350,
      showHero: false,
      toImageUrl: (d) => null,
      toHeroTag: (d) => 'library-series-${d.id}',
      toTitle: (d) => '${d.name.toUpperCase()} (${d.yearBegan ?? ''})',
      appBarTrailingAction: (d) => IconButton(
        icon: const Icon(Icons.open_in_new),
        tooltip: 'View full series details',
        onPressed: () =>
            context.pushRoute(SeriesDetailsRoute(seriesId: seriesId)),
      ),
      toHeaderExtra: (d) {
        final theme = Theme.of(context);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (d.publisher != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: GestureDetector(
                  onTap: () => context.pushRoute(
                    PublisherDetailsRoute(publisherId: d.publisher!.id),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        d.publisher!.name,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                    ],
                  ),
                ),
              ),
            if (d.issueCount != null && d.issueCount! > 0)
              _CategoryProgressBar(
                category: category,
                categoryLabel: _categoryLabel,
                seriesId: seriesId,
                total: d.issueCount!,
              ),
          ],
        );
      },
      headerBackground: (context, d) => [
        coverImageAsync.when(
          data: (imageUrl) => imageUrl != null
              ? Positioned.fill(
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        Container(color: Theme.of(context).colorScheme.surface),
                    errorWidget: (context, url, error) => Container(
                      color: Theme.of(context).colorScheme.surface,
                      child: const Icon(Icons.broken_image_outlined),
                    ),
                  ),
                )
              : Container(color: Theme.of(context).colorScheme.surface),
          loading: () =>
              Container(color: Theme.of(context).colorScheme.surface),
          error: (_, _) =>
              Container(color: Theme.of(context).colorScheme.surface),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).colorScheme.surface.withValues(alpha: 0.75),
                  Colors.transparent,
                  Theme.of(context).colorScheme.surface.withValues(alpha: 0.75),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),
      ],
      sheetContentBuilder: (context, d, ref) {
        return [
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          if (category == 'unread' || category == 'unrated')
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _BulkCategoryActions(
                  seriesId: seriesId,
                  category: category,
                  categoryLabel: _categoryLabel,
                  categorySeriesAsync: categorySeriesAsync,
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _CategoryIssueList(
                seriesId: seriesId,
                category: category,
                categoryLabel: _categoryLabel,
                categorySeriesAsync: categorySeriesAsync,
              ),
            ),
          ),
        ];
      },
    );
  }
}

class _CategoryProgressBar extends ConsumerWidget {
  const _CategoryProgressBar({
    required this.category,
    required this.categoryLabel,
    required this.seriesId,
    required this.total,
  });

  final String category;
  final String categoryLabel;
  final int seriesId;
  final int total;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categorySeriesAsync = ref.watch(seriesByCategoryProvider(category));

    return categorySeriesAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.only(top: 16),
        child: ShimmerWidget(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(width: 120, height: 12, borderRadius: 4),
              SizedBox(height: 10),
              SkeletonBox(height: 8, borderRadius: 4),
            ],
          ),
        ),
      ),
      error: (_, _) => const SizedBox(height: 24),
      data: (seriesList) {
        final match = seriesList
            .where((s) => s.seriesId == seriesId)
            .firstOrNull;
        final count = match?.categoryCount ?? 0;
        final percent = total > 0 ? (count / total).clamp(0.0, 1.0) : 0.0;

        return Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${categoryLabel.toUpperCase()}: $count / $total',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: percent,
                  minHeight: 8,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BulkCategoryActions extends ConsumerWidget {
  const _BulkCategoryActions({
    required this.seriesId,
    required this.category,
    required this.categoryLabel,
    required this.categorySeriesAsync,
  });

  final int seriesId;
  final String category;
  final String categoryLabel;
  final AsyncValue<List<CategorySeriesSummary>> categorySeriesAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return categorySeriesAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.only(bottom: 8),
        child: ShimmerWidget(child: SkeletonBox(height: 40, borderRadius: 12)),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (seriesList) {
        final match = seriesList
            .where((s) => s.seriesId == seriesId)
            .firstOrNull;
        if (match == null || match.items.isEmpty) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () async {
                    if (category == 'unread') {
                      await _markAllAsRead(context, ref, match.items);
                    } else if (category == 'unrated') {
                      await _showRateAllSheet(context, ref, match.items);
                    }
                  },
                  icon: Icon(
                    category == 'unread' ? Icons.done_all : Icons.star_outline,
                  ),
                  label: Text(
                    category == 'unread'
                        ? 'Mark All as Read (${match.items.length})'
                        : 'Rate All (${match.items.length})',
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _markAllAsRead(
    BuildContext context,
    WidgetRef ref,
    List<CollectionItem> items,
  ) async {
    final libraryRepository = ref.read(libraryRepositoryProvider);
    final activityRepository = ref.read(activityRepositoryProvider);
    var affected = 0;
    final now = DateTime.now().toUtc();

    for (final item in items) {
      final issueId = item.issue?.id;
      if (issueId == null) continue;
      if (item.isRead) continue;

      final localItem = await libraryRepository.getItemByIssueId(issueId);
      final seriesId = localItem?.metronSeriesId ?? item.issue?.series?.id;
      if (seriesId == null) continue;

      await libraryRepository.upsertItem(
        metronIssueId: issueId,
        metronSeriesId: seriesId,
        ownershipStatus:
            localItem?.ownershipStatus ??
            (item.quantity > 0
                ? LibraryOwnershipStatus.owned
                : LibraryOwnershipStatus.notOwned),
        isRead: true,
        rating: localItem?.rating,
        purchaseDate: localItem?.purchaseDate,
        pricePaid: localItem?.pricePaid,
        quantityOwned: localItem?.quantityOwned ?? 1,
        format: localItem?.format ?? LibraryItemFormat.print,
        firstReadAt: localItem?.firstReadAt ?? now,
        conditionGrade: localItem?.conditionGrade,
        acquiredOn: localItem?.acquiredOn ?? now,
        notes: localItem?.notes,
      );
      await libraryRepository.addReadLog(metronIssueId: issueId, readAt: now);
      await activityRepository.addEvent(
        LibraryActivityEvent(
          id: 'act-read-$issueId-${now.microsecondsSinceEpoch}',
          userId: 'local-user',
          type: ActivityEventType.read,
          issueId: issueId,
          seriesId: seriesId,
          seriesName: item.issue?.series?.name ?? 'Unknown Series',
          issueNumber: item.issue?.number ?? '',
          imageUrl: item.issue?.image,
          timestamp: now,
        ),
      );
      affected++;
    }

    if (!context.mounted) return;
    TakionAlerts.success(context, '$affected Marked as Read');
    ref.invalidate(seriesByCategoryProvider(category));
  }

  Future<void> _showRateAllSheet(
    BuildContext context,
    WidgetRef ref,
    List<CollectionItem> items,
  ) async {
    int? selectedRating;
    await showModalBottomSheet<int>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Rate ${items.length} Issues',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  final rating = i + 1;
                  return IconButton(
                    icon: Icon(
                      (selectedRating ?? 0) >= rating
                          ? Icons.star
                          : Icons.star_outline,
                      color: Theme.of(context).colorScheme.primary,
                      size: 36,
                    ),
                    onPressed: () =>
                        setModalState(() => selectedRating = rating),
                  );
                }),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: selectedRating == null
                    ? null
                    : () async {
                        Navigator.of(context).pop(selectedRating);
                      },
                child: const Text('Apply'),
              ),
            ],
          ),
        ),
      ),
    ).then((value) => selectedRating = value);

    if (selectedRating == null || !context.mounted) return;
    await _rateAll(context, ref, items, selectedRating!);
  }

  Future<void> _rateAll(
    BuildContext context,
    WidgetRef ref,
    List<CollectionItem> items,
    int rating,
  ) async {
    final libraryRepository = ref.read(libraryRepositoryProvider);
    var affected = 0;

    for (final item in items) {
      final issueId = item.issue?.id;
      if (issueId == null) continue;
      if (item.rating == rating) continue;

      final localItem = await libraryRepository.getItemByIssueId(issueId);
      final seriesId = localItem?.metronSeriesId ?? item.issue?.series?.id;
      if (seriesId == null) continue;

      await libraryRepository.upsertItem(
        metronIssueId: issueId,
        metronSeriesId: seriesId,
        ownershipStatus:
            localItem?.ownershipStatus ??
            (item.quantity > 0
                ? LibraryOwnershipStatus.owned
                : LibraryOwnershipStatus.notOwned),
        isRead: localItem?.isRead ?? item.isRead,
        rating: rating,
        purchaseDate: localItem?.purchaseDate,
        pricePaid: localItem?.pricePaid,
        quantityOwned: localItem?.quantityOwned ?? 1,
        format: localItem?.format ?? LibraryItemFormat.print,
        firstReadAt: localItem?.firstReadAt,
        conditionGrade: localItem?.conditionGrade,
        acquiredOn: localItem?.acquiredOn ?? DateTime.now().toUtc(),
        notes: localItem?.notes,
      );
      affected++;
    }

    if (!context.mounted) return;
    TakionAlerts.success(context, '$affected Issues Rated');
    ref.invalidate(seriesByCategoryProvider(category));
  }
}

class _CategoryIssueList extends ConsumerWidget {
  const _CategoryIssueList({
    required this.seriesId,
    required this.category,
    required this.categoryLabel,
    required this.categorySeriesAsync,
  });

  final int seriesId;
  final String category;
  final String categoryLabel;
  final AsyncValue<List<CategorySeriesSummary>> categorySeriesAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return categorySeriesAsync.when(
      loading: () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'ISSUES'),
          const SizedBox(height: 8),
          const ShimmerWidget(
            child: Column(
              children: [
                _IssueTileSkeleton(),
                _IssueTileSkeleton(),
                _IssueTileSkeleton(),
                _IssueTileSkeleton(),
              ],
            ),
          ),
        ],
      ),
      error: (error, _) => Text('Failed to load issues'),
      data: (seriesList) {
        final match = seriesList
            .where((s) => s.seriesId == seriesId)
            .firstOrNull;
        if (match == null || match.items.isEmpty) {
          return Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Center(
              child: Text(
                'No $categoryLabel issues in this series.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(title: 'ISSUES', badge: '(${match.items.length})'),
            const SizedBox(height: 8),
            ...match.items.map((item) {
              final index = match.items.indexOf(item);
              return IssueListTile(
                issue: item.toIssueList(),
                isFirst: index == 0,
                isLast: index == match.items.length - 1,
                isCollected: item.quantity > 0,
                isRead: item.isRead,
                rating: item.rating,
              );
            }),
          ],
        );
      },
    );
  }
}

extension _CollectionItemToIssueList on CollectionItem {
  IssueList toIssueList() {
    return IssueList(
      id: issue?.id ?? 0,
      name: issue?.series?.name ?? issue?.number ?? '',
      number: issue?.number ?? '',
      image: issue?.image,
      coverDate: issue?.coverDate,
      storeDate: issue?.storeDate,
      series: issue?.series != null
          ? Series(
              id: issue!.series!.id ?? 0,
              name: issue!.series!.name,
              volume: issue!.series!.volume,
              yearBegan: issue!.series!.yearBegan,
            )
          : null,
      modified: null,
    );
  }
}

class _IssueTileSkeleton extends StatelessWidget {
  const _IssueTileSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const SkeletonBox(width: 72, height: 98, borderRadius: 8),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(height: 14, borderRadius: 4),
                const SizedBox(height: 8),
                SkeletonBox(width: 80, height: 12, borderRadius: 4),
                const SizedBox(height: 6),
                SkeletonBox(width: 60, height: 12, borderRadius: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
