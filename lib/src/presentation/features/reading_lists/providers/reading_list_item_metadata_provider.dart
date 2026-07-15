import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/presentation/providers/providers.dart';

final readingListItemMetadataProvider =
    FutureProvider.family<dynamic, ({String targetId, bool isSeries})>((
      ref,
      args,
    ) async {
      final metronRepository = ref.read(metronRepositoryProvider);
      final id = int.tryParse(args.targetId.replaceAll(RegExp(r'\D'), '')) ?? 0;

      if (args.isSeries) {
        return await metronRepository.getSeriesDetails(id);
      } else {
        return await metronRepository.getIssueDetails(id);
      }
    });
