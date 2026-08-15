import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/core/notifications/notification_service.dart";
import "package:takion/src/core/storage/drift_database_provider.dart";
import "package:takion/src/presentation/features/library/providers/pulls_provider.dart";

enum NotificationDay {
  tuesday("Before Release Day", DateTime.tuesday),
  wednesday("Release Day", DateTime.wednesday),
  thursday("After Release Day", DateTime.thursday);

  const NotificationDay(this.label, this.dartWeekday);
  final String label;
  final int dartWeekday;
}

final notificationsEnabledProvider =
    AsyncNotifierProvider<NotificationsEnabledNotifier, bool>(
      NotificationsEnabledNotifier.new,
    );

class NotificationsEnabledNotifier extends AsyncNotifier<bool> {
  static const _key = "weekly_pull_notifications_enabled";

  @override
  Future<bool> build() async {
    final dao = ref.read(driftDatabaseProvider).settingsDao;
    return await dao.getBool(_key);
  }

  Future<void> setEnabled(bool enabled) async {
    final dao = ref.read(driftDatabaseProvider).settingsDao;
    await dao.setBool(_key, enabled);
    state = AsyncValue.data(enabled);
  }
}

final notificationDayProvider =
    AsyncNotifierProvider<NotificationDayNotifier, NotificationDay>(
      NotificationDayNotifier.new,
    );

class NotificationDayNotifier extends AsyncNotifier<NotificationDay> {
  static const _key = "weekly_pull_notification_day";

  @override
  Future<NotificationDay> build() async {
    final dao = ref.read(driftDatabaseProvider).settingsDao;
    final raw = await dao.getString(_key) ?? "wednesday";
    return switch (raw) {
      "tuesday" => NotificationDay.tuesday,
      "thursday" => NotificationDay.thursday,
      _ => NotificationDay.wednesday,
    };
  }

  Future<void> setDay(NotificationDay day) async {
    final dao = ref.read(driftDatabaseProvider).settingsDao;
    final raw = switch (day) {
      NotificationDay.tuesday => "tuesday",
      NotificationDay.wednesday => "wednesday",
      NotificationDay.thursday => "thursday",
    };
    await dao.setString(_key, raw);
    state = AsyncValue.data(day);
  }
}

/// Rebuilds the recurring reminder; awaiting avoids reading provider loading defaults at startup.
Future<void> scheduleWeeklyPullNotification(dynamic ref) async {
  final enabled = await ref.read(notificationsEnabledProvider.future);
  if (!enabled) {
    await NotificationService.instance.cancel();
    return;
  }

  final day = await ref.read(notificationDayProvider.future);
  final pulls = await ref.read(currentWeekPullsProvider.future);
  await NotificationService.instance.scheduleWeekly(pulls.length, day);
}
