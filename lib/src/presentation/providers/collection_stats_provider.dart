import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities/collection_stats.dart';
import 'package:takion/src/presentation/providers/repository_providers.dart';

final collectionStatsProvider = FutureProvider.autoDispose<CollectionStats>((
  ref,
) {
  final repository = ref.watch(metronRepositoryProvider);
  return repository.getCollectionStats();
});
