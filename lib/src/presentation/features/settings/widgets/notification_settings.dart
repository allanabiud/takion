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
                  'Weekly Pull List Reminder',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'Every Tuesday at 8:00 PM',
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
      ],
    ),
  );
}
