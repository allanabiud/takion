import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities/series_list.dart';
import 'package:takion/src/presentation/providers/repository_providers.dart';

final activeSubscriptionsProvider = FutureProvider.autoDispose((ref) {
  final repository = ref.watch(subscriptionRepositoryProvider);
  return repository.listSubscriptions(limit: 500);
});

final activeSubscriptionsCountProvider = Provider<int>((ref) {
  final subscriptionsAsync = ref.watch(activeSubscriptionsProvider);
  return subscriptionsAsync.maybeWhen(
    data: (subscriptions) => subscriptions.length,
    orElse: () => 0,
  );
});

final subscribedSeriesListProvider =
    FutureProvider.autoDispose<List<SeriesList>>((ref) async {
      final subscriptions = await ref.watch(activeSubscriptionsProvider.future);
      final metronRepository = ref.watch(metronRepositoryProvider);

      final series = await Future.wait(
        subscriptions.map((subscription) async {
          final details = await metronRepository.getSeriesDetails(
            subscription.metronSeriesId,
          );
          return SeriesList(
            id: details.id,
            name: details.name,
            yearBegan: details.yearBegan,
            volume: details.volume,
            issueCount: details.issueCount,
            modified: details.modified,
          );
        }),
      );

      return series;
    });
