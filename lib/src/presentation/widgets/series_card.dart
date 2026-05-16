import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities/series_list.dart';
import 'package:takion/src/presentation/providers/favorites_provider.dart';
import 'package:takion/src/presentation/providers/pulls_provider.dart';
import 'package:takion/src/presentation/providers/series_cover_provider.dart';
import 'package:takion/src/domain/entities/reading_list.dart';
import 'package:takion/src/presentation/widgets/role_badge.dart';

class SeriesCard extends ConsumerWidget {
  final SeriesList series;
  final VoidCallback? onTap;
  final double width;
  final bool allowRemoteCoverFetch;
  final bool? isRead;
  final ItemRole? role;

  const SeriesCard({
    super.key,
    required this.series,
    this.onTap,
    this.width = 120,
    this.allowRemoteCoverFetch = true,
    this.isRead,
    this.role,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final subscriptionAsync = ref.watch(seriesSubscriptionProvider(series.id));
    final isSubscribed = subscriptionAsync.asData?.value?.isActive ?? false;
    final isFavorite = ref.watch(isSeriesFavoriteProvider(series.id)).asData?.value == true;

    final coverImageAsync = ref.watch(
      seriesCoverImageProvider((
        seriesId: series.id,
        allowRemoteFetch: allowRemoteCoverFetch,
      )),
    );
    final coverImage = coverImageAsync.asData?.value;

    final cover = ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: 2 / 3,
        child: Stack(
          fit: StackFit.expand,
          children: [
            coverImage != null
                ? CachedNetworkImage(
                    imageUrl: coverImage,
                    fit: BoxFit.cover,
                  )
                : Container(
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: const Icon(Icons.collections_bookmark_outlined, size: 24),
                  ),
            if (role != null)
              Positioned(
                top: 4, left: 4,
                child: RoleBadge(role: role!),
              ),
            if (isFavorite)
              Positioned(
                top: 4, right: 4,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.favorite, size: 12, color: Colors.red),
                ),
              ),
            if (isRead == true)
              Positioned(
                bottom: 4, right: 4,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                  child: const Icon(Icons.check, color: Colors.white, size: 12),
                ),
              ),
          ],
        ),
      ),
    );


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
                  AspectRatio(
                    aspectRatio: 2 / 3,
                    child: cover,
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
