import "package:flutter/material.dart";
import "package:takion/src/domain/common/string_extensions.dart";
import "package:takion/src/presentation/shared/widgets/components.dart";

class SmartEntityImage extends StatelessWidget {
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
    this.cacheWidth,
    this.cacheHeight,
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
  final int? cacheWidth;
  final int? cacheHeight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveCacheWidth = cacheWidth ?? (width.isFinite ? (width * 2).round() : null);
    final effectiveCacheHeight = cacheHeight ?? (height.isFinite ? (height * 2).round() : null);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.8),
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircle ? null : BorderRadius.circular(borderRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: EntityCover(
        imageUrl: imageUrl,
        placeholderLabel: initials(name),
        width: width,
        height: height,
        borderRadius: 0,
        aspectRatio: width / height,
        iconSize: fontSize,
        alignment: alignment,
        circular: isCircle,
        cacheWidth: effectiveCacheWidth,
        cacheHeight: effectiveCacheHeight,
        fadeInDuration: Duration.zero,
        fadeOutDuration: Duration.zero,
      ),
    );
  }
}
