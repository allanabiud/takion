import "package:drift/drift.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/core/storage/drift_database_provider.dart";
import "package:takion/src/data/common/drift/daos/library_item_dao.dart";
import "package:takion/src/data/common/drift/database.dart";

class ReadingHistoryEntry {
  const ReadingHistoryEntry({
    required this.id,
    required this.issueId,
    required this.seriesId,
    required this.seriesName,
    required this.issueNumber,
    this.issueName,
    this.seriesVolume,
    this.seriesYearBegan,
    this.coverDate,
    this.storeDate,
    this.imageUrl,
    required this.readAt,
    this.rating,
    this.notes,
  });

  final String id;
  final int issueId;
  final int seriesId;
  final String seriesName;
  final String issueNumber;
  final String? issueName;
  final int? seriesVolume;
  final int? seriesYearBegan;
  final DateTime? coverDate;
  final DateTime? storeDate;
  final String? imageUrl;
  final DateTime readAt;
  final int? rating;
  final String? notes;
}

final readingHistoryProvider =
    StreamProvider.autoDispose<List<ReadingHistoryEntry>>((ref) {
      final db = ref.watch(driftDatabaseProvider);
      return db.libraryItemDao.watchHydratedItems(isRead: true).asyncMap((
        hydratedItems,
      ) async {
        final allLogs = await (db.select(
          db.libraryReadLogs,
        )..orderBy([(t) => OrderingTerm.desc(t.readAt)])).get();

        final logsByItem = <String, List<LibraryReadLog>>{};
        for (final log in allLogs) {
          logsByItem.putIfAbsent(log.collectionItemId, () => []).add(log);
        }

        final hydratedByItemId = <String, HydratedLibraryItemRow>{
          for (final h in hydratedItems) h.libraryItem.id: h,
        };

        final entries = <ReadingHistoryEntry>[];

        // 1. Every distinct read log session
        for (final log in allLogs) {
          final hydrated = hydratedByItemId[log.collectionItemId];
          final issue = hydrated?.issue;
          final series = hydrated?.series;
          final libItem = hydrated?.libraryItem;
          final issueId =
              libItem?.metronIssueId ??
              int.tryParse(log.collectionItemId.replaceFirst("lib-", "")) ??
              0;
          final readAtDate =
              DateTime.tryParse(log.readAt) ??
              DateTime.tryParse(log.createdAt) ??
              DateTime.now();

          final coverDate = issue?.coverDate != null
              ? DateTime.tryParse(issue!.coverDate!)
              : null;
          final storeDate = issue?.storeDate != null
              ? DateTime.tryParse(issue!.storeDate!)
              : null;

          entries.add(
            ReadingHistoryEntry(
              id: log.id,
              issueId: issueId,
              seriesId: libItem?.metronSeriesId ?? series?.id ?? 0,
              seriesName: series?.name ?? "Unknown Series",
              issueNumber: issue?.number ?? "",
              issueName: issue?.issueName,
              seriesVolume: series?.volume,
              seriesYearBegan: series?.yearBegan,
              coverDate: coverDate,
              storeDate: storeDate,
              imageUrl: issue?.imageUrl,
              readAt: readAtDate,
              rating: libItem?.rating,
              notes: log.notes,
            ),
          );
        }

        // 2. Read items that don't have read logs in libraryReadLogs yet
        for (final h in hydratedItems) {
          if (!logsByItem.containsKey(h.libraryItem.id)) {
            final issue = h.issue;
            final series = h.series;
            final libItem = h.libraryItem;
            final readAtDate =
                (libItem.firstReadAt != null
                    ? DateTime.tryParse(libItem.firstReadAt!)
                    : null) ??
                DateTime.tryParse(libItem.updatedAt) ??
                DateTime.now();

            final coverDate = issue?.coverDate != null
                ? DateTime.tryParse(issue!.coverDate!)
                : null;
            final storeDate = issue?.storeDate != null
                ? DateTime.tryParse(issue!.storeDate!)
                : null;

            entries.add(
              ReadingHistoryEntry(
                id: "synth-${libItem.id}",
                issueId: libItem.metronIssueId,
                seriesId: libItem.metronSeriesId,
                seriesName: series?.name ?? "Unknown Series",
                issueNumber: issue?.number ?? "",
                issueName: issue?.issueName,
                seriesVolume: series?.volume,
                seriesYearBegan: series?.yearBegan,
                coverDate: coverDate,
                storeDate: storeDate,
                imageUrl: issue?.imageUrl,
                readAt: readAtDate,
                rating: libItem.rating,
                notes: libItem.notes,
              ),
            );
          }
        }

        entries.sort((a, b) => b.readAt.compareTo(a.readAt));
        return entries;
      });
    });

/// Deprecated compatibility alias for existing consumers.
final readingHistoryCollectionItemsProvider = readingHistoryProvider;
