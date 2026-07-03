import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities/reading_list.dart';
import 'package:takion/src/domain/entities/series_list.dart';
import 'package:takion/src/presentation/components/entity_cover.dart';
import 'package:takion/src/presentation/features/library/providers/favorites_provider.dart';
import 'package:takion/src/presentation/features/library/providers/pulls_provider.dart';
import 'package:takion/src/core/cache/entity_image_cache.dart';
import 'package:takion/src/presentation/logic/string_extensions.dart';

class SeriesCard extends ConsumerWidget {
  final SeriesList series;
  final String? imageUrl;
  final VoidCallback? onTap;
  final double width;
  final bool allowRemoteCoverFetch;
  final bool? isRead;
  final ItemRole? role;

  const SeriesCard({
    super.key,
    required this.series,
    this.imageUrl,
    this.onTap,
    this.width = 120,
    this.allowRemoteCoverFetch = false,
    this.isRead,
    this.role,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final subscriptionAsync = ref.watch(seriesSubscriptionProvider(series.id));
    final isSubscribed = subscriptionAsync.asData?.value?.isActive ?? false;
    final isFavorite =
        ref.watch(isSeriesFavoriteProvider(series.id)).asData?.value == true;

    ref.watch(entityImageVersionProvider);
    final cache = ref.read(entityImageCacheProvider);
    final cachedImage = cache.getCached('series', series.id);
    final coverImage = imageUrl ?? cachedImage;

    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final cacheWidth =
        width.isInfinite ? null : (width * devicePixelRatio).round();

    return SizedBox(
      width: width,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              margin: EdgeInsets.zero,
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  EntityCover(
                    imageUrl: coverImage,
                    placeholderLabel: initials(series.name),
                    isFavorite: isFavorite,
                    isRead: isRead ?? false,
                    role: role,
                    placeholderIcon: Icons.collections_bookmark_outlined,
                    cacheWidth: cacheWidth,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isSubscribed
                                ? Icons.notifications_active
                                : Icons.notifications_none_outlined,
                            size: 16,
                            color: isSubscribed
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outline,
                          ),
                          if (isRead == true) ...[
                            const SizedBox(width: 4),
                            Icon(
                              Icons.bookmark_added,
                              size: 16,
                              color: theme.colorScheme.primary,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              series.name,
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
