import "dart:async";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/presentation/shared/alerts/takion_alerts.dart";
import "package:takion/src/presentation/features/library/providers/subscription_pull_reconciler.dart";
import "package:takion/src/presentation/providers/providers.dart";

Future<void> toggleSeriesSubscription({
  required BuildContext context,
  required ProviderContainer container,
  required bool enabled,
  required int seriesId,
}) async {
  try {
    final subscriptionRepository = container.read(
      subscriptionRepositoryProvider,
    );
    final pullListRepository = container.read(pullListRepositoryProvider);

    if (enabled) {
      await subscriptionRepository.subscribe(metronSeriesId: seriesId);
    } else {
      await subscriptionRepository.unsubscribe(seriesId);
      await pullListRepository.deleteEntriesBySeriesId(seriesId);
    }

    if (enabled) {
      await container
          .read(subscriptionPullReconcilerProvider)
          .reconcile(force: true, onlySeriesId: seriesId);
    }

    if (!context.mounted) return;
    (enabled ? TakionAlerts.successWithUndo : TakionAlerts.infoWithUndo)(
      context,
      enabled ? "Subscribed" : "Unsubscribed",
      icon: Icons.notifications,
      actionLabel: "Undo",
      onUndo: () async {
        if (enabled) {
          await subscriptionRepository.unsubscribe(seriesId);
          await pullListRepository.deleteEntriesBySeriesId(seriesId);
        } else {
          await subscriptionRepository.subscribe(metronSeriesId: seriesId);
        }
      },
    );
  } catch (error) {
    if (context.mounted) {
      TakionAlerts.error(context, "Failed to update subscription");
    }
  }
}
