import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/constants/pagination.dart';
import 'package:takion/src/domain/entities.dart';
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
      const pageSize = metronDefaultPageSize;

      Future<SeriesIssueListPage> fetchPage(int page) {
        return repository.getSeriesIssueList(args.seriesId, page: page);
      }

      int? findIssue(List<IssueList> issues) {
        final idx = issues.indexWhere((issue) => issue.id == args.issueId);
        return idx < 0 ? null : idx;
      }

      Future<IssueSeriesNavResult> buildResult(
        int page,
        List<IssueList> issues,
        int idx,
        int totalCount,
      ) async {
        int? prevId = idx > 0 ? issues[idx - 1].id : null;
        int? nextId = idx < issues.length - 1 ? issues[idx + 1].id : null;

        if (prevId == null && page > 1) {
          final prev = await fetchPage(page - 1);
          if (prev.results.isNotEmpty) {
            prevId = prev.results.last.id;
          }
        }

        if (nextId == null) {
          final totalPages = ((totalCount - 1) ~/ pageSize) + 1;
          if (page < totalPages) {
            final next = await fetchPage(page + 1);
            if (next.results.isNotEmpty) {
              nextId = next.results.first.id;
            }
          }
        }

        return IssueSeriesNavResult(
          previousIssueId: prevId,
          nextIssueId: nextId,
        );
      }

      final page1 = await fetchPage(1);
      if (page1.count == 0) return const IssueSeriesNavResult();

      final page1Issues = page1.results;
      final idx1 = findIssue(page1Issues);
      if (idx1 != null) {
        return buildResult(1, page1Issues, idx1, page1.count);
      }

      final totalPages = ((page1.count - 1) ~/ pageSize) + 1;
      if (totalPages <= 1) return const IssueSeriesNavResult();

      final lastOnPage1 = page1Issues.last.id;
      if (lastOnPage1 != null && args.issueId <= lastOnPage1) {
        return const IssueSeriesNavResult();
      }

      int low = 2;
      int high = totalPages;

      while (low <= high) {
        final mid = (low + high) ~/ 2;
        final pageData = await fetchPage(mid);
        final issues = pageData.results;
        if (issues.isEmpty) {
          high = mid - 1;
          continue;
        }

        final firstId = issues.first.id;
        final lastId = issues.last.id;

        if (firstId != null && args.issueId < firstId) {
          high = mid - 1;
        } else if (lastId != null && args.issueId > lastId) {
          low = mid + 1;
        } else {
          final idx = findIssue(issues);
          if (idx != null) {
            return buildResult(mid, issues, idx, pageData.count);
          }
          break;
        }
      }

      return const IssueSeriesNavResult();
    });
