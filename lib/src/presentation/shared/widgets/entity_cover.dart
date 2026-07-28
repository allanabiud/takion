import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:takion/src/domain/entities.dart';
import 'package:takion/src/presentation/shared/widgets/components.dart';
import 'package:takion/src/presentation/shared/widgets/image_error_placeholder.dart';

class EntityCover extends StatelessWidget {
  final String? imageUrl;
  final String? placeholderLabel;
  final bool isFavorite;
  final bool isRead;
  final ItemRole? role;
  final double borderRadius;
  final double aspectRatio;
  final IconData placeholderIcon;
  final double iconSize;
  final int? cacheWidth;
  final int? cacheHeight;

  const EntityCover({
    super.key,
    this.imageUrl,
    this.placeholderLabel,
    this.isFavorite = false,
    this.isRead = false,
    this.role,
    this.borderRadius = 8,
    this.aspectRatio = 2 / 3,
    this.placeholderIcon = Icons.image,
    this.iconSize = 24,
    this.cacheWidth,
    this.cacheHeight,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: Stack(
            fit: StackFit.expand,
            children: [
              imageUrl != null && imageUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: imageUrl!,
                      fit: BoxFit.cover,
                      memCacheWidth: cacheWidth,
                      placeholder: (context, url) => Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, url, error) =>
                          imageErrorPlaceholder(
                            context,
                            url,
                            error,
                            label: placeholderLabel,
                            icon: placeholderIcon,
                            iconSize: iconSize,
                          ),
                    )
                  : Container(
                      color:
                          placeholderLabel != null &&
                              placeholderLabel!.isNotEmpty
                          ? theme.colorScheme.primaryContainer.withValues(
                              alpha: 0.8,
                            )
                          : theme.colorScheme.surfaceContainerHighest,
                      child:
                          placeholderLabel != null &&
                              placeholderLabel!.isNotEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Text(
                                  placeholderLabel!,
                                  style: TextStyle(
                                    color: theme.colorScheme.primary,
                                    fontSize: iconSize,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                          : Icon(placeholderIcon, size: iconSize),
                    ),
              if (role != null)
                Positioned(top: 4, left: 4, child: RoleBadge(role: role!)),
              if (isFavorite)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(
                        alpha: 0.8,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.favorite,
                      size: 14,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              if (isRead)
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
