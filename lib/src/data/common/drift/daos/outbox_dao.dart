import "dart:convert";

import "package:drift/drift.dart";
import "package:takion/src/core/commands/outbox_constants.dart";
import "package:takion/src/data/common/drift/database.dart";
import "package:uuid/uuid.dart";

/// One-shot snapshot of outbox queue health for diagnostics/telemetry.
class OutboxQueueTelemetry {
  const OutboxQueueTelemetry({
    required this.pendingCount,
    required this.oldestAge,
  });

  /// Number of operations in pending/retry/running states.
  final int pendingCount;

  /// Age of the oldest still-pending operation.
  final Duration oldestAge;

  Map<String, dynamic> toJson() => {
    "pendingCount": pendingCount,
    "oldestAgeMinutes": oldestAge.inMinutes,
  };
}

/// Persistence primitives for the durable outbox.
/// Supports atomic writes, idempotent coalescing, dependency resolution,
/// and lease/claim execution transitions.
class OutboxDao extends DatabaseAccessor<AppDatabase> {
  OutboxDao(super.db);

  static const _uuid = Uuid();

  Future<void> upsert(OutboxOperationsCompanion operation) =>
      into(attachedDatabase.outboxOperations).insertOnConflictUpdate(operation);

  Future<OutboxOperation?> getById(String id) => (select(
    attachedDatabase.outboxOperations,
  )..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> deleteById(String id) => (delete(
    attachedDatabase.outboxOperations,
  )..where((t) => t.id.equals(id))).go();

  Future<OutboxOperation?> getActiveByCoalesceKey({
    required String accountId,
    required String coalesceKey,
  }) {
    return (select(attachedDatabase.outboxOperations)
          ..where(
            (t) =>
                t.accountId.equals(accountId) &
                t.coalesceKey.equals(coalesceKey) &
                t.state.isIn(const [
                  OutboxState.pending,
                  OutboxState.retry,
                  OutboxState.blocked,
                ]),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<OutboxOperation?> getRunningByCoalesceKey({
    required String accountId,
    required String coalesceKey,
  }) {
    return (select(attachedDatabase.outboxOperations)
          ..where(
            (t) =>
                t.accountId.equals(accountId) &
                t.coalesceKey.equals(coalesceKey) &
                t.state.equals(OutboxState.running),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(1))
        .getSingleOrNull();
  }

  /// Claims the next ready outbox operation within a transaction,
  /// marking it [OutboxState.running] and incrementing attemptCount.
  /// Skips operations waiting on [dependsOnId].
  Future<OutboxOperation?> claimNextReady({
    required String accountId,
    DateTime? now,
  }) {
    final reference = now ?? DateTime.now().toUtc();
    return transaction(() async {
      final readyList =
          await (select(attachedDatabase.outboxOperations)
                ..where(
                  (t) =>
                      t.accountId.equals(accountId) &
                      t.state.isIn(const [
                        OutboxState.pending,
                        OutboxState.retry,
                      ]) &
                      (t.notBefore.isNull() |
                          t.notBefore.isSmallerOrEqualValue(reference)) &
                      t.dependsOnId.isNull(),
                )
                ..orderBy([(t) => OrderingTerm.asc(t.createdAt)])
                ..limit(1))
              .get();

      if (readyList.isEmpty) return null;
      final op = readyList.first;
      final newAttempt = op.attemptCount + 1;
      final updatedTime = DateTime.now().toUtc();

      await (update(
        attachedDatabase.outboxOperations,
      )..where((t) => t.id.equals(op.id))).write(
        OutboxOperationsCompanion(
          state: const Value(OutboxState.running),
          attemptCount: Value(newAttempt),
          updatedAt: Value(updatedTime),
        ),
      );

      return op.copyWith(
        state: OutboxState.running,
        attemptCount: newAttempt,
        updatedAt: updatedTime,
      );
    });
  }

  Future<List<OutboxOperation>> getReady({
    required String accountId,
    DateTime? now,
    int limit = 50,
  }) {
    final reference = now ?? DateTime.now().toUtc();
    return (select(attachedDatabase.outboxOperations)
          ..where(
            (t) =>
                t.accountId.equals(accountId) &
                t.state.isIn(const [OutboxState.pending, OutboxState.retry]) &
                (t.notBefore.isNull() |
                    t.notBefore.isSmallerOrEqualValue(reference)) &
                t.dependsOnId.isNull(),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)])
          ..limit(limit))
        .get();
  }

  Future<List<OutboxOperation>> getPendingEntries({
    String? accountId,
    int limit = 50,
  }) {
    final query = select(attachedDatabase.outboxOperations)
      ..where(
        (t) => t.state.isIn(const [
          OutboxState.pending,
          OutboxState.retry,
          OutboxState.running,
          OutboxState.blocked,
        ]),
      )
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
      ..limit(limit);
    if (accountId != null) {
      query.where((t) => t.accountId.equals(accountId));
    }
    return query.get();
  }

  Future<List<OutboxOperation>> getFailedEntries({String? accountId}) {
    final query = select(attachedDatabase.outboxOperations)
      ..where(
        (t) => t.state.isIn(const [OutboxState.blocked, OutboxState.conflict]),
      )
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    if (accountId != null) {
      query.where((t) => t.accountId.equals(accountId));
    }
    return query.get();
  }

  Future<int> clearFailedEntries({String? accountId}) {
    final query = delete(attachedDatabase.outboxOperations)
      ..where(
        (t) => t.state.isIn(const [OutboxState.blocked, OutboxState.conflict]),
      );
    if (accountId != null) {
      query.where((t) => t.accountId.equals(accountId));
    }
    return query.go();
  }

  Future<int> retryFailedEntries({String? accountId}) {
    final query = update(attachedDatabase.outboxOperations)
      ..where(
        (t) => t.state.isIn(const [OutboxState.blocked, OutboxState.conflict]),
      );
    if (accountId != null) {
      query.where((t) => t.accountId.equals(accountId));
    }
    return query.write(
      const OutboxOperationsCompanion(
        state: Value(OutboxState.pending),
        attemptCount: Value(0),
        notBefore: Value(null),
      ),
    );
  }

  Stream<int> watchPendingCount({String? accountId}) {
    final count = attachedDatabase.outboxOperations.id.count();
    final query = selectOnly(attachedDatabase.outboxOperations)
      ..addColumns([count])
      ..where(
        attachedDatabase.outboxOperations.state.isIn(const [
          OutboxState.pending,
          OutboxState.retry,
          OutboxState.running,
        ]),
      );
    if (accountId != null) {
      query.where(
        attachedDatabase.outboxOperations.accountId.equals(accountId),
      );
    }
    return query.map((row) => row.read(count) ?? 0).watchSingle();
  }

  /// One-shot queue telemetry for the diagnostics sheet: pending operation
  /// count and the age of the oldest pending operation. Unlike
  /// [watchPendingCount] this does not subscribe to table changes.
  Future<OutboxQueueTelemetry> getQueueTelemetry({
    String? accountId,
    DateTime? now,
  }) async {
    final reference = (now ?? DateTime.now().toUtc());
    final pendingStates = const [
      OutboxState.pending,
      OutboxState.retry,
      OutboxState.running,
    ];

    final countExpr = attachedDatabase.outboxOperations.id.count();
    final countQuery = selectOnly(attachedDatabase.outboxOperations)
      ..addColumns([countExpr])
      ..where(attachedDatabase.outboxOperations.state.isIn(pendingStates));
    if (accountId != null) {
      countQuery.where(
        attachedDatabase.outboxOperations.accountId.equals(accountId),
      );
    }
    final count = (await countQuery
        .map((row) => row.read(countExpr) ?? 0)
        .getSingle());

    if (count == 0) {
      return const OutboxQueueTelemetry(
        pendingCount: 0,
        oldestAge: Duration.zero,
      );
    }

    final oldestQuery = select(attachedDatabase.outboxOperations)
      ..where((t) => t.state.isIn(pendingStates))
      ..orderBy([(t) => OrderingTerm.asc(t.createdAt)])
      ..limit(1);
    if (accountId != null) {
      oldestQuery.where((t) => t.accountId.equals(accountId));
    }
    final oldest = await oldestQuery.getSingleOrNull();
    final age = oldest == null
        ? Duration.zero
        : reference.difference(oldest.createdAt.toUtc());

    return OutboxQueueTelemetry(
      pendingCount: count,
      oldestAge: age < Duration.zero ? Duration.zero : age,
    );
  }

  Stream<List<OutboxOperation>> watchByCoalesceKey({
    required String accountId,
    required String coalesceKey,
  }) {
    return (select(attachedDatabase.outboxOperations)
          ..where(
            (t) =>
                t.accountId.equals(accountId) &
                t.coalesceKey.equals(coalesceKey) &
                t.state.equals(OutboxState.done).not(),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  Future<void> updateState(
    String id, {
    required String state,
    DateTime? notBefore,
    String? errorCode,
    String? errorMessage,
    int? attemptCount,
  }) =>
      (update(
        attachedDatabase.outboxOperations,
      )..where((t) => t.id.equals(id))).write(
        OutboxOperationsCompanion(
          state: Value(state),
          notBefore: Value(notBefore),
          lastErrorCode: Value(errorCode),
          lastErrorMessage: Value(errorMessage),
          attemptCount: attemptCount == null
              ? const Value.absent()
              : Value(attemptCount),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );

  Future<void> finishAttempt(
    String id, {
    required String state,
    DateTime? notBefore,
    String? errorCode,
    String? errorMessage,
  }) => updateState(
    id,
    state: state,
    notBefore: notBefore,
    errorCode: errorCode,
    errorMessage: errorMessage,
  );

  Future<void> markDone(String id) =>
      (update(
        attachedDatabase.outboxOperations,
      )..where((t) => t.id.equals(id))).write(
        OutboxOperationsCompanion(
          state: const Value(OutboxState.done),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );

  Future<void> releaseDependents(String parentId, int remoteId) async {
    final now = DateTime.now().toUtc();
    final dependents = await (select(
      attachedDatabase.outboxOperations,
    )..where((t) => t.dependsOnId.equals(parentId))).get();

    for (final dep in dependents) {
      await (update(
        attachedDatabase.outboxOperations,
      )..where((t) => t.id.equals(dep.id))).write(
        OutboxOperationsCompanion(
          dependsOnId: const Value(null),
          entityRemoteId: Value(remoteId),
          updatedAt: Value(now),
        ),
      );
    }
  }

  /// Coalesces a create operation into the outbox.
  /// If an active operation already exists for this coalesce key:
  /// merges payload fields and resets to [OutboxState.pending].
  Future<OutboxOperation> coalesceCreate({
    required String accountId,
    required String entityType,
    required String entityLocalId,
    int? entityRemoteId,
    required String coalesceKey,
    required Map<String, dynamic> payload,
    String? baseRemoteModified,
    DateTime? notBefore,
  }) async {
    final now = DateTime.now().toUtc();
    final active = await getActiveByCoalesceKey(
      accountId: accountId,
      coalesceKey: coalesceKey,
    );

    if (active != null) {
      final existingPayload = Map<String, dynamic>.from(
        jsonDecode(active.payloadJson) as Map,
      );
      existingPayload.addAll(payload);

      final updated = active.copyWith(
        operation: OutboxOperationType.create,
        payloadJson: jsonEncode(existingPayload),
        state: OutboxState.pending,
        entityRemoteId: Value(entityRemoteId ?? active.entityRemoteId),
        baseRemoteModified: Value(
          baseRemoteModified ?? active.baseRemoteModified,
        ),
        updatedAt: now,
      );
      await upsert(updated.toCompanion(true));
      return updated;
    }

    final running = await getRunningByCoalesceKey(
      accountId: accountId,
      coalesceKey: coalesceKey,
    );

    final op = OutboxOperation(
      id: _uuid.v4(),
      accountId: accountId,
      entityType: entityType,
      entityLocalId: entityLocalId,
      entityRemoteId: entityRemoteId,
      operation: OutboxOperationType.create,
      payloadJson: jsonEncode(payload),
      coalesceKey: coalesceKey,
      dependsOnId: running?.id,
      state: OutboxState.pending,
      attemptCount: 0,
      notBefore: notBefore,
      baseRemoteModified: baseRemoteModified,
      createdAt: now,
      updatedAt: now,
    );
    await upsert(op.toCompanion(true));
    return op;
  }

  /// Coalesces a patch operation into the outbox.
  /// If an active create is pending, merges the patch directly into the create.
  /// If an active patch is pending, merges the patch fields.
  /// If an active operation is running, sets [dependsOnId] to that running operation.
  Future<OutboxOperation?> coalescePatch({
    required String accountId,
    required String entityType,
    required String entityLocalId,
    int? entityRemoteId,
    required String coalesceKey,
    required Map<String, dynamic> payload,
    String? baseRemoteModified,
    DateTime? notBefore,
  }) async {
    final now = DateTime.now().toUtc();
    final active = await getActiveByCoalesceKey(
      accountId: accountId,
      coalesceKey: coalesceKey,
    );

    if (active != null) {
      if (active.operation == OutboxOperationType.create) {
        final existingPayload = Map<String, dynamic>.from(
          jsonDecode(active.payloadJson) as Map,
        );
        existingPayload.addAll(payload);
        final updated = active.copyWith(
          payloadJson: jsonEncode(existingPayload),
          state: OutboxState.pending,
          updatedAt: now,
        );
        await upsert(updated.toCompanion(true));
        return updated;
      } else if (active.operation == OutboxOperationType.patch) {
        final existingPayload = Map<String, dynamic>.from(
          jsonDecode(active.payloadJson) as Map,
        );
        existingPayload.addAll(payload);
        final updated = active.copyWith(
          payloadJson: jsonEncode(existingPayload),
          state: OutboxState.pending,
          updatedAt: now,
        );
        await upsert(updated.toCompanion(true));
        return updated;
      }
    }

    final running = await getRunningByCoalesceKey(
      accountId: accountId,
      coalesceKey: coalesceKey,
    );

    final op = OutboxOperation(
      id: _uuid.v4(),
      accountId: accountId,
      entityType: entityType,
      entityLocalId: entityLocalId,
      entityRemoteId: entityRemoteId,
      operation: OutboxOperationType.patch,
      payloadJson: jsonEncode(payload),
      coalesceKey: coalesceKey,
      dependsOnId: running?.id,
      state: OutboxState.pending,
      attemptCount: 0,
      notBefore: notBefore,
      baseRemoteModified: baseRemoteModified,
      createdAt: now,
      updatedAt: now,
    );
    await upsert(op.toCompanion(true));
    return op;
  }

  /// Coalesces a delete operation into the outbox.
  /// If an active create is pending (never sent remotely), cancels it entirely!
  /// Returns null if cancelled, or the delete [OutboxOperation] if queued.
  Future<OutboxOperation?> coalesceDelete({
    required String accountId,
    required String entityType,
    required String entityLocalId,
    int? entityRemoteId,
    required String coalesceKey,
    String? baseRemoteModified,
  }) async {
    final now = DateTime.now().toUtc();
    final active = await getActiveByCoalesceKey(
      accountId: accountId,
      coalesceKey: coalesceKey,
    );

    if (active != null) {
      if (active.operation == OutboxOperationType.create) {
        // Never reached remote, delete outbox row and cancel
        await deleteById(active.id);
        return null;
      } else if (active.operation == OutboxOperationType.patch) {
        final updated = active.copyWith(
          operation: OutboxOperationType.delete,
          payloadJson: jsonEncode(<String, dynamic>{}),
          state: OutboxState.pending,
          updatedAt: now,
        );
        await upsert(updated.toCompanion(true));
        return updated;
      } else if (active.operation == OutboxOperationType.delete) {
        return active;
      }
    }

    final running = await getRunningByCoalesceKey(
      accountId: accountId,
      coalesceKey: coalesceKey,
    );

    final op = OutboxOperation(
      id: _uuid.v4(),
      accountId: accountId,
      entityType: entityType,
      entityLocalId: entityLocalId,
      entityRemoteId: entityRemoteId,
      operation: OutboxOperationType.delete,
      payloadJson: jsonEncode(<String, dynamic>{}),
      coalesceKey: coalesceKey,
      dependsOnId: running?.id,
      state: OutboxState.pending,
      attemptCount: 0,
      notBefore: null,
      baseRemoteModified: baseRemoteModified,
      createdAt: now,
      updatedAt: now,
    );
    await upsert(op.toCompanion(true));
    return op;
  }

  /// Coalesces a scrobble operation into the outbox.
  /// Updates pending scrobble for this issue if present.
  Future<OutboxOperation> coalesceScrobble({
    required String accountId,
    required int issueId,
    int? rating,
    DateTime? dateRead,
  }) async {
    final now = DateTime.now().toUtc();
    final coalesceKey = "scrobble:$issueId";
    final payload = <String, dynamic>{
      "issue": issueId,
      if (rating != null && rating > 0) "rating": rating,
      "date_read": (dateRead ?? now).toIso8601String().split("T").first,
    };

    final active = await getActiveByCoalesceKey(
      accountId: accountId,
      coalesceKey: coalesceKey,
    );

    if (active != null) {
      final updated = active.copyWith(
        payloadJson: jsonEncode(payload),
        state: OutboxState.pending,
        updatedAt: now,
      );
      await upsert(updated.toCompanion(true));
      return updated;
    }

    final running = await getRunningByCoalesceKey(
      accountId: accountId,
      coalesceKey: coalesceKey,
    );

    final op = OutboxOperation(
      id: _uuid.v4(),
      accountId: accountId,
      entityType: OutboxEntityType.scrobble,
      entityLocalId: "scrobble-$issueId",
      entityRemoteId: issueId,
      operation: OutboxOperationType.scrobble,
      payloadJson: jsonEncode(payload),
      coalesceKey: coalesceKey,
      dependsOnId: running?.id,
      state: OutboxState.pending,
      attemptCount: 0,
      notBefore: null,
      createdAt: now,
      updatedAt: now,
    );
    await upsert(op.toCompanion(true));
    return op;
  }

  /// Coalesces a wishlist acquire into the outbox.
  Future<OutboxOperation> coalesceAcquire({
    required String accountId,
    required int wishlistRemoteId,
    required int issueId,
    required Map<String, dynamic> payload,
    String? dependsOnId,
  }) async {
    final now = DateTime.now().toUtc();
    final coalesceKey = "wishlist:$wishlistRemoteId";

    final op = OutboxOperation(
      id: _uuid.v4(),
      accountId: accountId,
      entityType: OutboxEntityType.wishlist,
      entityLocalId: "wish-$wishlistRemoteId",
      entityRemoteId: wishlistRemoteId,
      operation: OutboxOperationType.acquire,
      payloadJson: jsonEncode(payload),
      coalesceKey: coalesceKey,
      dependsOnId: dependsOnId,
      state: OutboxState.pending,
      attemptCount: 0,
      notBefore: null,
      createdAt: now,
      updatedAt: now,
    );
    await upsert(op.toCompanion(true));
    return op;
  }
}
