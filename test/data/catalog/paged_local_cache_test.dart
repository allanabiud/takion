import "package:drift/drift.dart" show Value;
import "package:drift/native.dart";
import "package:flutter_test/flutter_test.dart";
import "package:takion/src/data/catalog/datasources/local/metron_list_local_data_source.dart";
import "package:takion/src/data/catalog/datasources/local/metron_releases_local_data_source.dart";
import "package:takion/src/data/catalog/datasources/local/metron_search_local_data_source.dart";
import "package:takion/src/data/catalog/datasources/local/paged_local_cache.dart";
import "package:takion/src/data/catalog/dto/dto.dart";
import "package:takion/src/data/common/drift/database.dart";
import "package:takion/src/data/reading_list/dto/reading_list_dto.dart";

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  PagedLocalCache<IssueListDto> issueCache({bool withMeta = true}) =>
      PagedLocalCache<IssueListDto>(
        db: db,
        cacheKeyPrefix: "issue_list",
        entityType: "issue_list",
        fromJson: IssueListDto.fromJson,
        toJson: (issue) => issue.toJson(),
        withMeta: withMeta,
      );

  group("codec registry", () {
    test("every production cache prefix resolves a codec", () {
      // Constructors throw ArgumentError when a prefix has no registered
      // codec, so building each data source fail-fast-checks all prefixes.
      expect(() => MetronListLocalDataSourceImpl(db), returnsNormally);
      expect(() => MetronSearchLocalDataSourceImpl(db), returnsNormally);
      expect(() => MetronReleasesLocalDataSourceImpl(db), returnsNormally);
    });

    test("an unknown prefix fails fast at construction", () {
      expect(
        () => PagedLocalCache<IssueListDto>(
          db: db,
          cacheKeyPrefix: "unknown_prefix",
          entityType: "unknown_prefix",
          fromJson: IssueListDto.fromJson,
          toJson: (issue) => issue.toJson(),
        ),
        throwsArgumentError,
      );
    });

    test("a prefix registered for the wrong DTO type fails fast", () {
      // "creator_search" is a CreatorListDto cache; asking for issues must
      // throw the cast error instead of mis-hydrating pages later.
      expect(
        () => PagedLocalCache<IssueListDto>(
          db: db,
          cacheKeyPrefix: "creator_search",
          entityType: "creator_search",
          fromJson: IssueListDto.fromJson,
          toJson: (issue) => issue.toJson(),
        ),
        throwsA(isA<TypeError>()),
      );
    });
  });

  group("PagedLocalCache normalized storage", () {
    test(
      "round-trips an issue page without JSON in the settings store",
      () async {
        final cache = issueCache();
        const issues = [
          IssueListDto(
            id: 1,
            number: "1",
            series: IssueListSeriesDto(
              name: "Saga",
              volume: 1,
              yearBegan: 2012,
              id: 77,
            ),
            coverDate: "2026-09-01",
            storeDate: "2026-09-03",
            image: "https://example.com/1.jpg",
            issueName: "Chapter One",
            modified: "2026-09-01T00:00:00Z",
            coverHash: "abc123",
          ),
          IssueListDto(
            id: 2,
            number: "2",
            series: null,
            image: null,
            issueName: null,
          ),
        ];

        await cache.cache(
          "issue_list:p1",
          issues,
          count: 42,
          next: "https://metron.cloud/api/issue/?page=2",
          previous: null,
        );

        final retrieved = await cache.get("issue_list:p1");
        expect(retrieved, isNotNull);
        expect(retrieved, hasLength(2));
        expect(retrieved!.first.id, 1);
        expect(retrieved.first.number, "1");
        expect(retrieved.first.issueName, "Chapter One");
        expect(retrieved.first.coverDate, "2026-09-01");
        expect(retrieved.first.storeDate, "2026-09-03");
        expect(retrieved.first.image, "https://example.com/1.jpg");
        expect(retrieved.first.coverHash, "abc123");
        expect(retrieved.first.modified, "2026-09-01T00:00:00Z");
        expect(retrieved.first.series?.name, "Saga");
        expect(retrieved.first.series?.id, 77);
        expect(retrieved.first.series?.volume, 1);
        expect(retrieved.first.series?.yearBegan, 2012);
        expect(retrieved.last.id, 2);
        expect(retrieved.last.series, isNull);

        final meta = await cache.meta("issue_list:p1");
        expect(meta?.count, 42);
        expect(meta?.next, "https://metron.cloud/api/issue/?page=2");
        expect(meta?.previous, isNull);
        expect(await cache.cachedAt("issue_list:p1"), isNotNull);

        // No JSON page payloads remain in the settings key-value store.
        final legacyKeys = await db
            .customSelect(
              "SELECT key FROM app_settings "
              "WHERE key LIKE 'paged\\_cache%' ESCAPE '\\'",
            )
            .get();
        expect(legacyKeys, isEmpty);
      },
    );

    test("misses return null and cached empty pages round-trip", () async {
      final cache = issueCache();
      expect(await cache.get("issue_list:absent"), isNull);
      expect(await cache.meta("issue_list:absent"), isNull);
      expect(await cache.cachedAt("issue_list:absent"), isNull);

      await cache.cache("issue_list:empty", const [], count: 0);
      expect(await cache.get("issue_list:empty"), isEmpty);
      final meta = await cache.meta("issue_list:empty");
      expect(meta, isNotNull);
      expect(meta!.count, 0);
    });

    test("page order and duplicates follow the cached id order", () async {
      final cache = issueCache();
      await cache.cache("issue_list:order", const [
        IssueListDto(id: 3, number: "3", series: null, image: null),
        IssueListDto(id: 1, number: "1", series: null, image: null),
        IssueListDto(id: 3, number: "3", series: null, image: null),
      ], count: 3);

      final retrieved = await cache.get("issue_list:order");
      expect(retrieved?.map((issue) => issue.id), [3, 1, 3]);
    });

    test("a deleted entity turns the page into a cache miss", () async {
      final cache = issueCache();
      await cache.cache("issue_list:partial", const [
        IssueListDto(id: 1, number: "1", series: null, image: null),
        IssueListDto(id: 2, number: "2", series: null, image: null),
      ], count: 2);

      await (db.delete(db.metronIssues)..where((t) => t.id.equals(1))).go();
      expect(await cache.get("issue_list:partial"), isNull);
    });

    test("write-through preserves hydrated and unprovided columns", () async {
      // A fully hydrated issue row with detail-only columns filled in.
      await db
          .into(db.metronIssues)
          .insert(
            const MetronIssuesCompanion(
              id: Value(5),
              number: Value("5"),
              description: Value("Hydrated description"),
              pageCount: Value(32),
              isFullyHydrated: Value(true),
            ),
          );

      final cache = issueCache();
      // The list payload only provides id/number; its null optional fields
      // stay absent so they cannot clobber the hydrated row.
      await cache.cache("issue_list:hydrate", const [
        IssueListDto(id: 5, number: "5", series: null, image: null),
      ], count: 1);

      final row = await (db.select(
        db.metronIssues,
      )..where((t) => t.id.equals(5))).getSingle();
      expect(row.number, "5");
      expect(row.description, "Hydrated description");
      expect(row.pageCount, 32);
      expect(row.isFullyHydrated, isTrue);
    });

    test(
      "re-caching a page replaces ids and clears stale pagination",
      () async {
        final cache = issueCache();
        await cache.cache(
          "issue_list:refresh",
          const [
            IssueListDto(id: 1, number: "1", series: null, image: null),
            IssueListDto(id: 2, number: "2", series: null, image: null),
          ],
          count: 2,
          next: "https://metron.cloud/api/issue/?page=2",
        );

        await cache.cache("issue_list:refresh", const [
          IssueListDto(id: 3, number: "3", series: null, image: null),
        ], count: 1);

        final retrieved = await cache.get("issue_list:refresh");
        expect(retrieved?.map((issue) => issue.id), [3]);
        final meta = await cache.meta("issue_list:refresh");
        expect(meta?.count, 1);
        expect(meta?.next, isNull);
      },
    );
  });

  group("entity codecs", () {
    test("series pages round-trip through metron_series", () async {
      final cache = PagedLocalCache<SeriesListDto>(
        db: db,
        cacheKeyPrefix: "series_list",
        entityType: "series_list",
        fromJson: SeriesListDto.fromJson,
        toJson: (series) => series.toJson(),
      );
      await cache.cache("series_list:p1", const [
        SeriesListDto(
          id: 10,
          series: "Batman",
          yearBegan: 2016,
          volume: 3,
          issueCount: 100,
          modified: "2026-02-02T00:00:00Z",
        ),
      ], count: 50);

      final retrieved = await cache.get("series_list:p1");
      expect(retrieved?.first.id, 10);
      expect(retrieved?.first.series, "Batman");
      expect(retrieved?.first.yearBegan, 2016);
      expect(retrieved?.first.volume, 3);
      expect(retrieved?.first.issueCount, 100);
      expect(retrieved?.first.modified, "2026-02-02T00:00:00Z");
    });

    test("character pages persist and read the slug column", () async {
      final cache = PagedLocalCache<CharacterListDto>(
        db: db,
        cacheKeyPrefix: "character_list",
        entityType: "character_list",
        fromJson: CharacterListDto.fromJson,
        toJson: (character) => character.toJson(),
      );
      await cache.cache("character_list:p1", const [
        CharacterListDto(
          id: 7,
          name: "Bruce Wayne",
          slug: "bruce-wayne",
          modified: "2026-01-01T00:00:00Z",
        ),
      ], count: 1);

      final retrieved = await cache.get("character_list:p1");
      expect(retrieved?.first.id, 7);
      expect(retrieved?.first.name, "Bruce Wayne");
      expect(retrieved?.first.slug, "bruce-wayne");
      expect(retrieved?.first.modified, "2026-01-01T00:00:00Z");
    });

    test("reading list pages round-trip every field", () async {
      final cache = PagedLocalCache<ReadingListDto>(
        db: db,
        cacheKeyPrefix: "reading_list",
        entityType: "reading_list",
        fromJson: ReadingListDto.fromJson,
        toJson: (list) => list.toJson(),
      );
      const saved = ReadingListDto(
        id: 3,
        name: "Best of 2026",
        slug: "best-of-2026",
        listType: "editorial",
        isPrivate: false,
        attributionSource: "staff",
        averageRating: 4.5,
        ratingCount: 12,
        modified: "2026-05-05T00:00:00Z",
      );
      await cache.cache("reading_list:p1", const [saved], count: 1);

      final retrieved = await cache.get("reading_list:p1");
      expect(retrieved?.first.id, 3);
      expect(retrieved?.first.name, "Best of 2026");
      expect(retrieved?.first.slug, "best-of-2026");
      expect(retrieved?.first.listType, "editorial");
      expect(retrieved?.first.isPrivate, false);
      expect(retrieved?.first.attributionSource, "staff");
      expect(retrieved?.first.averageRating, 4.5);
      expect(retrieved?.first.ratingCount, 12);
      expect(retrieved?.first.modified, "2026-05-05T00:00:00Z");
    });

    test("release pages (withMeta: false) report no meta", () async {
      final cache = PagedLocalCache<IssueListDto>(
        db: db,
        cacheKeyPrefix: "weekly_releases",
        entityType: "weekly_releases",
        fromJson: IssueListDto.fromJson,
        toJson: (issue) => issue.toJson(),
        withMeta: false,
      );
      await cache.cache("2026-8-23", const [
        IssueListDto(id: 1, number: "1", series: null, image: null),
      ]);

      expect(await cache.get("2026-8-23"), hasLength(1));
      expect(await cache.meta("2026-8-23"), isNull);
      expect(await cache.cachedAt("2026-8-23"), isNotNull);
    });
  });
}
