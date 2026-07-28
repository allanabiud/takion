import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/cache/entity_image_cache.dart';
import 'package:takion/src/domain/entities.dart';
import 'package:takion/src/presentation/providers/providers.dart';

final characterDetailsProvider = FutureProvider.autoDispose
    .family<CharacterDetails, int>((ref, id) async {
      final details = await ref
          .watch(catalogRepositoryProvider)
          .getCharacterDetails(id, forceRefresh: false);
      if (details.image != null && details.image!.trim().isNotEmpty) {
        ref.read(entityImageCacheProvider).set('character', id, details.image!);
        ref
            .read(entityImageVersionProvider.notifier)
            .update((value) => value + 1);
      }
      return details;
    });
