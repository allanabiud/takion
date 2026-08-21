import "package:drift/drift.dart" hide isNull, isNotNull;
import "package:drift/native.dart";
import "package:flutter_test/flutter_test.dart";
import "package:takion/src/core/cache/metron_metadata_cache.dart";
import "package:takion/src/data/common/drift/database.dart";

void main() {
  late AppDatabase db;
  late MetronMetadataCache cache;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    cache = MetronMetadataCache();
  });

  tearDown(() async {
    await db.close();
  });

  test("indexes entity names in memory synchronously", () {
    cache.indexSeries(1, "Batman");
    cache.indexPublisher(10, "DC Comics");
    cache.indexCharacter(100, "Bruce Wayne");
    cache.indexCreator(1000, "Bob Kane");
    cache.indexImprint(2000, "Vertigo");

    expect(cache.getSeriesName(1), equals("Batman"));
    expect(cache.getPublisherName(10), equals("DC Comics"));
    expect(cache.getCharacterName(100), equals("Bruce Wayne"));
    expect(cache.getCreatorName(1000), equals("Bob Kane"));
    expect(cache.getImprintName(2000), equals("Vertigo"));

    cache.clear();
    expect(cache.getSeriesName(1), isNull);
  });

  test("hydrates entity names from database tables", () async {
    await db.metronEntityDao.upsertSeriesStubsBatch([
      MetronSeriesCompanion.insert(
        id: const Value(1),
        name: "Spider-Man",
        isFullyHydrated: const Value(false),
      ),
    ]);
    await db.metronEntityDao.upsertPublisherStubsBatch([
      MetronPublishersCompanion.insert(
        id: const Value(2),
        name: "Marvel",
        isFullyHydrated: const Value(false),
      ),
    ]);

    await cache.hydrateFromDatabase(db.metronEntityDao);

    expect(cache.getSeriesName(1), equals("Spider-Man"));
    expect(cache.getPublisherName(2), equals("Marvel"));
  });
}
