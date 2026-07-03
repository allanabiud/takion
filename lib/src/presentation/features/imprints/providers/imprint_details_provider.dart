import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/cache/entity_image_cache.dart';
import 'package:takion/src/domain/entities/imprint_details.dart';
import 'package:takion/src/presentation/providers/repository_providers.dart';

final imprintDetailsProvider =
    FutureProvider.family<ImprintDetails, int>((ref, id) async {
  final repository = ref.watch(catalogRepositoryProvider);
  final result = await repository.getImprintDetails(id);
  if (result.image != null && result.image!.trim().isNotEmpty) {
    ref.read(entityImageCacheProvider).set('imprint', id, result.image!);
    ref.read(entityImageVersionProvider.notifier).update((s) => s + 1);
  }
  return result;
});
