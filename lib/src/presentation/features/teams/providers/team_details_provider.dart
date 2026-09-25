import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/domain/entities.dart";
import "package:takion/src/presentation/providers/providers.dart";

final teamDetailsProvider = FutureProvider.autoDispose.family<TeamDetails, int>(
  (ref, id) async {
    return ref
        .watch(catalogRepositoryProvider)
        .getTeamDetails(id, forceRefresh: false);
  },
);
