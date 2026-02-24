import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/presentation/providers/search_state_provider.dart';
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
              child: Hero(
                tag: kSearchBarHeroTag,
                child: Material(
                  color: Colors.transparent,
                  child: SearchBar(
                    hintText: 'Search comics...',
                    leading: const Icon(Icons.search, size: 24),
                    onTap: () {
                      context.pushRoute(const SearchRoute());
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            CompactListSection(
              title: 'Browse Metron',
              items: [
                CompactListSectionItem(
                  icon: Icons.schedule_outlined,
                  label: 'Recently Added',
                  onTap: () {
                    TakionAlerts.comingSoon(
                      context,
                      'Recently Added',
                      scope: 'browse',
                    );
                  },
                ),
                CompactListSectionItem(
                  icon: Icons.menu_book_outlined,
                  label: 'Issues',
                  onTap: () {
                    TakionAlerts.comingSoon(context, 'Issues', scope: 'browse');
                  },
                ),
                CompactListSectionItem(
                  icon: Icons.collections_bookmark_outlined,
                  label: 'Series',
                  onTap: () {
                    TakionAlerts.comingSoon(context, 'Series', scope: 'browse');
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
                  icon: Icons.groups_2_outlined,
                  label: 'Teams',
                  onTap: () {
                    TakionAlerts.comingSoon(context, 'Teams', scope: 'browse');
                  },
                ),
                CompactListSectionItem(
                  icon: Icons.playlist_add_check_circle_outlined,
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
