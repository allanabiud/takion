import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/cache/entity_image_cache.dart';
import 'package:takion/src/domain/entities/publisher_details.dart';
import 'package:takion/src/presentation/providers/repository_providers.dart';

final publisherDetailsProvider =
    FutureProvider.family<PublisherDetails, int>((ref, id) async {
  final repository = ref.watch(catalogRepositoryProvider);
  final result = await repository.getPublisherDetails(id);
  if (result.image != null && result.image!.trim().isNotEmpty) {
    ref.read(entityImageCacheProvider).set('publisher', id, result.image!);
    ref.read(entityImageVersionProvider.notifier).update((s) => s + 1);
  }
  return result;
});
