import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/presentation/features/library/providers/continue_reading_provider.dart';
import 'package:takion/src/presentation/providers/sort_preferences_provider.dart';
import 'package:takion/src/presentation/logic/content_sorting.dart';
import 'package:takion/src/presentation/common/async_state_panel.dart';
import 'package:takion/src/presentation/common/empty_content_state.dart';
import 'package:takion/src/presentation/features/issues/issue_list_tile.dart';
import 'package:takion/src/presentation/components/list_header.dart';
import 'package:takion/src/presentation/components/sort_bottom_sheet.dart';

@RoutePage()
class ContinueReadingScreen extends ConsumerWidget {
  const ContinueReadingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sortOption = ref.watch(
      sortPreferenceForContextProvider(SortPreferenceContext.continueReading),
    );
    final suggestionsAsync = ref.watch(continueReadingAllSuggestionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Continue Reading')),
      body: suggestionsAsync.when(
        loading: () => const AsyncStatePanel.loading(),
        error: (error, _) => AsyncStatePanel.error(
          errorMessage: 'Failed to load continue reading: $error',
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
              message: 'No continue reading suggestions yet.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 12),
            itemCount: sortedItems.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: ListHeader(
                    count: sortedItems.length,
                    unit: 'suggestion',
                    sortLabel: issueSortLabel(sortOption),
                    onSortTap: () => showSortBottomSheet(
                      context,
                      ref,
                      SortPreferenceContext.continueReading,
                      issueSortLabel,
                    ),
                  ),
                );
              }
              final item = sortedItems[index - 1];
              return IssueListTile(
                issue: item.issue,
                isFirst: index == 1,
                isLast: index == sortedItems.length,
              );
            },
          );
        },
      ),
    );
  }
}
