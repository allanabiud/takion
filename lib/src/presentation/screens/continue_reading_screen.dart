import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/presentation/providers/continue_reading_provider.dart';
import 'package:takion/src/presentation/providers/sort_preferences_provider.dart';
import 'package:takion/src/presentation/sorting/content_sorting.dart';
import 'package:takion/src/presentation/widgets/async_state_panel.dart';
import 'package:takion/src/presentation/widgets/display_settings_button.dart';
import 'package:takion/src/presentation/widgets/empty_content_state.dart';
import 'package:takion/src/presentation/widgets/issue_list_tile.dart';

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
      appBar: AppBar(
        title: const Text('Continue Reading'),
        actions: [
          DisplaySettingsButton(
            selectedOption: sortOption,
            optionLabel: issueSortLabel,
            onSelected: (option) {
              ref
                  .read(sortPreferencesProvider.notifier)
                  .setPreference(SortPreferenceContext.continueReading, option);
            },
          ),
        ],
      ),
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
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: sortedItems.length,
            itemBuilder: (context, index) {
              final item = sortedItems[index];
              return IssueListTile(
                issue: item.issue,
                isFirst: index == 0,
                isLast: index == sortedItems.length - 1,
              );
            },
          );
        },
      ),
    );
  }
}
