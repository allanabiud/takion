import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities/imprint_details.dart';
import 'package:takion/src/presentation/providers/repository_providers.dart';

final imprintDetailsProvider =
    FutureProvider.family<ImprintDetails, int>((ref, id) async {
  final repository = ref.watch(catalogRepositoryProvider);
  return repository.getImprintDetails(id);
});
