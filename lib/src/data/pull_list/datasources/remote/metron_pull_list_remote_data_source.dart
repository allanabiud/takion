import "package:dio/dio.dart";
import "package:takion/src/core/network/remote_page.dart";
import "package:takion/src/data/pull_list/dto/pull_list_dto.dart";

abstract class MetronPullListRemoteDataSource {
  Future<RemotePage<PullListSeriesDto>> getPullListSeriesPage({
    Uri? pageUrl,
    CancelToken? cancelToken,
  });

  Future<RemotePage<PullListIssueDto>> getPullListIssuesPage({
    Uri? pageUrl,
    DateTime? storeDateAfter,
    DateTime? storeDateBefore,
    CancelToken? cancelToken,
  });

  Future<List<PullListReadDto>> getPullLists({
    int page = 1,
    CancelToken? cancelToken,
  });

  Future<PullListReadDto> getPullList(int id, {CancelToken? cancelToken});

  Future<List<PullListSeriesDto>> getPullListSeries({
    int page = 1,
    DateTime? modifiedGt,
    CancelToken? cancelToken,
  });

  Future<PullListSeriesDto> addSeriesToPullList(
    int seriesId, {
    CancelToken? cancelToken,
  });

  Future<void> removeSeriesFromPullList(
    int seriesId, {
    CancelToken? cancelToken,
  });

  Future<List<PullListIssueDto>> getPullListIssues({
    int page = 1,
    DateTime? storeDateAfter,
    DateTime? storeDateBefore,
    CancelToken? cancelToken,
  });
}
