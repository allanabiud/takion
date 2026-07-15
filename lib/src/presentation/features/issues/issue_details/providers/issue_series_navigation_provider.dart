import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/constants/pagination.dart';
import 'package:takion/src/presentation/providers/providers.dart';

class IssueSeriesNavArgs {
  const IssueSeriesNavArgs({required this.seriesId, required this.issueId});

  final int seriesId;
  final int issueId;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is IssueSeriesNavArgs &&
        other.seriesId == seriesId &&
        other.issueId == issueId;
  }

  @override
  int get hashCode => Object.hash(seriesId, issueId);
}

class IssueSeriesNavResult {
  const IssueSeriesNavResult({this.previousIssueId, this.nextIssueId});

  final int? previousIssueId;
  final int? nextIssueId;
}

final issueSeriesNavigationProvider = FutureProvider.autoDispose
    .family<IssueSeriesNavResult, IssueSeriesNavArgs>((ref, args) async {
      final repository = ref.watch(catalogRepositoryProvider);
      final pageSize = metronDefaultPageSize;

      Future<IssueSeriesNavResult> searchPage(int page) async {
        final result = await repository.getSeriesIssueList(
          args.seriesId,
          page: page,
        );
        final issues = result.results;
        if (issues.isEmpty) return const IssueSeriesNavResult();

        final idx = issues.indexWhere((issue) => issue.id == args.issueId);
        if (idx < 0) return const IssueSeriesNavResult();

        return IssueSeriesNavResult(
          previousIssueId: idx > 0 ? issues[idx - 1].id : null,
          nextIssueId:
              idx < issues.length - 1 ? issues[idx + 1].id : null,
        );
      }

      final page1 = await repository.getSeriesIssueList(args.seriesId, page: 1);
      if (page1.count == 0) return const IssueSeriesNavResult();

      final result = await searchPage(1);
      if (result.previousIssueId != null || result.nextIssueId != null) {
        return result;
      }

      final totalPages = ((page1.count - 1) ~/ pageSize) + 1;
      for (var page = 2; page <= totalPages && page <= 5; page++) {
        final r = await searchPage(page);
        if (r.previousIssueId != null || r.nextIssueId != null) return r;
      }

      return const IssueSeriesNavResult();
    });
