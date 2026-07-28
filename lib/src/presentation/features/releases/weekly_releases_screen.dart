import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/presentation/features/releases/providers/selected_week_provider.dart';
import 'package:takion/src/presentation/features/releases/providers/weekly_releases_provider.dart';
import 'package:takion/src/presentation/providers/providers.dart';
import 'package:takion/src/domain/common/content_sorting.dart';
import 'package:takion/src/presentation/shared/widgets/components.dart';

@RoutePage()
class WeeklyReleasesScreen extends ConsumerWidget {
  const WeeklyReleasesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedWeekProvider);
    final sortOption = ref.watch(
      sortPreferenceForContextProvider(SortPreferenceContext.releasesWeekly),
    );
    final issuesAsync = ref.watch(weeklyReleasesProvider(selectedDate));

    return PagedIssueListScaffold(
      title: 'Weekly Releases',
      issuesAsync: issuesAsync,
      transformIssues: (issues) => sortIssues(issues, sortOption),
      header: issuesAsync.maybeWhen(
        data: (issues) => ListHeader(
          count: issues.length,
          unit: 'issue',
          sortLabel: issueSortLabel(sortOption),
          onSortTap: () => showSortBottomSheet(
            context,
            ref,
            SortPreferenceContext.releasesWeekly,
            issueSortLabel,
          ),
        ),
        orElse: () => null,
      ),
      emptyMessage: 'No weekly releases for this week.',
      emptyIcon: Icons.new_releases_outlined,
    );
  }
}
