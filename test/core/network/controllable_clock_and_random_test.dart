import "dart:math";

import "package:clock/clock.dart";
import "package:drift/native.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:takion/src/core/network/metron_dio_factory.dart";
import "package:takion/src/core/sync/outbox/outbox_executor.dart";
import "package:takion/src/core/sync/outbox/outbox_projection_applier.dart";
import "package:takion/src/core/sync/outbox/outbox_remote_dispatcher.dart";
import "package:takion/src/data/collection/datasources/remote/metron_collection_remote_data_source.dart";
import "package:takion/src/data/common/drift/daos/outbox_dao.dart";
import "package:takion/src/data/common/drift/database.dart";
import "package:takion/src/data/pull_list/datasources/remote/metron_pull_list_remote_data_source.dart";
import "package:takion/src/data/wishlist/datasources/remote/metron_wishlist_remote_data_source.dart";

import "../../helpers/fake_metron_http_adapter.dart";

class MockCollectionRemote extends Mock
    implements MetronCollectionRemoteDataSource {}

class MockPullListRemote extends Mock
    implements MetronPullListRemoteDataSource {}

class MockWishlistRemote extends Mock
    implements MetronWishlistRemoteDataSource {}

class FakeRandom implements Random {
  FakeRandom([this.fixedValue = 0]);
  final int fixedValue;

  @override
  bool nextBool() => false;

  @override
  double nextDouble() => 0.0;

  @override
  int nextInt(int max) => fixedValue % max;
}

void main() {
  group("Controllable Clock and Random Determinism", () {
    late AppDatabase db;
    late FakeMetronHttpAdapter fakeAdapter;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      fakeAdapter = FakeMetronHttpAdapter();
    });

    tearDown(() async {
      await db.close();
    });

    test(
      "buildMetronDio uses injected Clock and Random for deterministic 429 backoff",
      () async {
        final fixedInstant = DateTime.utc(2026, 10, 26, 12, 0, 0);
        final fixedClock = Clock.fixed(fixedInstant);
        final deterministicRandom = FakeRandom(50); // constant jitter

        final dio = buildMetronDio(
          readToken: () async => "test-token",
          db: db,
          random: deterministicRandom,
          clock: fixedClock,
        )..httpClientAdapter = fakeAdapter;

        // 429 reset in 1 second (12:00:01)
        final resetTimestamp =
            (fixedInstant.millisecondsSinceEpoch ~/ 1000) + 1;
        fakeAdapter.enqueue429(
          retryAfterSeconds: 1,
          resetTimestamp: resetTimestamp,
        );
        fakeAdapter.enqueueJsonResponse(200, {"id": 1, "success": true});

        // Execute request with deterministic backoff
        final response = await dio.get("issue/1/");
        expect(response.statusCode, 200);
        expect(fakeAdapter.recordedRequests.length, 2);
      },
    );

    test(
      "OutboxExecutor uses injected Clock and Random for deterministic budget & jitter",
      () async {
        final fixedInstant = DateTime.utc(2026, 10, 26, 12, 0, 0);
        final fixedClock = Clock.fixed(fixedInstant);
        final fixedRandom = FakeRandom(0);

        final executor = OutboxExecutor(
          db: db,
          outboxDao: OutboxDao(db),
          dispatcher: OutboxRemoteDispatcher(
            collectionRemote: MockCollectionRemote(),
            pullListRemote: MockPullListRemote(),
            wishlistRemote: MockWishlistRemote(),
          ),
          projectionApplier: OutboxProjectionApplier(db),
          clock: fixedClock,
          random: fixedRandom,
        );

        final result = await executor.drain(
          accountId: "default",
          budget: const Duration(seconds: 30),
        );

        expect(result.completedCount, 0);
        expect(result.stoppedDueToRateLimit, isFalse);
      },
    );
  });
}
