import "dart:async";
import "package:takion/src/domain/entities.dart";

abstract class ActivityRepository {
  Future<void> addEvent(LibraryActivityEvent event);

  Future<void> batchAddEvents(
    List<LibraryActivityEvent> events, {
    String? batchId,
  });

  Future<List<LibraryActivityEvent>> listEvents({
    int limit = 50,
    int offset = 0,
    ActivityEventType? typeFilter,
  });

  Future<List<LibraryActivityEvent>> getEventsBySeries(int seriesId);

  Stream<List<LibraryActivityEvent>> watchRecent({int limit = 100});

  Stream<List<LibraryActivityEvent>> watchBySeriesId(int seriesId);

  Future<int> count({ActivityEventType? typeFilter});

  Future<void> deleteEventsByIssueIds(
    List<int> issueIds, {
    ActivityEventType? type,
  });
}
