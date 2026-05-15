import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/presentation/providers/reading_lists_provider.dart';
import 'package:takion/src/presentation/widgets/create_reading_list_bottom_sheet.dart';
import 'package:takion/src/presentation/widgets/empty_content_state.dart';
import 'package:takion/src/presentation/widgets/reading_list_card.dart';

@RoutePage()
class MyReadingListsScreen extends ConsumerStatefulWidget {

  const MyReadingListsScreen({super.key});

  @override
  ConsumerState<MyReadingListsScreen> createState() => _MyReadingListsScreenState();
}

class _MyReadingListsScreenState extends ConsumerState<MyReadingListsScreen> {
  bool _isSearching = false;
  bool _isFabOpen = false;
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
            : const Text('My Reading Lists'),
        actions: _isSearching
            ? null
            : [
                IconButton(
                  tooltip: 'Search',
                  onPressed: () {
                    setState(() {
                      _isSearching = true;
                    });
                  },
                  icon: const Icon(Icons.search),
                ),
              ],
      ),
      body: listsAsync.when(
        data: (lists) {
          final filtered = _isSearching
              ? lists
                  .where((l) => l.title.toLowerCase().contains(_searchController.text.toLowerCase()))
                  .toList()
              : lists;

          if (filtered.isEmpty) {
            return const EmptyContentState(
              icon: Icons.list_alt_outlined,
              message: 'No reading lists created yet.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              return ReadingListCard(
                list: filtered[index],
                onTap: () {
                  context.pushRoute(ReadingListDetailsRoute(listId: filtered[index].id));
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_isFabOpen) ...[
            FloatingActionButton.extended(
              onPressed: () {
                setState(() => _isFabOpen = false);
                // TODO: Handle Import
              },
              icon: const Icon(Icons.file_download_outlined),
              label: const Text('Import'),
            ),
            const SizedBox(height: 12),
            FloatingActionButton.extended(
              onPressed: () {
                setState(() => _isFabOpen = false);
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => const CreateReadingListBottomSheet(),
                );
              },
              icon: const Icon(Icons.list_alt),
              label: const Text('Create'),
            ),
            const SizedBox(height: 12),
          ],
          FloatingActionButton(
            onPressed: () {
              setState(() => _isFabOpen = !_isFabOpen);
            },
            child: Icon(_isFabOpen ? Icons.close : Icons.add),
          ),
        ],
      ),
    );
  }
}
