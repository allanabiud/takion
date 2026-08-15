import "package:flutter/material.dart";
import "package:takion/src/presentation/shared/alerts/takion_alerts.dart";

/// Shared force-refresh flow for entity detail screens.
///
/// Implementers supply how to fetch fresh details, how to read the currently
/// stored value, and how to invalidate the relevant providers. This mixin
/// re-fetches, invalidates only when the value changed, and surfaces success
/// / error alerts. [context] is passed explicitly so the mixin does not shadow
/// a `State`'s own [BuildContext].
mixin DetailRefreshActions<T> {
  /// Capitalized entity label, e.g. `Team` or `Publisher`.
  String get entityLabel;

  /// Fetches fresh details from the catalog (force refresh).
  Future<T> fetchDetails();

  /// Invalidates the provider(s) backing this screen.
  void invalidateDetails();

  Future<void> refreshDetails(BuildContext context) async {
    try {
      await fetchDetails();
      invalidateDetails();
      if (context.mounted) {
        TakionAlerts.success(context, "$entityLabel details refreshed");
      }
    } catch (e) {
      if (context.mounted) {
        TakionAlerts.error(
          context,
          "Failed to refresh ${entityLabel.toLowerCase()} details",
        );
      }
    }
  }
}