import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/cache/entity_image_cache.dart';
import 'package:takion/src/domain/common/string_extensions.dart';
import 'package:takion/src/presentation/shared/widgets/image_error_placeholder.dart';

class SmartEntityImage extends ConsumerWidget {
  const SmartEntityImage({
    super.key,
    this.entityType,
    this.entityId,
    required this.name,
    this.imageUrl,
    this.width = 80,
    this.height = 80,
    this.borderRadius = 40,
    this.isCircle = true,
    this.alignment = Alignment.topCenter,
    this.fontSize = 24,
  });

  final String? entityType;
  final int? entityId;
  final String name;
  final String? imageUrl;
  final double width;
  final double height;
  final double borderRadius;
  final bool isCircle;
  final Alignment alignment;
  final double fontSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    ref.watch(entityImageVersionProvider);
    final cache = ref.read(entityImageCacheProvider);

    final cachedImage = (entityType != null && entityId != null)
        ? cache.getCached(entityType!, entityId!)
        : null;
    final effectiveImageUrl = imageUrl ?? cachedImage;

    final placeholder = Center(
      child: Text(
        initials(name),
        style: TextStyle(
          color: theme.colorScheme.primary,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
        ),
      ),
    );

    final imageWidget = effectiveImageUrl != null
        ? CachedNetworkImage(
            imageUrl: effectiveImageUrl,
            fit: BoxFit.cover,
            alignment: alignment,
            filterQuality: FilterQuality.high,
            placeholder: (context, url) => placeholder,
            errorWidget: (context, url, error) => imageErrorPlaceholder(
              context,
              url,
              error,
              label: initials(name),
              iconSize: fontSize,
            ),
          )
        : placeholder;

    final containerDecoration = BoxDecoration(
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.8),
      shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
      borderRadius: isCircle ? null : BorderRadius.circular(borderRadius),
    );

    return Container(
      width: width,
      height: height,
      decoration: containerDecoration,
      clipBehavior: Clip.antiAlias,
      child: imageWidget,
    );
  }
}
