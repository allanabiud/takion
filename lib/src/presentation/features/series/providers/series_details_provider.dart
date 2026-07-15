import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/cache/entity_image_cache.dart';
import 'package:takion/src/domain/entities/entities.dart';
import 'package:takion/src/presentation/providers/providers.dart';

final seriesDetailsProvider = FutureProvider.autoDispose
    .family<SeriesDetails, int>((ref, seriesId) async {
      final repository = ref.watch(metronRepositoryProvider);
      final result = await repository.getSeriesDetails(seriesId);
      if (result.image != null && result.image!.trim().isNotEmpty) {
        ref.read(entityImageCacheProvider).set('series', seriesId, result.image!);
        ref.read(entityImageVersionProvider.notifier).update((s) => s + 1);
      }
      return result;
    });
