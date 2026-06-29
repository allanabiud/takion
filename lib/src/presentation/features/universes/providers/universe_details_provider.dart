import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities/universe_details.dart';
import 'package:takion/src/presentation/providers/repository_providers.dart';

final universeDetailsProvider =
    FutureProvider.family<UniverseDetails, int>((ref, id) async {
  final repository = ref.watch(catalogRepositoryProvider);
  return repository.getUniverseDetails(id);
});
