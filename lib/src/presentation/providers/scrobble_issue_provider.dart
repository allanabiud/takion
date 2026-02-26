import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/presentation/providers/collection_items_provider.dart';
import 'package:takion/src/presentation/providers/collection_stats_provider.dart';
import 'package:takion/src/presentation/providers/issue_collection_status_provider.dart';
import 'package:takion/src/presentation/providers/collection_suggestions_provider.dart';
import 'package:takion/src/presentation/providers/repository_providers.dart';

final scrobbleIssueProvider = NotifierProvider.autoDispose
    .family<ScrobbleIssueController, AsyncValue<void>, int>(
      ScrobbleIssueController.new,
    );

class ScrobbleIssueController extends Notifier<AsyncValue<void>> {
  ScrobbleIssueController(this._issueId);

  final int _issueId;

  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> scrobble({
    DateTime? dateRead,
    int? rating,
    bool refreshReadingSuggestion = false,
    bool refreshRateSuggestion = false,
  }) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(metronRepositoryProvider);
      await repository.scrobbleIssueRead(
        issueId: _issueId,
        dateRead: dateRead,
        rating: rating,
      );

      ref.invalidate(collectionIssueStatusMapProvider);
      ref.invalidate(collectionStatsProvider);
      ref.invalidate(allCollectionItemsProvider);
      ref.invalidate(collectionItemsProvider);
      ref.invalidate(currentCollectionItemsProvider);
      if (refreshReadingSuggestion) {
        ref.invalidate(readingSuggestionProvider);
        ref.invalidate(readingSuggestionIssueProvider);
      }
      if (refreshRateSuggestion) {
        ref.invalidate(rateSuggestionProvider);
        ref.invalidate(rateSuggestionIssueProvider);
      }
    });
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}
