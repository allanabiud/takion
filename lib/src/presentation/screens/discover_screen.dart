import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/presentation/widgets/compact_list_section.dart';
import 'package:takion/src/presentation/widgets/takion_alerts.dart';

@RoutePage()
class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: InkWell(
                onTap: () => context.pushRoute(const SearchRoute()),
                borderRadius: BorderRadius.circular(28),
                child: Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Search comics...',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            CompactListSection(
              title: 'Browse',
              items: [
                CompactListSectionItem(
                  icon: Icons.schedule_outlined,
                  label: 'Recently Added',
                  onTap: () {
                    context.pushRoute(const DiscoverBrowseRecentlyAddedRoute());
                  },
                ),
                CompactListSectionItem(
                  icon: Icons.face_outlined,
                  label: 'Characters',
                  onTap: () {
                    TakionAlerts.comingSoon(
                      context,
                      'Characters',
                      scope: 'browse',
                    );
                  },
                ),
                CompactListSectionItem(
                  icon: Icons.groups_outlined,
                  label: 'Creators',
                  onTap: () {
                    TakionAlerts.comingSoon(
                      context,
                      'Creators',
                      scope: 'browse',
                    );
                  },
                ),
                CompactListSectionItem(
                  icon: Icons.branding_watermark_outlined,
                  label: 'Imprints',
                  onTap: () {
                    TakionAlerts.comingSoon(
                      context,
                      'Imprints',
                      scope: 'browse',
                    );
                  },
                ),
                CompactListSectionItem(
                  icon: Icons.menu_book_outlined,
                  label: 'Issues',
                  onTap: () {
                    context.pushRoute(const DiscoverBrowseIssuesRoute());
                  },
                ),
                CompactListSectionItem(
                  icon: Icons.business_outlined,
                  label: 'Publishers',
                  onTap: () {
                    TakionAlerts.comingSoon(
                      context,
                      'Publishers',
                      scope: 'browse',
                    );
                  },
                ),
                CompactListSectionItem(
                  icon: Icons.list_alt_outlined,
                  label: 'Reading Lists',
                  onTap: () {
                    TakionAlerts.comingSoon(
                      context,
                      'Reading Lists',
                      scope: 'browse',
                    );
                  },
                ),
                CompactListSectionItem(
                  icon: Icons.collections_bookmark_outlined,
                  label: 'Series',
                  onTap: () {
                    context.pushRoute(const DiscoverBrowseSeriesRoute());
                  },
                ),
                CompactListSectionItem(
                  icon: Icons.route_outlined,
                  label: 'Story Arcs',
                  onTap: () {
                    TakionAlerts.comingSoon(
                      context,
                      'Story Arcs',
                      scope: 'browse',
                    );
                  },
                ),
                CompactListSectionItem(
                  icon: Icons.groups_2_outlined,
                  label: 'Teams',
                  onTap: () {
                    TakionAlerts.comingSoon(context, 'Teams', scope: 'browse');
                  },
                ),
                CompactListSectionItem(
                  icon: Icons.public_outlined,
                  label: 'Universes',
                  onTap: () {
                    TakionAlerts.comingSoon(
                      context,
                      'Universes',
                      scope: 'browse',
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
