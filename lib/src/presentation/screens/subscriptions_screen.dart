import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/presentation/providers/subscriptions_provider.dart';
import 'package:takion/src/presentation/widgets/async_state_panel.dart';
import 'package:takion/src/presentation/widgets/series_list_tile.dart';

@RoutePage()
class SubscriptionsScreen extends ConsumerWidget {
  const SubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscribedSeriesAsync = ref.watch(subscribedSeriesListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Subscriptions')),
      body: subscribedSeriesAsync.when(
        loading: () => const AsyncStatePanel.loading(),
        error: (error, _) => AsyncStatePanel.error(
          errorMessage: 'Failed to load subscriptions: $error',
        ),
        data: (seriesList) {
          if (seriesList.isEmpty) {
            return const Center(child: Text('No subscriptions yet.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: seriesList.length,
            itemBuilder: (context, index) {
              final series = seriesList[index];
              return SeriesListTile(
                series: series,
                isFirst: index == 0,
                isLast: index == seriesList.length - 1,
                onTap: () {
                  context.pushRoute(SeriesDetailsRoute(seriesId: series.id));
                },
              );
            },
          );
        },
      ),
    );
  }
}
