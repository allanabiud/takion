import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/domain/entities/series_list.dart';
import 'package:takion/src/presentation/providers/favorites_provider.dart';
import 'package:takion/src/presentation/providers/pulls_provider.dart';
import 'package:takion/src/presentation/providers/series_cover_provider.dart';

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
    final effectiveOnTap =
        onTap ??
        () {
          context.pushRoute(SeriesDetailsRoute(seriesId: series.id));
        };
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

    final cover = Container(
      width: iconWidth,
      height: iconHeight,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: coverImage == null
          ? Icon(
              Icons.collections_bookmark_outlined,
              size: 40,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            )
          : CachedNetworkImage(imageUrl: coverImage, fit: BoxFit.cover),
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
                              Icon(
                                isSubscribed
                                    ? Icons.notifications_active
                                    : Icons.notifications_none_outlined,
                                size: 16,
                                color: isSubscribed
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.outline,
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
