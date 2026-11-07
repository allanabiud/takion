import "package:auto_route/auto_route.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/core/constants/date_formatter.dart";
import "package:takion/src/core/router/app_router.gr.dart";
import "package:takion/src/domain/catalog/entities/issue_list.dart";
import "package:takion/src/domain/catalog/entities/series.dart";
import "package:takion/src/presentation/features/issues/issue_list_tile.dart";
import "package:takion/src/presentation/features/library/providers/reading_history_provider.dart";
import "package:takion/src/presentation/shared/widgets/empty_content_state.dart";
import "package:takion/src/presentation/shared/widgets/list_header.dart";
import "package:takion/src/presentation/shared/widgets/takion_bottom_sheet.dart";

Future<void> showDayReadHistorySheet(BuildContext context, DateTime date) {
  return TakionBottomSheet.show(
    context: context,
    title: DateFormatter.comicDate(date),
    child: _DayReadHistoryContent(date: date),
  );
}

class _DayReadHistoryContent extends ConsumerWidget {
  const _DayReadHistoryContent({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(readingHistoryProvider);

    return historyAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: Text("Could not load read issues.")),
      ),
      data: (allEntries) {
        final targetDay = DateTime(date.year, date.month, date.day);
        final dayEntries = allEntries.where((entry) {
          final local = entry.readAt.toLocal();
          final entryDay = DateTime(local.year, local.month, local.day);
          return entryDay.isAtSameMomentAs(targetDay);
        }).toList();

        if (dayEntries.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: EmptyContentState(
              icon: Icons.menu_book_outlined,
              message: "No issues read on this day.",
            ),
          );
        }

        final maxHeight = MediaQuery.sizeOf(context).height * 0.65;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListHeader(
              count: dayEntries.length,
              unit: "read issue",
              padding: const EdgeInsets.only(bottom: 8),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxHeight),
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.only(bottom: 8),
                itemCount: dayEntries.length,
                itemBuilder: (context, index) {
                  final entry = dayEntries[index];
                  final isFirst = index == 0;
                  final isLast = index == dayEntries.length - 1;

                  final issueList = IssueList(
                    id: entry.issueId > 0 ? entry.issueId : null,
                    name: entry.seriesName,
                    number: entry.issueNumber,
                    series: Series(
                      id: entry.seriesId,
                      name: entry.seriesName,
                      volume: entry.seriesVolume,
                      yearBegan: entry.seriesYearBegan,
                    ),
                    coverDate: entry.coverDate,
                    storeDate: entry.storeDate,
                    image: entry.imageUrl,
                    modified: entry.readAt,
                  );

                  return IssueListTile(
                    issue: issueList,
                    horizontalPadding: 0,
                    isFirst: isFirst,
                    isLast: isLast,
                    useCardBackground: false,
                    isCollected: entry.issueId > 0,
                    isRead: true,
                    allowRemoteHydration: false,
                    rating: entry.rating,
                    trailing: Text(
                      DateFormatter.time(entry.readAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      context.pushRoute(
                        IssueDetailsRoute(
                          issueId: entry.issueId,
                          initialImageUrl: entry.imageUrl,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
