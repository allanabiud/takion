import 'package:takion/src/domain/entities.dart';

class ActivityLogGroup {
  final ActivityEventType type;
  final List<LibraryActivityEvent> events;
  final DateTime date;

  const ActivityLogGroup({
    required this.type,
    required this.events,
    required this.date,
  });

  int get count => events.length;

  List<String?> get imageUrls => events.map((e) => e.imageUrl).toList();

  List<int> get issueIds => events.map((e) => e.issueId).toList();

  DateTime get latestTimestamp {
    DateTime latest = events.first.timestamp;
    for (final e in events) {
      if (e.timestamp.isAfter(latest)) latest = e.timestamp;
    }
    return latest;
  }
}

List<ActivityLogGroup> groupActivityEvents(List<LibraryActivityEvent> events) {
  final sorted = List<LibraryActivityEvent>.from(events)
    ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

  final Map<String, ActivityLogGroup> groups = {};

  for (final event in sorted) {
    final local = event.timestamp.toLocal();
    final dateOnly = DateTime(local.year, local.month, local.day);
    final key = '${dateOnly.millisecondsSinceEpoch}:${event.type.name}';

    groups
        .putIfAbsent(
          key,
          () => ActivityLogGroup(type: event.type, events: [], date: dateOnly),
        )
        .events
        .add(event);
  }

  final result = groups.values.toList();
  result.sort((a, b) => b.date.compareTo(a.date));
  return result;
}
