import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/domain/common/string_extensions.dart";
import "package:takion/src/presentation/shared/widgets/components.dart";

class EntityListTile extends ConsumerWidget {
  final String entityType;
  final int entityId;
  final String name;
  final String? subtitle;
  final String? imageUrl;
  final VoidCallback? onTap;
  final bool isFirst;
  final bool isLast;
  final double horizontalPadding;
  final double imageWidth;
  final double imageHeight;
  final double imageBorderRadius;
  final int? cacheWidth;
  final int? cacheHeight;

  const EntityListTile({
    super.key,
    required this.entityType,
    required this.entityId,
    required this.name,
    this.subtitle,
    this.imageUrl,
    this.onTap,
    this.isFirst = false,
    this.isLast = false,
    this.horizontalPadding = 12,
    this.imageWidth = 64,
    this.imageHeight = 64,
    this.imageBorderRadius = 10,
    this.cacheWidth,
    this.cacheHeight,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final effectiveCacheWidth =
        cacheWidth ?? (imageWidth.isFinite ? (imageWidth * 2).round() : 120);
    final effectiveCacheHeight =
        cacheHeight ?? (imageHeight.isFinite ? (imageHeight * 2).round() : 180);

    var effectiveImageUrl = imageUrl;
    if ((effectiveImageUrl == null || effectiveImageUrl.trim().isEmpty) &&
        entityId > 0) {
      effectiveImageUrl = watchEntityImageUrl(ref, entityType, entityId);
    }

    return Padding(
      padding: EdgeInsets.only(
        left: horizontalPadding,
        right: horizontalPadding,
        top: isFirst ? 12 : 2,
        bottom: isLast ? 12 : 0,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(imageBorderRadius),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(imageBorderRadius),
                  child: Container(
                    width: imageWidth,
                    height: imageHeight,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(
                        alpha: 0.8,
                      ),
                    ),
                    child: EntityCover(
                      imageUrl: effectiveImageUrl,
                      placeholderLabel: initials(name),
                      width: imageWidth,
                      height: imageHeight,
                      borderRadius: 0,
                      aspectRatio: imageWidth / imageHeight,
                      iconSize: 20,
                      cacheWidth: effectiveCacheWidth,
                      cacheHeight: effectiveCacheHeight,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
