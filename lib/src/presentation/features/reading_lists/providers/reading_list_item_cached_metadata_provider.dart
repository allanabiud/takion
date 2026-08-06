import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/presentation/providers/providers.dart';

final readingListItemCachedMetadataProvider =
    StreamProvider.autoDispose.family<Object?, ({String targetId, bool isSeries})>((
      ref,
      args,
    ) async* {
      final db = ref.watch(driftDatabaseProvider);
      final mapper = ref.watch(entityMapperProvider);
      final id = int.tryParse(args.targetId.replaceAll(RegExp(r'\D'), '')) ?? 0;
      if (id <= 0) {
        yield null;
        return;
      }

      if (args.isSeries) {
        yield* db.metronEntityDao.watchSeries(id).asyncMap((series) async {
          return series != null ? await mapper.seriesToEntity(series) : null;
        });
      } else {
        yield* db.metronEntityDao.watchIssue(id).asyncMap((issue) async {
          return issue != null ? await mapper.issueToEntity(issue) : null;
        });
      }
    });
