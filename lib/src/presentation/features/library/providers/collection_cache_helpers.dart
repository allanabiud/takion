import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/presentation/features/library/providers/collection_items_provider.dart';

Future<void> invalidateLibraryItemsLocalCache(Ref ref) {
  ref.invalidate(allLibraryItemsProvider);
  return Future<void>.value();
}
