import 'package:auto_route/auto_route.dart';
import 'package:expressive_refresh/expressive_refresh.dart';
import 'package:flutter/material.dart' hide RefreshIndicatorTriggerMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/presentation/providers/issues_provider.dart';
import 'package:takion/src/presentation/widgets/media_card.dart';

@RoutePage()
class DiscoverScreen extends ConsumerWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentlyAddedAsync = ref.watch(recentlyAddedIssuesProvider);

    return ExpressiveRefreshIndicator(
      displacement: 80,
      triggerMode: RefreshIndicatorTriggerMode.anywhere,
      color: Theme.of(context).colorScheme.primary,
      onRefresh: () async {
        // ignore: unused_result
        await ref.refresh(recentlyAddedIssuesProvider.future);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Hero(
                tag: 'search_bar',
                child: Material(
                  color: Colors.transparent,
                  child: SearchBar(
                    hintText: 'Search Metron...',
                    leading: const Icon(Icons.search, size: 24),
                    onTap: () => context.router.push(SearchRoute()),
                    readOnly: true,
                    elevation: WidgetStateProperty.all(0),
                    backgroundColor: WidgetStateProperty.all(
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                  ),
                ),
              ),
            ),

            // Recently Added Section Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recently Added',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to full list
                    },
                    child: const Text('More'),
                  ),
                ],
              ),
            ),

            // Horizontal List
            SizedBox(
              height: 240,
              child: recentlyAddedAsync.when(
                data: (issues) => ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: issues.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final issue = issues[index];
                    return MediaCard(
                      imageUrl: issue.image,
                      title: issue.name,
                      onTap: () {
                        // Navigate to details (disabled for now)
                      },
                    );
                  },
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Error: $err')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
