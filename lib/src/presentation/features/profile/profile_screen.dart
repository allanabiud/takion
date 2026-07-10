import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/presentation/features/profile/providers/profile_insights_provider.dart';
import 'package:takion/src/presentation/features/profile/providers/profile_provider.dart';
import 'package:takion/src/presentation/common/empty_content_state.dart';
import 'package:takion/src/presentation/common/takion_alerts.dart';
import 'package:takion/src/presentation/components/takion_bottom_sheet.dart';
import 'package:takion/src/presentation/features/profile/widgets/edit_profile_sheet.dart';
import 'package:takion/src/presentation/features/profile/widgets/insight_row.dart';
import 'package:takion/src/presentation/features/profile/widgets/profile_charts.dart';
import 'package:takion/src/presentation/features/profile/widgets/profile_header.dart';
import 'package:takion/src/presentation/features/profile/widgets/profile_loading_view.dart';
import 'package:takion/src/presentation/features/profile/widgets/reading_goal_card.dart';
import 'package:takion/src/presentation/features/profile/widgets/stat_card.dart';
import 'package:takion/src/presentation/features/profile/widgets/streak_calendar_widget.dart';
import 'package:takion/src/presentation/features/library/providers/collection_items_provider.dart';
import 'package:takion/src/presentation/features/series/providers/subscriptions_provider.dart';

@RoutePage()
class UserProfileScreen extends ConsumerStatefulWidget {
  const UserProfileScreen({super.key});

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  ProfileFilter _filter = ProfileFilter.month;

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
    final insightsAsync = ref.watch(profileInsightsProvider(_filter));

