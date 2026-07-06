import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/presentation/providers/repository_providers.dart';

final readingListItemCachedMetadataProvider =
    FutureProvider.family<Object?, ({String targetId, bool isSeries})>((
      ref,
      args,
    ) async {
      final localDataSource = ref.read(metronLocalDataSourceProvider);
      final id = int.tryParse(args.targetId.replaceAll(RegExp(r'\D'), '')) ?? 0;
      if (id <= 0) return null;

      if (args.isSeries) {
        final dto = await localDataSource.getSeriesDetails(id);
        return dto?.toEntity();
      }

      final dto = await localDataSource.getIssueDetails(id);
      return dto?.toEntity();
    });
