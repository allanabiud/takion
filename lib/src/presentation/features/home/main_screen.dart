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
  final _chipKeys = <SearchTarget, GlobalKey>{};
  SearchTarget? _lastTarget;

  bool _overlayVisible = false;

  void openSearch() {
    if (_overlayVisible) return;
    setState(() => _overlayVisible = true);
    _animController.forward();
  }

  void _dismissSearch([VoidCallback? onComplete]) {
    _searchController.clear();
    _searchFocusNode.unfocus();
    _lastTarget = null;
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
    final choice = switch (target) {
      SearchTarget.series => 'Series',
      SearchTarget.issues => 'Issues',
      SearchTarget.characters => 'Characters',
      SearchTarget.creators => 'Creators',
      SearchTarget.universes => 'Universes',
      SearchTarget.imprints => 'Imprints',
      SearchTarget.teams => 'Teams',
      SearchTarget.publishers => 'Publishers',
    };
    _searchFocusNode.unfocus();
    context.pushRoute(
      SearchResultsRoute(query: query, searchChoice: choice),
    );
  }

  void _onSearchChanged() {
    if (mounted) {
      setState(() {});
    }
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
        _scrollToSelectedChip(animate: true);
      }
    });
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
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
      routes: const [HomeRoute(), ReleasesRoute(), LibraryRoute()],
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
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
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
          IgnorePointer(ignoring: _overlayVisible, child: mainContent),
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
                          SizedBox(height: 56, child: _buildSearchFieldRow()),
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
    final showClearButton = _searchController.text.isNotEmpty;

    return Row(
      children: [
        IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back),
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          onPressed: () => _dismissSearch(),
        ),
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
        if (showClearButton)
          IconButton(
            tooltip: 'Clear',
            icon: const Icon(Icons.close, size: 24),
            onPressed: () {
              _searchController.clear();
            },
          )
        else
          const SizedBox(width: 48),
      ],
    );
  }

  void _scrollToSelectedChip({required bool animate}) {
    if (!mounted || !_overlayVisible) return;
    final target = ref.read(searchStateProvider).target;
    final key = _chipKeys[target];
    final context = key?.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        alignment: 0.5,
        duration: animate ? const Duration(milliseconds: 200) : Duration.zero,
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _buildSearchBody() {
    final state = ref.watch(searchStateProvider);
    final target = state.target;

    if (_lastTarget != target) {
      _lastTarget = target;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToSelectedChip(animate: !_animController.isAnimating);
      });
    }

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
                key: _chipKeys[SearchTarget.series] ??= GlobalKey(),
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
                key: _chipKeys[SearchTarget.issues] ??= GlobalKey(),
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
              const SizedBox(width: 8),
              ChoiceChip(
                key: _chipKeys[SearchTarget.characters] ??= GlobalKey(),
                label: const Text(
                  'Characters',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                selected: state.target == SearchTarget.characters,
                shape: const StadiumBorder(),
                onSelected: (_) {
                  ref
                      .read(searchStateProvider.notifier)
                      .setTarget(SearchTarget.characters);
                },
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                key: _chipKeys[SearchTarget.creators] ??= GlobalKey(),
                label: const Text(
                  'Creators',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                selected: state.target == SearchTarget.creators,
                shape: const StadiumBorder(),
                onSelected: (_) {
                  ref
                      .read(searchStateProvider.notifier)
                      .setTarget(SearchTarget.creators);
                },
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                key: _chipKeys[SearchTarget.universes] ??= GlobalKey(),
                label: const Text(
                  'Universes',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                selected: state.target == SearchTarget.universes,
                shape: const StadiumBorder(),
                onSelected: (_) {
                  ref
                      .read(searchStateProvider.notifier)
                      .setTarget(SearchTarget.universes);
                },
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                key: _chipKeys[SearchTarget.imprints] ??= GlobalKey(),
                label: const Text(
                  'Imprints',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                selected: state.target == SearchTarget.imprints,
                shape: const StadiumBorder(),
                onSelected: (_) {
                  ref
                      .read(searchStateProvider.notifier)
                      .setTarget(SearchTarget.imprints);
                },
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                key: _chipKeys[SearchTarget.teams] ??= GlobalKey(),
                label: const Text(
                  'Teams',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                selected: state.target == SearchTarget.teams,
                shape: const StadiumBorder(),
                onSelected: (_) {
                  ref
                      .read(searchStateProvider.notifier)
                      .setTarget(SearchTarget.teams);
                },
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                key: _chipKeys[SearchTarget.publishers] ??= GlobalKey(),
                label: const Text(
                  'Publishers',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                selected: state.target == SearchTarget.publishers,
                shape: const StadiumBorder(),
                onSelected: (_) {
                  ref
                      .read(searchStateProvider.notifier)
                      .setTarget(SearchTarget.publishers);
                },
              ),
            ],
          ),
        ),
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
                        _searchController
                            .selection = TextSelection.fromPosition(
                          TextPosition(offset: _searchController.text.length),
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
