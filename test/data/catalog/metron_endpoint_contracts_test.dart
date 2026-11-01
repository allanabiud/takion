import "package:flutter_test/flutter_test.dart";
import "package:takion/src/data/catalog/dto/issue_details_dto.dart";
import "package:takion/src/data/collection/dto/collection_item_dto.dart";
import "package:takion/src/data/collection/dto/scrobble_dto.dart";
import "package:takion/src/data/pull_list/dto/pull_list_dto.dart";
import "package:takion/src/data/wishlist/dto/wishlist_dto.dart";

import "../../fixtures/metron_endpoint_fixtures.dart";

void main() {
  group("Metron Endpoint Contract Verification", () {
    test("collection list response contracts parse correctly", () {
      final results =
          MetronEndpointFixtures.collectionList["results"] as List<dynamic>;
      expect(results.length, 2);

      final firstDto = CollectionItemDto.fromJson(
        results[0] as Map<String, dynamic>,
      );
      expect(firstDto.id, 101);
      expect(firstDto.issueId, 2001);
      expect(firstDto.seriesName, "Batman");
      expect(firstDto.seriesVolume, 3);
      expect(firstDto.seriesYearBegan, 2016);
      expect(firstDto.quantity, 1);
      expect(firstDto.grade, 9.8);
      expect(firstDto.purchasePrice, 3.99);
      expect(firstDto.isRead, isTrue);
      expect(firstDto.readDates.length, 1);
      expect(firstDto.readDates.first.readDate, "2020-03-10");

      final secondDto = CollectionItemDto.fromJson(
        results[1] as Map<String, dynamic>,
      );
      expect(secondDto.id, 102);
      expect(secondDto.issueId, 2002);
      expect(secondDto.isRead, isFalse);
    });

    test("collection add response contract parses correctly", () {
      final dto = CollectionItemDto.fromJson(
        MetronEndpointFixtures.collectionAddResponse,
      );
      expect(dto.id, 103);
      expect(dto.issueId, 2003);
      expect(dto.seriesId, 301);
      expect(dto.seriesName, "Batman");
    });

    test("collection scrobble response contract parses correctly", () {
      final dto = ScrobbleResponseDto.fromJson(
        MetronEndpointFixtures.scrobbleResponse,
      );
      expect(dto.id, 101);
      expect(dto.isRead, isTrue);
      expect(dto.dateRead, "2026-10-26");
    });

    test("pull list series contract parses correctly", () {
      final summary = PullListReadDto.fromJson(
        MetronEndpointFixtures.pullListSummary,
      );
      expect(summary.id, 50);
      expect(summary.seriesCount, 1);

      final seriesResults =
          MetronEndpointFixtures.pullListSeries["results"] as List<dynamic>;
      final seriesDto = PullListSeriesDto.fromJson(
        seriesResults.first as Map<String, dynamic>,
      );
      expect(seriesDto.id, 701);
      expect(seriesDto.seriesId, 301);
      expect(seriesDto.seriesName, "Batman");
      expect(seriesDto.publisherName, "DC Comics");
    });

    test("pull list issues contract parses correctly", () {
      final issueResults =
          MetronEndpointFixtures.pullListIssues["results"] as List<dynamic>;
      final issueDto = PullListIssueDto.fromJson(
        issueResults.first as Map<String, dynamic>,
      );
      expect(issueDto.id, 2050);
      expect(issueDto.issueId, 2050);
      expect(issueDto.issueNumber, "50");
      expect(issueDto.seriesName, "Batman");
    });

    test("wishlist items contract parses correctly", () {
      final summary = WishListReadDto.fromJson(
        MetronEndpointFixtures.wishListSummary,
      );
      expect(summary.id, 60);
      expect(summary.itemCount, 1);

      final wishResults =
          MetronEndpointFixtures.wishListItems["results"] as List<dynamic>;
      final itemDto = WishListItemDto.fromJson(
        wishResults.first as Map<String, dynamic>,
      );
      expect(itemDto.id, 901);
      expect(itemDto.issueId, 2005);
      expect(itemDto.priority, 4);
      expect(itemDto.maxPrice, 25.00);
      expect(itemDto.desiredGrade, 9.6);
    });

    test(
      "issue details contract parses correctly with nested credits and arcs",
      () {
        final dto = IssueDetailsDto.fromJson(
          MetronEndpointFixtures.issueDetail,
        );
        expect(dto.id, 2001);
        expect(dto.number, "1");
        expect(dto.names, ["I Am Gotham: Part One"]);
        expect(dto.sku, "DEC190520");
        expect(dto.upc, "76194134182800111");
        expect(dto.page, 32);
        expect(dto.credits.length, 2);
        expect(dto.credits.first.creator, "Tom King");
        expect(dto.arcs.length, 1);
        expect(dto.arcs.first.name, "I Am Gotham");
      },
    );
  });
}
