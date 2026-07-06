import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/domain/entities/metron_reading_list.dart';
import 'package:takion/src/domain/entities/reading_list.dart';
import 'package:takion/src/presentation/components/browse_paged_list_screen.dart';
import 'package:takion/src/presentation/features/reading_lists/providers/metron_reading_lists_provider.dart';
import 'package:takion/src/presentation/features/reading_lists/providers/reading_lists_provider.dart';
import 'package:takion/src/presentation/features/reading_lists/reading_list_card.dart';

@RoutePage()
class MetronReadingListBrowserScreen extends ConsumerStatefulWidget {
  const MetronReadingListBrowserScreen({super.key});

  @override
  ConsumerState<MetronReadingListBrowserScreen> createState() =>
      _MetronReadingListBrowserScreenState();
}

class _MetronReadingListBrowserScreenState
    extends ConsumerState<MetronReadingListBrowserScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedListType;
  String? _selectedAttribution;
  int _page = 1;

  static const _listTypes = [
    null,
    'EVENT',
    'STORY',
    'CHARACTERS',
    'CREATOR',
    'TEAMS',
    'MASTER',
  ];

  static const _attributionSources = [
    null,
    'CBRO',
    'CMRO',
    'CBH',
    'CBT',
    'MG',
    'HTLC',
    'LOCG',
    'OTHER',
  ];

  String _listTypeLabel(String? t) =>
      t == null ? 'All' : t[0] + t.substring(1).toLowerCase();

  String _attributionLabel(String? s) => s ?? 'All';

  MetronReadingListFilter get _filter => MetronReadingListFilter(
    page: _page,
    name: _searchController.text.trim().isEmpty
        ? null
        : _searchController.text.trim(),
    listType: _selectedListType,
    attributionSource: _selectedAttribution,
  );

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final async = ref.watch(metronReadingListBrowseProvider(_filter));
    final importedListsAsync = ref.watch(readingListsProvider);
    final importedLists = importedListsAsync.value ?? const <ReadingList>[];
    final previewItemsMap = ref.watch(metronListPreviewItemsProvider);

    return BrowsePagedListScreen<MetronReadingList>(
      title: 'Browse Reading Lists',
      pageAsync: async,
      onRefresh: () async {
        ref.invalidate(metronReadingListBrowseProvider(_filter));
      },
      onPrevious: () => setState(() => _page--),
      onNext: () => setState(() => _page++),
      emptyMessage: 'No reading lists found.',
      emptyIcon: Icons.list_alt_outlined,
      errorPrefix: 'Failed to load',
      header: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 4),
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(26),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Icon(Icons.search, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Filter by name...',
                        border: InputBorder.none,
                        isDense: true,
                        filled: false,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: theme.textTheme.bodyLarge,
                      onChanged: (_) => setState(() => _page = 1),
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _page = 1);
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
                    height: 48,
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String?>(
                        value: _selectedListType,
                        isExpanded: true,
                        hint: const Text('Type'),
                        items: _listTypes.map((t) {
                          return DropdownMenuItem(
                            value: t,
                            child: Text(_listTypeLabel(t)),
                          );
                        }).toList(),
                        onChanged: (v) => setState(() {
                          _selectedListType = v;
                          _page = 1;
                        }),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    height: 48,
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String?>(
                        value: _selectedAttribution,
                        isExpanded: true,
                        hint: const Text('Source'),
                        items: _attributionSources.map((s) {
                          return DropdownMenuItem(
                            value: s,
                            child: Text(_attributionLabel(s)),
                          );
                        }).toList(),
                        onChanged: (v) => setState(() {
                          _selectedAttribution = v;
                          _page = 1;
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
        final localList = importedLists.cast<ReadingList?>().firstWhere(
          (l) => l?.metronSourceId == list.id,
          orElse: () => null,
        );

        final previewItems = previewItemsMap[list.id] ?? const [];
        final displayList = localList ?? ReadingList(
          id: 'metron-${list.id}',
          title: list.name,
          description: '',
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
            context.pushRoute(MetronReadingListDetailRoute(id: list.id));
          },
        );
      },
    );
  }
}
