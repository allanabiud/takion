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
                      placeholder: placeholder ??
                          (context, url) => Container(
                            color: theme.colorScheme.surfaceContainerHighest,
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                      errorWidget: errorBuilder ??
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
              if (role != null && role != ItemRole.standard)
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
              ?overlay,
            ],
          ),
        ),
      ),
    );

    if (circular) {
      cover = ClipOval(
        child: SizedBox(
          width: width,
          height: height,
          child: cover,
        ),
      );
    } else if (width != null || height != null) {
      cover = SizedBox(width: width, height: height, child: cover);
    }

    return cover;
  }
}
