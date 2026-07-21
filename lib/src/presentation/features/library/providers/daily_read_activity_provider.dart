import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/presentation/features/library/providers/collection_items_provider.dart';

final dailyReadActivityProvider =
    FutureProvider.autoDispose<Map<DateTime, int>>((ref) async {
      final libraryItems = await ref.watch(allLibraryItemsProvider.future);
      final readItems = libraryItems.where((item) => item.isRead).toList();

      final activity = <DateTime, int>{};
      for (final item in readItems) {
        final date = item.firstReadAt?.toLocal();
        if (date == null) continue;
        final day = DateTime(date.year, date.month, date.day);
        activity.update(day, (count) => count + 1, ifAbsent: () => 1);
      }
      return activity;
    });
