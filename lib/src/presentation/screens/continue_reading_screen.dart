import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/presentation/providers/continue_reading_provider.dart';
import 'package:takion/src/presentation/widgets/async_state_panel.dart';
import 'package:takion/src/presentation/widgets/issue_list_tile.dart';

@RoutePage()
class ContinueReadingScreen extends ConsumerWidget {
  const ContinueReadingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestionsAsync = ref.watch(continueReadingAllSuggestionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Continue Reading')),
      body: suggestionsAsync.when(
        loading: () => const AsyncStatePanel.loading(),
        error: (error, _) => AsyncStatePanel.error(
          errorMessage: 'Failed to load continue reading: $error',
        ),
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('No continue reading suggestions yet.'),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return IssueListTile(
                issue: item.issue,
                isFirst: index == 0,
                isLast: index == items.length - 1,
              );
            },
          );
        },
      ),
    );
  }
}
