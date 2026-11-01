import "package:drift/drift.dart";
import "package:takion/src/data/common/drift/database.dart";
import "package:uuid/uuid.dart";

class SyncJobDao extends DatabaseAccessor<AppDatabase> {
  SyncJobDao(super.db);

  static const _uuid = Uuid();

  Future<void> upsert(SyncJobsCompanion job) =>
      into(attachedDatabase.syncJobs).insertOnConflictUpdate(job);

  /// Enqueues a sync job or merges it into an existing pending/running job
  /// for the same account and resource scope.
  Future<String> enqueueOrMerge({
    required String accountId,
    required String reason,
    String? resource,
    int priority = 0,
    DateTime? notBefore,
  }) {
    final now = DateTime.now().toUtc();
    return transaction(() async {
      final query = select(attachedDatabase.syncJobs)
        ..where(
          (t) =>
              t.accountId.equals(accountId) &
              t.state.isIn(const ["pending", "running"]),
        );

      if (resource != null) {
        query.where((t) => t.resource.equals(resource));
      } else {
        query.where((t) => t.resource.isNull());
      }

      final existing = await query.getSingleOrNull();
      if (existing != null) {
        final mergedPriority = priority > existing.priority
            ? priority
            : existing.priority;
        final mergedNotBefore = existing.notBefore == null
            ? notBefore
            : (notBefore == null
                  ? existing.notBefore
                  : (notBefore.isBefore(existing.notBefore!)
                        ? notBefore
                        : existing.notBefore));

        await (update(
          attachedDatabase.syncJobs,
        )..where((t) => t.id.equals(existing.id))).write(
          SyncJobsCompanion(
            priority: Value(mergedPriority),
            notBefore: Value(mergedNotBefore),
            reason: Value(
              existing.reason.contains(reason)
                  ? existing.reason
                  : "${existing.reason}, $reason",
            ),
            updatedAt: Value(now),
          ),
        );
        return existing.id;
      }

      final newId = _uuid.v4();
      await into(attachedDatabase.syncJobs).insert(
        SyncJobsCompanion.insert(
          id: newId,
          accountId: accountId,
          resource: Value(resource),
          reason: reason,
          priority: Value(priority),
          notBefore: Value(notBefore),
          state: const Value("pending"),
          createdAt: now,
          updatedAt: now,
        ),
      );
      return newId;
    });
  }

  Future<List<SyncJob>> getDue({
    required String accountId,
    DateTime? now,
    int limit = 20,
  }) {
    final reference = now ?? DateTime.now().toUtc();
    return (select(attachedDatabase.syncJobs)
          ..where(
            (t) =>
                t.accountId.equals(accountId) &
                t.state.equals("pending") &
                (t.notBefore.isNull() |
                    t.notBefore.isSmallerOrEqualValue(reference)),
          )
          ..orderBy([
            (t) => OrderingTerm.desc(t.priority),
            (t) => OrderingTerm.asc(t.createdAt),
          ])
          ..limit(limit))
        .get();
  }

  /// Atomically claims the next highest-priority due job, marking it 'running'.
  Future<SyncJob?> claimNext({required String accountId, DateTime? now}) {
    final reference = now ?? DateTime.now().toUtc();
    return transaction(() async {
      final due =
          await (select(attachedDatabase.syncJobs)
                ..where(
                  (t) =>
                      t.accountId.equals(accountId) &
                      t.state.equals("pending") &
                      (t.notBefore.isNull() |
                          t.notBefore.isSmallerOrEqualValue(reference)),
                )
                ..orderBy([
                  (t) => OrderingTerm.desc(t.priority),
                  (t) => OrderingTerm.asc(t.createdAt),
                ])
                ..limit(1))
              .get();

      if (due.isEmpty) return null;
      final job = due.first;
      final updateTime = DateTime.now().toUtc();

      await (update(
        attachedDatabase.syncJobs,
      )..where((t) => t.id.equals(job.id))).write(
        SyncJobsCompanion(
          state: const Value("running"),
          startedAt: Value(updateTime),
          updatedAt: Value(updateTime),
        ),
      );

      return job.copyWith(
        state: "running",
        startedAt: Value(updateTime),
        updatedAt: updateTime,
      );
    });
  }

  Future<void> completeJob(String id) {
    final now = DateTime.now().toUtc();
    return (update(
      attachedDatabase.syncJobs,
    )..where((t) => t.id.equals(id))).write(
      SyncJobsCompanion(
        state: const Value("completed"),
        finishedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  Future<void> failJob(String id, {String? error, DateTime? retryAt}) {
    final now = DateTime.now().toUtc();
    return (update(
      attachedDatabase.syncJobs,
    )..where((t) => t.id.equals(id))).write(
      SyncJobsCompanion(
        state: Value(retryAt != null ? "pending" : "failed"),
        notBefore: Value(retryAt),
        lastError: Value(error),
        finishedAt: retryAt == null ? Value(now) : const Value.absent(),
        updatedAt: Value(now),
      ),
    );
  }

  Future<void> updateState(String id, String state, {String? error}) =>
      (update(attachedDatabase.syncJobs)..where((t) => t.id.equals(id))).write(
        SyncJobsCompanion(
          state: Value(state),
          lastError: Value(error),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );

  Stream<int> watchPendingCount({String? accountId}) {
    final count = attachedDatabase.syncJobs.id.count();
    final query = selectOnly(attachedDatabase.syncJobs)
      ..addColumns([count])
      ..where(attachedDatabase.syncJobs.state.equals("pending"));
    if (accountId != null) {
      query.where(attachedDatabase.syncJobs.accountId.equals(accountId));
    }
    return query.map((row) => row.read(count) ?? 0).watchSingle();
  }
}
