import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/domain/entities/series_list.dart';
import 'package:takion/src/presentation/components/entity_cover.dart';
import 'package:takion/src/presentation/features/library/providers/favorites_provider.dart';
import 'package:takion/src/presentation/features/library/providers/pulls_provider.dart';
import 'package:takion/src/presentation/features/series/providers/series_cover_provider.dart';

class SeriesListTile extends ConsumerWidget {
  final SeriesList series;
  final VoidCallback? onTap;
  final bool isFirst;
  final bool isLast;
  final String? heroTag;
  final bool allowRemoteCoverFetch;
  final bool showDivider;
  final bool? isRead;
  final double horizontalPadding;

  const SeriesListTile({
    super.key,
    required this.series,
    this.onTap,
    this.isFirst = false,
    this.isLast = false,
    this.heroTag,
    this.allowRemoteCoverFetch = true,
    this.showDivider = true,
    this.isRead,
    this.horizontalPadding = 12,
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
    final issueCount = series.issueCount ?? 0;
    final coverImageAsync = ref.watch(
      seriesCoverImageProvider((
        seriesId: series.id,
        allowRemoteFetch: allowRemoteCoverFetch,
      )),
    );
    final coverImage = coverImageAsync.asData?.value;
    final effectiveOnTap =
        onTap ??
        () {
          context.pushRoute(SeriesDetailsRoute(
            seriesId: series.id,
            initialImageUrl: coverImage,
          ));
        };

    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final cacheWidth = (iconWidth * devicePixelRatio).round();

    final cover = SizedBox(
      width: iconWidth,
      height: iconHeight,
      child: EntityCover(
        imageUrl: coverImage,
        isFavorite: false, // Handled below in the row
        isRead: false, // Handled below in the row
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
              borderRadius: BorderRadius.circular(12),
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
                                '$issueCount ${issueCount == 1 ? 'issue' : 'issues'}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              if (isSubscribed)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.notifications_active,
                                        size: 12,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'SUBSCRIBED',
                                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                          color: Theme.of(context).colorScheme.primary,
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
                                const Icon(
                                  Icons.favorite,
                                  size: 16,
                                  color: Colors.red,
                                ),
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
          if (showDivider && !isLast) const Divider(height: 1),
        ],
      ),
    );
  }
}
