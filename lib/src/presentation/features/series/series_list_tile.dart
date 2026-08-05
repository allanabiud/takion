import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/domain/entities.dart';
import 'package:takion/src/presentation/shared/widgets/components.dart';
import 'package:takion/src/presentation/features/library/providers/favorites_provider.dart';
import 'package:takion/src/presentation/features/series/providers/series_completion_provider.dart';
import 'package:takion/src/presentation/features/series/providers/series_details_provider.dart';
import 'package:takion/src/presentation/features/series/providers/subscriptions_provider.dart';
import 'package:takion/src/core/cache/entity_image_cache.dart';
import 'package:takion/src/domain/common/string_extensions.dart';

class SeriesListTile extends ConsumerWidget {
  final SeriesList series;
  final VoidCallback? onTap;
  final bool isFirst;
  final bool isLast;
  final String? heroTag;
  final bool allowRemoteCoverFetch;
  final bool? isRead;
  final double horizontalPadding;
  final ItemRole? role;
  final int? categoryCount;
  final String? categoryLabel;
  final bool showProgressBar;
  final int? ownedCount;

  const SeriesListTile({
    super.key,
    required this.series,
    this.onTap,
    this.isFirst = false,
    this.isLast = false,
    this.heroTag,
    this.allowRemoteCoverFetch = false,
    this.isRead,
    this.horizontalPadding = 12,
    this.role,
    this.categoryCount,
    this.categoryLabel,
    this.showProgressBar = false,
    this.ownedCount,
  });

  String _formatSeriesType(String? type) {
    if (type == null) return '';
    final lower = type.toLowerCase();
    if (lower == 'single issue') {
      return '';
    }
    if (lower == 'limited series') {
      return '';
    }
    if (lower.contains('trade paperback') || lower.contains('tpb')) {
      return 'TPB';
    }
    if (lower.contains('hardcover') || lower.contains('hc')) {
      return 'HC';
    }
    if (lower.contains('graphic novel') || lower.contains('gn')) {
      return 'GN';
    }
    if (lower.contains('omnibus')) {
      return 'Omnibus';
    }
    return type;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const double iconHeight = 100;
    const double iconWidth = 90;
    final isSubscribed = ref.watch(
      subscribedSeriesIdsSetProvider.select((set) => set.contains(series.id)),
    );
    final isFavorite = ref.watch(
      favoriteSeriesIdsSetProvider.select((set) => set.contains(series.id)),
    );
    final cachedIssueCountAsync = ref.watch(
      cachedSeriesIssueCountProvider(series.id),
    );
    // Only fetch full details (a network call) when the tile opts in via allowRemoteCoverFetch.
    int? remoteIssueCount;
    if (allowRemoteCoverFetch) {
      remoteIssueCount = ref
          .watch(seriesDetailsProvider(series.id))
          .asData
          ?.value
          .issueCount;
    }
    // Category summaries store the category count in issueCount; prefer the local DB cache, which has the real total from list responses.
    final totalIssuesCount =
        remoteIssueCount ??
        cachedIssueCountAsync.asData?.value ??
        series.issueCount;
    ref.watch(entityImageVersionProvider);
    final cache = ref.read(entityImageCacheProvider);
    final cachedImage = cache.getCached('series', series.id);
    final coverImage = cachedImage;
    final effectiveOnTap =
        onTap ??
        () {
          context.pushRoute(
            SeriesDetailsRoute(
              seriesId: series.id,
              initialImageUrl: coverImage,
            ),
          );
        };

    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final cacheWidth = (iconWidth * devicePixelRatio).round();

    final cover = SizedBox(
      width: iconWidth,
      height: iconHeight,
      child: EntityCover(
        imageUrl: coverImage,
        placeholderLabel: initials(series.name),
        isFavorite: false,
        isRead: false,
        placeholderIcon: Icons.collections_bookmark_outlined,
        aspectRatio: iconWidth / iconHeight,
        cacheWidth: cacheWidth,
      ),
    );

    return RepaintBoundary(
      child: Padding(
        padding: EdgeInsets.only(
          left: horizontalPadding,
          right: horizontalPadding,
          top: isFirst ? 12 : 2,
          bottom: isLast ? 12 : 0,
        ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: effectiveOnTap,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    heroTag != null ? Hero(tag: heroTag!, child: cover) : cover,
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Builder(
                            builder: (context) {
                              final formattedType = series.seriesType != null
                                  ? _formatSeriesType(series.seriesType!)
                                  : '';
                              return Text(
                                formattedType.isNotEmpty
                                    ? '${series.name} ($formattedType)'
                                    : series.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              );
                            },
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                '${series.yearBegan ?? 'Unknown'}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '•',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                categoryCount != null
                                    ? '$categoryCount / ${totalIssuesCount ?? '…'} ${totalIssuesCount == 1 ? 'issue' : 'issues'}'
                                    : '${totalIssuesCount ?? '…'} ${totalIssuesCount == 1 ? 'issue' : 'issues'}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                          if (showProgressBar &&
                              totalIssuesCount != null &&
                              totalIssuesCount > 0)
                            _SeriesProgressBar(
                              seriesId: series.id,
                              total: totalIssuesCount,
                              categoryCount: categoryCount,
                              ownedCount: ownedCount,
                            ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              if (isSubscribed)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.notifications_active,
                                        size: 12,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'SUBSCRIBED',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 10,
                                            ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                Icon(
                                  Icons.notifications_none_outlined,
                                  size: 16,
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                              if (isRead == true) ...[
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.bookmark_added,
                                  size: 16,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ],
                              if (isFavorite) ...[
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.favorite,
                                  size: 16,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ],
                              if (role != null &&
                                  role != ItemRole.standard) ...[
                                const SizedBox(width: 8),
                                RoleBadge(role: role!),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }
}

class _SeriesProgressBar extends ConsumerWidget {
  final int seriesId;
  final int total;
  final int? categoryCount;
  final int? ownedCount;

  const _SeriesProgressBar({
    required this.seriesId,
    required this.total,
    this.categoryCount,
    this.ownedCount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (categoryCount != null) {
      final count = categoryCount!;
      if (count == 0) return const SizedBox(height: 4);
      final percent = (count / total).clamp(0.0, 1.0);
      return Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: percent,
                  minHeight: 6,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$count/$total',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    if (ownedCount != null) {
      final owned = ownedCount!;
      if (owned <= 0) return const SizedBox(height: 4);
      final percent = (owned / total).clamp(0.0, 1.0);
      return _buildProgress(context, owned, percent);
    }

    final ownedAsync = ref.watch(seriesOwnedCountProvider(seriesId));

    return ownedAsync.when(
      loading: () => const SizedBox(height: 4),
      error: (_, _) => const SizedBox(height: 4),
      data: (owned) {
        if (owned == 0) return const SizedBox(height: 4);
        final percent = (owned / total).clamp(0.0, 1.0);
        return _buildProgress(context, owned, percent);
      },
    );
  }

  Widget _buildProgress(BuildContext context, int owned, double percent) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: percent,
                minHeight: 6,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$owned/$total',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
