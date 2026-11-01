import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:takion/src/data/pull_list/datasources/remote/metron_pull_list_remote_data_source.dart";
import "package:takion/src/data/pull_list/dto/pull_list_dto.dart";
import "package:takion/src/data/pull_list/repositories/metron_pull_list_repository_impl.dart";

class MockMetronPullListRemoteDataSource extends Mock
    implements MetronPullListRemoteDataSource {}

void main() {
  group("MetronPullListRepositoryImpl", () {
    late MockMetronPullListRemoteDataSource remoteDataSource;
    late MetronPullListRepositoryImpl repository;

    setUp(() {
      remoteDataSource = MockMetronPullListRemoteDataSource();
      repository = MetronPullListRepositoryImpl(remoteDataSource);
    });

    test("getPullListSeries maps DTOs to domain entities", () async {
      when(() => remoteDataSource.getPullListSeries(page: 1)).thenAnswer(
        (_) async => [
          const PullListSeriesDto(
            id: 1,
            seriesId: 100,
            seriesName: "Batman",
            volume: 1,
            yearBegan: 2016,
            publisherName: "DC Comics",
          ),
        ],
      );

      final result = await repository.getPullListSeries(page: 1);
      expect(result.length, 1);
      expect(result.first.id, 1);
      expect(result.first.seriesId, 100);
      expect(result.first.seriesName, "Batman");
      expect(result.first.publisherName, "DC Comics");
    });

    test("addSeriesToPullList delegates to remote data source", () async {
      when(() => remoteDataSource.addSeriesToPullList(100)).thenAnswer(
        (_) async =>
            const PullListSeriesDto(id: 2, seriesId: 100, seriesName: "Batman"),
      );

      final result = await repository.addSeriesToPullList(100);
      expect(result.id, 2);
      expect(result.seriesId, 100);
      expect(result.seriesName, "Batman");
    });

    test("removeSeriesFromPullList delegates to remote data source", () async {
      when(
        () => remoteDataSource.removeSeriesFromPullList(100),
      ).thenAnswer((_) async {});

      await repository.removeSeriesFromPullList(100);
      verify(() => remoteDataSource.removeSeriesFromPullList(100)).called(1);
    });

    test("getPullListIssues maps issue DTOs to entities", () async {
      when(
        () => remoteDataSource.getPullListIssues(
          page: 1,
          storeDateAfter: any(named: "storeDateAfter"),
          storeDateBefore: any(named: "storeDateBefore"),
        ),
      ).thenAnswer(
        (_) async => [
          const PullListIssueDto(
            id: 10,
            issueId: 501,
            seriesId: 100,
            seriesName: "Batman",
            issueNumber: "1",
            price: 3.99,
          ),
        ],
      );

      final result = await repository.getPullListIssues(page: 1);
      expect(result.length, 1);
      expect(result.first.id, 10);
      expect(result.first.issueId, 501);
      expect(result.first.seriesName, "Batman");
      expect(result.first.price, 3.99);
    });

    test(
      "PullListSeriesDto parses series name from 'series' field (PullListSeriesInfo)",
      () {
        final json = {
          "id": 101,
          "series": {
            "id": 3856,
            "series": "The 06 Protocol",
            "volume": 1,
            "year_began": 2022,
            "year_end": null,
            "modified": "2024-12-23T16:17:29Z",
          },
          "added_on": "2026-07-24T06:42:18Z",
        };

        final dto = PullListSeriesDto.fromJson(json);
        expect(dto.id, 101);
        expect(dto.seriesId, 3856);
        expect(dto.seriesName, "The 06 Protocol");
        expect(dto.volume, 1);
        expect(dto.yearBegan, 2022);
      },
    );

    test("PullListSeriesDto parses legacy series name from 'name' field", () {
      final json = {
        "id": 102,
        "series": {
          "id": 100,
          "name": "Detective Comics",
          "volume": 1,
          "year_began": 1937,
        },
      };

      final dto = PullListSeriesDto.fromJson(json);
      expect(dto.id, 102);
      expect(dto.seriesId, 100);
      expect(dto.seriesName, "Detective Comics");
    });
  });
}
