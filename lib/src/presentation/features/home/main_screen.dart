import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/presentation/features/profile/providers/profile_provider.dart';
import 'package:takion/src/presentation/features/search/providers/search_state_provider.dart';
import 'package:takion/src/presentation/common/empty_content_state.dart';

@RoutePage()
class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends ConsumerState<MainScreen>
    with SingleTickerProviderStateMixin {
  final titles = const ['Home', 'Releases', 'Library'];

  late AnimationController _animController;
  late CurvedAnimation _anim;
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();

  bool _overlayVisible = false;

  void openSearch() {
    if (_overlayVisible) return;
    setState(() => _overlayVisible = true);
    _animController.forward();
  }

  void _dismissSearch([VoidCallback? onComplete]) {
    _searchController.clear();
    _searchFocusNode.unfocus();
    _animController.reverse().then((_) {
      if (!mounted) return;
      setState(() => _overlayVisible = false);
      onComplete?.call();
    });
  }

  void _submitSearch() {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    final target = ref.read(searchStateProvider).target;
    ref.read(searchStateProvider.notifier).addHistory(query);
    final choice = target == SearchTarget.issues ? 'Issues' : 'Series';
    _dismissSearch(() {
      if (mounted) {
        context.pushRoute(
          SearchResultsRoute(query: query, searchChoice: choice),
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _anim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOutCubic,
    );
    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _searchFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _anim.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);
    final avatarUrl = profileAsync.maybeWhen(
      data: (profile) => (profile?['avatar_url'] as String?)?.trim(),
      orElse: () => null,
    );
    final hasAvatar = avatarUrl != null && avatarUrl.isNotEmpty;

    final bodyHeight = MediaQuery.of(context).size.height;
    final bodyWidth = MediaQuery.of(context).size.width;
    final topPadding = MediaQuery.of(context).padding.top;
    final searchBarTop = topPadding + kToolbarHeight;

    final mainContent = AutoTabsScaffold(
      routes: const [
        HomeRoute(),
        ReleasesRoute(),
        LibraryRoute(),
      ],
      appBarBuilder: (context, tabsRouter) => AppBar(
        leading: IconButton(
          icon: hasAvatar
              ? ClipOval(
                  child: Image.network(
                    avatarUrl,
                    width: 32,
                    height: 32,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        const Icon(Icons.account_circle_outlined),
                  ),
                )
              : const Icon(Icons.account_circle_outlined),
          onPressed: () => context.pushRoute(const UserProfileRoute()),
        ),
        title: Text(titles[tabsRouter.activeIndex]),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.pushRoute(const SettingsRoute()),
          ),
        ],
      ),
      bottomNavigationBuilder: (_, tabsRouter) {
        return PopScope(
          canPop: tabsRouter.activeIndex == 0,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop && tabsRouter.activeIndex != 0) {
              tabsRouter.setActiveIndex(0);
            }
          },
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(25),
            ),
            child: NavigationBar(
              selectedIndex: tabsRouter.activeIndex,
              onDestinationSelected: tabsRouter.setActiveIndex,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.new_releases_outlined),
                  selectedIcon: Icon(Icons.new_releases),
                  label: 'Releases',
                ),
                NavigationDestination(
                  icon: Icon(Icons.collections_bookmark_outlined),
                  selectedIcon: Icon(Icons.collections_bookmark),
                  label: 'Library',
                ),
              ],
            ),
          ),
        );
      },
    );

    return PopScope(
      canPop: !_overlayVisible,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _dismissSearch();
      },
      child: Stack(
        children: [
          IgnorePointer(
            ignoring: _overlayVisible,
            child: mainContent,
          ),
          if (_overlayVisible)
            GestureDetector(
              onTap: () => _dismissSearch(),
              child: AnimatedBuilder(
                animation: _anim,
                builder: (context, _) {
                  return Opacity(
                    opacity: _anim.value * 0.5,
                    child: Container(color: Colors.black),
                  );
                },
              ),
            ),
          if (_overlayVisible)
            AnimatedBuilder(
              animation: _anim,
              builder: (context, _) {
                final t = _anim.value;
                final pillTop = searchBarTop * (1 - t);
                final pillLeft = 16 * (1 - t);
                final pillWidth = bodyWidth - 32 * (1 - t);
                final pillHeight = 56 + (bodyHeight - 56) * t;
                final pillRadius = 28 * (1 - t);
                final topInset = topPadding * t;
                final contentOpacity = ((t - 0.2) / 0.8).clamp(0.0, 1.0);

                return Positioned(
                  top: pillTop,
                  left: pillLeft,
                  width: pillWidth,
                  height: pillHeight,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(pillRadius),
                    child: Material(
                      color: Theme.of(context).colorScheme.surfaceContainerHigh,
                      child: Column(
                        children: [
                          if (t > 0.01) SizedBox(height: topInset),
                          SizedBox(
                            height: 56,
                            child: _buildSearchFieldRow(),
                          ),
                          if (t > 0.2)
                            Expanded(
                              child: Opacity(
                                opacity: contentOpacity,
                                child: _buildSearchBody(),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSearchFieldRow() {
    return Row(
      children: [
        const SizedBox(width: 16),
        Icon(
          Icons.search,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              hintText: 'Search comics...',
              border: InputBorder.none,
              filled: false,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            onSubmitted: (_) => _submitSearch(),
          ),
        ),
        IconButton(
          tooltip: 'Close',
          icon: const Icon(Icons.close, size: 24),
          onPressed: () => _dismissSearch(),
        ),
      ],
    );
  }

  Widget _buildSearchBody() {
    final state = ref.watch(searchStateProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              ChoiceChip(
                label: const Text(
                  'Series',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                selected: state.target == SearchTarget.series,
                shape: const StadiumBorder(),
                onSelected: (_) {
                  ref
                      .read(searchStateProvider.notifier)
                      .setTarget(SearchTarget.series);
                },
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text(
                  'Issues',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                selected: state.target == SearchTarget.issues,
                shape: const StadiumBorder(),
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
              ? const EmptyContentState(
                  icon: Icons.history_outlined,
                  message: 'No search history yet.',
                )
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
                              _searchController.text = item;
                              _searchController.selection =
                                  TextSelection.fromPosition(
                                TextPosition(
                                  offset: _searchController.text.length,
                                ),
                              );
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
                        _searchController.text = item;
                        _searchController.selection =
                            TextSelection.fromPosition(
                          TextPosition(
                            offset: _searchController.text.length,
                          ),
                        );
                        _submitSearch();
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}
