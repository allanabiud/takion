import "dart:math" as math;

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/domain/common/string_extensions.dart";
import "package:takion/src/presentation/shared/widgets/components.dart";

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
    this.cacheWidth,
    this.cacheHeight,
    this.fit = BoxFit.cover,
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
  final int? cacheWidth;
  final int? cacheHeight;
  final BoxFit fit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final effectiveImageWidth = imageWidth ?? (width ?? 100);
    final effectiveImageHeight = imageHeight ?? effectiveImageWidth;

    final dpr = MediaQuery.devicePixelRatioOf(context);
    final multiplier = math.max(2.5, dpr);
    final effectiveCacheWidth =
        cacheWidth ??
        (effectiveImageWidth.isFinite
            ? (effectiveImageWidth * multiplier).round().clamp(100, 600)
            : 500);
    final effectiveCacheHeight = cacheHeight;

    var effectiveImageUrl = imageUrl;
    if ((effectiveImageUrl == null || effectiveImageUrl.trim().isEmpty) &&
        entityId > 0) {
      effectiveImageUrl = watchEntityImageUrl(ref, entityType, entityId);
    }

    Widget card = InkWell(
      borderRadius: BorderRadius.circular(borderRadius),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
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
                child: EntityCover(
                  imageUrl: effectiveImageUrl,
                  placeholderLabel: initials(name),
                  width: effectiveImageWidth,
                  height: effectiveImageHeight,
                  borderRadius: 0,
                  fit: fit,
                  aspectRatio: effectiveImageWidth / effectiveImageHeight,
                  cacheWidth: effectiveCacheWidth,
                  cacheHeight: effectiveCacheHeight,
                  iconSize: 24,
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
