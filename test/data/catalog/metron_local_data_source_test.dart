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

    test("caches and retrieves series search and list results with metadata", () async {
      final List<SeriesListDto> seriesList = [
        const SeriesListDto(
          id: 10,
          series: "Batman",
          volume: 3,
          yearBegan: 2016,
        ),
      ];

      await dataSource.cacheSeriesSearchResults(
        "batman",
        seriesList,
        page: 1,
        limit: 20,
        count: 50,
        next: "https://metron.cloud/api/series/?page=2",
      );

      final searchRetrieved = await dataSource.getSeriesSearchResults(
        "batman",
        page: 1,
        limit: 20,
      );
      expect(searchRetrieved?.first.id, 10);
      final searchMeta = await dataSource.getSeriesSearchResultsMeta(
        "batman",
        page: 1,
        limit: 20,
      );
      expect(searchMeta?.count, 50);

      await dataSource.cacheSeriesListResults(
        seriesList,
        page: 1,
        limit: 20,
        count: 50,
      );
      final listRetrieved = await dataSource.getSeriesListResults(
        page: 1,
        limit: 20,
      );
      expect(listRetrieved?.first.series, "Batman");
    });

    test("caches and retrieves series issue list results", () async {
      final issues = [
        const IssueListDto(
          id: 101,
          number: "1",
          series: IssueListSeriesDto(name: "Batman", volume: 3, yearBegan: 2016),
          image: null,
          issueName: "Batman #1",
        ),
      ];

      await dataSource.cacheSeriesIssueListResults(
        10,
        issues,
        page: 1,
        limit: 20,
        count: 1,
      );

      final retrieved = await dataSource.getSeriesIssueListResults(
        10,
        page: 1,
        limit: 20,
      );
      expect(retrieved?.first.id, 101);
      final meta = await dataSource.getSeriesIssueListResultsMeta(
        10,
        page: 1,
        limit: 20,
      );
      expect(meta?.count, 1);
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

      // Issue detail
      await dataSource.cacheIssueDetailsResponse(5, {"id": 5, "name": "Action Comics"});
      expect(await dataSource.getCachedIssueDetailsResponse(5), isNotNull);

      // Series detail
      await dataSource.cacheSeriesDetailsResponse(10, {"id": 10, "name": "Batman"});
      expect(await dataSource.getCachedSeriesDetailsResponse(10), isNotNull);

      // Creator detail
      await dataSource.cacheCreatorDetailsResponse(20, {"id": 20, "name": "Alan Moore"});
      expect(await dataSource.getCachedCreatorDetailsResponse(20), isNotNull);

      // Team detail
      await dataSource.cacheTeamDetailsResponse(30, {"id": 30, "name": "Justice League"});
      expect(await dataSource.getCachedTeamDetailsResponse(30), isNotNull);

      // Universe detail
      await dataSource.cacheUniverseDetailsResponse(40, {"id": 40, "name": "Prime Earth"});
      expect(await dataSource.getCachedUniverseDetailsResponse(40), isNotNull);

      // Imprint detail
      await dataSource.cacheImprintDetailsResponse(50, {"id": 50, "name": "Vertigo"});
      expect(await dataSource.getCachedImprintDetailsResponse(50), isNotNull);

      // Publisher detail
      await dataSource.cachePublisherDetailsResponse(60, {"id": 60, "name": "DC Comics"});
      expect(await dataSource.getCachedPublisherDetailsResponse(60), isNotNull);

      // Arc detail
      await dataSource.cacheArcDetailsResponse(70, {"id": 70, "name": "Crisis on Infinite Earths"});
      expect(await dataSource.getCachedArcDetailsResponse(70), isNotNull);
    });
  });
}

