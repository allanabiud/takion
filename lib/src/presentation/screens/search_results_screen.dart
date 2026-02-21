import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities/issue.dart';
import 'package:takion/src/domain/entities/series.dart';
import 'package:takion/src/presentation/providers/search_results_provider.dart';
import 'package:takion/src/presentation/widgets/issue_list_tile.dart';
import 'package:takion/src/presentation/widgets/series_list_tile.dart';

@RoutePage()
class SearchResultsScreen extends ConsumerStatefulWidget {
  const SearchResultsScreen({super.key});

  @override
  ConsumerState<SearchResultsScreen> createState() =>
      _SearchResultsScreenState();
}

class _SearchResultsScreenState extends ConsumerState<SearchResultsScreen> {
  bool _isSearching = false;
  final _filterController = TextEditingController();
  String _filterQuery = '';

  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchResultsProvider);

    final typeName =
        searchState.searchType.name[0].toUpperCase() +
        searchState.searchType.name.substring(1);

    final filteredResults = searchState.results.where((item) {
      if (_filterQuery.isEmpty) return true;
      if (item is Issue) {
        return item.name.toLowerCase().contains(_filterQuery.toLowerCase()) ||
            (item.seriesName?.toLowerCase().contains(
                  _filterQuery.toLowerCase(),
                ) ??
                false);
      }
      if (item is Series) {
        return item.name.toLowerCase().contains(_filterQuery.toLowerCase());
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: _isSearching ? 0 : null,
        title: _isSearching
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: TextField(
                  controller: _filterController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Filter results...',
                    border: InputBorder.none,
                    filled: false,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          _isSearching = false;
                          _filterQuery = '';
                          _filterController.clear();
                        });
                      },
                    ),
                  ),
                  style: Theme.of(context).textTheme.bodyLarge,
                  onChanged: (value) {
                    setState(() {
                      _filterQuery = value;
                    });
                  },
                ),
              )
            : null,
        actions: _isSearching
            ? null
            : [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    setState(() {
                      _isSearching = true;
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.sort),
                  onPressed: () {
                    // Implement sorting logic
                  },
                ),
              ],
        bottom: searchState.isLoading
            ? const PreferredSize(
                preferredSize: Size.fromHeight(2),
                child: LinearProgressIndicator(),
              )
            : null,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!searchState.isLoading)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Found ${filteredResults.length} results for "${searchState.query}" in "$typeName"',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          Expanded(
            child: filteredResults.isEmpty && !searchState.isLoading
                ? const Center(
                    child: Text(
                      'No matching results found',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () =>
                        ref.read(searchResultsProvider.notifier).refresh(),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: filteredResults.length,
                      itemBuilder: (context, index) {
                        final item = filteredResults[index];
                        final isFirst = index == 0;
                        final isLast = index == filteredResults.length - 1;

                        if (item is Issue) {
                          return IssueListTile(
                            issue: item,
                            isFirst: isFirst,
                            isLast: isLast,
                            onTap: () {
                              // Navigate to details
                            },
                          );
                        } else if (item is Series) {
                          return SeriesListTile(
                            series: item,
                            isFirst: isFirst,
                            isLast: isLast,
                            onTap: () {
                              // Navigate to details
                            },
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
