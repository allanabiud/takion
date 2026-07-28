import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/cache/entity_image_cache.dart';
import 'package:takion/src/presentation/shared/widgets/image_error_placeholder.dart';
import 'package:takion/src/domain/common/string_extensions.dart';

class EntityCard extends ConsumerWidget {
  const EntityCard({
    super.key,
    required this.entityType,
    required this.entityId,
    required this.name,
    this.subtitle,
    this.width,
    this.onTap,
    this.imageUrl,
    this.imageWidth,
    this.imageHeight,
    this.borderRadius = 10,
  });

  final String entityType;
  final int entityId;
  final String name;
  final String? subtitle;
  final double? width;
  final VoidCallback? onTap;
  final String? imageUrl;
  final double? imageWidth;
  final double? imageHeight;
  final double borderRadius;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    ref.watch(entityImageVersionProvider);
    final cache = ref.read(entityImageCacheProvider);
    final cachedImage = cache.getCached(entityType, entityId);
    final effectiveImageUrl = imageUrl ?? cachedImage;

    final effectiveImageWidth = imageWidth ?? (width ?? 100);
    final effectiveImageHeight = imageHeight ?? effectiveImageWidth;

    Widget card = InkWell(
      borderRadius: BorderRadius.circular(borderRadius),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: Container(
                width: effectiveImageWidth,
                height: effectiveImageHeight,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(
                    alpha: 0.8,
                  ),
                ),
                child: effectiveImageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: effectiveImageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Center(
                          child: Text(
                            initials(name),
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) =>
                            imageErrorPlaceholder(
                              context,
                              url,
                              error,
                              label: initials(name),
                              iconSize: 24,
                            ),
                      )
                    : Center(
                        child: Text(
                          initials(name),
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 6),
            if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
              Text(
                subtitle!,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontSize: 10,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
            ],
            Text(
              name,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );

    if (width != null) {
      card = SizedBox(width: width, child: card);
    }

    return card;
  }
}
