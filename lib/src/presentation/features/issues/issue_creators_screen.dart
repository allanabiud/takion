import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities/issue_details.dart';
import 'package:takion/src/presentation/components/person_list_tile.dart';
import 'package:takion/src/presentation/features/issues/providers/issue_details_provider.dart';

int _creditPriority(IssueDetailsCredit credit) {
  const primary = [
    'writer', 'script', 'artist', 'penciler', 'penciller',
    'colorist', 'letterer', 'inker', 'cover',
  ];
  for (final role in credit.roles) {
    final name = role.name.trim().toLowerCase();
    for (var i = 0; i < primary.length; i++) {
      if (name.contains(primary[i])) return i;
    }
  }
  return primary.length;
}

@RoutePage()
class IssueCreatorsScreen extends ConsumerWidget {
  const IssueCreatorsScreen({super.key, @pathParam required this.issueId});

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
                  const Text('Creators'),
                  Text(
                    '$seriesName #$issueNumber',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              );
            }
            return const Text('Creators');
          },
        ) ?? const Text('Creators'),
      ),
      body: issueAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (issue) {
          final credits = List<IssueDetailsCredit>.from(issue.credits)
            ..sort((a, b) => _creditPriority(a).compareTo(_creditPriority(b)));
          if (credits.isEmpty) {
            return const Center(child: Text('No creators listed.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: credits.length,
            itemBuilder: (context, index) {
              final credit = credits[index];
              final creator = credit.creator?.trim();
              final roles = credit.roles
                  .map((r) => r.name.trim())
                  .where((n) => n.isNotEmpty)
                  .toSet()
                  .toList();
              return PersonListTile(
                creatorId: credit.id,
                name: creator != null && creator.isNotEmpty
                    ? creator
                    : 'Unknown Creator',
                subtitle: roles.isNotEmpty ? roles.join(' • ') : null,
                isFirst: index == 0,
                isLast: index == credits.length - 1,
                horizontalPadding: 0,
              );
            },
          );
        },
      ),
    );
  }
}
