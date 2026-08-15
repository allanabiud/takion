import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/domain/entities.dart";
import "package:takion/src/presentation/providers/providers.dart";

final recentActivityProvider = StreamProvider.autoDispose
    .family<List<LibraryActivityEvent>, ActivityEventType?>((ref, typeFilter) {
      final repository = ref.watch(activityRepositoryProvider);
      return repository.watchRecent(limit: 100).map((events) {
        if (typeFilter == null) return events;
        return events.where((e) => e.type == typeFilter).toList();
      });
    });

final seriesActivityProvider = StreamProvider.autoDispose
    .family<List<LibraryActivityEvent>, int>((ref, seriesId) {
      final repository = ref.watch(activityRepositoryProvider);
      return repository.watchBySeriesId(seriesId);
    });
