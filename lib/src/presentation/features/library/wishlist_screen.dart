import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/presentation/features/library/providers/category_series_providers.dart';
import 'package:takion/src/presentation/features/library/activity_log_view.dart';
import 'package:takion/src/presentation/common/async_state_panel.dart';
import 'package:takion/src/presentation/common/empty_content_state.dart';
import 'package:takion/src/presentation/components/components.dart';
import 'package:takion/src/domain/entities/entities.dart';
import 'package:takion/src/presentation/features/series/series_list_tile.dart';


@RoutePage()
class WishlistScreen extends ConsumerStatefulWidget {
  const WishlistScreen({super.key});

  @override
  ConsumerState<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends ConsumerState<WishlistScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishlist'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'BROWSE'),
            Tab(text: 'ACTIVITY'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _WishlistBrowseTab(),
          const ActivityLogView(typeFilter: ActivityEventType.wishlisted),
        ],
      ),
    );
  }
}

class _WishlistBrowseTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seriesAsync = ref.watch(wishlistSeriesProvider);

    return seriesAsync.when(
      loading: () => const AsyncStatePanel.loading(),
      error: (error, _) => AsyncStatePanel.error(
        errorMessage: 'Failed to load wishlist series',
      ),
      data: (seriesList) {
        if (seriesList.isEmpty) {
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(wishlistSeriesProvider),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: const [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyContentState(
                    icon: Icons.turned_in_not,
                    message: 'No wishlist comics yet.',
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(wishlistSeriesProvider),
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 12),
            itemCount: seriesList.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: ListHeader(
                    count: seriesList.length,
                    unit: 'series',
                    pluralUnit: 'series',
                    enabled: true,
                  ),
                );
              }
              final summary = seriesList[index - 1];
              return SeriesListTile(
                series: SeriesList(
                  id: summary.seriesId,
                  name: summary.seriesName,
                  volume: summary.volume,
                  yearBegan: summary.yearBegan,
                  issueCount: summary.categoryCount,
                ),
                categoryCount: summary.categoryCount,
                categoryLabel: 'wishlist',
                isFirst: index == 1,
                isLast: index == seriesList.length,
                onTap: () => context.pushRoute(
                  LibrarySeriesRoute(
                    seriesId: summary.seriesId,
                    category: 'wishlist',
                    seriesName: summary.seriesName,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

