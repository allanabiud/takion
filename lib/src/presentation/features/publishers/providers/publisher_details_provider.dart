import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/domain/entities.dart";
import "package:takion/src/presentation/providers/providers.dart";

final publisherDetailsProvider = FutureProvider.autoDispose
    .family<PublisherDetails, int>((ref, id) async {
      return ref
          .watch(catalogRepositoryProvider)
          .getPublisherDetails(id, forceRefresh: false);
    });
