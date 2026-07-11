import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/presentation/components/takion_bottom_sheet.dart';
import 'package:takion/src/presentation/features/settings/widgets/settings_helpers.dart';
import 'package:takion/src/presentation/features/settings/providers/settings_provider.dart';
import 'package:takion/src/presentation/common/takion_alerts.dart';

void showNotificationSettings(BuildContext context, WidgetRef ref) {
  TakionBottomSheet.show(
    context: context,
    title: 'Notifications',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        buildSettingsGroup(context, 'Pull List', [
          Consumer(
            builder: (context, ref, _) {
              final enabledAsync = ref.watch(
                pushPullNotificationsEnabledProvider,
              );
              final enabled = enabledAsync.value ?? false;
              return SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Weekly Reminder',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'Receive notifications about your pull list releases',
                ),
                value: enabled,
                onChanged: enabledAsync.isLoading
                    ? null
                    : (bool value) async {
                        await ref
                            .read(
                              pushPullNotificationsEnabledProvider.notifier,
                            )
                            .setEnabled(value);
                        if (!context.mounted) return;
                        if (value) {
                          TakionAlerts.success(
                            context,
                            'Reminders Enabled',
                          );
                        } else {
                          TakionAlerts.info(
                            context,
                            'Reminders Disabled',
                          );
                        }
                      },
              );
            },
          ),
        ]),
        const SizedBox(height: 16),
        buildSettingsGroup(context, 'Scheduling', [
          Consumer(
            builder: (context, ref, _) {
              final timingAsync = ref.watch(pullNotificationTimingProvider);
              final timing = timingAsync.value ?? PullNotificationTiming.releaseDay;
              final enabledAsync = ref.watch(pushPullNotificationsEnabledProvider);
              final notificationsEnabled = enabledAsync.value ?? false;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'When to notify you before release day',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  RadioGroup<PullNotificationTiming>(
                    groupValue: timing,
                    onChanged: (value) {
                      if (value == null || timingAsync.isLoading) return;
                      ref
                          .read(pullNotificationTimingProvider.notifier)
                          .setTiming(value);
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RadioListTile<PullNotificationTiming>(
                          value: PullNotificationTiming.dayBefore,
                          title: const Text('Day before'),
                          subtitle: const Text('Tuesday'),
                          contentPadding: EdgeInsets.zero,
                          enabled: !timingAsync.isLoading && notificationsEnabled,
                        ),
                        RadioListTile<PullNotificationTiming>(
                          value: PullNotificationTiming.releaseDay,
                          title: const Text('On release day'),
                          subtitle: const Text('Wednesday'),
                          contentPadding: EdgeInsets.zero,
                          enabled: !timingAsync.isLoading && notificationsEnabled,
                        ),
                        RadioListTile<PullNotificationTiming>(
                          value: PullNotificationTiming.dayAfter,
                          title: const Text('Day after'),
                          subtitle: const Text('Thursday'),
                          contentPadding: EdgeInsets.zero,
                          enabled: !timingAsync.isLoading && notificationsEnabled,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ]),
      ],
    ),
  );
}
