import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:takion/hive_registrar.g.dart';
import 'package:workmanager/workmanager.dart';

const String _taskName = 'weeklyPullReminder';
const int _notificationId = 1001;
const String _notificationPayload = 'my-pulls';

@pragma('vm:entry-point')
void pullReminderBackgroundCallback() {
  Workmanager().executeTask((task, inputData) async {
    if (task != _taskName) return Future.value(false);

    await Hive.initFlutter();
    Hive.registerAdapters();

    final box = await Hive.openBox<Map>('local_pull_list_box');

    final now = DateTime.now();
    final weekStart = _weekStart(now);
    final weekEnd = weekStart.add(const Duration(days: 6));

    int count = 0;
    for (final raw in box.values) {
      final map = raw as Map<String, dynamic>;
      final releaseDate =
          DateTime.tryParse(map['release_date'] as String? ?? '');
      if (releaseDate != null && map['entry_status'] == 'upcoming') {
        final releaseDay = DateTime(
          releaseDate.year,
          releaseDate.month,
          releaseDate.day,
        );
        if (!releaseDay.isBefore(weekStart) && !releaseDay.isAfter(weekEnd)) {
          count++;
        }
      }
    }

    final plugin = FlutterLocalNotificationsPlugin();
    await plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );

    await plugin.show(
      _notificationId,
      'Pull List Reminder',
      'You have $count issue${count == 1 ? '' : 's'} in your pull list this week.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'takion_notifications',
          'Takion Notifications',
          channelDescription: 'General notifications from Takion',
          icon: 'ic_notification',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          playSound: true,
          visibility: NotificationVisibility.public,
        ),
      ),
      payload: _notificationPayload,
    );

    return Future.value(true);
  });
}

DateTime _weekStart(DateTime date) {
  final normalized = DateTime(date.year, date.month, date.day);
  final offset = normalized.weekday % 7;
  return normalized.subtract(Duration(days: offset));
}
