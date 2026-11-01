import "package:flutter_test/flutter_test.dart";
import "package:takion/src/data/catalog/dto/series_list_dto.dart";

void main() {
  group("SeriesListDto", () {
    test(
      "parses new Metron fields (publisher, series_type, cv_id, gcd_id)",
      () {
        final json = {
          "id": 1,
          "series": "Batman",
          "year_began": 2016,
          "year_end": null,
          "volume": 3,
          "issue_count": 150,
          "publisher": {"id": 1, "name": "DC Comics"},
          "series_type": {"id": 1, "name": "Ongoing"},
          "cv_id": 91819,
          "gcd_id": 169363,
          "modified": "2026-10-25T12:00:00Z",
        };

        final dto = SeriesListDto.fromJson(json);
        expect(dto.id, 1);
        expect(dto.series, "Batman");
        expect(dto.yearBegan, 2016);
        expect(dto.yearEnd, isNull);
        expect(dto.volume, 3);
        expect(dto.issueCount, 150);
        expect(dto.publisherName, "DC Comics");
        expect(dto.seriesType, "Ongoing");
        expect(dto.cvId, 91819);
        expect(dto.gcdId, 169363);

        final entity = dto.toEntity();
        expect(entity.id, 1);
        expect(entity.name, "Batman");
        expect(entity.publisherName, "DC Comics");
        expect(entity.seriesType, "Ongoing");
        expect(entity.cvId, 91819);
        expect(entity.gcdId, 169363);
      },
    );

    test("handles legacy payload without new fields gracefully", () {
      final json = {
        "id": 2,
        "series": "Detective Comics",
        "year_began": 1937,
        "volume": 1,
        "issue_count": 1000,
      };

      final dto = SeriesListDto.fromJson(json);
      expect(dto.id, 2);
      expect(dto.series, "Detective Comics");
      expect(dto.publisherName, isNull);
      expect(dto.seriesType, isNull);
      expect(dto.cvId, isNull);
      expect(dto.gcdId, isNull);

      final entity = dto.toEntity();
      expect(entity.name, "Detective Comics");
      expect(entity.publisherName, isNull);
    });
  });
}
