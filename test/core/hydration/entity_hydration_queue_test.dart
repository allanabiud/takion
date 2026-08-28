import "package:dio/dio.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:takion/src/core/cache/entity_image_cache.dart";
import "package:takion/src/core/hydration/entity_hydration_queue.dart";
import "package:takion/src/core/network/dio_client.dart";
import "package:takion/src/core/network/rate_limit_interceptor.dart";
import "package:takion/src/domain/entities.dart";
import "package:takion/src/domain/repositories.dart";
import "package:takion/src/presentation/providers/connectivity_provider.dart";
import "package:takion/src/presentation/providers/repository_providers.dart";

class MockCatalogRepository extends Mock implements CatalogRepository {}

class MockEntityImageCache extends Mock implements EntityImageCache {}

class MockRateLimitInterceptor extends Mock implements RateLimitInterceptor {}

void main() {
  late MockCatalogRepository mockRepo;
  late MockEntityImageCache mockImageCache;
  late MockRateLimitInterceptor mockRateLimit;
  late MetronMetadataCache metadataCache;
  late ProviderContainer container;

  setUp(() {
    mockRepo = MockCatalogRepository();
    mockImageCache = MockEntityImageCache();
    mockRateLimit = MockRateLimitInterceptor();
    metadataCache = MetronMetadataCache();

    when(() => mockRateLimit.state).thenReturn(
      const RateLimitState(
        sustainedLimit: 5000,
        sustainedRemaining: 4000,
        sustainedReset: 0,
        burstRemaining: 15,
        burstReset: 0,
        hasObservedHeaders: true,
      ),
    );

    when(
      () => mockImageCache.set(any(), any(), any()),
    ).thenAnswer((_) async {});

    container = ProviderContainer(
      overrides: [
        metronRepositoryProvider.overrideWithValue(mockRepo),
        entityImageCacheProvider.overrideWithValue(mockImageCache),
        rateLimitInterceptorProvider.overrideWithValue(mockRateLimit),
        metronMetadataCacheProvider.overrideWithValue(metadataCache),
        connectivityStatusProvider.overrideWith(
          (ref) => Stream.value(AppConnectivityStatus.online),
        ),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test("enqueues and deduplicates keys", () {
    final queue = container.read(entityHydrationQueueProvider);

    expect(queue.enqueue(HydrationEntityType.series, 101), isTrue);
    expect(queue.enqueue(HydrationEntityType.series, 101), isFalse); // duplicate
    expect(queue.enqueue(HydrationEntityType.series, -1), isFalse); // invalid id

    expect(queue.stats.queuedCount + queue.stats.inFlightCount, 1);
  });

  test("enqueueMany adds unique IDs only", () {
    final queue = container.read(entityHydrationQueueProvider);

    final added = queue.enqueueMany(HydrationEntityType.publisher, [1, 2, 2, 3]);
    expect(added, 3);
  });

  test("processes series hydration and populates metadata and image cache", () async {
    const seriesDetails = SeriesDetails(
      id: 201,
      name: "Saga",
      sortName: "Saga",
      volume: 1,
      yearBegan: 2012,
      issueCount: 60,
      image: "https://example.com/saga.jpg",
      publisher: SeriesDetailsNamedRef(id: 50, name: "Image Comics"),
    );

    when(() => mockRepo.getSeriesDetails(201)).thenAnswer((_) async => seriesDetails);

    final queue = container.read(entityHydrationQueueProvider);
    queue.enqueue(HydrationEntityType.series, 201);

    await pumpEventQueue();

    expect(metadataCache.getSeriesName(201), "Saga");
    expect(metadataCache.getPublisherName(50), "Image Comics");
    verify(() => mockImageCache.set("series", 201, "https://example.com/saga.jpg")).called(1);
    expect(queue.stats.succeededCount, 1);
  });

  test("marks 404 responses as notFound without continuous retry", () async {
    when(() => mockRepo.getSeriesDetails(999)).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: "/api/series/999/"),
        response: Response(
          requestOptions: RequestOptions(path: "/api/series/999/"),
          statusCode: 404,
        ),
        type: DioExceptionType.badResponse,
      ),
    );

    final queue = container.read(entityHydrationQueueProvider);
    queue.enqueue(HydrationEntityType.series, 999);

    await pumpEventQueue();

    expect(queue.getStatus(HydrationEntityType.series, 999), HydrationStatus.notFound);
    expect(queue.stats.failedCount, 1);

    // Attempting to enqueue again should be rejected
    expect(queue.enqueue(HydrationEntityType.series, 999), isFalse);
  });

  test("defers drain when rate limit burst is exhausted", () async {
    when(() => mockRateLimit.state).thenReturn(
      const RateLimitState(
        sustainedLimit: 5000,
        sustainedRemaining: 100,
        sustainedReset: 0,
        burstRemaining: 1, // Below minimum 3
        burstReset: 0,
        hasObservedHeaders: true,
      ),
    );

    final queue = container.read(entityHydrationQueueProvider);
    queue.enqueue(HydrationEntityType.character, 301);

    await pumpEventQueue();

    // Should stay queued and not in flight or completed
    expect(queue.getStatus(HydrationEntityType.character, 301), HydrationStatus.queued);
    expect(queue.stats.inFlightCount, 0);
    verifyNever(() => mockRepo.getCharacterDetails(any()));
  });
}
