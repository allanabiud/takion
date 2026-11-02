import "package:flutter/material.dart";

ButtonStyle detailHeaderIconButtonStyle(ThemeData theme) {
  return IconButton.styleFrom(
    backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(
      alpha: 0.85,
    ),
    foregroundColor: theme.colorScheme.onSurface,
    shape: const CircleBorder(),
    fixedSize: const Size(40, 40),
    padding: EdgeInsets.zero,
  );
}

class EntityDetailActions extends StatelessWidget {
  const EntityDetailActions({
    super.key,
    this.onRefresh,
    this.onShare,
    this.onOpenInBrowser,
    this.style,
  });

  final VoidCallback? onRefresh;
  final VoidCallback? onShare;
  final VoidCallback? onOpenInBrowser;
  final ButtonStyle? style;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_EntityMenuAction>(
      tooltip: "More options",
      style: style,
      onSelected: (action) {
        switch (action) {
          case _EntityMenuAction.refresh:
            onRefresh?.call();
          case _EntityMenuAction.share:
            onShare?.call();
          case _EntityMenuAction.openInBrowser:
            onOpenInBrowser?.call();
        }
      },
      itemBuilder: (context) => [
        if (onRefresh != null)
          const PopupMenuItem(
            value: _EntityMenuAction.refresh,
            child: Text("Refresh"),
          ),
        if (onShare != null)
          const PopupMenuItem(
            value: _EntityMenuAction.share,
            child: Text("Share"),
          ),
        if (onOpenInBrowser != null)
          const PopupMenuItem(
            value: _EntityMenuAction.openInBrowser,
            child: Text("Open in Metron"),
          ),
      ],
    );
  }
}

enum _EntityMenuAction { refresh, share, openInBrowser }

class FavoriteToggleButton extends StatelessWidget {
  const FavoriteToggleButton({
    super.key,
    required this.isFavorite,
    required this.onToggleFavorite,
    this.compact = false,
  });

  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final padding = compact
        ? EdgeInsets.zero
        : const EdgeInsets.symmetric(vertical: 14);

    final button = isFavorite
        ? FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.primaryContainer,
              foregroundColor: theme.colorScheme.onPrimaryContainer,
              padding: padding,
              iconSize: compact ? 22 : 28,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: onToggleFavorite,
            child: const Icon(Icons.favorite),
          )
        : FilledButton.tonal(
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.surfaceContainerHigh,
              foregroundColor: theme.colorScheme.onSurfaceVariant,
              padding: padding,
              iconSize: compact ? 22 : 28,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: onToggleFavorite,
            child: const Icon(Icons.favorite_border),
          );

    if (compact) {
      return SizedBox(width: 44, height: 44, child: button);
    }
    return button;
  }
}
