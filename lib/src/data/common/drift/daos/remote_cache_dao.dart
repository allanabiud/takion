import "package:drift/drift.dart";
import "package:takion/src/data/common/drift/database.dart";

class RemoteCacheDao extends DatabaseAccessor<AppDatabase> {
  RemoteCacheDao(super.db);

  Future<RemoteCacheEntry?> get(String accountId, String cacheKey) =>
      (select(attachedDatabase.remoteCacheEntries)..where(
            (t) => t.accountId.equals(accountId) & t.cacheKey.equals(cacheKey),
          ))
          .getSingleOrNull();

  Future<RemoteCacheEntry?> getEntry(
    String accountId,
    String cacheKey, {
    bool touch = false,
  }) async {
    final entry = await get(accountId, cacheKey);
    if (entry != null && touch) {
      await touchEntry(accountId, cacheKey);
    }
    return entry;
  }

  Future<void> upsert(RemoteCacheEntriesCompanion entry) =>
      into(attachedDatabase.remoteCacheEntries).insertOnConflictUpdate(entry);

  Future<void> upsertEntry({
    required String accountId,
    required String cacheKey,
    String? etag,
    String? lastModified,
    String? payloadJson,
    required DateTime fetchedAt,
    required DateTime staleAt,
    DateTime? lastAccessedAt,
    bool isPinned = false,
  }) {
    final accessed = lastAccessedAt ?? DateTime.now().toUtc();
    return upsert(
      RemoteCacheEntriesCompanion(
        accountId: Value(accountId),
        cacheKey: Value(cacheKey),
        etag: Value(etag),
        lastModified: Value(lastModified),
        payloadJson: Value(payloadJson),
        fetchedAt: Value(fetchedAt),
        staleAt: Value(staleAt),
        lastAccessedAt: Value(accessed),
        isPinned: Value(isPinned),
      ),
    );
  }

  Future<void> touchEntry(
    String accountId,
    String cacheKey, {
    DateTime? fetchedAt,
    DateTime? staleAt,
    DateTime? accessedAt,
  }) async {
    final now = accessedAt ?? DateTime.now().toUtc();
    final companion = RemoteCacheEntriesCompanion(
      lastAccessedAt: Value(now),
      fetchedAt: fetchedAt != null ? Value(fetchedAt) : const Value.absent(),
      staleAt: staleAt != null ? Value(staleAt) : const Value.absent(),
    );
    await (update(attachedDatabase.remoteCacheEntries)..where(
          (t) => t.accountId.equals(accountId) & t.cacheKey.equals(cacheKey),
        ))
        .write(companion);
  }

  Future<void> setPinned(
    String accountId,
    String cacheKey,
    bool isPinned,
  ) async {
    await (update(attachedDatabase.remoteCacheEntries)..where(
          (t) => t.accountId.equals(accountId) & t.cacheKey.equals(cacheKey),
        ))
        .write(RemoteCacheEntriesCompanion(isPinned: Value(isPinned)));
  }

  Future<void> pinEntries(
    String accountId,
    Iterable<String> cacheKeys,
    bool isPinned,
  ) async {
    if (cacheKeys.isEmpty) return;
    await (update(attachedDatabase.remoteCacheEntries)..where(
          (t) => t.accountId.equals(accountId) & t.cacheKey.isIn(cacheKeys),
        ))
        .write(RemoteCacheEntriesCompanion(isPinned: Value(isPinned)));
  }

  Future<int> deleteExpired({
    required String accountId,
    required DateTime before,
  }) => evictStale(accountId: accountId, before: before);

  Future<int> evictStale({
    required String accountId,
    required DateTime before,
  }) =>
      (delete(attachedDatabase.remoteCacheEntries)..where(
            (t) =>
                t.accountId.equals(accountId) &
                t.staleAt.isSmallerThanValue(before) &
                t.isPinned.equals(false),
          ))
          .go();

  Future<int> evictLru({
    required String accountId,
    required int maxEntries,
  }) async {
    final countQuery = selectOnly(attachedDatabase.remoteCacheEntries)
      ..addColumns([attachedDatabase.remoteCacheEntries.cacheKey.count()])
      ..where(
        attachedDatabase.remoteCacheEntries.accountId.equals(accountId) &
            attachedDatabase.remoteCacheEntries.isPinned.equals(false),
      );
    final count =
        await countQuery
            .map(
              (row) => row.read(
                attachedDatabase.remoteCacheEntries.cacheKey.count(),
              ),
            )
            .getSingle() ??
        0;
    if (count <= maxEntries) return 0;

    final excess = count - maxEntries;
    final oldest =
        await (select(attachedDatabase.remoteCacheEntries)
              ..where(
                (t) => t.accountId.equals(accountId) & t.isPinned.equals(false),
              )
              ..orderBy([(t) => OrderingTerm.asc(t.lastAccessedAt)])
              ..limit(excess))
            .get();

    if (oldest.isEmpty) return 0;
    final keysToDelete = oldest.map((e) => e.cacheKey).toList();
    return (delete(attachedDatabase.remoteCacheEntries)..where(
          (t) => t.accountId.equals(accountId) & t.cacheKey.isIn(keysToDelete),
        ))
        .go();
  }

  Future<int> clearAll(String accountId, {bool includePinned = false}) =>
      (delete(attachedDatabase.remoteCacheEntries)..where(
            (t) =>
                t.accountId.equals(accountId) &
                (includePinned
                    ? const Constant(true)
                    : t.isPinned.equals(false)),
          ))
          .go();
}
