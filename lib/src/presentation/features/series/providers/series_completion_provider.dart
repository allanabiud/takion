import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities/library_item.dart';
import 'package:takion/src/presentation/features/library/providers/collection_items_provider.dart';

final seriesOwnedCountProvider = FutureProvider.autoDispose
    .family<int, int>((ref, seriesId) async {
  final libraryItems = await ref.watch(allLibraryItemsProvider.future);
  return libraryItems
      .where(
        (item) =>
            item.metronSeriesId == seriesId &&
            item.ownershipStatus == LibraryOwnershipStatus.owned,
      )
      .length;
});
