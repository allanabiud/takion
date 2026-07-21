import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/domain/entities/entities.dart';
import 'package:takion/src/presentation/features/library/activity_log_group.dart';
import 'package:takion/src/presentation/features/library/providers/collection_stats_provider.dart';
import 'package:takion/src/presentation/features/library/providers/library_activity_provider.dart';
import 'package:takion/src/presentation/features/library/widgets/activity_log_group_tile.dart';
import 'package:takion/src/presentation/features/issues/issue_list_tile.dart';
import 'package:takion/src/presentation/features/profile/providers/profile_insights_provider.dart';
import 'package:takion/src/presentation/features/profile/providers/profile_provider.dart';
import 'package:takion/src/presentation/common/empty_content_state.dart';
import 'package:takion/src/presentation/common/takion_alerts.dart';
import 'package:takion/src/presentation/components/components.dart';
import 'package:takion/src/presentation/features/profile/widgets/edit_profile_sheet.dart';
import 'package:takion/src/presentation/features/profile/widgets/profile_header.dart';
import 'package:takion/src/presentation/features/profile/widgets/profile_loading_view.dart';
import 'package:takion/src/presentation/features/profile/widgets/stat_card.dart';
import 'package:takion/src/presentation/features/library/providers/collection_items_provider.dart';
import 'package:takion/src/presentation/features/series/providers/subscriptions_provider.dart';

@RoutePage()
class UserProfileScreen extends ConsumerStatefulWidget {
  const UserProfileScreen({super.key});

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _stringField(
    Map<String, dynamic> profile,
    String key,
    String fallback,
  ) {
    final value = (profile[key] as String?)?.trim();
    return (value == null || value.isEmpty) ? fallback : value;
  }

