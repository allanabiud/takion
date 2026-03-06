import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/core/storage/hive_service.dart';
import 'package:takion/src/presentation/providers/subscriptions_provider.dart';
import 'package:takion/src/presentation/widgets/async_state_panel.dart';
import 'package:takion/src/presentation/widgets/paged_list_scaffold.dart';
import 'package:takion/src/presentation/widgets/series_list_tile.dart';

@RoutePage()
class SubscriptionsScreen extends ConsumerStatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  ConsumerState<SubscriptionsScreen> createState() =>
      _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends ConsumerState<SubscriptionsScreen> {
  int _page = 1;

  Future<void> _refreshPage() async {
    await invalidateSubscriptionsLocalCacheWithHive(
      ref.read(hiveServiceProvider),
    );
    ref.invalidate(subscribedSeriesPageProvider(_page));
    await ref.read(subscribedSeriesPageProvider(_page).future);
  }

  @override
  Widget build(BuildContext context) {
    final pageAsync = ref.watch(subscribedSeriesPageProvider(_page));

    return Scaffold(
      appBar: AppBar(title: const Text('Subscriptions')),
      body: pageAsync.when(
        loading: () => const AsyncStatePanel.loading(),
        error: (error, _) => AsyncStatePanel.error(
          errorMessage: 'Failed to load subscriptions: $error',
        ),
        data: (pageData) {
          final pageSize = pageData.results.isEmpty
              ? 100
              : pageData.results.length;
          final totalPages = (pageData.count / pageSize).ceil().clamp(1, 9999);
          return PagedListScaffold(
            onRefresh: _refreshPage,
            currentPage: _page,
            totalPages: totalPages,
            hasPrevious: pageData.hasPrevious,
            hasNext: pageData.hasNext,
            onPrevious: () {
              final previousPage = pageData.previousPage;
              if (previousPage == null) return;
              setState(() {
                _page = previousPage;
              });
            },
            onNext: () {
              final nextPage = pageData.nextPage;
              if (nextPage == null) return;
              setState(() {
                _page = nextPage;
              });
            },
            itemCount: pageData.results.length,
            itemBuilder: (context, index) {
              final series = pageData.results[index];
              return SeriesListTile(
                series: series,
                isFirst: index == 0,
                isLast: index == pageData.results.length - 1,
                onTap: () {
                  context.pushRoute(SeriesDetailsRoute(seriesId: series.id));
                },
              );
            },
            emptyMessage: 'No subscriptions yet.',
          );
        },
      ),
    );
  }
}
