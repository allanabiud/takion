import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities/collection_item_details.dart';
import 'package:takion/src/presentation/providers/repository_providers.dart';

final collectionItemDetailsProvider =
    FutureProvider.autoDispose.family<CollectionItemDetails, int>((
      ref,
      collectionId,
    ) {
      final repository = ref.watch(metronRepositoryProvider);
      return repository.getCollectionItemDetails(collectionId);
    });
