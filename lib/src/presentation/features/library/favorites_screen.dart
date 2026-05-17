import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/presentation/features/library/providers/favorites_provider.dart';
import 'package:takion/src/presentation/common/async_state_panel.dart';
import 'package:takion/src/presentation/common/empty_content_state.dart';
import 'package:takion/src/presentation/features/issues/issue_list_tile.dart';
import 'package:takion/src/presentation/features/reading_lists/reading_list_card.dart';
import 'package:takion/src/presentation/features/series/series_list_tile.dart';

@RoutePage()
class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Favorites'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Series'),
              Tab(text: 'Issues'),
              Tab(text: 'Reading Lists'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _FavoriteSeriesTab(),
            _FavoriteIssuesTab(),
            _FavoriteReadingListsTab(),
          ],
        ),
      ),
    );
  }
}

class _FavoriteSeriesTab extends ConsumerWidget {
  const _FavoriteSeriesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoriteSeriesFullListProvider);

    return favoritesAsync.when(
      data: (seriesList) {
        if (seriesList.isEmpty) {
          return const EmptyContentState(
            icon: Icons.favorite_border,
            message: 'No favorite series yet.',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: seriesList.length,
          itemBuilder: (context, index) {
            final series = seriesList[index];
            return SeriesListTile(
              series: series,
              isFirst: index == 0,
              isLast: index == seriesList.length - 1,
            );
          },
        );
      },
      loading: () => const AsyncStatePanel.loading(),
      error: (error, stack) => AsyncStatePanel.error(
        errorMessage: 'Failed to load favorite series: $error',
        onRetry: () => ref.invalidate(favoriteSeriesListProvider),
      ),
    );
  }
}

class _FavoriteIssuesTab extends ConsumerWidget {
  const _FavoriteIssuesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoriteIssuesFullListProvider);

    return favoritesAsync.when(
      data: (issuesList) {
        if (issuesList.isEmpty) {
          return const EmptyContentState(
            icon: Icons.favorite_border,
            message: 'No favorite issues yet.',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: issuesList.length,
          itemBuilder: (context, index) {
            final issue = issuesList[index];
            return IssueListTile(
              issue: issue,
              isFirst: index == 0,
              isLast: index == issuesList.length - 1,
            );
          },
        );
      },
      loading: () => const AsyncStatePanel.loading(),
      error: (error, stack) => AsyncStatePanel.error(
        errorMessage: 'Failed to load favorite issues: $error',
        onRetry: () => ref.invalidate(favoriteIssuesListProvider),
      ),
    );
  }
}

class _FavoriteReadingListsTab extends ConsumerWidget {
  const _FavoriteReadingListsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoriteReadingListsFullListProvider);

    return favoritesAsync.when(
      data: (readingLists) {
        if (readingLists.isEmpty) {
          return const EmptyContentState(
            icon: Icons.favorite_border,
            message: 'No favorite reading lists yet.',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: readingLists.length,
          itemBuilder: (context, index) {
            final list = readingLists[index];
            return ReadingListCard(
              list: list,
              onTap: () {
                context.pushRoute(ReadingListDetailsRoute(listId: list.id));
              },
            );
          },
        );
      },
      loading: () => const AsyncStatePanel.loading(),
      error: (error, stack) => AsyncStatePanel.error(
        errorMessage: 'Failed to load favorite reading lists: $error',
        onRetry: () => ref.invalidate(favoriteReadingListsListProvider),
      ),
    );
  }
}
