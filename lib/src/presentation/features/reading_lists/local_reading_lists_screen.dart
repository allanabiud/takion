import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/domain/entities.dart';
import 'package:takion/src/presentation/features/reading_lists/providers/local_reading_lists_provider.dart';
import 'package:takion/src/presentation/features/reading_lists/create_or_import_local_reading_list_sheet.dart';
import 'package:takion/src/presentation/shared/widgets/empty_content_state.dart';
import 'package:takion/src/presentation/shared/alerts/takion_alerts.dart';
import 'package:takion/src/presentation/shared/widgets/components.dart';
import 'package:takion/src/presentation/features/reading_lists/reading_list_card.dart';

enum _ReadingListFilter { all, local, metron }

@RoutePage()
class LocalReadingListsScreen extends ConsumerStatefulWidget {
  const LocalReadingListsScreen({super.key});

  @override
  ConsumerState<LocalReadingListsScreen> createState() =>
      _LocalReadingListsScreenState();
}

class _LocalReadingListsScreenState
    extends ConsumerState<LocalReadingListsScreen> {
  bool _isSearching = false;
  _ReadingListFilter _filter = _ReadingListFilter.all;
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
        titleSpacing: _isSearching ? 0 : null,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search lists...',
                  border: InputBorder.none,
                  isDense: true,
                  filled: false,
                  suffixIcon: IconButton(
                    tooltip: 'Close search',
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
            : const Text('Reading Lists'),
        actions: _isSearching
            ? null
            : [
                IconButton(
                  tooltip: 'Search',
                  onPressed: () => setState(() => _isSearching = true),
                  icon: const Icon(Icons.search),
                ),
              ],
      ),
      body: listsAsync.when(
        data: (lists) {
          final query = _searchController.text.toLowerCase().trim();
          final matchQuery = _isSearching && query.isNotEmpty
              ? (LocalReadingList l) =>
                    l.title.toLowerCase().contains(query) ||
                    l.description.toLowerCase().contains(query)
              : (LocalReadingList l) => true;

          final filtered = lists.where((l) {
            if (!matchQuery(l)) return false;
            return switch (_filter) {
              _ReadingListFilter.all => true,
              _ReadingListFilter.local => !l.isMetronImported,
              _ReadingListFilter.metron => l.isMetronImported,
            };
          }).toList();

          final Widget content;
          if (lists.isEmpty) {
            content = const EmptyContentState(
              icon: Icons.list_alt_outlined,
              message: 'No reading lists created.',
            );
          } else if (filtered.isEmpty) {
            if (_isSearching) {
              content = EmptyContentState(
                icon: Icons.search_off,
                message: 'No reading lists found for "$query"',
              );
            } else if (_filter == _ReadingListFilter.local) {
              content = const EmptyContentState(
                icon: Icons.list_alt_outlined,
                message: 'No local reading lists created.',
              );
            } else if (_filter == _ReadingListFilter.metron) {
              content = EmptyContentState(
                icon: Icons.cloud_download_outlined,
                message: 'No Metron reading lists imported.',
                actionLabel: 'Browse Metron',
                onAction: () {
                  context.pushRoute(const MetronReadingListBrowserRoute());
                },
                secondaryActionLabel: 'Browse Arcs',
                onSecondaryAction: () {
                  context.pushRoute(const ArcBrowseRoute());
                },
              );
            } else {
              content = const EmptyContentState(
                icon: Icons.list_alt_outlined,
                message: 'No reading lists found.',
              );
            }
          } else {
            content = ListView.separated(
              padding: const EdgeInsets.only(bottom: 8),
              itemCount: filtered.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final list = filtered[index];
                return ReadingListCard(
                  list: list,
                  flat: true,
                  onTap: () {
                    context.pushRoute(
                      LocalReadingListDetailsRoute(listId: list.id),
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
                  child: SegmentedButton<_ReadingListFilter>(
                    segments: const [
                      ButtonSegment(
                        value: _ReadingListFilter.all,
                        label: Text('All'),
                      ),
                      ButtonSegment(
                        value: _ReadingListFilter.local,
                        label: Text('Local'),
                      ),
                      ButtonSegment(
                        value: _ReadingListFilter.metron,
                        label: Text('Metron'),
                      ),
                    ],
                    selected: {_filter},
                    onSelectionChanged: (v) {
                      setState(() => _filter = v.first);
                    },
                  ),
                ),
              ),
              Expanded(child: content),
            ],
          );
        },
        loading: () => _buildSkeletonList(),
        error: (e, _) => Center(
          child: Text(
            TakionAlerts.cleanError(
              e,
              fallback: 'Failed to load reading lists',
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => CreateOrImportLocalReadingListSheet.show(context),
        child: const Icon(Icons.add),
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
                            Positioned(
                              left: 0,
                              child: SkeletonBox(
                                width: coverWidth * 0.85,
                                height: coverHeight * 0.9,
                                borderRadius: 6,
                              ),
                            ),
                            Positioned(
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
