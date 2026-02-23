import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/presentation/providers/search_state_provider.dart';

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

  void _submitSearch() {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    final target = ref.read(searchStateProvider).target;
    ref.read(searchStateProvider.notifier).addHistory(query);
    if (target == SearchTarget.issues) {
      context.pushRoute(
        SearchResultsRoute(query: query, searchChoice: 'Issues'),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Series search coming soon.')),
      );
    }
    FocusScope.of(context).unfocus();
  }

  void _populateSearchField(String value) {
    _searchController.text = value;
    _searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: _searchController.text.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchStateProvider);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Hero(
          tag: kSearchBarHeroTag,
          child: Material(
            color: Colors.transparent,
            child: SearchBar(
              controller: _searchController,
              hintText: 'Search comics...',
              leading: const Icon(Icons.search),
              autoFocus: true,
              onSubmitted: (_) => _submitSearch(),
              trailing: [
                IconButton(
                  tooltip: 'Clear',
                  onPressed: () {
                    _searchController.clear();
                  },
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('Series'),
                  selected: state.target == SearchTarget.series,
                  onSelected: (_) {
                    ref
                        .read(searchStateProvider.notifier)
                        .setTarget(SearchTarget.series);
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Issues'),
                  selected: state.target == SearchTarget.issues,
                  onSelected: (_) {
                    ref
                        .read(searchStateProvider.notifier)
                        .setTarget(SearchTarget.issues);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: state.history.isEmpty
                ? const Center(child: Text('No search history yet'))
                : ListView.builder(
                    itemCount: state.history.length,
                    itemBuilder: (context, index) {
                      final item = state.history[index];
                      return ListTile(
                        leading: const Icon(Icons.history),
                        title: Text(item),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Use query',
                              icon: const Icon(Icons.north_west),
                              onPressed: () {
                                _populateSearchField(item);
                              },
                            ),
                            IconButton(
                              tooltip: 'Delete from history',
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () {
                                ref
                                    .read(searchStateProvider.notifier)
                                    .removeHistory(item);
                              },
                            ),
                          ],
                        ),
                        onTap: () {
                          _populateSearchField(item);
                          _submitSearch();
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
