import "package:drift/drift.dart";
import "package:takion/src/data/common/drift/database.dart";

/// A database-backed lease ensuring that foreground and background Workmanager isolates
/// cannot concurrently execute sync jobs for the same account.
class SyncLeaseDao extends DatabaseAccessor<AppDatabase> {
  SyncLeaseDao(super.db);

  Future<SyncLease?> get(String name) => (select(
    attachedDatabase.syncLeases,
  )..where((t) => t.name.equals(name))).getSingleOrNull();

  /// Tries to acquire the lease named [name] for [ownerId].
  /// Returns `true` if acquired (new lease, expired lease, or re-acquired by same owner).
  /// Returns `false` if another owner holds an active, non-expired lease.
  Future<bool> tryAcquire({
    required String name,
    required String ownerId,
    required Duration ttl,
    DateTime? now,
  }) {
    final reference = now ?? DateTime.now().toUtc();
    return transaction(() async {
      final existing = await (select(
        attachedDatabase.syncLeases,
      )..where((t) => t.name.equals(name))).getSingleOrNull();

      if (existing == null ||
          existing.expiresAt.isBefore(reference) ||
          existing.ownerId == ownerId) {
        await into(attachedDatabase.syncLeases).insertOnConflictUpdate(
          SyncLeasesCompanion.insert(
            name: name,
            ownerId: ownerId,
            expiresAt: reference.add(ttl),
            heartbeatAt: reference,
          ),
        );
        return true;
      }
      return false;
    });
  }

  /// Refreshes the expiration timestamp on an active lease held by [ownerId].
  Future<bool> heartbeat({
    required String name,
    required String ownerId,
    required Duration ttl,
    DateTime? now,
  }) {
    final reference = now ?? DateTime.now().toUtc();
    return transaction(() async {
      final existing = await (select(
        attachedDatabase.syncLeases,
      )..where((t) => t.name.equals(name))).getSingleOrNull();

      if (existing != null && existing.ownerId == ownerId) {
        await (update(
          attachedDatabase.syncLeases,
        )..where((t) => t.name.equals(name) & t.ownerId.equals(ownerId))).write(
          SyncLeasesCompanion(
            expiresAt: Value(reference.add(ttl)),
            heartbeatAt: Value(reference),
          ),
        );
        return true;
      }
      return false;
    });
  }

  /// Releases the lease if currently held by [ownerId].
  Future<void> release(String name, String ownerId) => (delete(
    attachedDatabase.syncLeases,
  )..where((t) => t.name.equals(name) & t.ownerId.equals(ownerId))).go();
}
