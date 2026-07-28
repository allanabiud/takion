import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/notifications/notification_service.dart';
import 'package:takion/src/core/notifications/notification_settings_provider.dart';
import 'package:takion/src/presentation/shared/widgets/components.dart';
import 'package:takion/src/presentation/features/settings/widgets/settings_helpers.dart';

void showNotificationSettings(BuildContext context, WidgetRef ref) {
  TakionBottomSheet.show(
    context: context,
    title: 'Notifications',
    child: Consumer(
      builder: (context, ref, _) {
        final enabledAsync = ref.watch(notificationsEnabledProvider);
        final dayAsync = ref.watch(notificationDayProvider);
        final enabled = enabledAsync.value ?? false;
        final selectedDay = dayAsync.value ?? NotificationDay.wednesday;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildSettingsGroup(context, 'Pull Notifications', [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Pull Notifications',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    'Get a weekly notification of your pulls',
                  ),
                  value: enabled,
                  onChanged: enabledAsync.isLoading
                      ? null
                      : (v) async {
                          if (v) {
                            final granted = await NotificationService.instance
                                .requestPermissions();
                            if (!granted) return;
                            await NotificationService.instance
                                .requestExactAlarmPermission();
                          }
                          await ref
                              .read(notificationsEnabledProvider.notifier)
                              .setEnabled(v);
                          await scheduleWeeklyPullNotification(ref);
                        },
                ),
                const Divider(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Remind Me On',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              '${selectedDay.label} at 8:00 PM',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                RadioGroup<NotificationDay>(
                  groupValue: selectedDay,
                  onChanged: (value) async {
                    if (value == null || !enabled || dayAsync.isLoading) return;
                    await ref
                        .read(notificationDayProvider.notifier)
                        .setDay(value);
                    await scheduleWeeklyPullNotification(ref);
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RadioListTile<NotificationDay>(
                        value: NotificationDay.tuesday,
                        title: const Text('Before Release Day'),
                        contentPadding: EdgeInsets.zero,
                        enabled: enabled && !dayAsync.isLoading,
                      ),
                      RadioListTile<NotificationDay>(
                        value: NotificationDay.wednesday,
                        title: const Text('Release Day'),
                        contentPadding: EdgeInsets.zero,
                        enabled: enabled && !dayAsync.isLoading,
                      ),
                      RadioListTile<NotificationDay>(
                        value: NotificationDay.thursday,
                        title: const Text('After Release Day'),
                        contentPadding: EdgeInsets.zero,
                        enabled: enabled && !dayAsync.isLoading,
                      ),
                    ],
                  ),
                ),
              ]),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    ),
  );
}
