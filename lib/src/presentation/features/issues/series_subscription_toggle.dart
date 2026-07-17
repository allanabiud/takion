import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/presentation/common/takion_alerts.dart';
import 'package:takion/src/presentation/features/library/providers/subscription_pull_reconciler.dart';
import 'package:takion/src/presentation/features/releases/providers/selected_week_provider.dart';
import 'package:takion/src/presentation/features/series/providers/subscriptions_provider.dart';
import 'package:takion/src/presentation/providers/providers.dart';

Future<void> toggleSeriesSubscription(
  BuildContext context,
  WidgetRef ref,
  bool enabled,
  int seriesId,
) async {
  try {
    final subscriptionRepository = ref.read(subscriptionRepositoryProvider);
    if (enabled) {
      await subscriptionRepository.subscribe(metronSeriesId: seriesId);
    } else {
      await subscriptionRepository.unsubscribe(seriesId);
      await ref
          .read(pullListRepositoryProvider)
          .deleteEntriesBySeriesId(seriesId);
    }
    final now = DateTime.now();
    final startOfWeek = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday % 7));
    await ref
        .read(pullListRepositoryProvider)
        .regenerateFromSubscriptions(fromDate: startOfWeek);
    if (enabled) {
      await ref
          .read(subscriptionPullReconcilerProvider)
          .reconcile(force: true, onlySeriesId: seriesId);
    }
    final selectedWeek = ref.read(selectedWeekProvider);
    invalidateOnSubscriptionToggle(ref,
      seriesId: seriesId,
      selectedWeek: selectedWeek,
    );
    if (!context.mounted) return;
    (enabled ? TakionAlerts.successWithUndo : TakionAlerts.infoWithUndo)(
      context,
      enabled ? 'Subscribed' : 'Unsubscribed',
      icon: Icons.notifications,
      actionLabel: 'Undo',
      onUndo: () async {
        if (enabled) {
          await subscriptionRepository.unsubscribe(seriesId);
          await ref
              .read(pullListRepositoryProvider)
              .deleteEntriesBySeriesId(seriesId);
        } else {
          await subscriptionRepository.subscribe(metronSeriesId: seriesId);
        }
        invalidateOnSubscriptionToggle(ref,
          seriesId: seriesId,
          selectedWeek: selectedWeek,
        );
      },
    );
  } catch (error) {
    if (context.mounted) {
      TakionAlerts.error(context, 'Failed to update subscription');
    }
  }
}
