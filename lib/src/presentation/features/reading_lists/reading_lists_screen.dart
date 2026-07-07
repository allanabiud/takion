import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/domain/entities/reading_list.dart';
import 'package:takion/src/presentation/features/reading_lists/providers/reading_lists_provider.dart';
import 'package:takion/src/presentation/features/reading_lists/create_or_import_reading_list_sheet.dart';
import 'package:takion/src/presentation/common/empty_content_state.dart';
import 'package:takion/src/presentation/components/shimmer_widget.dart';
import 'package:takion/src/presentation/components/skeleton.dart';
import 'package:takion/src/presentation/features/reading_lists/reading_list_card.dart';

enum _ReadingListFilter { all, local, metron }

@RoutePage()
class ReadingListsScreen extends ConsumerStatefulWidget {
  const ReadingListsScreen({super.key});

  @override
  ConsumerState<ReadingListsScreen> createState() =>
      _ReadingListsScreenState();
}

class _ReadingListsScreenState extends ConsumerState<ReadingListsScreen> {
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
    final listsAsync = ref.watch(readingListsProvider);

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
              ? (ReadingList l) =>
                  l.title.toLowerCase().contains(query) ||
                  l.description.toLowerCase().contains(query)
              : (ReadingList l) => true;

          final filtered = lists.where((l) {
            if (!matchQuery(l)) return false;
            return switch (_filter) {
              _ReadingListFilter.all => true,
              _ReadingListFilter.local => l.metronSourceId == null,
              _ReadingListFilter.metron => l.metronSourceId != null,
            };
          }).toList();

          final isEmptyState = lists.isEmpty;

          if (isEmptyState) {
            return const EmptyContentState(
              icon: Icons.list_alt_outlined,
              message: 'No reading lists created yet.',
            );
          }

          final Widget content;
          if (filtered.isEmpty) {
            if (_isSearching) {
              content = EmptyContentState(
                icon: Icons.search_off,
                message: 'No reading lists found for "$query"',
              );
            } else if (_filter == _ReadingListFilter.local) {
              content = const EmptyContentState(
                icon: Icons.list_alt_outlined,
                message: 'No local reading lists created yet.',
              );
            } else if (_filter == _ReadingListFilter.metron) {
              content = EmptyContentState(
                icon: Icons.cloud_download_outlined,
                message: 'No Metron reading lists imported yet.',
                actionLabel: 'Browse Metron',
                onAction: () {
                  context.pushRoute(
                    const MetronReadingListBrowserRoute(),
                  );
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
              separatorBuilder: (context, index) =>
                  const Divider(height: 1),
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
              Expanded(
                child: content,
              ),
            ],
          );
        },
        loading: () => _buildSkeletonList(),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => CreateOrImportReadingListSheet.show(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSkeletonList() {
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
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
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
                    children: [
                      const SkeletonBox(width: 60, height: 85, borderRadius: 8),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SkeletonBox(height: 16, width: 200),
                            SizedBox(height: 6),
                            SkeletonBox(height: 14, width: 120),
                            SizedBox(height: 10),
                            SkeletonBox(height: 8, width: double.infinity, borderRadius: 4),
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

