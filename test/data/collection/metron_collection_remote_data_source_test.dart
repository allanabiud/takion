import "package:dio/dio.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:takion/src/data/collection/datasources/remote/metron_collection_remote_data_source_impl.dart";
import "package:takion/src/data/collection/dto/scrobble_dto.dart";

class MockDio extends Mock implements Dio {}

void main() {
  group("MetronCollectionRemoteDataSourceImpl", () {
    late MockDio dio;
    late MetronCollectionRemoteDataSourceImpl dataSource;

    setUp(() {
      dio = MockDio();
      dataSource = MetronCollectionRemoteDataSourceImpl(dio);
    });

    test("getCollection parses items correctly", () async {
      when(
        () => dio.get(
          "collection/",
          queryParameters: any(named: "queryParameters"),
          cancelToken: any(named: "cancelToken"),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: "collection/"),
          data: {
            "count": 1,
            "results": [
              {
                "id": 101,
                "quantity": 1,
                "book_format": "PRINT",
                "grade": "9.8",
                "is_read": true,
                "read_count": 1,
                "issue": {
                  "id": 500,
                  "number": "1",
                  "cover_date": "2024-01-01",
                  "series": {
                    "id": 20,
                    "name": "Batman",
                    "volume": 3,
                    "year_began": 2016,
                  },
                },
              },
            ],
          },
        ),
      );

      final items = await dataSource.getCollection(page: 1);
      expect(items.length, 1);
      expect(items.first.id, 101);
      expect(items.first.seriesName, "Batman");
      expect(items.first.issueNumber, "1");
      expect(items.first.grade, 9.8);
      expect(items.first.isRead, true);
    });

    test("addToCollection sends correct payload and parses response", () async {
      when(
        () => dio.post(
          "collection/add/",
          data: any(named: "data"),
          cancelToken: any(named: "cancelToken"),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: "collection/add/"),
          data: {
            "id": 202,
            "quantity": 2,
            "book_format": "DIGITAL",
            "issue": {
              "id": 600,
              "number": "2",
              "series": {"id": 21, "name": "Flash"},
            },
          },
        ),
      );

      final result = await dataSource.addToCollection(
        issueId: 600,
        quantity: 2,
        bookFormat: "DIGITAL",
      );

      expect(result.id, 202);
      expect(result.quantity, 2);
      expect(result.bookFormat, "DIGITAL");
    });

    test("scrobble sends scrobble request", () async {
      when(
        () => dio.post(
          "collection/scrobble/",
          data: any(named: "data"),
          cancelToken: any(named: "cancelToken"),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: "collection/scrobble/"),
          data: {"id": 303, "is_read": true, "date_read": "2026-09-03"},
        ),
      );

      final result = await dataSource.scrobble(
        const ScrobbleRequestDto(issueId: 700, rating: 5),
      );

      expect(result.id, 303);
      expect(result.isRead, true);
    });

    test("getCollectionStats returns stats entity", () async {
      when(
        () => dio.get(
          "collection/stats/",
          cancelToken: any(named: "cancelToken"),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: "collection/stats/"),
          data: {
            "total_items": 100,
            "total_quantity": 110,
            "total_value": "1250.50",
            "read_count": 80,
            "unread_count": 20,
            "rating_count": 50,
            "average_rating": 4.2,
            "by_format": [
              {"book_format": "PRINT", "count": 90},
              {"book_format": "DIGITAL", "count": 10},
            ],
          },
        ),
      );

      final stats = await dataSource.getCollectionStats();
      expect(stats.totalItems, 100);
      expect(stats.totalQuantity, 110);
      expect(stats.totalValue, "1250.50");
      expect(stats.readCount, 80);
      expect(stats.byFormat.length, 2);
    });
  });
}
