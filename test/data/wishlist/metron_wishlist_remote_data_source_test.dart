import "package:dio/dio.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:takion/src/data/wishlist/datasources/remote/metron_wishlist_remote_data_source_impl.dart";
import "package:takion/src/data/wishlist/dto/wishlist_dto.dart";

class MockDio extends Mock implements Dio {}

void main() {
  group("MetronWishlistRemoteDataSourceImpl", () {
    late MockDio dio;
    late MetronWishlistRemoteDataSourceImpl dataSource;

    setUp(() {
      dio = MockDio();
      dataSource = MetronWishlistRemoteDataSourceImpl(dio);
    });

    test("getWishListItems parses wishlist items correctly", () async {
      when(
        () => dio.get(
          "wish_list/items/",
          queryParameters: any(named: "queryParameters"),
          cancelToken: any(named: "cancelToken"),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: "wish_list/items/"),
          data: {
            "count": 1,
            "results": [
              {
                "id": 55,
                "priority": 4,
                "desired_grade": "9.4",
                "max_price": "50.00",
                "notes": "Looking for first print",
                "issue": {
                  "id": 333,
                  "number": "1",
                  "series": {"id": 12, "name": "Saga"},
                },
              },
            ],
          },
        ),
      );

      final items = await dataSource.getWishListItems();
      expect(items.length, 1);
      expect(items.first.id, 55);
      expect(items.first.seriesName, "Saga");
      expect(items.first.priority, 4);
      expect(items.first.desiredGrade, 9.4);
      expect(items.first.maxPrice, 50.0);
    });

    test("addToWishList posts correctly", () async {
      when(
        () => dio.post(
          "wish_list/items/add/",
          data: any(named: "data"),
          cancelToken: any(named: "cancelToken"),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: "wish_list/items/add/"),
          data: {
            "id": 77,
            "priority": 3,
            "issue": {
              "id": 444,
              "number": "5",
              "series": {"id": 15, "name": "Daredevil"},
            },
          },
        ),
      );

      final item = await dataSource.addToWishList(
        const WishListAddItemDto(issueId: 444, priority: 3),
      );

      expect(item.id, 77);
      expect(item.seriesName, "Daredevil");
    });
  });
}
