import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/domain/entities.dart";
import "package:takion/src/presentation/providers/providers.dart";

final characterDetailsProvider = FutureProvider.autoDispose
    .family<CharacterDetails, int>((ref, id) async {
      return ref
          .watch(catalogRepositoryProvider)
          .getCharacterDetails(id, forceRefresh: false);
    });
