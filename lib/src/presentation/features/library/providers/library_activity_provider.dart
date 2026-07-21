import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities/entities.dart';
import 'package:takion/src/presentation/providers/providers.dart';

final recentActivityProvider = FutureProvider.autoDispose
    .family<List<LibraryActivityEvent>, ActivityEventType?>((ref, typeFilter) async {
  final repository = ref.read(activityRepositoryProvider);
  return repository.listEvents(limit: 100, typeFilter: typeFilter);
});

final seriesActivityProvider =
    FutureProvider.autoDispose.family<List<LibraryActivityEvent>, int>((
  ref,
  seriesId,
) async {
  final repository = ref.read(activityRepositoryProvider);
  return repository.getEventsBySeries(seriesId);
});
