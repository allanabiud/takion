import "package:dio/dio.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:takion/src/data/pull_list/datasources/remote/metron_pull_list_remote_data_source_impl.dart";

class MockDio extends Mock implements Dio {}

void main() {
  group("MetronPullListRemoteDataSourceImpl", () {
    late MockDio dio;
    late MetronPullListRemoteDataSourceImpl dataSource;

    setUp(() {
      dio = MockDio();
      dataSource = MetronPullListRemoteDataSourceImpl(dio);
    });

    test("getPullListSeries returns series items", () async {
      when(
        () => dio.get(
          "pull_list/series/",
          queryParameters: any(named: "queryParameters"),
          cancelToken: any(named: "cancelToken"),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: "pull_list/series/"),
          data: {
            "count": 1,
            "results": [
              {
                "id": 10,
                "added_on": "2026-01-01T00:00:00Z",
                "series": {
                  "id": 50,
                  "name": "Action Comics",
                  "volume": 1,
                  "year_began": 1938,
                  "publisher": {"name": "DC Comics"},
                },
              }
            ],
          },
        ),
      );

      final seriesList = await dataSource.getPullListSeries();
      expect(seriesList.length, 1);
      expect(seriesList.first.seriesName, "Action Comics");
      expect(seriesList.first.publisherName, "DC Comics");
    });

    test("getPullListIssues returns issues", () async {
      when(
        () => dio.get(
          "pull_list/issues/",
          queryParameters: any(named: "queryParameters"),
          cancelToken: any(named: "cancelToken"),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: "pull_list/issues/"),
          data: {
            "count": 1,
            "results": [
              {
                "id": 99,
                "number": "1000",
                "cover_date": "2024-05-01",
                "series": {
                  "id": 50,
                  "name": "Action Comics",
                },
              }
            ],
          },
        ),
      );

      final issues = await dataSource.getPullListIssues();
      expect(issues.length, 1);
      expect(issues.first.issueNumber, "1000");
      expect(issues.first.seriesName, "Action Comics");
    });
  });
}
