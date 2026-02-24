import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities/series_details.dart';
import 'package:takion/src/presentation/providers/repository_providers.dart';

final seriesDetailsProvider =
    FutureProvider.autoDispose.family<SeriesDetails, int>((ref, seriesId) {
      final repository = ref.watch(metronRepositoryProvider);
      return repository.getSeriesDetails(seriesId);
    });
