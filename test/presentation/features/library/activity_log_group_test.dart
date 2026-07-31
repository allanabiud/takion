import 'package:flutter_test/flutter_test.dart';
import 'package:takion/src/domain/entities.dart';
import 'package:takion/src/presentation/features/library/activity_log_group.dart';

LibraryActivityEvent _event(
  int id,
  DateTime timestamp, {
  ActivityEventType type = ActivityEventType.read,
}) {
  return LibraryActivityEvent(
    id: 'act-$id',
    userId: 'local-user',
    type: type,
    issueId: id,
    seriesId: 1,
    timestamp: timestamp,
  );
}

void main() {
  group('groupActivityEvents', () {
    test('groups same-type events within the 5 minute window', () {
      final now = DateTime.utc(2026, 3, 5, 18, 30);
      final groups = groupActivityEvents([
        _event(1, now),
        _event(2, now.add(const Duration(minutes: 2))),
        _event(3, now.add(const Duration(minutes: 4))),
      ]);

      expect(groups, hasLength(1));
      expect(groups.single.count, 3);
    });

    test('splits groups when more than 5 minutes elapse', () {
      final now = DateTime.utc(2026, 3, 5, 18, 30);
      final groups = groupActivityEvents([
        _event(1, now),
        _event(2, now.add(const Duration(minutes: 2))),
        _event(3, now.add(const Duration(minutes: 12))),
        _event(4, now.add(const Duration(minutes: 14))),
      ]);

      expect(groups, hasLength(2));
      expect(groups[0].count, 2);
      expect(groups[1].count, 2);
    });

    test('splits groups on event type change', () {
      final now = DateTime.utc(2026, 3, 5, 18, 30);
      final groups = groupActivityEvents([
        _event(1, now, type: ActivityEventType.read),
        _event(
          2,
          now.add(const Duration(seconds: 30)),
          type: ActivityEventType.collected,
        ),
      ]);

      expect(groups, hasLength(2));
    });

    test('splits groups across calendar days', () {
      final localDayStart = DateTime(2026, 3, 5);
      final lateNight = localDayStart
          .subtract(const Duration(seconds: 1))
          .toUtc();
      final earlyMorning = localDayStart
          .add(const Duration(seconds: 1))
          .toUtc();
      final groups = groupActivityEvents([
        _event(1, lateNight),
        _event(2, earlyMorning),
      ]);

      expect(groups, hasLength(2));
    });

    test('keeps bulk events with identical timestamps in one group', () {
      final now = DateTime.utc(2026, 3, 5, 18, 30);
      final groups = groupActivityEvents([
        _event(1, now),
        _event(2, now),
        _event(3, now),
      ]);

      expect(groups, hasLength(1));
      expect(groups.single.count, 3);
    });

    test('orders groups newest first', () {
      final now = DateTime.utc(2026, 3, 5, 18, 30);
      final earlier = DateTime.utc(2026, 3, 5, 18, 0);
      final groups = groupActivityEvents([_event(1, earlier), _event(2, now)]);

      expect(groups, hasLength(2));
      expect(groups[0].latestTimestamp, now);
      expect(groups[1].latestTimestamp, earlier);
    });

    test('empty input produces no groups', () {
      expect(groupActivityEvents([]), isEmpty);
    });
  });
}
