import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/presentation/providers/collection_items_provider.dart';
import 'package:takion/src/presentation/providers/issues_provider.dart';
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
                final issueId = issue?.id;
                final rawSeriesName = issue?.series?.name.trim() ?? '';
                final shouldHydrate =
                    issueId != null &&
                    (RegExp(r'^Series \d+$').hasMatch(rawSeriesName) ||
                        (issue?.number.isEmpty ?? true));
                final hydratedIssue = shouldHydrate
                    ? ref.watch(issueDetailsProvider(issueId)).asData?.value
                    : null;
                final seriesName =
                    (hydratedIssue?.series?.name.trim().isNotEmpty ?? false)
                    ? hydratedIssue!.series!.name.trim()
                    : (rawSeriesName.isNotEmpty ? rawSeriesName : 'Issue');
                final displayNumber =
                    (hydratedIssue?.number.trim().isNotEmpty ?? false)
                    ? hydratedIssue!.number.trim()
                    : (issue?.number ?? '');
                final number = displayNumber.isNotEmpty
                    ? ' #$displayNumber'
                    : '';
                final readAtLabel = entry.readAt == null
                    ? 'Date unavailable'
                    : DateFormat.yMMMd().format(entry.readAt!.toLocal());
                final ratingValue = (entry.item.rating ?? 0).clamp(0, 5);

                return Card(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: ListTile(
                    title: Text('$seriesName$number'),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          Icon(
                            Icons.event_outlined,
                            size: 14,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Text(readAtLabel),
                          const Spacer(),
                          ...List.generate(5, (starIndex) {
                            final filled = starIndex < ratingValue;
                            return Icon(
                              filled ? Icons.star : Icons.star_border,
                              size: 14,
                              color: filled
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.outline,
                            );
                          }),
                        ],
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: issueId == null
                        ? null
                        : () => context.pushRoute(
                            IssueDetailsRoute(issueId: issueId),
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
