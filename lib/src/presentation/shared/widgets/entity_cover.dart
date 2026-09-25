import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:takion/src/domain/entities.dart";
import "package:takion/src/presentation/shared/widgets/components.dart";
import "package:takion/src/presentation/shared/widgets/image_error_placeholder.dart";

class EntityCover extends StatelessWidget {
  final String? imageUrl;
  final String? placeholderLabel;
  final bool isFavorite;
  final bool isRead;
  final ItemRole? role;
  final String? syncStatus;
  final double borderRadius;
  final double aspectRatio;
  final double? width;
  final double? height;
  final IconData placeholderIcon;
  final double iconSize;
  final int? cacheWidth;
  final int? cacheHeight;
  final Alignment alignment;
  final Widget? overlay;
  final Duration fadeInDuration;
  final Duration fadeOutDuration;
  final bool circular;
  final Widget Function(BuildContext context, String url, Object error)?
  errorBuilder;
  final PlaceholderWidgetBuilder? placeholder;

  const EntityCover({
    super.key,
    this.imageUrl,
    this.placeholderLabel,
    this.isFavorite = false,
    this.isRead = false,
    this.role,
    this.syncStatus,
    this.borderRadius = 8,
    this.aspectRatio = 2 / 3,
    this.width,
    this.height,
    this.placeholderIcon = Icons.image,
    this.iconSize = 24,
    this.cacheWidth,
    this.cacheHeight,
    this.alignment = Alignment.center,
    this.overlay,
    this.fadeInDuration = const Duration(milliseconds: 400),
    this.fadeOutDuration = const Duration(milliseconds: 400),
    this.circular = false,
    this.errorBuilder,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasPendingSync = syncStatus == "pending";
    final hasFailedSync = syncStatus == "failed";
    final hasRoleBadge = role != null && role != ItemRole.standard;

    Widget cover = RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(circular ? 0 : borderRadius),
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: Stack(
            fit: StackFit.expand,
            children: [
              imageUrl != null && imageUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: imageUrl!,
                      fit: BoxFit.cover,
                      alignment: alignment,
                      memCacheWidth: cacheWidth,
                      memCacheHeight: cacheHeight,
                      fadeInDuration: fadeInDuration,
                      fadeOutDuration: fadeOutDuration,
                      placeholder:
                          placeholder ??
                          (context, url) => Container(
                            color: theme.colorScheme.surfaceContainerHighest,
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                      errorWidget:
                          errorBuilder ??
                          (context, url, error) => imageErrorPlaceholder(
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
              if (hasRoleBadge || hasPendingSync || hasFailedSync)
                Positioned(
                  top: 4,
                  left: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (hasRoleBadge) RoleBadge(role: role!),
                      if (hasRoleBadge && (hasPendingSync || hasFailedSync))
                        const SizedBox(height: 3),
                      if (hasPendingSync)
                        Tooltip(
                          message: "Changes queued to sync",
                          child: Container(
                            padding: const EdgeInsets.all(3.5),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface.withValues(
                                alpha: 0.92,
                              ),
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                color: theme.colorScheme.outlineVariant
                                    .withValues(alpha: 0.5),
                                width: 0.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 3,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.cloud_upload_outlined,
                              size: 13,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        )
                      else if (hasFailedSync)
                        Tooltip(
                          message: "Sync failed - will retry",
                          child: Container(
                            padding: const EdgeInsets.all(3.5),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.errorContainer
                                  .withValues(alpha: 0.95),
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                color: theme.colorScheme.error.withValues(
                                  alpha: 0.6,
                                ),
                                width: 0.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  blurRadius: 3,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.sync_problem_outlined,
                              size: 13,
                              color: theme.colorScheme.onErrorContainer,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              if (isFavorite)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.all(3.5),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(
                        alpha: 0.95,
                      ),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                        width: 0.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.favorite,
                      size: 13,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      circular ? 0 : borderRadius,
                    ),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant.withValues(
                        alpha: 0.25,
                      ),
                      width: 0.5,
                    ),
                  ),
                ),
              ),
              ?overlay,
            ],
          ),
        ),
      ),
    );

    if (circular) {
      cover = ClipOval(
        child: SizedBox(width: width, height: height, child: cover),
      );
    } else if (width != null || height != null) {
      cover = SizedBox(width: width, height: height, child: cover);
    }

    return cover;
  }
}
