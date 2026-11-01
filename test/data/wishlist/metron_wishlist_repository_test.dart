import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:takion/src/data/wishlist/datasources/remote/metron_wishlist_remote_data_source.dart";
import "package:takion/src/data/wishlist/dto/wishlist_dto.dart";
import "package:takion/src/data/wishlist/repositories/metron_wishlist_repository_impl.dart";

class MockMetronWishlistRemoteDataSource extends Mock
    implements MetronWishlistRemoteDataSource {}

void main() {
  setUpAll(() {
    registerFallbackValue(const WishListAddItemDto(issueId: 1));
    registerFallbackValue(const AcquireWishListItemDto());
  });

  group("MetronWishlistRepositoryImpl", () {
    late MockMetronWishlistRemoteDataSource remoteDataSource;
    late MetronWishlistRepositoryImpl repository;

    setUp(() {
      remoteDataSource = MockMetronWishlistRemoteDataSource();
      repository = MetronWishlistRepositoryImpl(
        remoteDataSource: remoteDataSource,
      );
    });

    test("getWishListItems maps DTOs to entities", () async {
      when(() => remoteDataSource.getWishListItems(page: 1)).thenAnswer(
        (_) async => [
          const WishListItemDto(
            id: 1,
            issueId: 200,
            seriesId: 50,
            seriesName: "Spider-Man",
            issueNumber: "1",
            priority: 4,
            maxPrice: 25.0,
            maxPriceCurrency: "USD",
          ),
        ],
      );

      final result = await repository.getWishListItems(page: 1);
      expect(result.length, 1);
      expect(result.first.id, 1);
      expect(result.first.issueId, 200);
      expect(result.first.seriesName, "Spider-Man");
      expect(result.first.priority, 4);
      expect(result.first.maxPrice, 25.0);
    });

    test(
      "addToWishList delegates to remote data source and returns entity",
      () async {
        when(() => remoteDataSource.addToWishList(any())).thenAnswer(
          (_) async => const WishListItemDto(
            id: 5,
            issueId: 200,
            seriesId: 50,
            seriesName: "Spider-Man",
            issueNumber: "1",
            priority: 3,
          ),
        );

        final result = await repository.addToWishList(
          issueId: 200,
          priority: 3,
        );

        expect(result.id, 5);
        expect(result.issueId, 200);
        expect(result.seriesName, "Spider-Man");
        verify(() => remoteDataSource.addToWishList(any())).called(1);
      },
    );

    test("acquireWishListItem delegates to remote data source", () async {
      when(
        () => remoteDataSource.acquireWishListItem(5, any()),
      ).thenAnswer((_) async {});

      await repository.acquireWishListItem(
        itemId: 5,
        purchasePrice: 19.99,
        purchaseStore: "Local Comic Shop",
      );

      verify(() => remoteDataSource.acquireWishListItem(5, any())).called(1);
    });

    test("removeFromWishList delegates to remote data source", () async {
      when(
        () => remoteDataSource.removeFromWishList(5),
      ).thenAnswer((_) async {});

      await repository.removeFromWishList(5);
      verify(() => remoteDataSource.removeFromWishList(5)).called(1);
    });

    test("getItemCount returns count from wishlists", () async {
      when(
        () => remoteDataSource.getWishLists(),
      ).thenAnswer((_) async => [const WishListReadDto(id: 1, itemCount: 12)]);

      final count = await repository.getItemCount();
      expect(count, 12);
    });
  });
}
