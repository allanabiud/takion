import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/common/content_sorting.dart';
import 'package:takion/src/domain/entities.dart';
import 'package:takion/src/presentation/shared/alerts/takion_alerts.dart';
import 'package:takion/src/presentation/features/issues/issue_list_tile.dart';
import 'package:takion/src/presentation/features/series/providers/series_details_provider.dart';
import 'package:takion/src/presentation/features/series/providers/series_issue_list_provider.dart';
import 'package:takion/src/presentation/features/series/series_issue_bulk_actions.dart';
import 'package:takion/src/presentation/shared/widgets/entity_paged_list_screen.dart';

@RoutePage()
class SeriesIssuesScreen extends ConsumerWidget {
  const SeriesIssuesScreen({super.key, @pathParam required this.seriesId});

  final int seriesId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final details = ref.watch(seriesDetailsProvider(seriesId)).asData?.value;
    final seriesName = details?.name ?? '';
    final yearBegan = details?.yearBegan;

    return EntityPagedListScreen<SeriesIssueListPage, IssueList>(
      title: 'Issues',
      subtitle: yearBegan != null ? '$seriesName ($yearBegan)' : seriesName,
      unit: 'issue',
      emptyHeight: 360,
      sortContext: SortPreferenceContext.seriesDetailsIssues,
      sortLabel: issueSortLabel,
      sortItems: sortIssues,
      watchPage: (ref, page) => ref.watch(
        seriesIssueListProvider(SeriesIssueListArgs(seriesId: seriesId, page: page)),
      ),
      invalidatePage: (ref, page) => ref.invalidate(
        seriesIssueListProvider(SeriesIssueListArgs(seriesId: seriesId, page: page)),
      ),
      onRefresh: (ref, page) async {
        try {
          await ref
              .read(
                seriesIssueListProvider(
                  SeriesIssueListArgs(seriesId: seriesId, page: page),
                ).notifier,
              )
              .refresh();
        } catch (e) {
          if (context.mounted) {
            TakionAlerts.safeError(context, e, userMessage: 'Refresh failed');
          }
        }
      },
      appBarActions: [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => showSeriesIssueBulkActionsSheet(
            context: context,
            ref: ref,
            seriesId: seriesId,
            seriesName: seriesName,
            seriesYear: yearBegan,
          ),
          tooltip: 'Bulk actions',
        ),
      ],
      countOf: (page) => page.count,
      resultsOf: (page) => page.results,
      hasNextOf: (page) => page.hasNext,
      hasPreviousOf: (page) => page.hasPrevious,
      tileBuilder: (context, issue, {required isFirst, required isLast}) =>
          IssueListTile(issue: issue, isFirst: isFirst, isLast: isLast),
      emptyMessage: 'No issues available.',
      emptyIcon: Icons.menu_book_outlined,
      errorMessage: 'Failed to load issues',
    );
  }
}