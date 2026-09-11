import "package:flutter_test/flutter_test.dart";
import "package:takion/src/data/common/drift/daos/library_item_dao.dart";
import "package:takion/src/data/common/drift/database.dart";
import "package:takion/src/presentation/features/library/providers/collection_status_cache_provider.dart";

void main() {
  test("buildStatusMap enforces strict mutual exclusivity where owned status overrides wishlist", () {
    final now = DateTime.now().toUtc();
    final libraryRows = [
      const LibraryItemStatusRow(
        metronIssueId: 101,
        ownershipStatus: "owned",
        isRead: true,
        rating: 5,
        syncStatus: "synced",
      ),
      const LibraryItemStatusRow(
        metronIssueId: 103,
        ownershipStatus: "not_owned",
        isRead: false,
        rating: null,
        syncStatus: "synced",
      ),
    ];

    final wishlistRows = <WishlistItem>[
      WishlistItem(
        id: 1,
        issueId: 101, // Duplicate on wishlist: should be ignored because it is owned in library
        seriesId: 1,
        seriesName: "Spider-Man",
        issueNumber: "101",
        priority: 1,
        maxPriceCurrency: "USD",
        syncStatus: "synced",
        addedOn: now,
        createdAt: now.toIso8601String(),
        updatedAt: now.toIso8601String(),
      ),
      WishlistItem(
        id: 2,
        issueId: 102, // Only wishlisted
        seriesId: 1,
        seriesName: "Spider-Man",
        issueNumber: "102",
        priority: 1,
        maxPriceCurrency: "USD",
        syncStatus: "synced",
        addedOn: now,
        createdAt: now.toIso8601String(),
        updatedAt: now.toIso8601String(),
      ),
    ];

    final statusMap = buildStatusMap(
      libraryRows: libraryRows,
      wishlistRows: wishlistRows,
    );

    // Issue 101: Collected = true, Wishlisted = false
    expect(statusMap[101]?.isCollected, true);
    expect(statusMap[101]?.isWishlisted, false);
    expect(statusMap[101]?.isRead, true);
    expect(statusMap[101]?.rating, 5);

    // Issue 102: Collected = false, Wishlisted = true
    expect(statusMap[102]?.isCollected, false);
    expect(statusMap[102]?.isWishlisted, true);

    // Issue 103: Collected = false, Wishlisted = false
    expect(statusMap[103]?.isCollected, false);
    expect(statusMap[103]?.isWishlisted, false);
  });
}
