import 'package:flutter/material.dart';
import 'package:takion/src/presentation/shared/alerts/takion_alerts.dart';

/// Shared favorite toggle with undo snackbar for entity detail screens.
///
/// Implementers supply the "is favorite" check and the toggle action; this
/// flips the state and surfaces an undoable confirmation. [context] is passed
/// explicitly so the mixin does not shadow a `State`'s own [BuildContext].
mixin FavoriteToggleActions {
  Future<void> toggleFavoriteWithUndo(
    BuildContext context, {
    required Future<bool> isFavorite,
    required Future<void> Function() toggle,
  }) async {
    try {
      final wasFavorite = await isFavorite;
      await toggle();
      if (context.mounted) {
        final added = !wasFavorite;
        (added ? TakionAlerts.successWithUndo : TakionAlerts.infoWithUndo)(
          context,
          added ? 'Added to Favourites' : 'Removed from Favourites',
          icon: Icons.favorite,
          actionLabel: 'Undo',
          onUndo: () async {
            await toggle();
          },
        );
      }
    } catch (e) {
      if (context.mounted) {
        TakionAlerts.error(context, 'Failed to update favourites');
      }
    }
  }
}