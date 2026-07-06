import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/presentation/features/library/providers/collection_stats_provider.dart';
import 'package:takion/src/presentation/features/library/providers/collection_suggestions_provider.dart';
import 'package:takion/src/presentation/features/issues/providers/scrobble_issue_provider.dart';
import 'package:takion/src/presentation/components/action_card.dart';
import 'package:takion/src/presentation/components/compact_list_section.dart';
import 'package:takion/src/presentation/features/issues/issue_list_tile.dart';
import 'package:takion/src/presentation/components/rating_picker.dart';
import 'package:takion/src/presentation/components/section_subtitle_header.dart';
import 'package:takion/src/presentation/features/reading_lists/providers/reading_lists_provider.dart';
import 'package:takion/src/presentation/features/reading_lists/providers/random_reading_list_provider.dart';
import 'package:takion/src/presentation/features/reading_lists/reading_list_card.dart';
import 'package:takion/src/presentation/components/takion_bottom_sheet.dart';

@RoutePage()
class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(collectionStatsProvider);
    final suggestionAsync = ref.watch(readingSuggestionIssueProvider);
    final rateSuggestionAsync = ref.watch(rateSuggestionIssueProvider);

    void showRateSuggestionSheet({
      required int issueId,
      required String comicName,
      required int initialRating,
    }) {
      var selectedRating = initialRating.clamp(0, 5);
      ref.read(scrobbleIssueProvider(issueId).notifier).reset();

      TakionBottomSheet.show<void>(
        context: context,
        title: 'Rate $comicName',
        child: Consumer(
          builder: (context, ref, _) {
            final scrobbleState = ref.watch(scrobbleIssueProvider(issueId));
            final isSubmitting = scrobbleState.isLoading;
            final errorMessage = scrobbleState.whenOrNull(
              error: (error, _) => '$error',
            );

            return StatefulBuilder(
              builder: (context, setModalState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RatingPicker(
                      selectedRating: selectedRating,
                      enabled: !isSubmitting,
                      iconSize: 38,
                      onChanged: (value) {
                        setModalState(() {
                          selectedRating = value;
                        });
                      },
                      onReset: () {
                        setModalState(() {
                          selectedRating = 0;
                        });
                      },
                    ),
                    if (errorMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        errorMessage,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton(
                        onPressed: isSubmitting || selectedRating <= 0
                            ? null
                            : () async {
                                await ref
                                    .read(
                                      scrobbleIssueProvider(issueId).notifier,
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

                                if (context.mounted) {
                                  Navigator.of(context).pop();
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
                );
              },
            );
          },
        ),
      );
    }

    return Scaffold(
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
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                  const SizedBox(width: 4),
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
                  const SizedBox(width: 4),
                  ActionCard(
                    icon: Icons.turned_in_not,
                    value: statsAsync.when(
                      data: (stats) => stats.wishlistCount.toString(),
                      loading: () => '--',
                      error: (_, _) => '!',
                    ),
                    label: 'Wishlist',
                    onTap: () {
                      context.pushRoute(const WishlistRoute());
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
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
                    context.pushRoute(CollectionReadStatusRoute(isRead: false));
                  },
                ),
                CompactListSectionItem(
                  icon: Icons.star_border_outlined,
                  label: 'Unrated',
                  value: statsAsync.when(
                    data: (stats) => stats.unratedCount.toString(),
                    loading: () => '--',
                    error: (_, _) => '!',
                  ),
                  onTap: () {
                    context.pushRoute(const UnratedIssuesRoute());
                  },
                ),
                CompactListSectionItem(
                  icon: Icons.list_alt_outlined,
                  label: 'Reading Lists',
                  value: ref
                      .watch(readingListsProvider)
                      .when(
                        data: (lists) => lists.length.toString(),
                        loading: () => '--',
                        error: (_, _) => '!',
                      ),
                  onTap: () {
                    context.pushRoute(const ReadingListsRoute());
                  },
                ),
                CompactListSectionItem(
                  icon: Icons.favorite_border,
                  label: 'Favorites',
                  onTap: () {
                    context.pushRoute(const FavoritesRoute());
                  },
                ),
                CompactListSectionItem(
                  icon: Icons.history_outlined,
                  label: 'Reading History',
                  onTap: () {
                    context.pushRoute(const ReadingHistoryRoute());
                  },
                ),
              ],
            ),
            suggestionAsync.when(
              loading: () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: SectionSubtitleHeader(
                      title: 'Reading Suggestion',
                      subtitle: 'Not sure what to read next?',
                    ),
                  ),
                  SizedBox(height: 8),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 16,
                    ),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ],
              ),
              error: (error, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
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
                      useCardBackground: false,
                      isCollected: suggestion.isCollected,
                      isRead: suggestion.isRead,
                      rating: suggestion.rating,
                    ),
                  ],
                );
              },
            ),
            Consumer(
              builder: (context, ref, _) {
                final suggestion = ref.watch(randomReadingListProvider);
                if (suggestion == null) return const SizedBox.shrink();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: SectionSubtitleHeader(
                        title: 'Reading List Suggestion',
                        subtitle: 'Pick up where you left off!',
                      ),
                    ),
                    const SizedBox(height: 8),
                    ReadingListCard(
                      list: suggestion,
                      flat: true,
                      onTap: () {
                        if (suggestion.metronSourceId != null) {
                          context.pushRoute(
                            MetronReadingListDetailRoute(id: suggestion.metronSourceId!),
                          );
                        } else {
                          context.pushRoute(
                            ReadingListDetailsRoute(listId: suggestion.id),
                          );
                        }
                      },
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
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 16,
                    ),
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
                      useCardBackground: false,
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
