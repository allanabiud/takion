import "package:auto_route/auto_route.dart";
import "package:flutter/material.dart";
import "package:flutter_svg/flutter_svg.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/core/router/app_router.gr.dart";
import "package:takion/src/presentation/features/search/providers/search_state_provider.dart";
import "package:takion/src/presentation/providers/providers.dart";
import "package:takion/src/presentation/shared/widgets/empty_content_state.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";

@RoutePage()
class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends ConsumerState<MainScreen>
    with SingleTickerProviderStateMixin {
  final titles = const ["Home", "Releases", "Library"];

  late AnimationController _animController;
  late CurvedAnimation _anim;
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  final _chipKeys = <SearchTarget, GlobalKey>{};
  SearchTarget? _lastTarget;

  bool _overlayVisible = false;

  void openSearch() {
    if (_overlayVisible && _animController.status == AnimationStatus.completed) {
      return;
    }
    _overlayVisible = true;
    _animController.forward();
    setState(() {});
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
      SearchTarget.series => "Series",
      SearchTarget.issues => "Issues",
      SearchTarget.characters => "Characters",
      SearchTarget.creators => "Creators",
      SearchTarget.universes => "Universes",
      SearchTarget.imprints => "Imprints",
      SearchTarget.teams => "Teams",
      SearchTarget.publishers => "Publishers",
      SearchTarget.arcs => "Arcs",
    };
    _searchFocusNode.unfocus();
    context.pushRoute(SearchResultsRoute(query: query, searchChoice: choice));
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
    final bodyHeight = MediaQuery.of(context).size.height;
    final bodyWidth = MediaQuery.of(context).size.width;
    final topPadding = MediaQuery.of(context).padding.top;
    final searchBarTop = topPadding + kToolbarHeight;

    final mainContent = AutoTabsRouter(
      routes: const [HomeRoute(), ReleasesRoute(), LibraryRoute()],
      builder: (context, child) {
        final tabsRouter = context.tabsRouter;
        final syncState = ref.watch(driveSyncProvider);
        final connectivityState = ref.watch(connectivityStatusProvider);
        final isOffline =
            connectivityState.asData?.value == AppConnectivityStatus.offline;

        return PopScope(
          canPop: tabsRouter.activeIndex == 0,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop && tabsRouter.activeIndex != 0) {
              tabsRouter.setActiveIndex(0);
            }
          },
          child: Scaffold(
            appBar: AppBar(
              leading: Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: Center(
                  child: SizedBox(
                    width: 32,
                    height: 32,
                    child: SvgPicture.asset(
                      "assets/branding/takion_logo.svg",
                      fit: BoxFit.contain,
                      colorFilter: ColorFilter.mode(
                        Theme.of(context).colorScheme.primary,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
              title: Text(
                titles[tabsRouter.activeIndex],
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Rubik",
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () => context.pushRoute(const SettingsRoute()),
                ),
              ],
            ),
            body: child,
            bottomNavigationBar: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: isOffline
                      ? Container(
                          width: double.infinity,
                          color: Theme.of(context).colorScheme.errorContainer,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.wifi_off_outlined,
                                size: 16,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onErrorContainer,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "You are offline",
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onErrorContainer,
                                    ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox(width: double.infinity, height: 0),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: syncState.isSyncing
                      ? Container(
                          width: double.infinity,
                          color: Theme.of(context).colorScheme.surfaceContainer,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      "Syncing with Google Drive",
                                      style: Theme.of(context).textTheme.labelSmall,
                                    ),
                                    const Spacer(),
                                    const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                  ],
                                ),
                              ),
                              const LinearProgressIndicator(minHeight: 2),
                            ],
                          ),
                        )
                      : const SizedBox(width: double.infinity, height: 0),
                ),
                NavigationBar(
                  selectedIndex: tabsRouter.activeIndex,
                  onDestinationSelected: tabsRouter.setActiveIndex,
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home),
                      label: "Home",
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.new_releases_outlined),
                      selectedIcon: Icon(Icons.new_releases),
                      label: "Releases",
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.collections_bookmark_outlined),
                      selectedIcon: Icon(Icons.collections_bookmark),
                      label: "Library",
                    ),
                  ],
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
              onTap: _dismissSearch,
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

  String _searchHintForTarget(SearchTarget target) {
    return switch (target) {
      SearchTarget.series => "Search series...",
      SearchTarget.issues => "Search issues...",
      SearchTarget.characters => "Search characters...",
      SearchTarget.creators => "Search creators...",
      SearchTarget.universes => "Search universes...",
      SearchTarget.imprints => "Search imprints...",
      SearchTarget.teams => "Search teams...",
      SearchTarget.publishers => "Search publishers...",
      SearchTarget.arcs => "Search arcs...",
    };
  }

  Widget _buildSearchFieldRow() {
    final showClearButton = _searchController.text.isNotEmpty;
    final target = ref.watch(searchStateProvider).target;

    return Row(
      children: [
        const SizedBox(width: 8),
        IconButton(
          tooltip: "Back",
          icon: const Icon(Icons.arrow_back),
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          onPressed: _dismissSearch,
        ),
        Expanded(
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              hintText: _searchHintForTarget(target),
              border: InputBorder.none,
              filled: false,
              isDense: true,
              contentPadding: const EdgeInsets.only(left: 12),
            ),
            onSubmitted: (_) => _submitSearch(),
          ),
        ),
        if (showClearButton)
          IconButton(
            tooltip: "Clear",
            icon: const Icon(Icons.close, size: 24),
            onPressed: _searchController.clear,
          )
        else
          const SizedBox(width: 48),
        IconButton(
          tooltip: "Scan barcode",
          icon: const Icon(LucideIcons.scanBarcode),
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          onPressed: () => context.pushRoute(const BarcodeScannerRoute()),
        ),
        const SizedBox(width: 4),
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "Search in:",
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: List.generate(SearchTarget.values.length, (i) {
              final t = SearchTarget.values[i];
              final label = switch (t) {
                SearchTarget.series => "Series",
                SearchTarget.issues => "Issues",
                SearchTarget.characters => "Characters",
                SearchTarget.creators => "Creators",
                SearchTarget.universes => "Universes",
                SearchTarget.imprints => "Imprints",
                SearchTarget.teams => "Teams",
                SearchTarget.publishers => "Publishers",
                SearchTarget.arcs => "Arcs",
              };
              return Padding(
                padding: EdgeInsets.only(
                  right: i < SearchTarget.values.length - 1 ? 8 : 0,
                ),
                child: ChoiceChip(
                  key: _chipKeys[t] ??= GlobalKey(),
                  label: Text(
                    label,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  selected: state.target == t,
                  shape: const StadiumBorder(),
                  onSelected: (_) {
                    ref.read(searchStateProvider.notifier).setTarget(t);
                  },
                ),
              );
            }),
          ),
        ),
        Expanded(
          child: state.history.isEmpty
              ? const EmptyContentState(
                  icon: Icons.history_outlined,
                  message: "No search history.",
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
                            tooltip: "Fill search field",
                            icon: const Icon(Icons.north_west),
                            onPressed: () {
                              _searchController.text = item;
                              _searchController.selection = TextSelection.fromPosition(
                                TextPosition(offset: _searchController.text.length),
                              );
                              _searchFocusNode.requestFocus();
                            },
                          ),
                          IconButton(
                            tooltip: "Delete from history",
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
