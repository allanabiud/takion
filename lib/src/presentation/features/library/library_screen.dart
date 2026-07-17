import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/presentation/features/library/providers/collection_stats_provider.dart';
import 'package:takion/src/presentation/features/library/providers/collection_suggestions_provider.dart';
import 'package:takion/src/presentation/components/components.dart';
import 'package:takion/src/presentation/features/issues/issue_list_tile.dart';
import 'package:takion/src/presentation/common/takion_alerts.dart';
import 'package:takion/src/presentation/features/reading_lists/providers/reading_lists_provider.dart';
import 'package:takion/src/presentation/features/reading_lists/providers/random_reading_list_provider.dart';
import 'package:takion/src/presentation/features/reading_lists/reading_list_card.dart';

@RoutePage()
class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(collectionStatsProvider);
    final suggestionAsync = ref.watch(readingSuggestionIssueProvider);
    final rateSuggestionAsync = ref.watch(rateSuggestionIssueProvider);

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
                      TakionAlerts.cleanError(error, fallback: 'Something went wrong'),
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
                        context.pushRoute(
                          ReadingListDetailsRoute(listId: suggestion.id),
                        );
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
                      TakionAlerts.cleanError(error, fallback: 'Something went wrong'),
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
