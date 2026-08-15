import "package:dio/dio.dart";
import "package:drift/native.dart";
import "package:flutter_test/flutter_test.dart";
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
  int getIssueListCalls = 0;
  final List<int> _pageTwoIssueIds;

  FakeMetronRemoteDataSource(this._pageTwoIssueIds);

  @override
  Future<IssueSearchResponseDto> getIssueList({
    Uri? nextUrl,
    int page = 1,
    String? ordering,
    DateTime? modifiedGt,
    int? limit,
    CancelToken? cancelToken,
  }) async {
    getIssueListCalls++;
    if (nextUrl != null) {
      return IssueSearchResponseDto(
        count: _pageTwoIssueIds.length + 1,
        next: null,
        previous: null,
        results: [
          for (final id in _pageTwoIssueIds)
            _issue(id: id, number: "$id", storeDate: "2026-10-14"),
        ],
      );
    }
    return IssueSearchResponseDto(
      count: _pageTwoIssueIds.length + 1,
      next: "https://metron.example/issue/?page=2&modified_gt=2026-01-01",
      previous: null,
      results: [_issue(id: 1, number: "1", storeDate: "2026-10-07")],
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError("${invocation.memberName}");
  }
}

IssueListDto _issue({
  required int id,
  required String number,
  required String storeDate,
}) {
  return IssueListDto(
    id: id,
    number: number,
    series: const IssueListSeriesDto(
      id: 900,
      name: "Test Series",
      volume: 1,
      yearBegan: 2026,
    ),
    coverDate: storeDate,
    storeDate: storeDate,
    image: null,
    issueName: "Test Series #$number",
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

  MetronRepositoryImpl buildRepo(FakeMetronRemoteDataSource remote) {
    return MetronRepositoryImpl(
      remote,
      MetronLocalDataSourceImpl(db),
      MetronEntityDao(db),
      JunctionDao(db),
      series_index.SeriesNameIndex(db),
    );
  }

  test(
    "getIssueList with nextUrl returns the next page, not cached page 1",
    () async {
      final remote = FakeMetronRemoteDataSource([202]);
      final repo = buildRepo(remote);
      final modifiedGt = DateTime.utc(2026, 9, 1);

      final page1 = await repo.getIssueList(modifiedGt: modifiedGt);
      expect(page1.results.map((i) => i.id), [1]);
      expect(page1.next, isNotNull);

      final page2 = await repo.getIssueList(
        nextUrl: page1.next,
        modifiedGt: modifiedGt,
      );
      expect(page2.results.map((i) => i.id), [202]);
      expect(remote.getIssueListCalls, 2);
    },
  );

  test("getIssueList serves a fresh cached page 1 without re-fetching", () async {
    final remote = FakeMetronRemoteDataSource([202]);
    final repo = buildRepo(remote);
    final modifiedGt = DateTime.utc(2026, 9, 1);

    await repo.getIssueList(modifiedGt: modifiedGt);
    final cached = await repo.getIssueList(modifiedGt: modifiedGt);

    expect(cached.results.map((i) => i.id), [1]);
    expect(remote.getIssueListCalls, 1);
  });
}
