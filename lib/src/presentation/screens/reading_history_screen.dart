import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/presentation/providers/collection_items_provider.dart';
import 'package:takion/src/presentation/widgets/async_state_panel.dart';

@RoutePage()
class ReadingHistoryScreen extends ConsumerWidget {
  const ReadingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(readingHistoryCollectionItemsProvider);

    Future<void> refresh() async {
      ref.invalidate(readingHistoryCollectionItemsProvider);
      await ref.read(readingHistoryCollectionItemsProvider.future);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Reading History')),
      body: historyAsync.when(
        loading: () => const AsyncStatePanel.loading(),
        error: (error, _) => AsyncStatePanel.error(
          errorMessage: 'Failed to load reading history: $error',
        ),
        data: (entries) {
          if (entries.isEmpty) {
            return RefreshIndicator(
              onRefresh: refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 220),
                  Center(child: Text('No reading history in your collection.')),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: refresh,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                final issue = entry.item.issue;
                final seriesName = issue?.series?.name ?? 'Issue';
                final number = (issue?.number.isNotEmpty ?? false)
                    ? ' #${issue!.number}'
                    : '';
                final readAtLabel = entry.readAt == null
                    ? 'Read date unavailable'
                    : 'Read on ${DateFormat.yMMMd().format(entry.readAt!.toLocal())}';
                final ratingLabel = entry.item.rating == null
                    ? 'Unrated'
                    : 'Rating: ${entry.item.rating}/5';

                return Card(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: ListTile(
                    title: Text('$seriesName$number'),
                    subtitle: Text('$readAtLabel • $ratingLabel'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: issue == null
                        ? null
                        : () => context.pushRoute(
                            IssueDetailsRoute(issueId: issue.id),
                          ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
