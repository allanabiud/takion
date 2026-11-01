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
    final isDark = theme.brightness == Brightness.dark;

    return IconButton(
      tooltip: isFavorite ? "Remove from favorites" : "Add to favorites",
      icon: Icon(
        isFavorite ? Icons.favorite : Icons.favorite_border,
        color: isFavorite
            ? theme.colorScheme.primary
            : (isDark
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onSurfaceVariant),
        size: compact ? 20 : 24,
      ),
      onPressed: onToggleFavorite,
    );
  }
}
