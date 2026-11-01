import "package:auto_route/auto_route.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/core/router/app_router.gr.dart";
import "package:takion/src/domain/entities.dart";
import "package:takion/src/presentation/features/reading_lists/create_or_import_local_reading_list_sheet.dart";
import "package:takion/src/presentation/features/reading_lists/providers/local_reading_lists_provider.dart";
import "package:takion/src/presentation/features/reading_lists/reading_list_card.dart";
import "package:takion/src/presentation/shared/alerts/takion_alerts.dart";
import "package:takion/src/presentation/shared/widgets/components.dart";
import "package:takion/src/presentation/shared/widgets/empty_content_state.dart";

enum _MyListsFilter { all, custom, followed }

@RoutePage()
class ReadingListsScreen extends ConsumerStatefulWidget {
  const ReadingListsScreen({super.key});

  @override
  ConsumerState<ReadingListsScreen> createState() => _ReadingListsScreenState();
}

class _ReadingListsScreenState extends ConsumerState<ReadingListsScreen> {
  bool _isSearching = false;
  _MyListsFilter _myListsFilter = _MyListsFilter.all;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listsAsync = ref.watch(localReadingListsProvider);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
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
                        _isSearching = false;
                        _searchController.clear();
                      });
                    },
                  ),
                ),
              )
            : const Text("Reading Lists"),
        actions: [
          if (_isSearching)
            const SizedBox.shrink()
          else
            IconButton(
              tooltip: "Search my lists",
              onPressed: () => setState(() => _isSearching = true),
              icon: const Icon(Icons.search),
            ),
        ],
      ),
      body: _buildListsBody(context, listsAsync),
      floatingActionButton: FloatingActionButton(
        onPressed: () => CreateOrImportLocalReadingListSheet.show(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildListsBody(
    BuildContext context,
    AsyncValue<List<LocalReadingList>> listsAsync,
  ) {
    return listsAsync.when(
      data: (lists) {
        final query = _searchController.text.toLowerCase().trim();
        final matchQuery = _isSearching && query.isNotEmpty
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
            actionLabel: "Discover",
            onAction: () {
              context.pushRoute(const BrowseReadingListsRoute());
            },
          );
        } else if (filtered.isEmpty) {
          if (_isSearching) {
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
              actionLabel: "Discover",
              onAction: () {
                context.pushRoute(const BrowseReadingListsRoute());
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
                  context.pushRoute(ReadingListDetailsRoute(listId: list.id));
                },
              );
            },
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          TakionAlerts.cleanError(e, fallback: "Failed to load reading lists"),
        ),
      ),
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
