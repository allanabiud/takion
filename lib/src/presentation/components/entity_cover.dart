import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:takion/src/domain/entities/reading_list.dart';
import 'package:takion/src/presentation/components/role_badge.dart';

class EntityCover extends StatelessWidget {
  final String? imageUrl;
  final bool isFavorite;
  final bool isRead;
  final ItemRole? role;
  final double borderRadius;
  final double aspectRatio;
  final IconData placeholderIcon;
  final double iconSize;

  const EntityCover({
    super.key,
    this.imageUrl,
    this.isFavorite = false,
    this.isRead = false,
    this.role,
    this.borderRadius = 12,
    this.aspectRatio = 2 / 3,
    this.placeholderIcon = Icons.image,
    this.iconSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
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
                    placeholder: (context, url) => Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Icon(Icons.broken_image, size: iconSize),
                    ),
                  )
                : Container(
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Icon(placeholderIcon, size: iconSize),
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
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite,
                    size: 14,
                    color: Colors.red,
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
                  child: const Icon(Icons.check, color: Colors.white, size: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
