import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/presentation/providers/providers.dart';

final readingListItemCachedMetadataProvider =
    FutureProvider.family<Object?, ({String targetId, bool isSeries})>((
      ref,
      args,
    ) async {
      final db = ref.read(driftDatabaseProvider);
      final mapper = ref.read(entityMapperProvider);
      final id = int.tryParse(args.targetId.replaceAll(RegExp(r'\D'), '')) ?? 0;
      if (id <= 0) return null;

      if (args.isSeries) {
        final series = await db.metronEntityDao.getSeries(id);
        return series != null ? await mapper.seriesToEntity(series) : null;
      }

      final issue = await db.metronEntityDao.getIssue(id);
      return issue != null ? await mapper.issueToEntity(issue) : null;
    });
