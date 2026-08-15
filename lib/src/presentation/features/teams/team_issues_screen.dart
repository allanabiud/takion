import "package:auto_route/auto_route.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/domain/common/content_sorting.dart";
import "package:takion/src/domain/entities.dart";
import "package:takion/src/presentation/features/teams/providers/team_details_provider.dart";
import "package:takion/src/presentation/features/teams/providers/team_issue_list_provider.dart";
import "package:takion/src/presentation/features/issues/issue_list_tile.dart";
import "package:takion/src/presentation/shared/widgets/entity_paged_list_screen.dart";

@RoutePage()
class TeamIssuesScreen extends ConsumerWidget {
  const TeamIssuesScreen({super.key, @pathParam required this.teamId});

  final int teamId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamName =
        ref.watch(teamDetailsProvider(teamId)).asData?.value.name ?? "";
    return EntityPagedListScreen<CharacterIssueListPage, IssueList>(
      title: "Issues",
      subtitle: teamName,
      unit: "issue",
      sortContext: SortPreferenceContext.teamIssues,
      sortLabel: contentSortLabel,
      sortItems: sortIssues,
      watchPage: (ref, page) => ref.watch(
        teamIssueListProvider(TeamIssueListArgs(teamId: teamId, page: page)),
      ),
      invalidatePage: (ref, page) => ref.invalidate(
        teamIssueListProvider(TeamIssueListArgs(teamId: teamId, page: page)),
      ),
      countOf: (page) => page.count,
      resultsOf: (page) => page.results,
      hasNextOf: (page) => page.hasNext,
      hasPreviousOf: (page) => page.hasPrevious,
      pageSizeOf: (page) => page.realPageSize,
      tileBuilder: (context, issue, {required isFirst, required isLast}) =>
          IssueListTile(issue: issue, isFirst: isFirst, isLast: isLast),
      emptyMessage: "No issues available.",
      emptyIcon: Icons.menu_book_outlined,
      errorMessage: "Failed to load issues",
    );
  }
}