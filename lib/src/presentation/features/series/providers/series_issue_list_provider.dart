import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities/series_issue_list_page.dart';
import 'package:takion/src/presentation/providers/repository_providers.dart';

class SeriesIssueListArgs {
  const SeriesIssueListArgs({
    required this.seriesId,
    required this.page,
  });

  final int seriesId;
  final int page;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SeriesIssueListArgs &&
        other.seriesId == seriesId &&
        other.page == page;
  }

  @override
  int get hashCode => Object.hash(seriesId, page);
}

final seriesIssueListProvider =
    FutureProvider.autoDispose.family<SeriesIssueListPage, SeriesIssueListArgs>(
      (ref, args) {
        final repository = ref.watch(metronRepositoryProvider);
        return repository.getSeriesIssueList(
          args.seriesId,
          page: args.page,
        );
      },
    );
