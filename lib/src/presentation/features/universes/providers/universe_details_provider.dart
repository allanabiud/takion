import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/cache/entity_image_cache.dart';
import 'package:takion/src/domain/entities/entities.dart';
import 'package:takion/src/presentation/providers/providers.dart';

final universeDetailsProvider =
    FutureProvider.family<UniverseDetails, int>((ref, id) async {
  final repository = ref.watch(catalogRepositoryProvider);
  final result = await repository.getUniverseDetails(id);
  if (result.image != null && result.image!.trim().isNotEmpty) {
    ref.read(entityImageCacheProvider).set('universe', id, result.image!);
    ref.read(entityImageVersionProvider.notifier).update((s) => s + 1);
  }
  return result;
});
