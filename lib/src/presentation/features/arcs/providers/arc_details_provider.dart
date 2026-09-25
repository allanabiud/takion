import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/domain/entities.dart";
import "package:takion/src/presentation/providers/providers.dart";

final arcDetailsProvider = FutureProvider.autoDispose.family<ArcDetails, int>((
  ref,
  id,
) async {
  return ref
      .watch(catalogRepositoryProvider)
      .getArcDetails(id, forceRefresh: false);
});
