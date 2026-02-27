import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/presentation/providers/collection_stats_provider.dart';
import 'package:takion/src/presentation/providers/collection_suggestions_provider.dart';
import 'package:takion/src/presentation/providers/scrobble_issue_provider.dart';
import 'package:takion/src/presentation/widgets/action_card.dart';
import 'package:takion/src/presentation/widgets/compact_list_section.dart';
import 'package:takion/src/presentation/widgets/issue_list_tile.dart';
import 'package:takion/src/presentation/widgets/section_subtitle_header.dart';
import 'package:takion/src/presentation/widgets/takion_alerts.dart';

@RoutePage()
class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(collectionStatsProvider);
    final suggestionAsync = ref.watch(readingSuggestionIssueProvider);
    final rateSuggestionAsync = ref.watch(rateSuggestionIssueProvider);

    void showAddComicSheet() {
      showModalBottomSheet<void>(
        context: context,
        builder: (sheetContext) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add Comic',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.add_circle_outline),
                    title: const Text('Add Issue'),
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.library_add_outlined),
                    title: const Text('Add from Series'),
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    void showRateSuggestionSheet({
      required int issueId,
      required String comicName,
      required int initialRating,
    }) {
      var selectedRating = initialRating.clamp(0, 5);
      ref.read(scrobbleIssueProvider(issueId).notifier).reset();

      showModalBottomSheet<void>(
        context: context,
        builder: (sheetContext) {
          return Consumer(
            builder: (context, ref, _) {
              final scrobbleState = ref.watch(scrobbleIssueProvider(issueId));
              final isSubmitting = scrobbleState.isLoading;
              final errorMessage = scrobbleState.whenOrNull(
                error: (error, _) => '$error',
              );

              return StatefulBuilder(
                builder: (context, setModalState) {
                  return SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rate $comicName',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(5, (index) {
                              final starValue = index + 1;
                              return IconButton(
                                onPressed: isSubmitting
                                    ? null
                                    : () {
                                        setModalState(() {
                                          selectedRating = starValue;
                                        });
                                      },
                                iconSize: 38,
                                icon: Icon(
                                  starValue <= selectedRating
                                      ? Icons.star
                                      : Icons.star_border,
                                ),
                              );
                            }),
                          ),
                          if (errorMessage != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              errorMessage,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Theme.of(context).colorScheme.error),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: FilledButton(
                              onPressed: isSubmitting || selectedRating <= 0
                                  ? null
                                  : () async {
                                      await ref
                                          .read(
                                            scrobbleIssueProvider(
                                              issueId,
                                            ).notifier,
                                          )
                                          .scrobble(
                                            dateRead: DateTime.now(),
                                            rating: selectedRating,
                                            refreshRateSuggestion: true,
                                          );

                                      final latestState = ref.read(
                                        scrobbleIssueProvider(issueId),
                                      );
                                      if (latestState.hasError) return;

                                      if (sheetContext.mounted) {
                                        Navigator.of(sheetContext).pop();
                                      }
                                    },
                              child: isSubmitting
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Done'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      );
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: showAddComicSheet,
        child: const Icon(Icons.add),
      ),
      appBar: statsAsync.isLoading
          ? AppBar(
              toolbarHeight: 0,
              bottom: const PreferredSize(
                preferredSize: Size.fromHeight(4),
                child: LinearProgressIndicator(),
              ),
            )
          : null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  ActionCard(
                    icon: Icons.inventory_2_outlined,
                    value: statsAsync.when(
                      data: (stats) => stats.totalQuantity.toString(),
                      loading: () => '--',
                      error: (_, _) => '!',
                    ),
                    label: 'Comics',
                    onTap: () {
                      context.pushRoute(const MyComicsRoute());
                    },
                  ),
                  const SizedBox(width: 8),
                  ActionCard(
                    icon: Icons.bookmark_added,
                    value: statsAsync.when(
                      data: (stats) => stats.readCount.toString(),
                      loading: () => '--',
                      error: (_, _) => '!',
                    ),
                    label: 'Read',
                    onTap: () {
                      context.pushRoute(
                        CollectionReadStatusRoute(isRead: true),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  ActionCard(
                    icon: Icons.attach_money_outlined,
                    value: statsAsync.when(
                      data: (stats) => stats.totalValue,
                      loading: () => '--',
                      error: (_, _) => '!',
                    ),
                    label: 'Value',
                    onTap: () {
                      TakionAlerts.comingSoon(context, 'Value page');
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            CompactListSection(
              title: 'Lists',
              items: [
                CompactListSectionItem(
                  icon: Icons.bookmark_added_outlined,
                  label: 'Unread',
                  value: statsAsync.when(
                    data: (stats) => stats.unreadCount.toString(),
                    loading: () => '--',
                    error: (_, _) => '!',
                  ),
                  onTap: () {
                    context.pushRoute(
                      CollectionReadStatusRoute(isRead: false),
                    );
                  },
                ),
                CompactListSectionItem(
                  icon: Icons.warning_amber_outlined,
                  label: 'Incomplete Series',
                  onTap: () {
                    context.pushRoute(const IncompleteSeriesRoute());
                  },
                ),
                CompactListSectionItem(
                  icon: Icons.playlist_add_check_circle_outlined,
                  label: 'My Reading Lists',
                  onTap: () {
                    TakionAlerts.comingSoon(context, 'My Reading Lists');
                  },
                ),
                CompactListSectionItem(
                  icon: Icons.history,
                  label: 'Reading History',
                  onTap: () {
                    TakionAlerts.comingSoon(context, 'Reading History');
                  },
                ),
              ],
            ),
            suggestionAsync.when(
              loading: () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SizedBox(height: 24),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: SectionSubtitleHeader(
                      title: 'Reading Suggestion',
                      subtitle: 'Not sure what to read next?',
                    ),
                  ),
                  SizedBox(height: 8),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ],
              ),
              error: (error, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: SectionSubtitleHeader(
                      title: 'Reading Suggestion',
                      subtitle: 'Not sure what to read next?',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      '$error',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              data: (suggestion) {
                if (suggestion == null) return const SizedBox.shrink();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: SectionSubtitleHeader(
                        title: 'Reading Suggestion',
                        subtitle: 'Not sure what to read next?',
                      ),
                    ),
                    const SizedBox(height: 8),
                    IssueListTile(
                      issue: suggestion.issue,
                      isFirst: true,
                      isLast: true,
                      isCollected: suggestion.isCollected,
                      isRead: suggestion.isRead,
                      rating: suggestion.rating,
                    ),
                  ],
                );
              },
            ),
            rateSuggestionAsync.when(
              loading: () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SizedBox(height: 24),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: SectionSubtitleHeader(
                      title: 'Rate Suggestion',
                      subtitle: 'You read it, what did you think?',
                    ),
                  ),
                  SizedBox(height: 8),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ],
              ),
              error: (error, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: SectionSubtitleHeader(
                      title: 'Rate Suggestion',
                      subtitle: 'You read it, what did you think?',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      '$error',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              data: (suggestion) {
                if (suggestion == null) return const SizedBox.shrink();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: SectionSubtitleHeader(
                        title: 'Rate Suggestion',
                        subtitle: 'You read it, what did you think?',
                      ),
                    ),
                    const SizedBox(height: 8),
                    IssueListTile(
                      issue: suggestion.issue,
                      isFirst: true,
                      isLast: true,
                      isCollected: suggestion.isCollected,
                      isRead: suggestion.isRead,
                      rating: suggestion.rating,
                      onTap: suggestion.issue.id == null
                          ? null
                          : () {
                              showRateSuggestionSheet(
                                issueId: suggestion.issue.id!,
                                comicName: suggestion.issue.name,
                                initialRating: suggestion.rating ?? 0,
                              );
                            },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
