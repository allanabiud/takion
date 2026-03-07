import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/presentation/providers/collection_items_provider.dart';
import 'package:takion/src/presentation/providers/sort_preferences_provider.dart';
import 'package:takion/src/presentation/sorting/content_sorting.dart';
import 'package:takion/src/presentation/providers/issues_provider.dart';
import 'package:takion/src/presentation/widgets/async_state_panel.dart';
import 'package:takion/src/presentation/widgets/display_settings_button.dart';
import 'package:takion/src/presentation/widgets/empty_content_state.dart';

@RoutePage()
class ReadingHistoryScreen extends ConsumerWidget {
  const ReadingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sortOption = ref.watch(
      sortPreferenceForContextProvider(
        SortPreferenceContext.libraryReadingHistory,
      ),
    );
    final historyAsync = ref.watch(readingHistoryCollectionItemsProvider);

    Future<void> refresh() async {
      ref.invalidate(readingHistoryCollectionItemsProvider);
      await ref.read(readingHistoryCollectionItemsProvider.future);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reading History'),
        actions: [
          DisplaySettingsButton(
            selectedOption: sortOption,
            optionLabel: issueSortLabel,
            onSelected: (option) {
              ref
                  .read(sortPreferencesProvider.notifier)
                  .setPreference(
                    SortPreferenceContext.libraryReadingHistory,
                    option,
                  );
            },
          ),
        ],
      ),
      body: historyAsync.when(
        loading: () => const AsyncStatePanel.loading(),
        error: (error, _) => AsyncStatePanel.error(
          errorMessage: 'Failed to load reading history: $error',
        ),
        data: (entries) {
          final sortedEntries = sortItemsByNameAndDate(
            entries,
            sortOption: sortOption,
            nameOf: (entry) =>
                '${entry.item.issue?.series?.name ?? ''} #${entry.item.issue?.number ?? ''}',
            dateOf: (entry) =>
                entry.readAt ??
                entry.item.modified ??
                entry.item.issue?.storeDate ??
                entry.item.issue?.coverDate ??
                entry.item.issue?.modified,
          );

          if (sortedEntries.isEmpty) {
            return RefreshIndicator(
              onRefresh: refresh,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: const [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyContentState(
                      icon: Icons.history_outlined,
                      message: 'No reading history yet.',
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: refresh,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: sortedEntries.length,
              itemBuilder: (context, index) {
                final entry = sortedEntries[index];
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
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
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
