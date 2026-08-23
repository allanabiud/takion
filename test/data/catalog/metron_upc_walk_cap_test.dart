import "package:dio/dio.dart";
import "package:drift/native.dart";
import "package:flutter_test/flutter_test.dart";
import "package:takion/src/core/constants/pagination.dart";
import "package:takion/src/data/catalog/datasources/local/metron_local_data_source.dart";
import "package:takion/src/data/catalog/datasources/local/series_name_index.dart"
    as series_index;
import "package:takion/src/data/catalog/datasources/remote/metron_remote_data_source.dart";
import "package:takion/src/data/catalog/dto/dto.dart";
import "package:takion/src/data/catalog/repositories/metron_repository_impl.dart";
import "package:takion/src/data/common/drift/database.dart";
import "package:takion/src/data/common/drift/daos/junction_dao.dart";
import "package:takion/src/data/common/drift/daos/metron_entity_dao.dart";

class FakeMetronRemoteDataSource implements MetronRemoteDataSource {
  final List<IssueListDto> allIssues;
  final int pageSize;
  int fetchCount = 0;

  FakeMetronRemoteDataSource(this.allIssues, this.pageSize);

  Future<IssueSearchResponseDto> _page(int pageNumber) {
    final start = (pageNumber - 1) * pageSize;
    final slice = allIssues.skip(start).take(pageSize).toList();
    return Future.value(
      IssueSearchResponseDto(
        count: allIssues.length,
        next: start + slice.length < allIssues.length
            ? "https://metron.example/issue/?upc_starts_with=x&page=${pageNumber + 1}"
            : null,
        previous: null,
        results: slice,
      ),
    );
  }

  @override
  Future<IssueSearchResponseDto> searchIssuesByUpcPrefix(
    String prefix, {
    CancelToken? cancelToken,
  }) async {
    fetchCount++;
    return _page(1);
  }

  @override
  Future<IssueSearchResponseDto> getIssueSearchPage(
    String url, {
    CancelToken? cancelToken,
  }) async {
    fetchCount++;
    final pageNumber = int.parse(Uri.parse(url).queryParameters["page"]!);
    return _page(pageNumber);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError("${invocation.memberName}");
  }
}

IssueListDto _issue(int id) {
  return IssueListDto(
    id: id,
    number: "$id",
    series: const IssueListSeriesDto(
      id: 900,
      name: "Test Series",
      volume: 1,
      yearBegan: 2026,
    ),
    coverDate: "2026-10-14",
    storeDate: "2026-10-14",
    image: null,
    issueName: "Test Series #$id",
    modified: "2026-10-01T00:00:00Z",
    coverHash: null,
  );
}

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.customStatement("SELECT 1");
    await db.close();
  });

  test("searchIssuesByUpcPrefix caps the page walk", () async {
    final remote = FakeMetronRemoteDataSource([
      for (var i = 1; i <= 40; i++) _issue(i),
    ], 10);
    final repo = MetronRepositoryImpl(
      remote,
      MetronLocalDataSourceImpl(db),
      MetronEntityDao(db),
      JunctionDao(db),
      series_index.SeriesNameIndex(db),
    );

    final page = await repo.searchIssuesByUpcPrefix(
      "759606",
      forceRefresh: true,
    );

    expect(page.results, hasLength(10 * metronMaxWalkPages));
    expect(remote.fetchCount, metronMaxWalkPages);
  });
}
