import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/presentation/common/takion_alerts.dart';
import 'package:takion/src/presentation/features/library/providers/subscription_pull_reconciler.dart';
import 'package:takion/src/presentation/features/releases/providers/selected_week_provider.dart';
import 'package:takion/src/presentation/features/series/providers/subscriptions_provider.dart';
import 'package:takion/src/presentation/providers/providers.dart';

Future<void> toggleSeriesSubscription({
  required BuildContext context,
  required ProviderContainer container,
  required bool enabled,
  required int seriesId,
}) async {
  try {
    final subscriptionRepository = container.read(subscriptionRepositoryProvider);
    final pullListRepository = container.read(pullListRepositoryProvider);

    List<int>? affectedIssueIds;
    if (enabled) {
      await subscriptionRepository.subscribe(metronSeriesId: seriesId);
    } else {
      await subscriptionRepository.unsubscribe(seriesId);
      final deleted = await pullListRepository.deleteEntriesBySeriesId(seriesId);
      affectedIssueIds = deleted.map((e) => e.metronIssueId).toList();
    }
    final now = DateTime.now();
    final startOfWeek = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday % 7));
    await pullListRepository.regenerateFromSubscriptions(fromDate: startOfWeek);

    if (enabled) {
      final result = await container
          .read(subscriptionPullReconcilerProvider)
          .reconcile(force: true, onlySeriesId: seriesId);
      affectedIssueIds = result.issueIds;
    }

    final selectedWeek = container.read(selectedWeekProvider);
    invalidateOnSubscriptionToggleContainer(container,
      seriesId: seriesId,
      selectedWeek: selectedWeek,
      affectedIssueIds: affectedIssueIds,
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
          await pullListRepository.deleteEntriesBySeriesId(seriesId);
        } else {
          await subscriptionRepository.subscribe(metronSeriesId: seriesId);
        }
        invalidateOnSubscriptionToggleContainer(container,
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