  Future<void> _showEditProfileSheet(Map<String, dynamic> profile) async {
    final didUpdate = await TakionBottomSheet.show<bool>(
      context: context,
      title: 'Edit Profile',
      child: EditProfileSheet(profile: profile),
    );

    if (!mounted) return;
    if (didUpdate == true) {
      TakionAlerts.success(context, 'Profile Updated');
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);
    final statsAsync = ref.watch(collectionStatsProvider);
    final insightsAsync = ref.watch(profileInsightsProvider(ProfileFilter.allTime));
    final activityAsync = ref.watch(recentActivityProvider(null));

    return Scaffold(
      body: profileAsync.when(
        loading: () => const ProfileLoadingView(),
        error: (error, _) => Center(child: Text(TakionAlerts.cleanError(error, fallback: 'Failed to load profile'))),
        data: (profile) {
          if (profile == null) {
            return Scaffold(
              appBar: AppBar(),
              body: const EmptyContentState(
                icon: Icons.person_outline,
                message: 'No profile available.',
              ),
            );
          }
          final displayName = _stringField(
            profile,
            'display_name',
            'Takion Reader',
          );
          final avatarUrl = _stringField(profile, 'avatar_url', '');
          final backdropPath = _stringField(profile, 'backdrop_image_path', '');

          return Stack(
            children: [
              SizedBox(
                height: 350,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ProfileHeader(
                      displayName: displayName,
                      avatarUrl: avatarUrl,
                      backdropPath: backdropPath,
                      titleOpacity: 0.0,
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: AppBar(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        scrolledUnderElevation: 0,
                        iconTheme: const IconThemeData(color: Colors.white),
                        actions: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () => _showEditProfileSheet(profile),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              DraggableScrollableSheet(
                initialChildSize: 0.60,
                minChildSize: 0.60,
                maxChildSize: 0.9,
                snap: true,
                snapSizes: const [0.60, 0.9],
                builder: (context, scrollController) {
                  return ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: Container(
                      color: Theme.of(context).colorScheme.surface,
                      child: RefreshIndicator(
                        onRefresh: () async {
                          ref.invalidate(collectionStatsProvider);
                          ref.invalidate(profileInsightsProvider(ProfileFilter.allTime));
                          ref.invalidate(allLibraryItemsProvider);
                          ref.invalidate(recentActivityProvider(null));
                          ref.invalidate(allCollectionItemsProvider);
                          ref.invalidate(activeSubscriptionsProvider);
                        },
                        child: CustomScrollView(
                          controller: scrollController,
                          slivers: [
                            const SliverToBoxAdapter(child: SizedBox(height: 8)),
                            SliverToBoxAdapter(
                              child: Center(
                                child: Container(
                                  width: 32,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant
                                        .withValues(alpha: 0.4),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            ),
                            SliverPersistentHeader(
                              pinned: true,
                              delegate: _PinnedTabBarDelegate(
                                TabBar(
                                  controller: _tabController,
                                  tabs: const [
                                    Tab(text: 'OVERVIEW'),
                                    Tab(text: 'ACTIVITY'),
                                  ],
                                ),
                              ),
                            ),
                            if (_tabController.index == 0)
                              ..._buildOverviewSlivers(statsAsync, insightsAsync),
                            if (_tabController.index == 1)
                              ..._buildActivitySlivers(activityAsync),
                            SliverToBoxAdapter(
                              child: SizedBox(
                                height: MediaQuery.of(context).padding.bottom + 24,
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
          );
        },
      ),
    );
  }

  List<Widget> _buildOverviewSlivers(
    AsyncValue<CollectionStats> statsAsync,
    AsyncValue<ProfileInsights> insightsAsync,
  ) {
    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: _buildStatsGrid(statsAsync, insightsAsync),
        ),
      ),
      ..._buildRecentlyReadSlivers(insightsAsync),
    ];
  }

  Widget _buildStatsGrid(
    AsyncValue<CollectionStats> statsAsync,
    AsyncValue<ProfileInsights> insightsAsync,
  ) {
    final stats = statsAsync.asData?.value;
    final insights = insightsAsync.asData?.value;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.35,
      children: [
        StatCard(
          icon: Icons.inventory_2,
          label: 'Collected',
          value: _formatCount(stats?.totalQuantity ?? 0),
          color: Theme.of(context).colorScheme.primary,
        ),
        StatCard(
          icon: Icons.bookmark_added,
          label: 'Read',
          value: _formatCount(stats?.readCount ?? 0),
          color: Theme.of(context).colorScheme.primary,
        ),
        StatCard(
          icon: Icons.turned_in,
          label: 'Wishlist',
          value: _formatCount(stats?.wishlistCount ?? 0),
          color: Theme.of(context).colorScheme.tertiary,
        ),
        StatCard(
          icon: Icons.star,
          label: 'Avg Rating',
          value: insights != null && insights.averageRating > 0
              ? insights.averageRating.toStringAsFixed(1)
              : '-',
          color: Colors.amber,
        ),
      ],
    );
  }

  List<Widget> _buildRecentlyReadSlivers(AsyncValue<ProfileInsights> insightsAsync) {
    final recentlyFinished = insightsAsync.asData?.value.recentlyFinished ?? [];

    if (recentlyFinished.isEmpty) {
      return [
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: SectionHeader(title: 'Recently Read'),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'No recently read issues',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      ];
    }

    return [
      const SliverToBoxAdapter(child: SizedBox(height: 24)),
      const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: SectionHeader(title: 'Recently Read'),
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 8)),
      SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final item = recentlyFinished[index];
            final issueRef = item.issue;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: IssueListTile(
                issue: IssueList(
                  id: issueRef?.id ?? 0,
                  name: issueRef?.series?.name ?? issueRef?.number ?? '',
                  number: issueRef?.number ?? '',
                  series: issueRef?.series != null
                      ? Series(
                          id: 0,
                          name: issueRef!.series!.name,
                          volume: issueRef.series!.volume,
                          yearBegan: issueRef.series!.yearBegan,
                        )
                      : null,
                  image: issueRef?.image,
                  coverDate: issueRef?.coverDate,
                  storeDate: issueRef?.storeDate,
                  modified: null,
                ),
                isCollected: item.quantity > 0,
                isRead: item.isRead,
                rating: item.rating,
                onTap: issueRef?.id != null
                    ? () => context.pushRoute(
                          IssueDetailsRoute(issueId: issueRef!.id),
                        )
                    : null,
              ),
            );
          },
          childCount: recentlyFinished.length,
        ),
      ),
    ];
  }

  List<Widget> _buildActivitySlivers(AsyncValue<List<LibraryActivityEvent>> activityAsync) {
    final Widget sliver = activityAsync.when(
      loading: () => const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => SliverFillRemaining(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              TakionAlerts.cleanError(error, fallback: 'Failed to load activity'),
            ),
          ),
        ),
      ),
      data: (events) {
        if (events.isEmpty) {
          return const SliverFillRemaining(
            child: Center(
              child: EmptyContentState(
                icon: Icons.history,
                message: 'No Recent Activity',
              ),
            ),
          );
        }

        final groups = groupActivityEvents(events);
        final flatItems = <_ProfileActivityItem>[];
        for (int i = 0; i < groups.length; i++) {
          final group = groups[i];
          final isNewDate = i == 0 || groups[i].date != groups[i - 1].date;
          if (isNewDate) {
            flatItems.add(_ProfileActivityItem.header(group.date));
          }
          final isFirstInDate = isNewDate;
          final isLastInDate = i == groups.length - 1 ||
              groups[i + 1].date != group.date;
          flatItems.add(_ProfileActivityItem.group(
            group: group,
            isFirst: isFirstInDate,
            isLast: isLastInDate,
          ));
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final item = flatItems[index];
              if (item.isHeader) {
                return _buildHeader(context, item.date!);
              } else {
                return ActivityLogGroupTile(
                  group: item.group!,
                  isFirst: item.isFirst,
                  isLast: item.isLast,
                );
              }
            },
            childCount: flatItems.length,
          ),
        );
      },
    );
    return [sliver];
  }

  Widget _buildHeader(BuildContext context, DateTime date) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 16.0, top: 16.0, bottom: 8.0),
      child: Text(
        _formatDateHeader(date),
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final eventDate = DateTime(date.year, date.month, date.day);

    if (eventDate == today) {
      return 'Today';
    } else if (eventDate == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('MMMM d, yyyy').format(date);
    }
  }

  String _formatCount(int count) {
    if (count >= 10000) {
      return '${(count / 1000).toStringAsFixed(0)}k';
    }
    return count.toString();
  }
}

class _PinnedTabBarDelegate extends SliverPersistentHeaderDelegate {
  _PinnedTabBarDelegate(this.tabBar);

  final TabBar tabBar;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(_PinnedTabBarDelegate oldDelegate) =>
      oldDelegate.tabBar != tabBar;
}

class _ProfileActivityItem {
  final DateTime? date;
  final ActivityLogGroup? group;
  final bool isFirst;
  final bool isLast;

  _ProfileActivityItem.header(this.date)
      : group = null,
        isFirst = false,
        isLast = false;

  _ProfileActivityItem.group({
    required this.group,
    required this.isFirst,
    required this.isLast,
  }) : date = null;

  bool get isHeader => date != null;
}
