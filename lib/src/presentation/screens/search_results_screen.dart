import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities/issue_list.dart';
import 'package:takion/src/presentation/providers/issue_search_provider.dart';
import 'package:takion/src/presentation/providers/repository_providers.dart';
import 'package:takion/src/presentation/widgets/issue_list_tile.dart';

@RoutePage()
class SearchResultsScreen extends ConsumerStatefulWidget {
  const SearchResultsScreen({
    super.key,
    required this.query,
    this.searchChoice = 'Issues',
  });

  final String query;
  final String searchChoice;

  @override
  ConsumerState<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends ConsumerState<SearchResultsScreen> {
  final TextEditingController _filterController = TextEditingController();
  bool _isFiltering = false;

  Future<void> _forceRefreshResults() async {
    await ref
        .read(metronRepositoryProvider)
        .searchIssues(widget.query, forceRefresh: true);
    ref.invalidate(issueSearchResultsProvider(widget.query));
    await ref.read(issueSearchResultsProvider(widget.query).future);
  }

  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
  }

  List<IssueList> _applyFilter(List<IssueList> issues) {
    final filter = _filterController.text.trim().toLowerCase();
    if (filter.isEmpty) return issues;

    return issues.where((issue) {
      final issueName = issue.name.toLowerCase();
      final seriesName = issue.series?.name.toLowerCase() ?? '';
      return issueName.contains(filter) || seriesName.contains(filter);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final resultsAsync = ref.watch(issueSearchResultsProvider(widget.query));

    return Scaffold(
      appBar: AppBar(
        titleSpacing: _isFiltering ? 0 : null,
        title: _isFiltering
            ? TextField(
                controller: _filterController,
                autofocus: true,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Filter results...',
                  border: InputBorder.none,
                  isDense: true,
                  filled: false,
                  suffixIcon: IconButton(
                    tooltip: 'Close filter',
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _isFiltering = false;
                        _filterController.clear();
                      });
                    },
                  ),
                ),
              )
            : null,
        actions: _isFiltering
            ? null
            : [
                IconButton(
                  tooltip: 'Search',
                  onPressed: () {
                    setState(() {
                      _isFiltering = true;
                    });
                  },
                  icon: const Icon(Icons.search),
                ),
                IconButton(
                  tooltip: 'Sort',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Sort options coming soon.')),
                    );
                  },
                  icon: const Icon(Icons.sort),
                ),
              ],
        bottom: resultsAsync.isLoading
            ? const PreferredSize(
                preferredSize: Size.fromHeight(4),
                child: LinearProgressIndicator(),
              )
            : null,
      ),
      body: resultsAsync.when(
        loading: () => const SizedBox.shrink(),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Search failed: $error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (issues) {
          final filteredIssues = _applyFilter(issues);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  '${filteredIssues.length} results for "${widget.query}" in ${widget.searchChoice}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              Expanded(
                child: filteredIssues.isEmpty
                    ? RefreshIndicator(
                        onRefresh: _forceRefreshResults,
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(height: 220),
                            Center(child: Text('No issues found.')),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _forceRefreshResults,
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          itemCount: filteredIssues.length,
                          itemBuilder: (context, index) {
                            final issue = filteredIssues[index];
                            return IssueListTile(
                              issue: issue,
                              isFirst: index == 0,
                              isLast: index == filteredIssues.length - 1,
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
