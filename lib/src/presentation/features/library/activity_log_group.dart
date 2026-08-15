import "package:takion/src/domain/entities.dart";

class ActivityLogGroup {
  final ActivityEventType type;
  final List<LibraryActivityEvent> events;
  final DateTime date;
  final int? seriesId;
  final String? seriesName;
  final String? batchId;

  const ActivityLogGroup({
    required this.type,
    required this.events,
    required this.date,
    this.seriesId,
    this.seriesName,
    this.batchId,
  });

  int get count => events.length;

  List<String?> get imageUrls => events.map((e) => e.imageUrl).toList();

  List<int> get issueIds => events.map((e) => e.issueId).toList();

  DateTime get latestTimestamp {
    if (events.isEmpty) return date;
    DateTime latest = events.first.timestamp;
    for (final e in events) {
      if (e.timestamp.isAfter(latest)) latest = e.timestamp;
    }
    return latest;
  }
}

const maxItemsPerActivityGroup = 25;
const activityGroupWindow = Duration(minutes: 15);

List<ActivityLogGroup> groupActivityEvents(List<LibraryActivityEvent> events) {
  if (events.isEmpty) return const [];

  final sorted = List<LibraryActivityEvent>.from(events)
    ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

  final groups = <ActivityLogGroup>[];

  for (final event in sorted) {
    final local = event.timestamp.toLocal();
    final dateOnly = DateTime(local.year, local.month, local.day);
    final eventSeriesId = event.seriesId != 0 ? event.seriesId : null;
    final eventSeriesName = event.seriesName?.trim().isNotEmpty == true
        ? event.seriesName!.trim()
        : null;

    ActivityLogGroup? matchingGroup;

    for (final group in groups.reversed) {
      if (group.type != event.type || group.date != dateOnly) continue;

      final sameBatch =
          event.batchId != null &&
          group.batchId != null &&
          event.batchId == group.batchId;
      final sameSeries =
          eventSeriesId != null &&
          group.seriesId != null &&
          eventSeriesId == group.seriesId;

      final isCompatible =
          sameBatch ||
          sameSeries ||
          (event.batchId == null && group.batchId == null && sameSeries);

      if (isCompatible) {
        final groupStartTimestamp = group.events.first.timestamp;
        final timeDiff = groupStartTimestamp.difference(event.timestamp).abs();

        if (timeDiff <= activityGroupWindow &&
            group.events.length < maxItemsPerActivityGroup) {
          matchingGroup = group;
          break;
        }
      }
    }

    if (matchingGroup != null) {
      matchingGroup.events.add(event);
    } else {
      groups.add(
        ActivityLogGroup(
          type: event.type,
          events: [event],
          date: dateOnly,
          seriesId: eventSeriesId,
          seriesName: eventSeriesName,
          batchId: event.batchId,
        ),
      );
    }
  }

  return groups;
}
