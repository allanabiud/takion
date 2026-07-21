import 'package:takion/src/domain/entities/entities.dart';

abstract class ActivityRepository {
  Future<void> addEvent(LibraryActivityEvent event);

  Future<List<LibraryActivityEvent>> listEvents({
    int limit = 50,
    int offset = 0,
    ActivityEventType? typeFilter,
  });

  Future<List<LibraryActivityEvent>> getEventsBySeries(int seriesId);

  Future<int> count({ActivityEventType? typeFilter});
}
