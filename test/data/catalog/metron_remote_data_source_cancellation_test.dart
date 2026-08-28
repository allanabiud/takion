import "package:dio/dio.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:takion/src/data/catalog/datasources/remote/metron_remote_data_source_impl.dart";

class MockDio extends Mock implements Dio {}

void main() {
  setUpAll(() {
    registerFallbackValue(Uri.parse("https://metron.cloud/api/issue/"));
    registerFallbackValue(RequestOptions(path: "/"));
    registerFallbackValue(CancelToken());
  });

  group("MetronRemoteDataSourceImpl cancellation & nextUrl forwarding", () {
    late MockDio dio;
    late MetronRemoteDataSourceImpl dataSource;

    setUp(() {
      dio = MockDio();
      dataSource = MetronRemoteDataSourceImpl(dio);
    });

    test(
      "forwards cancelToken when nextUrl is provided in getIssueList",
      () async {
        final token = CancelToken();
        final nextUri = Uri.parse("https://metron.cloud/api/issue/?page=2");

        when(
          () => dio.getUri(
            nextUri,
            cancelToken: token,
            options: any(named: "options"),
            onReceiveProgress: any(named: "onReceiveProgress"),
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: nextUri.toString()),
            data: {"count": 10, "results": []},
          ),
        );

        final res = await dataSource.getIssueList(
          nextUrl: nextUri,
          cancelToken: token,
        );

        expect(res.count, 10);
        verify(
          () => dio.getUri(
            nextUri,
            cancelToken: token,
            options: any(named: "options"),
            onReceiveProgress: any(named: "onReceiveProgress"),
          ),
        ).called(1);
      },
    );

    test(
      "forwards cancelToken when nextUrl is provided in searchSeries",
      () async {
        final token = CancelToken();
        final nextUri = Uri.parse(
          "https://metron.cloud/api/series/?name=batman&page=2",
        );

        when(
          () => dio.getUri(
            nextUri,
            cancelToken: token,
            options: any(named: "options"),
            onReceiveProgress: any(named: "onReceiveProgress"),
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: nextUri.toString()),
            data: {"count": 5, "results": []},
          ),
        );

        final res = await dataSource.searchSeries(
          "batman",
          nextUrl: nextUri,
          cancelToken: token,
        );

        expect(res.count, 5);
        verify(
          () => dio.getUri(
            nextUri,
            cancelToken: token,
            options: any(named: "options"),
            onReceiveProgress: any(named: "onReceiveProgress"),
          ),
        ).called(1);
      },
    );

    test(
      "forwards cancelToken when fetching first page via searchIssues",
      () async {
        final token = CancelToken();

        when(
          () => dio.get(
            "issue/",
            queryParameters: any(named: "queryParameters"),
            cancelToken: token,
            options: any(named: "options"),
            onReceiveProgress: any(named: "onReceiveProgress"),
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: "issue/"),
            data: {"count": 1, "results": []},
          ),
        );

        final res = await dataSource.searchIssues("spawn", cancelToken: token);

        expect(res.count, 1);
        verify(
          () => dio.get(
            "issue/",
            queryParameters: any(named: "queryParameters"),
            cancelToken: token,
            options: any(named: "options"),
            onReceiveProgress: any(named: "onReceiveProgress"),
          ),
        ).called(1);
      },
    );
  });
}
