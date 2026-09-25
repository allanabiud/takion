import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/domain/entities.dart";
import "package:takion/src/presentation/providers/providers.dart";

final creatorDetailsProvider = FutureProvider.autoDispose
    .family<CreatorDetails, int>((ref, id) async {
      return ref
          .watch(catalogRepositoryProvider)
          .getCreatorDetails(id, forceRefresh: false);
    });
