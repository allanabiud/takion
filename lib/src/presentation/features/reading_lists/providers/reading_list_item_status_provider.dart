import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities/reading_list.dart';
import 'package:takion/src/presentation/features/issues/providers/issue_collection_status_provider.dart';
import 'package:takion/src/presentation/providers/repository_providers.dart';

final readingListItemEffectiveReadStatusProvider = Provider.autoDispose
    .family<AsyncValue<bool>, ReadingListItem>((ref, item) {
      final idString = item.targetId.replaceAll(RegExp(r'^.*-'), '');
      final id = int.tryParse(idString) ?? 0;

      if (item.isSeries) {
        return ref.watch(seriesAllIssuesReadProvider(id));
      } else {
        final statusAsync = ref.watch(collectionIssueStatusMapProvider);
        return statusAsync.when(
          data: (statusMap) {
            final status = statusMap[id];
            // If we have library data, use it. If not in library, it's not read.
            return AsyncValue.data(status?.isRead ?? false);
          },
          loading: () => AsyncValue.data(item.isRead),
          error: (_, __) => AsyncValue.data(item.isRead),
        );
      }
    });

final readingListEffectiveStatusProvider = Provider.autoDispose
    .family<
      AsyncValue<({int readCount, int totalCount, double progress})>,
      ReadingList
    >((ref, list) {
      final itemsStatuses = list.items
          .map(
            (item) =>
                ref.watch(readingListItemEffectiveReadStatusProvider(item)),
          )
          .toList();

      bool isLoading = false;
      int readCount = 0;

      for (final status in itemsStatuses) {
        if (status is AsyncLoading) {
          isLoading = true;
        } else if (status.value == true) {
          readCount++;
        }
      }

      final totalCount = list.items.length;
      final progress = totalCount > 0 ? readCount / totalCount : 0.0;

      if (isLoading) {
        return AsyncValue.data((
          readCount: readCount,
          totalCount: totalCount,
          progress: progress,
        ));
      }

      return AsyncValue.data((
        readCount: readCount,
        totalCount: totalCount,
        progress: progress,
      ));
    });

final seriesAllIssuesReadProvider = FutureProvider.autoDispose
    .family<bool, int>((ref, seriesId) async {
      final metronRepo = ref.read(metronRepositoryProvider);

      // Fetch all pages of issues for the series
      final allIssues = <int>[];
      int currentPage = 1;
      bool hasNext = true;

      while (hasNext) {
        final page = await metronRepo.getSeriesIssueList(
          seriesId,
          page: currentPage,
        );
        for (final issue in page.results) {
          if (issue.id != null) allIssues.add(issue.id!);
        }
        hasNext = page.next != null;
        currentPage++;
        if (currentPage > 20) break; // Safety break
      }

      if (allIssues.isEmpty) return false;

      final statusMap = await ref.watch(
        collectionIssueStatusMapProvider.future,
      );

      for (final id in allIssues) {
        final status = statusMap[id];
        if (status == null || !status.isRead) return false;
      }
      return true;
    });
