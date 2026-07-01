import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/presentation/components/person_list_tile.dart';
import 'package:takion/src/presentation/features/issues/providers/issue_details_provider.dart';

@RoutePage()
class IssueCharactersScreen extends ConsumerWidget {
  const IssueCharactersScreen({super.key, @pathParam required this.issueId});

  final int issueId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final issueAsync = ref.watch(issueDetailsProvider(issueId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: issueAsync.whenOrNull(
          data: (issue) {
            final seriesName = issue.series?.name.trim();
            final issueNumber = issue.number.trim();
            if (seriesName != null && seriesName.isNotEmpty) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Characters'),
                  Text(
                    '$seriesName #$issueNumber',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              );
            }
            return const Text('Characters');
          },
        ) ?? const Text('Characters'),
      ),
      body: issueAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (issue) {
          final characters = issue.characters;
          if (characters.isEmpty) {
            return const Center(child: Text('No characters listed.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: characters.length,
            itemBuilder: (context, index) {
              final character = characters[index];
              return PersonListTile(
                characterId: character.id,
                name: character.name.trim().isNotEmpty
                    ? character.name.trim()
                    : 'Unknown Character',
                isFirst: index == 0,
                isLast: index == characters.length - 1,
                horizontalPadding: 0,
              );
            },
          );
        },
      ),
    );
  }
}
