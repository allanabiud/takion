import "package:drift/native.dart";
import "package:flutter_test/flutter_test.dart";
import "package:takion/src/data/catalog/datasources/local/metron_local_data_source.dart";
import "package:takion/src/data/catalog/dto/dto.dart";
import "package:takion/src/data/common/drift/database.dart";

void main() {
  late AppDatabase db;
  late MetronLocalDataSource dataSource;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dataSource = MetronLocalDataSourceImpl(db);
  });

  tearDown(() async {
    await db.close();
  });

  group("MetronLocalDataSource", () {
    test("caches and retrieves weekly releases", () async {
      final date = DateTime.utc(2026, 8, 26);
      final issues = [
        const IssueListDto(
          id: 1,
          number: "1",
          series: IssueListSeriesDto(name: "Saga", volume: 1, yearBegan: 2012),
          coverDate: "2026-08-26",
          image: "https://example.com/1.jpg",
          issueName: "Saga #1",
        ),
      ];

      await dataSource.cacheWeeklyReleases(date, issues);

      final retrieved = await dataSource.getWeeklyReleases(date);
      expect(retrieved, isNotNull);
      expect(retrieved!.length, 1);
      expect(retrieved.first.id, 1);
      expect(retrieved.first.number, "1");

      final cachedAt = await dataSource.getWeeklyReleasesCachedAt(date);
      expect(cachedAt, isNotNull);
    });

    test("caches and retrieves issue search results with metadata", () async {
      final issues = [
        const IssueListDto(
          id: 42,
          number: "50",
          series: IssueListSeriesDto(name: "Batman", volume: 3, yearBegan: 2016),
          image: null,
          issueName: "Batman #50",
        ),
      ];

      await dataSource.cacheIssueSearchResults(
        "batman",
        issues,
        page: 1,
        limit: 20,
        count: 100,
        next: "https://metron.cloud/api/issue/?page=2",
      );

      final retrieved = await dataSource.getIssueSearchResults(
        "batman",
        page: 1,
        limit: 20,
      );
      expect(retrieved, isNotNull);
      expect(retrieved!.first.id, 42);

      final meta = await dataSource.getIssueSearchResultsMeta(
        "batman",
        page: 1,
        limit: 20,
      );
      expect(meta, isNotNull);
      expect(meta!.count, 100);
      expect(meta.next, "https://metron.cloud/api/issue/?page=2");
    });

    test("caches and retrieves raw entity details responses", () async {
      final jsonPayload = {
        "id": 100,
        "name": "Batman",
        "desc": "The Dark Knight",
      };

      await dataSource.cacheCharacterDetailsResponse(100, jsonPayload);

      final retrieved = await dataSource.getCachedCharacterDetailsResponse(100);
      expect(retrieved, isNotNull);
      expect(retrieved!["name"], "Batman");
      expect(retrieved["id"], 100);

      final cachedAt = await dataSource.getCachedCharacterDetailsCachedAt(100);
      expect(cachedAt, isNotNull);
    });
  });
}
