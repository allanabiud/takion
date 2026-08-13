import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/common/content_sorting.dart';
import 'package:takion/src/domain/entities.dart';
import 'package:takion/src/presentation/features/characters/providers/character_details_provider.dart';
import 'package:takion/src/presentation/features/characters/providers/character_issue_list_provider.dart';
import 'package:takion/src/presentation/features/issues/issue_list_tile.dart';
import 'package:takion/src/presentation/shared/widgets/entity_paged_list_screen.dart';

@RoutePage()
class CharacterIssuesScreen extends ConsumerWidget {
  const CharacterIssuesScreen({
    super.key,
    @pathParam required this.characterId,
  });

  final int characterId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final characterName =
        ref.watch(characterDetailsProvider(characterId)).asData?.value.name ??
        '';
    return EntityPagedListScreen<CharacterIssueListPage, IssueList>(
      title: 'Issues',
      subtitle: characterName,
      unit: 'issue',
      sortContext: SortPreferenceContext.characterIssues,
      sortLabel: issueSortLabel,
      sortItems: sortIssues,
      watchPage: (ref, page) => ref.watch(
        characterIssueListProvider(
          CharacterIssueListArgs(characterId: characterId, page: page),
        ),
      ),
      invalidatePage: (ref, page) => ref.invalidate(
        characterIssueListProvider(
          CharacterIssueListArgs(characterId: characterId, page: page),
        ),
      ),
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