import "package:flutter/material.dart";
import "package:takion/src/core/logging/app_logger.dart";

Widget imageErrorPlaceholder(
  BuildContext context,
  String url,
  Object error, {
  String? label,
  IconData? icon,
  double? iconSize,
}) {
  AppLogger.warning("Image load failed: $url", error: error);
  final theme = Theme.of(context);
  return Container(
    color: label != null && label.isNotEmpty
        ? theme.colorScheme.primaryContainer.withValues(alpha: 0.8)
        : theme.colorScheme.surfaceContainerHighest,
    child: Center(
      child: label != null && label.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                label,
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontSize: iconSize ?? 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            )
          : Icon(icon ?? Icons.broken_image, size: iconSize ?? 24),
    ),
  );
}
