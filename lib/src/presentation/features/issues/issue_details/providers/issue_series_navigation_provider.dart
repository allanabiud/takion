import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/core/constants/pagination.dart";
import "package:takion/src/domain/entities.dart";
import "package:takion/src/presentation/features/issues/providers/issue_details_provider.dart";
import "package:takion/src/presentation/providers/providers.dart";

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
        int effectivePageSize,
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
          final totalPages = ((totalCount - 1) ~/ effectivePageSize) + 1;
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
      if (page1.count == 0 || page1.results.isEmpty) {
        return const IssueSeriesNavResult();
      }

      final page1Issues = page1.results;
      final actualPageSize =
          page1.realPageSize ??
          (page1.results.isNotEmpty ? page1.results.length : pageSize);

      final idx1 = findIssue(page1Issues);
      if (idx1 != null) {
        return buildResult(1, page1Issues, idx1, page1.count, actualPageSize);
      }

      final totalPages = ((page1.count - 1) ~/ actualPageSize) + 1;
      if (totalPages <= 1) return const IssueSeriesNavResult();

      IssueDetails? issueDetails = ref
          .watch(issueDetailsProvider(args.issueId))
          .asData
          ?.value;
      if (issueDetails == null) {
        try {
          issueDetails = await ref.watch(
            issueDetailsProvider(args.issueId).future,
          );
        } catch (_) {
          // Proceed with best-effort position matching if issue details fetch fails
        }
      }

      final targetNumber = issueDetails?.number ?? "";
      final targetDate = issueDetails?.coverDate ?? issueDetails?.storeDate;

      double? parseNumericNumber(String numStr) {
        final match = RegExp(r"^\d+(?:\.\d+)?").firstMatch(numStr.trim());
        if (match == null) return null;
        return double.tryParse(match.group(0)!);
      }

      int comparePosition(IssueList item) {
        final itemNum = parseNumericNumber(item.number);
        final targetNum = parseNumericNumber(targetNumber);

        if (itemNum != null && targetNum != null && itemNum != targetNum) {
          return itemNum.compareTo(targetNum);
        }

        final itemDt = item.coverDate ?? item.storeDate;
        if (itemDt != null && targetDate != null) {
          final cmp = itemDt.compareTo(targetDate);
          if (cmp != 0) return cmp;
        }

        return item.number.compareTo(targetNumber);
      }

      final targetNumeric = parseNumericNumber(targetNumber);

      if (targetNumeric != null && targetNumeric > 0) {
        final estPage = (targetNumeric / actualPageSize).ceil().clamp(
          2,
          totalPages,
        );
        final estPageData = await fetchPage(estPage);
        final estIdx = findIssue(estPageData.results);
        if (estIdx != null) {
          return buildResult(
            estPage,
            estPageData.results,
            estIdx,
            page1.count,
            actualPageSize,
          );
        }
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

        final idx = findIssue(issues);
        if (idx != null) {
          return buildResult(mid, issues, idx, page1.count, actualPageSize);
        }

        final firstCmp = comparePosition(issues.first);
        final lastCmp = comparePosition(issues.last);

        if (firstCmp > 0) {
          high = mid - 1;
        } else if (lastCmp < 0) {
          low = mid + 1;
        } else {
          for (int pageOffset = -2; pageOffset <= 2; pageOffset++) {
            final scanPage = mid + pageOffset;
            if (scanPage >= 2 && scanPage <= totalPages && scanPage != mid) {
              final scanData = await fetchPage(scanPage);
              final scanIdx = findIssue(scanData.results);
              if (scanIdx != null) {
                return buildResult(
                  scanPage,
                  scanData.results,
                  scanIdx,
                  page1.count,
                  actualPageSize,
                );
              }
            }
          }
          break;
        }
      }

      for (int scanPage = 2; scanPage <= totalPages; scanPage++) {
        final scanData = await fetchPage(scanPage);
        final scanIdx = findIssue(scanData.results);
        if (scanIdx != null) {
          return buildResult(
            scanPage,
            scanData.results,
            scanIdx,
            page1.count,
            actualPageSize,
          );
        }
      }

      return const IssueSeriesNavResult();
    });
