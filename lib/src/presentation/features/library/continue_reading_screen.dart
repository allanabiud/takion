import "package:auto_route/auto_route.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/presentation/features/library/providers/continue_reading_provider.dart";
import "package:takion/src/presentation/providers/providers.dart";
import "package:takion/src/domain/common/content_sorting.dart";
import "package:takion/src/presentation/shared/widgets/async_state_panel.dart";
import "package:takion/src/presentation/shared/widgets/empty_content_state.dart";
import "package:takion/src/presentation/features/issues/issue_list_tile.dart";
import "package:takion/src/presentation/shared/widgets/components.dart";

@RoutePage()
class ContinueReadingScreen extends ConsumerStatefulWidget {
  const ContinueReadingScreen({super.key});

  @override
  ConsumerState<ContinueReadingScreen> createState() =>
      _ContinueReadingScreenState();
}

class _ContinueReadingScreenState extends ConsumerState<ContinueReadingScreen> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sortOption = ref.watch(
      sortPreferenceForContextProvider(SortPreferenceContext.continueReading),
    );
    final suggestionsAsync = ref.watch(continueReadingAllSuggestionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Continue Reading")),
      floatingActionButton: ScrollToTopFab(controller: _scrollController),
      body: suggestionsAsync.when(
        loading: () => const AsyncStatePanel.loading(),
        error: (error, _) => const AsyncStatePanel.error(
          errorMessage: "Failed to load continue reading",
        ),
        data: (items) {
          final sortedItems = sortItemsByNameAndDate(
            items,
            sortOption: sortOption,
            nameOf: (item) =>
                '${item.issue.series?.name ?? ''} #${item.issue.number}',
            dateOf: (item) => item.lastReadAt,
          );

          if (sortedItems.isEmpty) {
            return const EmptyContentState(
              icon: Icons.menu_book_outlined,
              message: "No continue reading suggestions.",
            );
          }

          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              PinnedListHeader(
                child: ListHeader(
                  count: sortedItems.length,
                  unit: "suggestion",
                  sortLabel: contentSortLabel(sortOption),
                  onSortTap: () => showSortBottomSheet(
                    context,
                    ref,
                    SortPreferenceContext.continueReading,
                    contentSortLabel,
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final item = sortedItems[index];
                  return IssueListTile(
                    issue: item.issue,
                    isFirst: index == 0,
                    isLast: index == sortedItems.length - 1,
                  );
                }, childCount: sortedItems.length),
              ),
            ],
          );
        },
      ),
    );
  }
}
