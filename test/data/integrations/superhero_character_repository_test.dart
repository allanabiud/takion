import "package:drift/native.dart";
import "package:flutter_test/flutter_test.dart";
import "package:takion/src/data/common/drift/database.dart";
import "package:takion/src/data/common/drift/daos/superhero_character_cache_dao.dart";
import "package:takion/src/data/integrations/superhero/dto/superhero_search_response_dto.dart";
import "package:takion/src/data/integrations/superhero/superhero_character_repository_impl.dart";
import "package:takion/src/data/integrations/superhero/superhero_remote_data_source.dart";

class FakeSuperHeroRemoteDataSource implements SuperHeroRemoteDataSource {
  FakeSuperHeroRemoteDataSource(this._resultsByQuery);

  final Map<String, SuperHeroSearchResponseDto> _resultsByQuery;
  int searchCalls = 0;

  @override
  Future<SuperHeroSearchResponseDto> search(String token, String name) async {
    searchCalls++;
    final normalized = normalizeSuperHeroName(name);
    for (final entry in _resultsByQuery.entries) {
      if (normalizeSuperHeroName(entry.key) == normalized) {
        return entry.value;
      }
    }
    return const SuperHeroSearchResponseDto(response: "error");
  }
}

SuperHeroSearchResponseDto _response(List<Map<String, dynamic>> results) {
  return SuperHeroSearchResponseDto.fromJson({
    "response": "success",
    "results-for": "batman",
    "results": results,
  });
}

Map<String, dynamic> _hero({
  String id = "70",
  String name = "Batman",
  String image = "https://example.com/batman.jpg",
}) {
  return {
    "id": id,
    "name": name,
    "powerstats": {
      "intelligence": "100",
      "strength": "26",
      "speed": "27",
      "durability": "50",
      "power": "47",
      "combat": "100",
    },
    "image": {"url": image},
  };
}

void main() {
  late AppDatabase db;
  late SuperheroCharacterCacheDao cacheDao;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    cacheDao = db.superheroCharacterCacheDao;
  });

  tearDown(() async {
    await db.close();
  });

  SuperHeroCharacterRepositoryImpl buildRepo(
    FakeSuperHeroRemoteDataSource remote,
  ) {
    return SuperHeroCharacterRepositoryImpl(
      remoteDataSource: remote,
      cacheDao: cacheDao,
      getToken: () async => "test-token",
    );
  }

  test("exact normalized name match wins over other results", () async {
    final remote = FakeSuperHeroRemoteDataSource({
      "batman": _response([_hero(name: "Batman Beyond"), _hero(name: "Batman")]),
    });

    final repo = buildRepo(remote);
    final result = await repo.getCharacter(1, "batman");

    expect(result, isNotNull);
    expect(result!.name, "Batman");
    expect(result.powerstats!.intelligence, 100);
    expect(remote.searchCalls, 1);
  });

  test("first-result fallback when no exact match", () async {
    final remote = FakeSuperHeroRemoteDataSource({
      "Spider-Man (Peter Parker)": _response([
        _hero(id: "620", name: "Spider-Man"),
      ]),
    });

    final repo = buildRepo(remote);
    final result = await repo.getCharacter(2, "Spider-Man (Peter Parker)");

    expect(result, isNotNull);
    expect(result!.name, "Spider-Man");
  });

  test("returns null when search returns no results", () async {
    final remote = FakeSuperHeroRemoteDataSource({
      "unknown": _response([]),
    });

    final repo = buildRepo(remote);
    final result = await repo.getCharacter(3, "Unknown Character");

    expect(result, isNull);
  });

  test("returns null when token is missing", () async {
    final remote = FakeSuperHeroRemoteDataSource({});
    final repo = SuperHeroCharacterRepositoryImpl(
      remoteDataSource: remote,
      cacheDao: cacheDao,
      getToken: () async => null,
    );

    final result = await repo.getCharacter(4, "batman");
    expect(result, isNull);
    expect(remote.searchCalls, 0);
  });

  test("caches match and does not re-search within TTL", () async {
    final remote = FakeSuperHeroRemoteDataSource({
      "batman": _response([_hero()]),
    });

    final repo = buildRepo(remote);

    final first = await repo.getCharacter(1, "batman");
    final second = await repo.getCharacter(1, "batman");

    expect(first, isNotNull);
    expect(second, isNotNull);
    expect(first!.id, second!.id);
    expect(remote.searchCalls, 1);
  });

  test("forceRefresh bypasses cache", () async {
    final remote = FakeSuperHeroRemoteDataSource({
      "batman": _response([_hero()]),
    });

    final repo = buildRepo(remote);

    await repo.getCharacter(1, "batman");
    await repo.getCharacter(1, "batman", forceRefresh: true);

    expect(remote.searchCalls, 2);
  });

  test("cached powerstats survive DB round-trip", () async {
    final remote = FakeSuperHeroRemoteDataSource({
      "batman": _response([_hero()]),
    });

    final repo = buildRepo(remote);
    final first = await repo.getCharacter(5, "batman");

    expect(first, isNotNull);
    expect(first!.powerstats!.combat, 100);

    final cached = await cacheDao.getByMetronCharacterId(5);
    expect(cached, isNotNull);
    expect(cached!.powerstatsJson, contains('"combat":100'));
  });

  test("validateToken delegates to search and checks success", () async {
    final remote = FakeSuperHeroRemoteDataSource({
      "batman": _response([_hero()]),
    });
    final repo = buildRepo(remote);

    final valid = await repo.validateToken("test-token");
    expect(valid, isTrue);
    expect(remote.searchCalls, 1);
  });
}
