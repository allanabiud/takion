import "package:dio/dio.dart";
import "package:flutter_test/flutter_test.dart";
import "package:takion/src/core/cache/cache_policy.dart";
import "package:takion/src/data/catalog/datasources/local/paged_local_cache.dart";
import "package:takion/src/data/catalog/repositories/primitives/entity_detail_repository.dart";
import "package:takion/src/data/catalog/repositories/primitives/paged_resource_repository.dart";

class SampleDto {
  const SampleDto(this.id, this.name);
  final int id;
  final String name;
}

class SampleEntity {
  const SampleEntity(this.id, this.name);
  final int id;
  final String name;
}

void main() {
  group("EntityDetailRepository", () {
    test("returns cached JSON when fresh without remote call", () async {
      var remoteCalled = false;
      final cachedJson = {"id": 1, "name": "Spider-Man"};

      final repo = EntityDetailRepository<SampleDto, SampleEntity>(
        resourceName: "character",
        cachePolicy: const CachePolicy(ttl: Duration(hours: 1)),
        getRemote: (id) async {
          remoteCalled = true;
          return Response(
            requestOptions: RequestOptions(path: "/"),
            data: cachedJson,
            statusCode: 200,
          );
        },
        getLocalCachedJson: (id) async => cachedJson,
        getCachedAt: (id) async => DateTime.now().subtract(const Duration(minutes: 5)),
        cacheLocalJson: (id, json) async {},
        dtoFromJson: (json) => SampleDto(json["id"] as int, json["name"] as String),
        dtoToEntity: (dto) => SampleEntity(dto.id, dto.name),
      );

      final result = await repo.getDetails(1);

      expect(result.id, 1);
      expect(result.name, "Spider-Man");
      expect(remoteCalled, isFalse);
    });

    test("fetches remote and caches when local cache is stale", () async {
      var remoteCalled = false;
      var cachedSaved = false;
      final remoteJson = {"id": 2, "name": "Batman"};

      final repo = EntityDetailRepository<SampleDto, SampleEntity>(
        resourceName: "character",
        cachePolicy: const CachePolicy(ttl: Duration(hours: 1)),
        getRemote: (id) async {
          remoteCalled = true;
          return Response(
            requestOptions: RequestOptions(path: "/"),
            data: remoteJson,
            statusCode: 200,
          );
        },
        getLocalCachedJson: (id) async => null,
        getCachedAt: (id) async => null,
        cacheLocalJson: (id, json) async {
          cachedSaved = true;
        },
        dtoFromJson: (json) => SampleDto(json["id"] as int, json["name"] as String),
        dtoToEntity: (dto) => SampleEntity(dto.id, dto.name),
      );

      final result = await repo.getDetails(2);

      expect(result.id, 2);
      expect(result.name, "Batman");
      expect(remoteCalled, isTrue);
      expect(cachedSaved, isTrue);
    });
  });

  group("PagedResourceRepository", () {
    test("returns local paged items when fresh", () async {
      var remoteCalled = false;
      final items = [const SampleDto(1, "A"), const SampleDto(2, "B")];

      final repo = PagedResourceRepository<SampleDto, List<SampleEntity>>(
        resourceName: "series_list",
        cachePolicy: const CachePolicy(ttl: Duration(hours: 1)),
        getLocalItems: (key) async => items,
        getLocalMeta: (key) async => const PageCacheMeta(count: 2),
        getCachedAt: (key) async => DateTime.now().subtract(const Duration(minutes: 10)),
        cacheLocal: (key, items, {required count, next, previous}) async {},
        getRemotePage: (key, token) async {
          remoteCalled = true;
          return (items: items, count: 2, next: null, previous: null);
        },
        dtoToEntity: (dtos, count, next, previous) =>
            dtos.map((d) => SampleEntity(d.id, d.name)).toList(),
      );

      final result = await repo.getPage("key_1");

      expect(result.length, 2);
      expect(remoteCalled, isFalse);
    });
  });
}
