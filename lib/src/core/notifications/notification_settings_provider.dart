import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/storage/hive_service.dart';

enum NotificationDay {
  tuesday('Tuesday', DateTime.tuesday),
  wednesday('Wednesday', DateTime.wednesday),
  thursday('Thursday', DateTime.thursday);

  const NotificationDay(this.label, this.dartWeekday);
  final String label;
  final int dartWeekday;
}

final notificationsEnabledProvider =
    AsyncNotifierProvider<NotificationsEnabledNotifier, bool>(
  NotificationsEnabledNotifier.new,
);

class NotificationsEnabledNotifier extends AsyncNotifier<bool> {
  static const _boxName = 'settings_box';
  static const _key = 'weekly_pull_notifications_enabled';

  @override
  Future<bool> build() async {
    final hive = ref.read(hiveServiceProvider);
    final box = await hive.openBox(_boxName);
    return (box.get(_key, defaultValue: false) as bool?) ?? false;
  }

  Future<void> setEnabled(bool enabled) async {
    final hive = ref.read(hiveServiceProvider);
    final box = await hive.openBox(_boxName);
    await box.put(_key, enabled);
    state = AsyncValue.data(enabled);
  }
}

final notificationDayProvider =
    AsyncNotifierProvider<NotificationDayNotifier, NotificationDay>(
  NotificationDayNotifier.new,
);

class NotificationDayNotifier extends AsyncNotifier<NotificationDay> {
  static const _boxName = 'settings_box';
  static const _key = 'weekly_pull_notification_day';

  @override
  Future<NotificationDay> build() async {
    final hive = ref.read(hiveServiceProvider);
    final box = await hive.openBox(_boxName);
    final raw = box.get(_key, defaultValue: 'wednesday') as String? ?? 'wednesday';
    return switch (raw) {
      'tuesday' => NotificationDay.tuesday,
      'thursday' => NotificationDay.thursday,
      _ => NotificationDay.wednesday,
    };
  }

  Future<void> setDay(NotificationDay day) async {
    final hive = ref.read(hiveServiceProvider);
    final box = await hive.openBox(_boxName);
    final raw = switch (day) {
      NotificationDay.tuesday => 'tuesday',
      NotificationDay.wednesday => 'wednesday',
      NotificationDay.thursday => 'thursday',
    };
    await box.put(_key, raw);
    state = AsyncValue.data(day);
  }
}
