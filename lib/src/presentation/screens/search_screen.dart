import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/presentation/providers/search_provider.dart';
import 'package:takion/src/presentation/providers/search_results_provider.dart';

@RoutePage()
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query, SearchType type) {
    if (query.trim().isEmpty) return;
    ref.read(searchHistoryProvider.notifier).addQuery(query);
    ref.read(searchResultsProvider.notifier).initiateSearch(query, type);
    context.pushRoute(const SearchResultsRoute());
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);
    final history = ref.watch(searchHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Hero(
            tag: 'search_bar',
            child: Material(
              color: Colors.transparent,
              child: SearchBar(
                controller: _searchController,
                hintText: 'Search Metron...',
                leading: const Icon(Icons.search, size: 24),
                autoFocus: true,
                onSubmitted: (value) =>
                    _onSearch(value, searchState.searchType),
                elevation: WidgetStateProperty.all(0),
                backgroundColor: WidgetStateProperty.all(
                  Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: SearchType.values.map((type) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(
                      type.name[0].toUpperCase() + type.name.substring(1),
                    ),
                    selected: searchState.searchType == type,
                    onSelected: (selected) {
                      if (selected) {
                        ref.read(searchProvider.notifier).setSearchType(type);
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(child: _buildHistory(history, searchState.searchType)),
        ],
      ),
    );
  }

  Widget _buildHistory(List<String> history, SearchType currentType) {
    if (history.isEmpty) {
      return const Center(child: Text('No search history yet'));
    }
    return ListView.builder(
      itemCount: history.length,
      itemBuilder: (context, index) {
        final query = history[index];
        return ListTile(
          contentPadding: const EdgeInsets.only(left: 16, right: 0),
          leading: const Icon(Icons.history),
          title: Text(query),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.north_west, size: 24),
                tooltip: 'Copy to search field',
                onPressed: () {
                  _searchController.text = query;
                  // Move cursor to end
                  _searchController.selection = TextSelection.fromPosition(
                    TextPosition(offset: _searchController.text.length),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 24),
                tooltip: 'Delete from history',
                onPressed: () =>
                    ref.read(searchHistoryProvider.notifier).removeQuery(query),
              ),
            ],
          ),
          onTap: () {
            _searchController.text = query;
            _onSearch(query, currentType);
          },
        );
      },
    );
  }
}
