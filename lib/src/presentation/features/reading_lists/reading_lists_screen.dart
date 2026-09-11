import "dart:async";

import "package:auto_route/auto_route.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/core/router/app_router.gr.dart";
import "package:takion/src/domain/entities.dart";
import "package:takion/src/presentation/features/reading_lists/create_or_import_local_reading_list_sheet.dart";
import "package:takion/src/presentation/features/reading_lists/providers/local_reading_lists_provider.dart";
import "package:takion/src/presentation/features/reading_lists/providers/metron_reading_lists_provider.dart";
import "package:takion/src/presentation/features/reading_lists/reading_list_card.dart";
import "package:takion/src/presentation/shared/alerts/takion_alerts.dart";
import "package:takion/src/presentation/shared/widgets/components.dart";
import "package:takion/src/presentation/shared/widgets/empty_content_state.dart";

enum _MyListsFilter { all, custom, followed }

@RoutePage()
class ReadingListsScreen extends ConsumerStatefulWidget {
  final int initialTab;

  const ReadingListsScreen({
    super.key,
    this.initialTab = 0,
  });

  @override
  ConsumerState<ReadingListsScreen> createState() => _ReadingListsScreenState();
}

class _ReadingListsScreenState extends ConsumerState<ReadingListsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // My Lists state
  bool _isMyListsSearching = false;
  _MyListsFilter _myListsFilter = _MyListsFilter.all;
  final TextEditingController _myListsSearchController = TextEditingController();

  // Discover state
  final TextEditingController _discoverSearchController = TextEditingController();
  Timer? _discoverSearchDebounce;
  String? _selectedListType;
  String? _selectedAttribution;
  int _discoverPage = 1;

  static const _listTypes = [
    null,
    "EVENT",
    "STORY",
    "CHARACTERS",
    "CREATOR",
    "TEAMS",
    "MASTER",
  ];

  static const _attributionSources = [
    null,
    "CBRO",
    "CMRO",
    "CBH",
    "CBT",
    "MG",
    "HTLC",
    "LOCG",
    "OTHER",
  ];

  String _listTypeLabel(String? t) =>
      t == null ? "All Types" : t[0] + t.substring(1).toLowerCase();

  String _attributionLabel(String? s) => s ?? "All Sources";

  MetronReadingListFilter get _discoverFilter => MetronReadingListFilter(
        page: _discoverPage,
        name: _discoverSearchController.text.trim().isEmpty
            ? null
            : _discoverSearchController.text.trim(),
        listType: _selectedListType,
        attributionSource: _selectedAttribution,
      );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, 1),
    );
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _myListsSearchController.dispose();
    _discoverSearchDebounce?.cancel();
    _discoverSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final myListsAsync = ref.watch(localReadingListsProvider);
    final myListsCount = myListsAsync.value?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: _isMyListsSearching && _tabController.index == 0 ? 0 : null,
        title: _isMyListsSearching && _tabController.index == 0
            ? TextField(
                controller: _myListsSearchController,
                autofocus: true,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: "Search my lists...",
                  border: InputBorder.none,
                  isDense: true,
                  filled: false,
                  suffixIcon: IconButton(
                    tooltip: "Close search",
                    iconSize: 28,
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _isMyListsSearching = false;
                        _myListsSearchController.clear();
                      });
                    },
                  ),
                ),
              )
            : const Text("Reading Lists"),
        actions: [
          if (_tabController.index == 0)
            if (_isMyListsSearching)
              const SizedBox.shrink()
            else
              IconButton(
                tooltip: "Search my lists",
                onPressed: () => setState(() => _isMyListsSearching = true),
                icon: const Icon(Icons.search),
              ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("My Lists"),
                  if (myListsCount > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "$myListsCount",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.explore_outlined, size: 18),
                  SizedBox(width: 6),
                  Text("Discover"),
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMyListsTab(context, myListsAsync),
          _buildDiscoverTab(context),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: () => CreateOrImportLocalReadingListSheet.show(context),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildMyListsTab(
    BuildContext context,
    AsyncValue<List<LocalReadingList>> listsAsync,
  ) {
    return listsAsync.when(
      data: (lists) {
        final query = _myListsSearchController.text.toLowerCase().trim();
        final matchQuery = _isMyListsSearching && query.isNotEmpty
            ? (LocalReadingList l) =>
                l.title.toLowerCase().contains(query) ||
                l.description.toLowerCase().contains(query)
            : (LocalReadingList l) => true;

        final filtered = lists.where((l) {
          if (!matchQuery(l)) return false;
          return switch (_myListsFilter) {
            _MyListsFilter.all => true,
            _MyListsFilter.custom => !l.isMetronImported,
            _MyListsFilter.followed => l.isMetronImported,
          };
        }).toList();

        final Widget content;
        if (lists.isEmpty) {
          content = EmptyContentState(
            icon: Icons.list_alt_outlined,
            message: "No reading lists yet.",
            actionLabel: "Explore Curated Lists",
            onAction: () {
              _tabController.animateTo(1);
            },
            secondaryActionLabel: "Create Custom List",
            onSecondaryAction: () {
              CreateOrImportLocalReadingListSheet.show(context);
            },
          );
        } else if (filtered.isEmpty) {
          if (_isMyListsSearching) {
            content = EmptyContentState(
              icon: Icons.search_off,
              message: 'No reading lists found for "$query"',
            );
          } else if (_myListsFilter == _MyListsFilter.custom) {
            content = EmptyContentState(
              icon: Icons.list_alt_outlined,
              message: "No custom reading lists created.",
              actionLabel: "Create List",
              onAction: () {
                CreateOrImportLocalReadingListSheet.show(context);
              },
            );
          } else if (_myListsFilter == _MyListsFilter.followed) {
            content = EmptyContentState(
              icon: Icons.explore_outlined,
              message: "No Metron reading lists followed yet.",
              actionLabel: "Discover Lists",
              onAction: () {
                _tabController.animateTo(1);
              },
            );
          } else {
            content = const EmptyContentState(
              icon: Icons.list_alt_outlined,
              message: "No reading lists found.",
            );
          }
        } else {
          content = ListView.separated(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: filtered.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final list = filtered[index];
              return ReadingListCard(
                list: list,
                flat: true,
                onTap: () {
                  context.pushRoute(
                    ReadingListDetailsRoute(listId: list.id),
                  );
                },
              );
            },
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: SizedBox(
                width: double.infinity,
                child: SegmentedButton<_MyListsFilter>(
                  segments: const [
                    ButtonSegment(
                      value: _MyListsFilter.all,
                      label: Text("All"),
                    ),
                    ButtonSegment(
                      value: _MyListsFilter.custom,
                      label: Text("Custom"),
                    ),
                    ButtonSegment(
                      value: _MyListsFilter.followed,
                      label: Text("Followed"),
                    ),
                  ],
                  selected: {_myListsFilter},
                  onSelectionChanged: (v) {
                    setState(() => _myListsFilter = v.first);
                  },
                ),
              ),
            ),
            Expanded(child: content),
          ],
        );
      },
      loading: _buildSkeletonList,
      error: (e, _) => Center(
        child: Text(
          TakionAlerts.cleanError(
            e,
            fallback: "Failed to load reading lists",
          ),
        ),
      ),
    );
  }

  Widget _buildDiscoverTab(BuildContext context) {
    final theme = Theme.of(context);
    final async = ref.watch(metronReadingListBrowseProvider(_discoverFilter));
    final importedListsAsync = ref.watch(localReadingListsProvider);
    final importedLists = importedListsAsync.value ?? const <LocalReadingList>[];
    final previewItemsMap = ref.watch(metronListPreviewItemsProvider);

    return BrowsePagedListScreen<MetronReadingList>(
      title: "",
      pageAsync: async,
      onRefresh: () async {
        ref.invalidate(metronReadingListBrowseProvider(_discoverFilter));
      },
      onPrevious: () => setState(() => _discoverPage--),
      onNext: () => setState(() => _discoverPage++),
      emptyMessage: "No reading lists found.",
      emptyIcon: Icons.list_alt_outlined,
      errorPrefix: "Failed to load",
      header: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Icon(Icons.search, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _discoverSearchController,
                      decoration: const InputDecoration(
                        hintText: "Search Metron curated reading lists...",
                        border: InputBorder.none,
                        isDense: true,
                        filled: false,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: theme.textTheme.bodyLarge,
                      onChanged: (value) {
                        _discoverSearchDebounce?.cancel();
                        _discoverSearchDebounce = Timer(
                          const Duration(milliseconds: 400),
                          () {
                            if (mounted) {
                              setState(() => _discoverPage = 1);
                            }
                          },
                        );
                      },
                    ),
                  ),
                  if (_discoverSearchController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () {
                        _discoverSearchController.clear();
                        setState(() => _discoverPage = 1);
                      },
                    ),
                  const SizedBox(width: 4),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    height: 44,
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String?>(
                        value: _selectedListType,
                        isExpanded: true,
                        hint: const Text("Type"),
                        items: _listTypes.map((t) {
                          return DropdownMenuItem(
                            value: t,
                            child: Text(_listTypeLabel(t)),
                          );
                        }).toList(),
                        onChanged: (v) => setState(() {
                          _selectedListType = v;
                          _discoverPage = 1;
                        }),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    height: 44,
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String?>(
                        value: _selectedAttribution,
                        isExpanded: true,
                        hint: const Text("Source"),
                        items: _attributionSources.map((s) {
                          return DropdownMenuItem(
                            value: s,
                            child: Text(_attributionLabel(s)),
                          );
                        }).toList(),
                        onChanged: (v) => setState(() {
                          _selectedAttribution = v;
                          _discoverPage = 1;
                        }),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      itemBuilder: (context, list, index, total) {
        final localList = importedLists.cast<LocalReadingList?>().firstWhere(
          (l) => l?.metronSourceId == list.id,
          orElse: () => null,
        );

        final previewItems = previewItemsMap[list.id]
                ?.map(
                  (item) => LocalReadingListItem(
                    targetId: "issue-${item.issueId}",
                    isSeries: false,
                    role: ItemRole.standard,
                    isRead: false,
                    seriesName: item.seriesName,
                    seriesVolume: item.seriesVolume,
                    issueNumber: item.issueNumber,
                  ),
                )
                .toList() ??
            const [];

        final displayList = localList ??
            LocalReadingList(
              id: "metron-${list.id}",
              title: list.name,
              description: "",
              isOrdered: true,
              contentType: ListContentType.issue,
              createdAt: list.modified ?? DateTime.now(),
              updatedAt: list.modified ?? DateTime.now(),
              items: previewItems,
              metronSourceId: list.id,
              metronAttributionSource: list.attributionSource,
              metronListType: list.listType,
            );

        return ReadingListCard(
          list: displayList,
          alreadyExists: localList != null,
          isMetronBrowse: true,
          averageRating: list.averageRating,
          ratingCount: list.ratingCount,
          onTap: () {
            context.pushRoute(ReadingListDetailsRoute(id: list.id));
          },
        );
      },
    );
  }

  Widget _buildSkeletonList() {
    const double coverWidth = 60;
    const double coverHeight = 85;
    const double peekOffset = 14;
    const double stackedWidth = coverWidth + peekOffset * 2;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ShimmerWidget(
            child: Row(
              children: List.generate(3, (i) {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: i > 0 ? 8 : 0,
                      right: i < 2 ? 8 : 0,
                    ),
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
        Expanded(
          child: ShimmerWidget(
            child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              padding: const EdgeInsets.only(bottom: 8),
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: index == 0 ? 12 : 2,
                    bottom: index == 4 ? 12 : 0,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: stackedWidth,
                        height: coverHeight,
                        child: Stack(
                          children: [
                            const Positioned(
                              left: 0,
                              child: SkeletonBox(
                                width: coverWidth * 0.85,
                                height: coverHeight * 0.9,
                                borderRadius: 6,
                              ),
                            ),
                            const Positioned(
                              right: 0,
                              child: SkeletonBox(
                                width: coverWidth * 0.85,
                                height: coverHeight * 0.9,
                                borderRadius: 6,
                              ),
                            ),
                            Positioned(
                              child: Container(
                                width: coverWidth,
                                height: coverHeight,
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: SkeletonBox(
                                    height: 16,
                                    width: double.infinity,
                                  ),
                                ),
                                SizedBox(width: 8),
                                SkeletonBox(
                                  width: 16,
                                  height: 16,
                                  borderRadius: 3,
                                ),
                              ],
                            ),
                            SizedBox(height: 6),
                            SkeletonBox(height: 14, width: 120),
                            SizedBox(height: 12),
                            SkeletonBox(
                              height: 6,
                              width: double.infinity,
                              borderRadius: 3,
                            ),
                            SizedBox(height: 4),
                            Align(
                              alignment: Alignment.centerRight,
                              child: SkeletonBox(
                                height: 12,
                                width: 60,
                                borderRadius: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
