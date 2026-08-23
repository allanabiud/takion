import "dart:async";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/domain/entities.dart";
import "package:takion/src/presentation/features/library/providers/library_stats_models.dart";
import "package:takion/src/presentation/features/library/providers/collection_items_provider.dart";
import "package:takion/src/presentation/features/library/providers/stats_debounce.dart";
import "package:takion/src/presentation/providers/providers.dart";

final libraryEntityStatsProvider =
    StreamProvider.autoDispose<LibraryEntityStats>((ref) {
      final localCatalog = ref.watch(localCatalogRepositoryProvider);
      final controller = StreamController<LibraryEntityStats>();
      final debounced = DebouncedWorker();

      Future<void> computeStats(List<LibraryItem> libraryItems) async {
        try {
          final owned = libraryItems
              .where(
                (item) => item.ownershipStatus == LibraryOwnershipStatus.owned,
              )
              .toList();
          final allRead = libraryItems.where((item) => item.isRead).toList();

          final topPublisherCounts = <String, int>{};
          final characterCounts = <int, int>{};
          final characterNames = <int, String>{};
          final creatorCounts = <int, int>{};
          final creatorNames = <int, String>{};
          final insightIssueIds =
              (owned.map((item) => item.metronIssueId).toSet()
                    ..addAll(allRead.map((item) => item.metronIssueId)))
                  .toList();

          final cachedDetails = await localCatalog.hydrateIssueDetails(
            insightIssueIds,
          );

          final missingCreatorIds = <int>{};
          for (final details in cachedDetails) {
            for (final credit in details.credits) {
              final creatorId =
                  (credit.creatorId != null && credit.creatorId! > 0)
                  ? credit.creatorId!
                  : credit.id;
              final rawName = credit.creator?.trim();
              if (creatorId > 0 && (rawName == null || rawName.isEmpty)) {
                missingCreatorIds.add(creatorId);
              }
            }
          }

          final creatorMap = missingCreatorIds.isNotEmpty
              ? await localCatalog.getCreatorsByIds(missingCreatorIds.toList())
              : <int, CreatorList>{};

          for (final details in cachedDetails) {
            final name = details.publisher?.name.trim();
            if (name != null && name.isNotEmpty) {
              topPublisherCounts.update(
                name,
                (value) => value + 1,
                ifAbsent: () => 1,
              );
            }
            for (final char in details.characters) {
              final charName = char.name.trim();
              if (charName.isEmpty) continue;
              characterCounts.update(
                char.id,
                (value) => value + 1,
                ifAbsent: () => 1,
              );
              characterNames[char.id] = charName;
            }
            final seenCreatorIds = <int>{};
            for (final credit in details.credits) {
              final creatorId =
                  (credit.creatorId != null && credit.creatorId! > 0)
                  ? credit.creatorId!
                  : credit.id;
              if (creatorId <= 0 || !seenCreatorIds.add(creatorId)) {
                continue;
              }
              final rawName = credit.creator?.trim();
              if (rawName != null && rawName.isNotEmpty) {
                creatorNames[creatorId] = rawName;
              } else {
                final c = creatorMap[creatorId];
                final daoName = c?.name;
                creatorNames[creatorId] =
                    (daoName != null && daoName.trim().isNotEmpty)
                    ? daoName.trim()
                    : "Unknown";
              }
              creatorCounts.update(
                creatorId,
                (value) => value + 1,
                ifAbsent: () => 1,
              );
            }
          }

          final topPublishers =
              (topPublisherCounts.entries.toList()
                    ..sort((a, b) => b.value.compareTo(a.value)))
                  .take(5)
                  .toList();
          final allCharacters =
              characterCounts.entries
                  .map(
                    (e) => EntityStat(
                      id: e.key,
                      name: characterNames[e.key] ?? "Unknown",
                      count: e.value,
                    ),
                  )
                  .toList()
                ..sort((a, b) => b.count.compareTo(a.count));
          final topCharacters = allCharacters.take(5).toList();
          final allCreators =
              creatorCounts.entries
                  .map(
                    (e) => EntityStat(
                      id: e.key,
                      name: creatorNames[e.key] ?? "Unknown",
                      count: e.value,
                    ),
                  )
                  .toList()
                ..sort((a, b) => b.count.compareTo(a.count));
          final topCreators = allCreators.take(5).toList();

          if (!controller.isClosed) {
            controller.add(
              LibraryEntityStats(
                topPublishers: topPublishers,
                topCharacters: topCharacters,
                allCharacters: allCharacters,
                topCreators: topCreators,
                allCreators: allCreators,
              ),
            );
          }
        } catch (e) {
          if (!controller.isClosed) {
            controller.addError(e);
          }
        }
      }

      ref.listen<AsyncValue<List<LibraryItem>>>(allLibraryItemsProvider, (
        _,
        next,
      ) {
        if (!next.hasValue) return;
        debounced.schedule(() => computeStats(next.value!));
      });

      ref
          .read(allLibraryItemsProvider)
          .whenOrNull(
            data: (libraryItems) {
              debounced.schedule(() => computeStats(libraryItems));
            },
          );

      ref.onDispose(() {
        debounced.cancel();
        controller.close();
      });

      return controller.stream;
    });
