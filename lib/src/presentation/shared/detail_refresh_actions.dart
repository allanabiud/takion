import "package:flutter/material.dart";
import "package:takion/src/presentation/shared/alerts/takion_alerts.dart";

/// Shared force-refresh flow for entity detail screens.
mixin DetailRefreshActions<T> {
  String get entityLabel;
  Future<T> fetchDetails();
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
