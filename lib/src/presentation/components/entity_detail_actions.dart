import 'package:flutter/material.dart';

class EntityDetailActions extends StatelessWidget {
  const EntityDetailActions({
    super.key,
    this.onShare,
    this.onOpenInBrowser,
  });

  final VoidCallback? onShare;
  final VoidCallback? onOpenInBrowser;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_EntityMenuAction>(
      tooltip: 'More options',
      onSelected: (action) {
        switch (action) {
          case _EntityMenuAction.share:
            onShare?.call();
          case _EntityMenuAction.openInBrowser:
            onOpenInBrowser?.call();
        }
      },
      itemBuilder: (context) => [
        if (onShare != null)
          const PopupMenuItem(
            value: _EntityMenuAction.share,
            child: Text('Share'),
          ),
        if (onOpenInBrowser != null)
          const PopupMenuItem(
            value: _EntityMenuAction.openInBrowser,
            child: Text('Open in Metron'),
          ),
      ],
    );
  }
}

enum _EntityMenuAction { share, openInBrowser }

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
    final padding = compact ? EdgeInsets.zero : const EdgeInsets.symmetric(vertical: 14);

    final button = isFavorite
        ? FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.primaryContainer,
              foregroundColor: theme.colorScheme.onPrimaryContainer,
              padding: padding,
              iconSize: 28,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: onToggleFavorite,
            child: const Icon(Icons.favorite),
          )
        : FilledButton.tonal(
            style: FilledButton.styleFrom(
              padding: padding,
              iconSize: 28,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: onToggleFavorite,
            child: const Icon(Icons.favorite_border),
          );

    if (compact) {
      return SizedBox(width: 52, height: 52, child: button);
    }
    return button;
  }
}
