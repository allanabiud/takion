import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities/issue_details.dart';
import 'package:takion/src/domain/entities/series_details.dart';
import 'package:takion/src/presentation/providers/repository_providers.dart';

final readingListItemMetadataProvider = FutureProvider.family<dynamic, ({String targetId, bool isSeries})>((ref, args) async {
  final metronRepository = ref.read(metronRepositoryProvider);
  final id = int.tryParse(args.targetId.replaceAll(RegExp(r'\D'), '')) ?? 0;
  
  if (args.isSeries) {
    return await metronRepository.getSeriesDetails(id);
  } else {
    return await metronRepository.getIssueDetails(id);
  }
});
