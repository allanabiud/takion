import "package:drift/native.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_test/flutter_test.dart";
import "package:takion/src/data/collection/repositories/local_library_repository.dart";
import "package:takion/src/data/wishlist/repositories/local_wishlist_repository.dart";
import "package:takion/src/domain/entities.dart";
import "package:takion/src/presentation/features/issues/providers/scrobble_issue_provider.dart";
import "package:takion/src/presentation/providers/providers.dart";

void main() {
  late AppDatabase db;
  late ProviderContainer container;
  late LocalLibraryRepository libraryRepository;
  late LocalWishlistRepository wishlistRepository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    libraryRepository = LocalLibraryRepository(db);
    wishlistRepository = LocalWishlistRepository(db);

    container = ProviderContainer(
      overrides: [
        driftDatabaseProvider.overrideWithValue(db),
        libraryRepositoryProvider.overrideWithValue(libraryRepository),
        wishlistRepositoryProvider.overrideWithValue(wishlistRepository),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  test(
    "scrobble with addToCollection deletes any wishlist entry for that issue",
    () async {
      // 1. Add issue 201 to wishlist
      await wishlistRepository.addToWishList(
        issueId: 201,
        seriesId: 10,
        seriesName: "Batman",
        issueNumber: "201",
        imageUrl: "https://example.com/batman201.jpg",
      );

      var wishlistItem = await wishlistRepository.getItemByIssueId(201);
      expect(wishlistItem, isNotNull);

      // 2. Scrobble with addToCollection: true
      final controller = container.read(scrobbleIssueProvider(201).notifier);
      controller.setContext(
        const ScrobbleIssueContext(
          seriesId: 10,
          seriesName: "Batman",
          issueNumber: "201",
          imageUrl: "https://example.com/batman201.jpg",
        ),
      );

      await controller.scrobble(
        addToCollection: true,
        markAsRead: true,
        rating: 5,
      );

      // 3. Verify wishlist entry was removed
      wishlistItem = await wishlistRepository.getItemByIssueId(201);
      expect(wishlistItem, isNull);

      // 4. Verify library item was created as owned
      final libItem = await libraryRepository.getItemByIssueId(201);
      expect(libItem, isNotNull);
      expect(libItem?.ownershipStatus, LibraryOwnershipStatus.owned);
      expect(libItem?.isRead, true);
      expect(libItem?.rating, 5);
    },
  );
}
