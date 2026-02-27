import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities/collection_item_details.dart';

final collectionItemDetailsProvider =
    FutureProvider.autoDispose.family<CollectionItemDetails, int>((
      (ref, collectionId) => Future.error(
        UnsupportedError(
          'Collection item details are now Supabase-backed and this provider is deprecated.',
        ),
      ),
    );
