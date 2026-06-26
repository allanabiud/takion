import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/presentation/features/issues/providers/issues_provider.dart';

String _initials(String name) {
  if (name.isEmpty) return '?';
  final parts = name.trim().split(RegExp(r'[\s\-\/]+'));
  final valid = parts.where((p) => p.isNotEmpty && RegExp(r'^[a-zA-Z]').hasMatch(p)).toList();
  if (valid.isEmpty) return '?';
  if (valid.length >= 2) {
    return '${valid[0][0]}${valid[1][0]}'.toUpperCase();
  }
  return valid[0][0].toUpperCase();
}

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
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer
                            .withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          _initials(character.name),
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            character.name.trim().isNotEmpty
                                ? character.name.trim()
                                : 'Unknown Character',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
