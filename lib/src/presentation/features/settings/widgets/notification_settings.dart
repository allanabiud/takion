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
        buildSettingsGroup(context, 'Pull List Notifications', [
          Consumer(
            builder: (context, ref, _) {
              final enabledAsync = ref.watch(
                pushPullNotificationsEnabledProvider,
              );
              final enabled = enabledAsync.value ?? false;
              return SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Enable Weekly Pull List Reminder',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'Get weekly notification on pull list.',
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
          const SizedBox(height: 8),
          Consumer(
            builder: (context, ref, _) {
              final scheduleAsync = ref.watch(pullReminderScheduleProvider);
              final schedule = scheduleAsync.value ?? const PullReminderSchedule(weekday: 2, hour: 20, minute: 0);
              final enabled = (ref.watch(pushPullNotificationsEnabledProvider).value ?? false);

              final dayLabels = const {
                1: 'Mon',
                2: 'Tue',
                3: 'Wed',
                4: 'Thu',
                5: 'Fri',
                6: 'Sat',
                7: 'Sun',
              };

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Schedule',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surface,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: DropdownButton<int>(
                                  value: schedule.weekday,
                                  underline: const SizedBox.shrink(),
                                  items: dayLabels.entries
                                      .map(
                                        (e) => DropdownMenuItem<int>(
                                          value: e.key,
                                          child: Text(e.value),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: enabled
                                      ? (val) async {
                                          if (val == null) return;
                                          final newSchedule = PullReminderSchedule(
                                            weekday: val,
                                            hour: schedule.hour,
                                            minute: schedule.minute,
                                          );
                                          await ref
                                              .read(pullReminderScheduleProvider.notifier)
                                              .setSchedule(newSchedule);
                                        }
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                onPressed: enabled
                                    ? () async {
                                        final picked = await showTimePicker(
                                          context: context,
                                          initialTime: TimeOfDay(hour: schedule.hour, minute: schedule.minute),
                                        );
                                        if (picked == null) return;
                                        final newSchedule = PullReminderSchedule(
                                          weekday: schedule.weekday,
                                          hour: picked.hour,
                                          minute: picked.minute,
                                        );
                                        await ref
                                            .read(pullReminderScheduleProvider.notifier)
                                            .setSchedule(newSchedule);
                                      }
                                    : null,
                                icon: const Icon(Icons.access_time),
                                label: Text('${schedule.hour.toString().padLeft(2, '0')}:${schedule.minute.toString().padLeft(2, '0')}'),
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                  foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                              ),
                              const Spacer(),
                            ],
                          ),
                          if (!enabled)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                'Enable reminders to change schedule',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ]),
      ],
    ),
  );
}