    return Scaffold(
      body: profileAsync.when(
        loading: () => const ProfileLoadingView(),
        error: (error, _) => Center(child: Text(error.toString())),
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
                          await ref.read(userProfileProvider.notifier).refresh();
                          ref.invalidate(allLibraryItemsProvider);
                          ref.invalidate(allCollectionItemsProvider);
                          ref.invalidate(activeSubscriptionsProvider);
                          await ref.read(profileInsightsProvider(_filter).future);
                        },
                        child: CustomScrollView(
                          controller: scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          slivers: [
                            SliverToBoxAdapter(
                              child: Column(
                                children: [
                                  const SizedBox(height: 8),
                                  Center(
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
                                  const SizedBox(height: 16),
                                ],
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  children: ProfileFilter.values
                                      .map(
                                        (f) => Padding(
                                          padding: const EdgeInsets.only(right: 8),
                                          child: ChoiceChip(
                                            label: Text(
                                              f == ProfileFilter.allTime
                                                  ? 'All-Time'
                                                  : f.name[0].toUpperCase() +
                                                        f.name.substring(1),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            selected: _filter == f,
                                            onSelected: (selected) {
                                              if (selected) {
                                                setState(() => _filter = f);
                                              }
                                            },
                                            shape: const StadiumBorder(),
                                            showCheckmark: true,
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                            ),
                            const SliverToBoxAdapter(child: SizedBox(height: 16)),
                            SliverToBoxAdapter(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: insightsAsync.when(
                                  loading: () => const Padding(
                                    key: ValueKey('loading'),
                                    padding: EdgeInsets.only(top: 100),
                                    child: Center(child: CircularProgressIndicator()),
                                  ),
                                  error: (error, _) => Padding(
                                    key: ValueKey('error'),
                                    padding: const EdgeInsets.all(16),
                                    child: Text('$error'),
                                  ),
                                  data: (insights) => Column(
                                    key: ValueKey(_filter),
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        child: Text(
                                          'Library Stats',
                                          style: Theme.of(context).textTheme.titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context).colorScheme.primary,
                                              ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      GridView.count(
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        crossAxisCount: 2,
                                        crossAxisSpacing: 12,
                                        mainAxisSpacing: 12,
                                        childAspectRatio: 2.2,
                                        children: [
                                          StatCard(
                                            label: 'Total Owned',
                                            value: '${insights.totalOwned}',
                                            icon: Icons.inventory_2_outlined,
                                            color: Theme.of(context).colorScheme.primary,
                                          ),
                                          StatCard(
                                            label: 'Read %',
                                            value:
                                                '${insights.readPercent.toStringAsFixed(1)}%',
                                            icon: Icons.menu_book_outlined,
                                            color: Theme.of(context).colorScheme.secondary,
                                          ),
                                          StatCard(
                                            label: 'Reads (${_filterLabel(_filter)})',
                                            value: '${insights.readsInPeriod}',
                                            icon: Icons.auto_stories_outlined,
                                            color: Colors.green,
                                          ),
                                          StatCard(
                                            label: 'Pulls (${_filterLabel(_filter)})',
                                            value: '${insights.pullsInPeriod}',
                                            icon: Icons.shopping_bag_outlined,
                                            color: Colors.orange,
                                          ),
                                          StatCard(
                                            label: 'Wishlist',
                                            value: '${insights.wishlistCount}',
                                            icon: Icons.turned_in_not,
                                            color: Theme.of(context).colorScheme.tertiary,
                                          ),
                                          StatCard(
                                            label: 'Subscriptions',
                                            value: '${insights.subscriptionsCount}',
                                            icon: Icons.notifications_outlined,
                                            color: Theme.of(context).colorScheme.error,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 32),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        child: Text(
                                          'Reading Trends',
                                          style: Theme.of(context).textTheme.titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context).colorScheme.primary,
                                              ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        child: ReadingTrendChart(
                                          data: insights.readingTrends,
                                        ),
                                      ),
                                      const SizedBox(height: 32),
                                      const StreakCalendarWidget(),
                                      const SizedBox(height: 32),
                                      const ReadingGoalCard(),
                                      const SizedBox(height: 32),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        child: Text(
                                          'Reading Insights',
                                          style: Theme.of(context).textTheme.titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context).colorScheme.primary,
                                              ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        child: Container(
                                          padding: const EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.surfaceContainerLow,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Column(
                                            children: [
                                              InsightRow(
                                                label: 'Current Streak',
                                                value: '${insights.streakDays} Days',
                                                icon: Icons.local_fire_department,
                                                iconColor: Colors.orange,
                                              ),
                                              const Divider(height: 24),
                                              InsightRow(
                                                label: 'Avg Rating',
                                                value: insights.averageRating == 0
                                                    ? '-'
                                                    : insights.averageRating.toStringAsFixed(
                                                        2,
                                                      ),
                                                icon: Icons.star,
                                                iconColor: Colors.amber,
                                              ),
                                              const Divider(height: 24),
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Icon(
                                                    Icons.collections_bookmark_outlined,
                                                    color: Theme.of(
                                                      context,
                                                    ).colorScheme.primary,
                                                    size: 24,
                                                  ),
                                                  const SizedBox(width: 16),
                                                  Expanded(
                                                    child: Text(
                                                      'Most-Read Series',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium
                                                          ?.copyWith(
                                                            color: Theme.of(
                                                              context,
                                                            ).colorScheme.onSurfaceVariant,
                                                          ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  ConstrainedBox(
                                                    constraints: const BoxConstraints(
                                                      maxWidth: 180,
                                                    ),
                                                    child: Text(
                                                      insights.mostReadSeries ?? '-',
                                                      textAlign: TextAlign.right,
                                                      maxLines: 2,
                                                      softWrap: true,
                                                      overflow: TextOverflow.clip,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge
                                                          ?.copyWith(
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      if (insights.topPublishers.isNotEmpty) ...[
                                        const SizedBox(height: 32),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 16),
                                          child: Text(
                                            'Top Publishers',
                                            style: Theme.of(context).textTheme.titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.primary,
                                                ),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 16),
                                          child: PublisherDistributionChart(
                                            publishers: insights.topPublishers,
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 32),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        child: ListTile(
                                          contentPadding: EdgeInsets.zero,
                                          leading: Icon(
                                            Icons.history_outlined,
                                            color: Theme.of(context).colorScheme.primary,
                                          ),
                                          title: Text(
                                            'Reading History',
                                            style: Theme.of(context).textTheme.titleMedium
                                                ?.copyWith(fontWeight: FontWeight.bold),
                                          ),
                                          subtitle: const Text(
                                            'View all issues you have finished reading',
                                          ),
                                          trailing: const Icon(Icons.chevron_right_rounded),
                                          onTap: () =>
                                              context.pushRoute(const ReadingHistoryRoute()),
                                        ),
                                      ),
                                      const SizedBox(height: 40),
                                    ],
                                  ),
                                ),
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

  String _filterLabel(ProfileFilter filter) {
    switch (filter) {
      case ProfileFilter.week:
        return 'Week';
      case ProfileFilter.month:
        return 'Month';
      case ProfileFilter.year:
        return 'Year';
      case ProfileFilter.allTime:
        return 'All-Time';
    }
  }
}


