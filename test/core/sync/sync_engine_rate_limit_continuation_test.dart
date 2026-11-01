import "package:drift/native.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:takion/src/core/network/metron_request_scheduler.dart";
import "package:takion/src/core/sync/outbox/outbox_executor.dart";
import "package:takion/src/core/sync/outbox/outbox_projection_applier.dart";
import "package:takion/src/core/sync/outbox/outbox_remote_dispatcher.dart";
import "package:takion/src/core/sync/sync_engine.dart";
import "package:takion/src/data/collection/datasources/remote/metron_collection_remote_data_source.dart";
import "package:takion/src/data/common/drift/database.dart";
import "package:takion/src/data/pull_list/datasources/remote/metron_pull_list_remote_data_source.dart";
import "package:takion/src/data/wishlist/datasources/remote/metron_wishlist_remote_data_source.dart";

class MockCollectionRemote extends Mock
    implements MetronCollectionRemoteDataSource {}

class MockPullListRemote extends Mock
    implements MetronPullListRemoteDataSource {}

class MockWishlistRemote extends Mock
    implements MetronWishlistRemoteDataSource {}

/// Phase 5 Step 1: a run that starts inside a rate-limit blackout must yield
/// immediately and reschedule the durable job at the reset time instead of
/// burning quota on requests that would 429 anyway.
void main() {
  late AppDatabase db;
  const local = "local-user";

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  SyncEngine buildEngine(MetronRequestScheduler? scheduler) {
    final outboxDao = db.outboxDao;
    final dispatcher = OutboxRemoteDispatcher(
      collectionRemote: MockCollectionRemote(),
      pullListRemote: MockPullListRemote(),
      wishlistRemote: MockWishlistRemote(),
    );
    final executor = OutboxExecutor(
      db: db,
      outboxDao: outboxDao,
      dispatcher: dispatcher,
      projectionApplier: OutboxProjectionApplier(db),
    );
    final engine = SyncEngine(
      leaseDao: db.syncLeaseDao,
      jobDao: db.syncJobDao,
      outboxDao: outboxDao,
      outboxExecutor: executor,
      adapters: const [],
      scheduler: scheduler,
      runnerId: "test-runner",
    );
    addTearDown(engine.dispose);
    return engine;
  }

  Future<SyncJob?> jobRow(String id) {
    return (db.select(
      db.syncJobs,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  group("SyncEngine rate-limit continuation", () {
    test(
      "run yields immediately and reschedules the job at the reset time",
      () async {
        final scheduler = MetronRequestScheduler();
        addTearDown(scheduler.dispose);
        scheduler.noteRetryAfter(const Duration(seconds: 120));
        final blockedUntil = scheduler.rateLimitedUntil!;
        expect(blockedUntil, isNotNull);

        final engine = buildEngine(scheduler);
        final jobId = await db.syncJobDao.enqueueOrMerge(
          accountId: local,
          reason: "manual",
        );

        final result = await engine.runDueWork(trigger: "manual", jobId: jobId);

        expect(result.status, SyncEngineStatus.yieldedRateLimit);
        expect(result.errorMessage, contains("Rate-limited until"));

        // The durable job survives as pending with a notBefore at the reset
        // time, so neither isolate fires into the blackout.
        final job = await jobRow(jobId);
        expect(job, isNotNull);
        expect(job!.state, "pending");
        expect(job.notBefore, isNotNull);
        expect(job.notBefore!.toUtc(), blockedUntil);
        expect(job.lastError, contains("Rate limit"));
        expect(job.finishedAt, isNull);
      },
    );

    test("requestSync defers its enqueued job while rate-limited", () async {
      final scheduler = MetronRequestScheduler();
      addTearDown(scheduler.dispose);
      scheduler.noteRetryAfter(const Duration(seconds: 300));
      final blockedUntil = scheduler.rateLimitedUntil!;

      final engine = buildEngine(scheduler);
      final result = await engine.requestSync(reason: "outbox_pending");

      expect(result.status, SyncEngineStatus.yieldedRateLimit);

      final jobs = await (db.select(
        db.syncJobs,
      )..where((t) => t.state.equals("pending"))).get();
      expect(jobs.length, 1);
      expect(jobs.first.notBefore!.toUtc(), blockedUntil);
    });

    test(
      "a cooldown that already elapsed lets the run proceed to success",
      () async {
        final scheduler = MetronRequestScheduler();
        addTearDown(scheduler.dispose);
        // Restore a snapshot whose cooldown expired a minute ago.
        scheduler.restoreState(
          RateLimitState(
            retryAfterUntil:
                DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000 - 60,
          ),
        );
        expect(scheduler.rateLimitedUntil, isNull);

        final engine = buildEngine(scheduler);
        final jobId = await db.syncJobDao.enqueueOrMerge(
          accountId: local,
          reason: "manual",
        );

        final result = await engine.runDueWork(trigger: "manual", jobId: jobId);

        expect(result.status, SyncEngineStatus.success);
        final job = await jobRow(jobId);
        expect(job!.state, "completed");
      },
    );

    test("run without a scheduler is unaffected", () async {
      final engine = buildEngine(null);
      final jobId = await db.syncJobDao.enqueueOrMerge(
        accountId: local,
        reason: "manual",
      );

      final result = await engine.runDueWork(trigger: "manual", jobId: jobId);

      expect(result.status, SyncEngineStatus.success);
      expect((await jobRow(jobId))!.state, "completed");
    });
  });
}
