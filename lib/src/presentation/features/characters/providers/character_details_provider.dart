import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities/character_details.dart';
import 'package:takion/src/presentation/providers/repository_providers.dart';

final characterDetailsProvider =
    FutureProvider.family<CharacterDetails, int>((ref, id) {
  final repository = ref.watch(catalogRepositoryProvider);
  return repository.getCharacterDetails(id);
});
