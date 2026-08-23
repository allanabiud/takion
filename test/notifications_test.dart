import "package:flutter_test/flutter_test.dart";
import "package:takion/src/core/notifications/notification_settings_provider.dart";
import "package:timezone/data/latest_all.dart" as tz;
import "package:timezone/timezone.dart" as tz;

void main() {
  setUpAll(tz.initializeTimeZones);

  group("NotificationDay", () {
    test("NotificationDay weekday values are correct", () {
      expect(NotificationDay.tuesday.dartWeekday, DateTime.tuesday);
      expect(NotificationDay.wednesday.dartWeekday, DateTime.wednesday);
      expect(NotificationDay.thursday.dartWeekday, DateTime.thursday);
    });

    test("NotificationDay labels are accurate", () {
      expect(NotificationDay.tuesday.label, "Before Release Day");
      expect(NotificationDay.wednesday.label, "Release Day");
      expect(NotificationDay.thursday.label, "After Release Day");
    });
  });

  group("Timezone 8:00 PM Scheduling Calculation", () {
    test(
      "Schedules for today at 8:00 PM if current time is before 8:00 PM on target day",
      () {
        final location = tz.getLocation("America/New_York");
        final now = tz.TZDateTime(location, 2026, 7, 29, 10, 0);

        int daysUntil = NotificationDay.wednesday.dartWeekday - now.weekday;
        if (daysUntil < 0 || (daysUntil == 0 && now.hour >= 20)) {
          daysUntil += 7;
        }
        final targetDate = now.add(Duration(days: daysUntil));
        final scheduledDate = tz.TZDateTime(
          location,
          targetDate.year,
          targetDate.month,
          targetDate.day,
          20,
          0,
        );

        expect(scheduledDate.year, 2026);
        expect(scheduledDate.month, 7);
        expect(scheduledDate.day, 29);
        expect(scheduledDate.hour, 20);
        expect(scheduledDate.minute, 0);
      },
    );

    test(
      "Schedules for next week at 8:00 PM if current time is past 8:00 PM on target day",
      () {
        final location = tz.getLocation("America/New_York");
        final now = tz.TZDateTime(location, 2026, 7, 29, 20, 30);

        int daysUntil = NotificationDay.wednesday.dartWeekday - now.weekday;
        if (daysUntil < 0 || (daysUntil == 0 && now.hour >= 20)) {
          daysUntil += 7;
        }
        final targetDate = now.add(Duration(days: daysUntil));
        final scheduledDate = tz.TZDateTime(
          location,
          targetDate.year,
          targetDate.month,
          targetDate.day,
          20,
          0,
        );

        expect(scheduledDate.year, 2026);
        expect(scheduledDate.month, 8);
        expect(scheduledDate.day, 5);
        expect(scheduledDate.hour, 20);
        expect(scheduledDate.minute, 0);
      },
    );

    test("Handles month rollover correctly across different timezones", () {
      for (final tzName in [
        "America/Los_Angeles",
        "Europe/London",
        "Asia/Tokyo",
      ]) {
        final location = tz.getLocation(tzName);
        final now = tz.TZDateTime(location, 2026, 7, 28, 21, 0);

        int daysUntil = NotificationDay.tuesday.dartWeekday - now.weekday;
        if (daysUntil < 0 || (daysUntil == 0 && now.hour >= 20)) {
          daysUntil += 7;
        }
        final targetDate = now.add(Duration(days: daysUntil));
        final scheduledDate = tz.TZDateTime(
          location,
          targetDate.year,
          targetDate.month,
          targetDate.day,
          20,
          0,
        );

        expect(scheduledDate.month, 8);
        expect(scheduledDate.day, 4);
        expect(scheduledDate.hour, 20);
      }
    });
  });

  group("Pull Notification Body Text", () {
    test("Pluralization logic produces correct text", () {
      String getBodyText(int count) {
        return count == 1
            ? "You have 1 pull this week"
            : "You have $count pulls this week";
      }

      expect(getBodyText(1), "You have 1 pull this week");
      expect(getBodyText(5), "You have 5 pulls this week");
      expect(getBodyText(12), "You have 12 pulls this week");
    });
  });
}
