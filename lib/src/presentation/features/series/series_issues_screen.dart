import "package:auto_route/auto_route.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/core/constants/pagination.dart";
import "package:takion/src/domain/common/content_sorting.dart";
import "package:takion/src/domain/entities.dart";
import "package:takion/src/presentation/features/issues/issue_list_tile.dart";
import "package:takion/src/presentation/features/library/providers/collection_items_provider.dart";
import "package:takion/src/presentation/features/series/providers/series_details_provider.dart";
import "package:takion/src/presentation/features/series/providers/series_issue_list_provider.dart";
import "package:takion/src/presentation/features/series/series_issue_bulk_actions.dart";
import "package:takion/src/presentation/providers/providers.dart";
import "package:takion/src/presentation/shared/widgets/async_state_panel.dart";
import "package:takion/src/presentation/shared/widgets/components.dart";

@RoutePage()
class SeriesIssuesScreen extends ConsumerStatefulWidget {
  const SeriesIssuesScreen({
    super.key,
    @pathParam required this.seriesId,
    this.initialFilter,
    this.seriesName,
  });

  final int seriesId;
  final String? initialFilter;
  final String? seriesName;

  @override
  ConsumerState<SeriesIssuesScreen> createState() =>
      _SeriesIssuesScreenState();
}

class _SeriesIssuesScreenState extends ConsumerState<SeriesIssuesScreen> {
  late String _selectedFilter;
  int _currentPage = 1;
  final ScrollController _chipScrollController = ScrollController();
  final Map<String, GlobalKey> _chipKeys = {};

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.initialFilter ?? "all";
    if (_selectedFilter == "collected") _selectedFilter = "owned";
    _scrollToSelectedChip(animate: false);
  }

  @override
  void dispose() {
    _chipScrollController.dispose();
    super.dispose();
  }

  GlobalKey _chipKey(String filter) {
    return _chipKeys.putIfAbsent(filter, GlobalKey.new);
  }

  void _scrollToSelectedChip({bool animate = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final key = _chipKeys[_selectedFilter];
      final currentContext = key?.currentContext;
      if (currentContext != null) {
        Scrollable.ensureVisible(
          currentContext,
          duration: animate ? const Duration(milliseconds: 250) : Duration.zero,
          curve: Curves.easeInOutCubic,
          alignment: 0.5,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final details = ref.watch(seriesDetailsProvider(widget.seriesId)).asData?.value;
    final seriesName = widget.seriesName ?? details?.name ?? "";
    final yearBegan = details?.yearBegan;
    final cleanName = seriesName.replaceAll(RegExp(r"\s*\(\d{4}\)\s*$"), "");
    final subtitle = yearBegan != null ? "$cleanName ($yearBegan)" : seriesName;

    final issuesPageAsync = _selectedFilter == "all"
        ? ref.watch(
            seriesIssueListProvider(
              SeriesIssueListArgs(seriesId: widget.seriesId, page: _currentPage),
            ),
          )
        : null;
    final pageData = issuesPageAsync?.asData?.value;
    final pageSize = pageData?.realPageSize ?? metronDefaultPageSize;
    final totalPages = pageData != null && pageSize > 0
        ? (pageData.count / pageSize).ceil()
        : 1;
    final hasPagination = _selectedFilter == "all" &&
        pageData != null &&
        (pageData.hasNext || pageData.hasPrevious || totalPages > 1);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          subtitle.isNotEmpty ? subtitle : (seriesName.isNotEmpty ? seriesName : "Issues"),
          style: Theme.of(context).textTheme.titleMedium,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => showSeriesIssueBulkActionsSheet(
              context: context,
              ref: ref,
              seriesId: widget.seriesId,
              seriesName: seriesName,
              seriesYear: yearBegan,
            ),
            tooltip: "Bulk actions",
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          const Divider(height: 1),
          Expanded(child: _buildIssuesList()),
        ],
      ),
      bottomNavigationBar: hasPagination
          ? BottomAppBar(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: !pageData.hasPrevious
                        ? null
                        : () => setState(() => _currentPage--),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        totalPages > 1
                            ? "Page $_currentPage of $totalPages"
                            : "Page $_currentPage",
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: !pageData.hasNext
                        ? null
                        : () => setState(() => _currentPage++),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      controller: _chipScrollController,
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildChip("all", "All"),
          const SizedBox(width: 8),
          _buildChip("owned", "Owned"),
          const SizedBox(width: 8),
          _buildChip("unread", "Unread"),
          const SizedBox(width: 8),
          _buildChip("read", "Read"),
          const SizedBox(width: 8),
          _buildChip("wishlist", "Wishlist"),
          const SizedBox(width: 8),
          _buildChip("missing", "Missing"),
          const SizedBox(width: 8),
          _buildChip("unrated", "Unrated"),
        ],
      ),
    );
  }

  Widget _buildChip(String filterKey, String label) {
    final isSelected = _selectedFilter == filterKey;
    return ChoiceChip(
      key: _chipKey(filterKey),
      label: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      selected: isSelected,
      onSelected: (_) {
        HapticFeedback.selectionClick();
        setState(() {
          _selectedFilter = filterKey;
          _currentPage = 1;
        });
        _scrollToSelectedChip();
      },
      shape: const StadiumBorder(),
      showCheckmark: true,
    );
  }

  Widget _buildIssuesList() {
    switch (_selectedFilter) {
      case "all":
        return _buildAllIssuesList();
      case "missing":
        return _buildMissingIssuesList();
      case "owned":
      case "read":
      case "unread":
      case "wishlist":
      case "unrated":
        return _buildLocalFilteredIssuesList();
      default:
        return _buildAllIssuesList();
    }
  }

  Widget _buildAllIssuesList() {
    final issuesPageAsync = ref.watch(
      seriesIssueListProvider(
        SeriesIssueListArgs(seriesId: widget.seriesId, page: _currentPage),
      ),
    );
    final sortOption = ref.watch(
      sortPreferenceForContextProvider(
        SortPreferenceContext.seriesDetailsIssues,
      ),
    );

    return issuesPageAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => AsyncStatePanel.error(
        errorMessage: "Failed to load issues",
        onRetry: () => ref.invalidate(seriesIssueListProvider),
      ),
      data: (page) {
        final issues = page.results;

        if (issues.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Text("No issues found"),
            ),
          );
        }

        return _buildListWithHeader(
          issues: issues,
          totalCount: page.count,
          sortOption: sortOption,
        );
      },
    );
  }

  Widget _buildLocalFilteredIssuesList() {
    final allItemsAsync = _selectedFilter == "wishlist"
        ? ref.watch(wishlistCollectionItemsProvider)
        : ref.watch(allCollectionItemsProvider);
    final sortOption = ref.watch(
      sortPreferenceForContextProvider(
        SortPreferenceContext.seriesDetailsIssues,
      ),
    );

    return allItemsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => AsyncStatePanel.error(
        errorMessage: "Failed to load issues",
        onRetry: () {},
      ),
      data: (allItems) {
        final filtered = allItems.where((item) {
          if (item.seriesId != widget.seriesId) return false;
          switch (_selectedFilter) {
            case "owned":
              return item.ownershipStatus == LibraryOwnershipStatus.owned;
            case "read":
              return item.ownershipStatus == LibraryOwnershipStatus.owned && item.isRead;
            case "unread":
              return item.ownershipStatus == LibraryOwnershipStatus.owned && !item.isRead;
            case "wishlist":
              return item.ownershipStatus == LibraryOwnershipStatus.wishlist;
            case "unrated":
              return item.rating == null || item.rating == 0;
            default:
              return false;
          }
        }).toList();

        if (filtered.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Text("No $_selectedFilter issues"),
            ),
          );
        }

        final mapped = filtered.map((item) {
          final issueId = item.issueId > 0 ? item.issueId : item.id;
          return IssueList(
            id: issueId,
            name: "${item.seriesName} #${item.issueNumber}",
            number: item.issueNumber,
            storeDate: item.issue?.storeDate,
            coverDate: item.issue?.coverDate,
            image: item.imageUrl,
            modified: item.modified,
            series: Series(
              id: item.seriesId,
              name: item.seriesName,
              volume: null,
              yearBegan: null,
            ),
          );
        }).toList();

        final sorted = sortIssues(mapped, sortOption);

        return _buildListWithHeader(
          issues: sorted,
          totalCount: sorted.length,
          sortOption: sortOption,
        );
      },
    );
  }

  Widget _buildMissingIssuesList() {
    final missingAsync = ref.watch(
      seriesMissingIssuesProvider(SeriesMissingIssuesArgs(seriesId: widget.seriesId)),
    );
    final sortOption = ref.watch(
      sortPreferenceForContextProvider(
        SortPreferenceContext.seriesDetailsIssues,
      ),
    );

    return missingAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => AsyncStatePanel.error(
        errorMessage: "Failed to load missing issues",
        onRetry: () => ref.invalidate(
          seriesMissingIssuesProvider(SeriesMissingIssuesArgs(seriesId: widget.seriesId)),
        ),
      ),
      data: (missing) {
        if (missing.results.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Text("No missing issues"),
            ),
          );
        }

        final mapped = missing.results.map((m) {
          return IssueList(
            id: m.id,
            name: "${m.seriesName} #${m.issueNumber}",
            number: m.issueNumber,
            image: m.imageUrl,
            storeDate: m.storeDate,
            coverDate: m.coverDate,
            modified: null,
            series: Series(
              id: m.seriesId,
              name: m.seriesName,
              volume: null,
              yearBegan: null,
            ),
          );
        }).toList();

        final sorted = sortIssues(mapped, sortOption);

        return _buildListWithHeader(
          issues: sorted,
          totalCount: sorted.length,
          sortOption: sortOption,
        );
      },
    );
  }

  Widget _buildListWithHeader({
    required List<IssueList> issues,
    required int totalCount,
    required ContentSortOption sortOption,
  }) {
    return Column(
      children: [
        ListHeader(
          count: totalCount,
          unit: "issue",
          sortLabel: contentSortLabel(sortOption),
          onSortTap: () => showSortBottomSheet(
            context,
            ref,
            SortPreferenceContext.seriesDetailsIssues,
            contentSortLabel,
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: issues.length,
            itemBuilder: (context, index) {
              final issue = issues[index];
              return IssueListTile(
                issue: issue,
                isFirst: index == 0,
                isLast: index == issues.length - 1,
              );
            },
          ),
        ),
      ],
    );
  }
}
