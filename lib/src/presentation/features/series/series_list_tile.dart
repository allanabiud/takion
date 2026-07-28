import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/domain/entities.dart';
import 'package:takion/src/presentation/shared/widgets/components.dart';
import 'package:takion/src/presentation/features/library/providers/favorites_provider.dart';
import 'package:takion/src/presentation/features/library/providers/pulls_provider.dart';
import 'package:takion/src/presentation/features/series/providers/series_completion_provider.dart';
import 'package:takion/src/presentation/features/series/providers/series_details_provider.dart';
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
    this.showProgressBar = true,
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
    final subscriptionAsync = ref.watch(seriesSubscriptionProvider(series.id));
    final isSubscribed = subscriptionAsync.asData?.value?.isActive ?? false;
    final isFavorite =
        ref.watch(isSeriesFavoriteProvider(series.id)).asData?.value == true;
    final detailsAsync = ref.watch(seriesDetailsProvider(series.id));
    final cachedIssueCountAsync = ref.watch(
      cachedSeriesIssueCountProvider(series.id),
    );
    // Category summaries deliberately store the category count in issueCount.
    // If categoryCount is present, series.issueCount is the category count,
    // not the series total. Try the full details API first, then fall back
    // to the local DB cache (which has issue_count from list responses).
    final totalIssuesCount =
        detailsAsync.asData?.value.issueCount ??
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

    return Padding(
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
                    // Text Content
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
                              if (role != null) ...[
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
    );
  }
}

class _SeriesProgressBar extends ConsumerWidget {
  final int seriesId;
  final int total;
  final int? categoryCount;

  const _SeriesProgressBar({
    required this.seriesId,
    required this.total,
    this.categoryCount,
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

    final ownedAsync = ref.watch(seriesOwnedCountProvider(seriesId));

    return ownedAsync.when(
      loading: () => const SizedBox(height: 4),
      error: (_, _) => const SizedBox(height: 4),
      data: (owned) {
        if (owned == 0) return const SizedBox(height: 4);
        final percent = (owned / total).clamp(0.0, 1.0);
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
      },
    );
  }
}
