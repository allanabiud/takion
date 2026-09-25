import "dart:async";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/domain/collection/entities/collection_analytics.dart";
import "package:takion/src/presentation/features/library/providers/library_stats_models.dart";
import "package:takion/src/presentation/features/library/providers/stats_debounce.dart";
import "package:takion/src/presentation/providers/providers.dart";

/// Top publisher / creator / character rankings, aggregated by
/// [CollectionAnalyticsEngine] in SQLite. The three watch streams re-emit on
/// any catalog or library write; the combined model is published once all
/// three have produced their first value.
final libraryEntityStatsProvider =
    StreamProvider.autoDispose<LibraryEntityStats>((ref) {
      final engine = ref.watch(collectionAnalyticsEngineProvider);
      final controller = StreamController<LibraryEntityStats>();
      final debounced = DebouncedWorker();

      List<RankedEntity>? publishers;
      List<RankedEntity>? creators;
      List<RankedEntity>? characters;

      EntityStat toStat(RankedEntity e) =>
          EntityStat(id: e.id, name: e.name, count: e.count);

      void emit() {
        final pub = publishers;
        final cre = creators;
        final chr = characters;
        if (pub == null || cre == null || chr == null) return;
        if (controller.isClosed) return;
        controller.add(
          LibraryEntityStats(
            topPublishers: pub
                .take(5)
                .map((e) => MapEntry(e.name, e.count))
                .toList(),
            topCharacters: chr.take(5).map(toStat).toList(),
            allCharacters: chr.map(toStat).toList(),
            topCreators: cre.take(5).map(toStat).toList(),
            allCreators: cre.map(toStat).toList(),
          ),
        );
      }

      final subscriptions = <StreamSubscription<dynamic>>[
        engine.watchTopPublishers(limit: 0).listen((value) {
          publishers = value;
          debounced.schedule(emit);
        }),
        engine.watchTopCreators(limit: 0).listen((value) {
          creators = value;
          debounced.schedule(emit);
        }),
        engine.watchTopCharacters(limit: 0).listen((value) {
          characters = value;
          debounced.schedule(emit);
        }),
      ];

      ref.onDispose(() {
        for (final subscription in subscriptions) {
          subscription.cancel();
        }
        debounced.cancel();
        controller.close();
      });

      return controller.stream;
    });
