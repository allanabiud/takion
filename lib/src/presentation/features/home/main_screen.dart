import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/presentation/features/profile/providers/profile_provider.dart';

@RoutePage()
class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titles = ['Home', 'Releases', 'Library'];
    final profileAsync = ref.watch(userProfileProvider);
    final avatarUrl = profileAsync.maybeWhen(
      data: (profile) => (profile?['avatar_url'] as String?)?.trim(),
      orElse: () => null,
    );
    final hasAvatar = avatarUrl != null && avatarUrl.isNotEmpty;

    return AutoTabsScaffold(
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
  }
}
