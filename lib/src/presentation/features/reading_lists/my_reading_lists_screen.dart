import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/core/sharing/reading_list_sharing_service.dart';
import 'package:takion/src/presentation/features/reading_lists/providers/reading_lists_provider.dart';
import 'package:takion/src/presentation/features/reading_lists/create_reading_list_bottom_sheet.dart';
import 'package:takion/src/presentation/common/empty_content_state.dart';
import 'package:takion/src/presentation/features/reading_lists/reading_list_card.dart';
import 'package:takion/src/presentation/common/takion_alerts.dart';

@RoutePage()
class MyReadingListsScreen extends ConsumerStatefulWidget {
  const MyReadingListsScreen({super.key});

  @override
  ConsumerState<MyReadingListsScreen> createState() =>
      _MyReadingListsScreenState();
}

class _MyReadingListsScreenState extends ConsumerState<MyReadingListsScreen> {
  bool _isSearching = false;
  bool _isFabOpen = false;
  final TextEditingController _searchController = TextEditingController();

  void _closeFab() {
    if (_isFabOpen) {
      setState(() => _isFabOpen = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listsAsync = ref.watch(readingListsProvider);
    final theme = Theme.of(context);

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
                    _closeFab();
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
          final query = _searchController.text.toLowerCase().trim();
          final filtered = _isSearching && query.isNotEmpty
              ? lists.where((l) {
                  return l.title.toLowerCase().contains(query) ||
                      l.description.toLowerCase().contains(query);
                }).toList()
              : lists;

          if (lists.isEmpty) {
            return const EmptyContentState(
              icon: Icons.list_alt_outlined,
              message: 'No reading lists created yet.',
            );
          }

          if (filtered.isEmpty) {
            return EmptyContentState(
              icon: Icons.search_off,
              message: 'No reading lists found for "$query"',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: filtered.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              return ReadingListCard(
                list: filtered[index],
                flat: true,
                onTap: () {
                  _closeFab();
                  context.pushRoute(
                    ReadingListDetailsRoute(listId: filtered[index].id),
                  );
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
          _AnimatedFabAction(
            isVisible: _isFabOpen,
            label: 'Import',
            icon: Icons.file_download_outlined,
            onPressed: () async {
              _closeFab();
              final list = await ref
                  .read(readingListSharingServiceProvider)
                  .importReadingList();
              if (list != null) {
                final existingLists =
                    ref.read(readingListsProvider).value ?? [];
                if (existingLists.any((l) => l.id == list.id)) {
                  if (context.mounted) {
                    TakionAlerts.error(
                      context,
                      'Reading list already exists',
                    );
                  }
                  return;
                }
                await ref.read(readingListsProvider.notifier).addList(list);
                if (context.mounted) {
                  TakionAlerts.success(
                    context,
                    'Reading List Imported',
                  );
                }
              } else {
                if (context.mounted) {
                  TakionAlerts.error(
                    context,
                    'Failed to import reading list',
                  );
                }
              }
            },
          ),
          const SizedBox(height: 12),
          _AnimatedFabAction(
            isVisible: _isFabOpen,
            label: 'Create',
            icon: Icons.list_alt,
            onPressed: () {
              _closeFab();
              CreateReadingListBottomSheet.show(context);
            },
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => setState(() => _isFabOpen = !_isFabOpen),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(
                  _isFabOpen ? 28 : 12,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  customBorder: _isFabOpen
                      ? const CircleBorder()
                      : RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                  onTap: () => setState(() => _isFabOpen = !_isFabOpen),
                  child: Center(
                    child: AnimatedRotation(
                      turns: _isFabOpen ? 0.125 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        Icons.add,
                        size: 28,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedFabAction extends StatelessWidget {
  final bool isVisible;
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _AnimatedFabAction({
    required this.isVisible,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedOpacity(
      opacity: isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: AnimatedSlide(
        offset: isVisible ? Offset.zero : const Offset(0, 0.4),
            duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        child: Material(
          borderRadius: BorderRadius.circular(10),
          elevation: 3,
          color: theme.colorScheme.primaryContainer,
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 22,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    label,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
