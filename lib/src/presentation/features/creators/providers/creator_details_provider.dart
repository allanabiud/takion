import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities/creator_details.dart';
import 'package:takion/src/presentation/providers/repository_providers.dart';

final creatorDetailsProvider =
    FutureProvider.family<CreatorDetails, int>((ref, id) async {
  final repository = ref.watch(catalogRepositoryProvider);
  return repository.getCreatorDetails(id);
});
