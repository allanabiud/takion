import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/presentation/features/library/providers/reading_history_provider.dart";

final dailyReadActivityProvider =
    FutureProvider.autoDispose<Map<DateTime, int>>((ref) async {
      final entries = await ref.watch(readingHistoryProvider.future);
      final activity = <DateTime, int>{};
      for (final entry in entries) {
        final local = entry.readAt.toLocal();
        final day = DateTime(local.year, local.month, local.day);
        activity.update(day, (count) => count + 1, ifAbsent: () => 1);
      }
      return activity;
    });
