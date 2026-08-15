import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/presentation/providers/providers.dart";

final readingListItemCachedMetadataProvider =
    StreamProvider.autoDispose.family<Object?, ({String targetId, bool isSeries})>((
      ref,
      args,
    ) async* {
      final localCatalog = ref.watch(localCatalogRepositoryProvider);
      final id = int.tryParse(args.targetId.replaceAll(RegExp(r"\D"), "")) ?? 0;
      if (id <= 0) {
        yield null;
        return;
      }

      if (args.isSeries) {
        yield* localCatalog.watchSeriesDetails(id);
      } else {
        yield* localCatalog.watchIssueDetails(id);
      }
    });
