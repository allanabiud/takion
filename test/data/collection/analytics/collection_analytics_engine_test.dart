import "package:drift/drift.dart" hide isNotNull, isNull;
import "package:drift/native.dart";
import "package:flutter_test/flutter_test.dart";
import "package:takion/src/data/collection/analytics/collection_analytics_engine.dart";
import "package:takion/src/data/common/drift/database.dart";
import "package:takion/src/domain/collection/entities/collection_analytics.dart";

void main() {
  late AppDatabase db;
  late CollectionAnalyticsEngine engine;

  // Fixed "now" so streak/velocity/goal windows are deterministic:
  // Wednesday 2026-09-23, noon UTC.
  final now = DateTime.utc(2026, 9, 23, 12);

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    engine = CollectionAnalyticsEngine(db);
  });

  tearDown(() async {
    await db.close();
  });

  Value<String> present(String? value) =>
      value == null ? const Value.absent() : Value(value);

  Value<int> presentInt(int? value) =>
      value == null ? const Value.absent() : Value(value);

  Value<double> presentDouble(double? value) =>
      value == null ? const Value.absent() : Value(value);

  Future<void> insertLibraryItem({
    required int issueId,
    int? seriesId,
    bool isRead = false,
    String ownershipStatus = "owned",
    String? firstReadAt,
    double? pricePaid,
    int quantityOwned = 1,
    String? acquiredOn,
    String? purchaseDate,
  }) {
    return db.libraryItemDao.upsert(
      LibraryItemsCompanion.insert(
        id: "lib-$issueId",
        userId: "local-user",
        metronIssueId: issueId,
        metronSeriesId: seriesId ?? 0,
        ownershipStatus: ownershipStatus,
        isRead: isRead,
        format: "PRINT",
        createdAt: "2026-01-01T00:00:00.000Z",
        updatedAt: "2026-01-01T00:00:00.000Z",
        firstReadAt: present(firstReadAt),
        pricePaid: presentDouble(pricePaid),
        quantityOwned: Value(quantityOwned),
        acquiredOn: present(acquiredOn),
        purchaseDate: present(purchaseDate),
      ),
    );
  }

  Future<void> insertIssue(
    int id, {
    int? seriesId,
    int? publisherId,
    String number = "1",
  }) {
    return db.into(db.metronIssues).insert(
      MetronIssuesCompanion.insert(
        id: Value(id),
        number: number,
        seriesId: presentInt(seriesId),
        publisherId: presentInt(publisherId),
      ),
    );
  }

  Future<void> insertSeries(int id, String name, {int? publisherId}) {
    return db.into(db.metronSeries).insert(
      MetronSeriesCompanion.insert(
        id: Value(id),
        name: name,
        publisherId: presentInt(publisherId),
      ),
    );
  }

  Future<void> insertPublisher(int id, String name) => db
      .into(db.metronPublishers)
      .insert(MetronPublishersCompanion.insert(id: Value(id), name: name));

  Future<void> insertCreator(int id, String name) => db
      .into(db.metronCreators)
      .insert(MetronCreatorsCompanion.insert(id: Value(id), name: name));

  Future<void> insertCharacter(int id, String name) => db
      .into(db.metronCharacters)
      .insert(MetronCharactersCompanion.insert(id: Value(id), name: name));

  Future<void> creditCreator(int issueId, int creatorId) => db
      .into(db.issueCreators)
      .insert(
        IssueCreatorsCompanion.insert(issueId: issueId, creatorId: creatorId),
      );

  Future<void> tagCharacter(int issueId, int characterId) => db
      .into(db.issueCharacters)
      .insert(
        IssueCharactersCompanion.insert(
          issueId: issueId,
          characterId: characterId,
        ),
      );

  group("reading streaks", () {
    test("empty library has no streak", () async {
      final streak = await engine.getReadingStreak(now: now);
      expect(streak.currentDays, 0);
      expect(streak.longestDays, 0);
    });

    test("separates the active run from the record run", () async {
      // Record run: five consecutive days in August.
      for (var day = 25; day <= 29; day++) {
        await insertLibraryItem(
          issueId: 100 + day,
          isRead: true,
          firstReadAt: "2026-08-${day}T12:00:00.000Z",
        );
      }
      // Active run: today and the two preceding days (gap before it).
      await insertLibraryItem(
        issueId: 201,
        isRead: true,
        firstReadAt: "2026-09-21T10:00:00.000Z",
      );
      await insertLibraryItem(
        issueId: 202,
        isRead: true,
        firstReadAt: "2026-09-22T10:00:00.000Z",
      );
      await insertLibraryItem(
        issueId: 203,
        isRead: true,
        firstReadAt: "2026-09-23T10:00:00.000Z",
      );
      // Unread rows never count, even with a read date attached.
      await insertLibraryItem(
        issueId: 301,
        isRead: false,
        firstReadAt: "2026-09-23T11:00:00.000Z",
      );

      final streak = await engine.getReadingStreak(now: now);
      expect(streak.currentDays, 3);
      expect(streak.longestDays, 5);
    });

    test("an old last read breaks the active streak but not the record",
        () async {
      await insertLibraryItem(
        issueId: 1,
        isRead: true,
        firstReadAt: "2026-09-19T10:00:00.000Z",
      );
      await insertLibraryItem(
        issueId: 2,
        isRead: true,
        firstReadAt: "2026-09-20T10:00:00.000Z",
      );

      final streak = await engine.getReadingStreak(now: now);
      expect(streak.currentDays, 0);
      expect(streak.longestDays, 2);
    });

    test("watch re-emits when a new read lands", () async {
      final future = engine
          .watchReadingStreak(now: now)
          .firstWhere((streak) => streak.currentDays == 1)
          .timeout(const Duration(seconds: 5));

      await Future<void>.delayed(const Duration(milliseconds: 50));
      await insertLibraryItem(
        issueId: 1,
        isRead: true,
        firstReadAt: "2026-09-23T10:00:00.000Z",
      );

      final streak = await future;
      expect(streak.currentDays, 1);
      expect(streak.longestDays, 1);
    });
  });

  group("reading velocity", () {
    test("averages reads per week since the first read", () async {
      var issueId = 1;
      for (final readAt in [
        "2026-08-26T12:00:00.000Z", // exactly 28 days before `now`
        "2026-09-01T12:00:00.000Z",
        "2026-09-10T12:00:00.000Z",
        "2026-09-22T12:00:00.000Z",
      ]) {
        await insertLibraryItem(
          issueId: issueId++,
          isRead: true,
          firstReadAt: readAt,
        );
      }

      final velocity = await engine.getReadingVelocity(now: now);
      expect(velocity.totalReads, 4);
      expect(velocity.avgIssuesPerWeek, closeTo(1.0, 0.01));
      expect(velocity.since, DateTime.parse("2026-08-26T12:00:00.000Z"));
    });

    test("clamps the span to at least one week", () async {
      await insertLibraryItem(
        issueId: 1,
        isRead: true,
        firstReadAt: "2026-09-21T12:00:00.000Z",
      );
      await insertLibraryItem(
        issueId: 2,
        isRead: true,
        firstReadAt: "2026-09-22T12:00:00.000Z",
      );

      final velocity = await engine.getReadingVelocity(now: now);
      expect(velocity.totalReads, 2);
      expect(velocity.avgIssuesPerWeek, closeTo(2.0, 0.01));
    });

    test("empty library has zero velocity", () async {
      final velocity = await engine.getReadingVelocity(now: now);
      expect(velocity.totalReads, 0);
      expect(velocity.avgIssuesPerWeek, 0);
      expect(velocity.since, isNull);
    });
  });

  group("monthly reading totals", () {
    test("zero-fills the window and respects read/unread and bounds",
        () async {
      await insertLibraryItem(
        issueId: 1,
        isRead: true,
        firstReadAt: "2026-07-05T10:00:00.000Z",
      );
      await insertLibraryItem(
        issueId: 2,
        isRead: true,
        firstReadAt: "2026-09-10T10:00:00.000Z",
      );
      await insertLibraryItem(
        issueId: 3,
        isRead: true,
        firstReadAt: "2026-09-20T10:00:00.000Z",
      );
      await insertLibraryItem(
        issueId: 4,
        isRead: false,
        firstReadAt: "2026-09-15T10:00:00.000Z",
      );
      await insertLibraryItem(
        issueId: 5,
        isRead: true,
        firstReadAt: "2026-05-01T10:00:00.000Z",
      );

      final totals = await engine.getMonthlyReadingTotals(
        now: now,
        months: 3,
      );

      expect(totals, hasLength(3));
      expect(totals.map((t) => (t.year, t.month)), [
        (2026, 7),
        (2026, 8),
        (2026, 9),
      ]);
      expect(totals.map((t) => t.count), [1, 0, 2]);
    });
  });

  group("rankings", () {
    /// Shared fixture: owned issues {101,102,103,104,106,109}, a read-only
    /// row {108}, and an excluded wishlist row {105}.
    Future<void> seedRankings() async {
      await insertPublisher(1, "DC Comics");
      await insertPublisher(2, "Marvel");
      await insertSeries(10, "Batman", publisherId: 1);
      await insertSeries(11, "Spider-Man", publisherId: 2);
      await insertCreator(1, "Scott Snyder");
      await insertCreator(2, "Jim Lee");
      await insertCharacter(1, "Batman");
      await insertCharacter(2, "Spider-Man");

      for (final id in [101, 102, 103, 104, 105, 106, 107, 108, 109]) {
        // 106 carries an issue-level publisher override (Marvel).
        await insertIssue(
          id,
          seriesId: id == 104 || id == 108 ? 11 : 10,
          publisherId: id == 106 ? 2 : null,
        );
      }

      await insertLibraryItem(issueId: 101, seriesId: 10);
      await insertLibraryItem(issueId: 102, seriesId: 10);
      await insertLibraryItem(issueId: 103, seriesId: 10);
      await insertLibraryItem(issueId: 104, seriesId: 11);
      await insertLibraryItem(issueId: 105, seriesId: 10, ownershipStatus: "wishlist");
      await insertLibraryItem(issueId: 106, seriesId: 10);
      await insertLibraryItem(issueId: 107, seriesId: 10, ownershipStatus: "wishlist");
      await insertLibraryItem(issueId: 108, seriesId: 11, ownershipStatus: "unknown", isRead: true);
      await insertLibraryItem(issueId: 109, seriesId: 10);

      await creditCreator(101, 1);
      await creditCreator(102, 1);
      await creditCreator(103, 1);
      await creditCreator(104, 2);
      await creditCreator(108, 2);

      await tagCharacter(101, 1);
      await tagCharacter(102, 1);
      await tagCharacter(103, 1);
      await tagCharacter(105, 1); // wishlist row must not count
      await tagCharacter(104, 2);
      await tagCharacter(108, 2);
    }

    test("topPublishers counts owned/read issues per publisher", () async {
      await seedRankings();

      final publishers = await engine.topPublishers();
      expect(publishers, hasLength(2));
      // DC: 101,102,103,109 via series publisher.
      // Marvel: 104 (series), 108 (series), 106 (issue-level override).
      expect(publishers[0].name, "DC Comics");
      expect(publishers[0].count, 4);
      expect(publishers[1].name, "Marvel");
      expect(publishers[1].count, 3);

      final limited = await engine.topPublishers(limit: 1);
      expect(limited, hasLength(1));
      expect(limited.single.name, "DC Comics");
    });

    test("topSeries ranks by distinct collected/read issues", () async {
      await seedRankings();

      final series = await engine.topSeries();
      expect(series.map((s) => (s.name, s.count)), [
        ("Batman", 5), // 101,102,103,106,109
        ("Spider-Man", 2), // 104,108
      ]);
      expect(series.first.id, 10);
    });

    test("topCreators counts distinct issues per credited creator", () async {
      await seedRankings();

      final creators = await engine.topCreators();
      expect(creators.map((c) => (c.name, c.count)), [
        ("Scott Snyder", 3), // 101,102,103
        ("Jim Lee", 2), // 104,108
      ]);
    });

    test("topCharacters counts distinct issues and skips wishlist rows",
        () async {
      await seedRankings();

      final characters = await engine.topCharacters();
      expect(characters.map((c) => (c.name, c.count)), [
        ("Batman", 3), // 101,102,103 — 105 is wishlist, not counted
        ("Spider-Man", 2), // 104,108
      ]);
    });
  });

  group("spend time series", () {
    test("zero-fills monthly buckets by acquisition date", () async {
      await insertLibraryItem(
        issueId: 201,
        pricePaid: 10.0,
        quantityOwned: 2,
        acquiredOn: "2026-07-15T00:00:00.000Z",
      );
      await insertLibraryItem(
        issueId: 202,
        pricePaid: 5.5,
        purchaseDate: "2026-08-02", // purchase_date fallback
      );
      await insertLibraryItem(
        issueId: 203,
        acquiredOn: "2026-07-20T00:00:00.000Z", // no price → excluded
      );
      await insertLibraryItem(issueId: 204, pricePaid: 2.0); // created_at → Jan
      await insertLibraryItem(
        issueId: 205,
        pricePaid: 99.0,
        acquiredOn: "2026-11-01T00:00:00.000Z", // after `to` → excluded
      );

      final points = await engine.spendTimeSeries(
        from: DateTime.utc(2026, 1, 1),
        to: DateTime.utc(2026, 10, 1),
      );

      expect(points, hasLength(9)); // Jan..Sep, zero-filled
      expect(points.first.date, DateTime.utc(2026, 1, 1));
      expect(points.last.date, DateTime.utc(2026, 9, 1));
      expect(points[0].amount, closeTo(2.0, 0.001)); // Jan: created_at fallback
      expect(points[6].amount, closeTo(20.0, 0.001)); // Jul: 10.0 × 2
      expect(points[7].amount, closeTo(5.5, 0.001)); // Aug: purchase_date
      expect(points.where((p) => p.amount == 0), hasLength(6));
    });

    test("supports day buckets", () async {
      await insertLibraryItem(
        issueId: 201,
        pricePaid: 10.0,
        quantityOwned: 2,
        acquiredOn: "2026-07-15T00:00:00.000Z",
      );

      final points = await engine.spendTimeSeries(
        from: DateTime.utc(2026, 7, 14),
        to: DateTime.utc(2026, 7, 17),
        bucket: SpendBucket.day,
      );

      expect(points.map((p) => p.date), [
        DateTime.utc(2026, 7, 14),
        DateTime.utc(2026, 7, 15),
        DateTime.utc(2026, 7, 16),
      ]);
      expect(points[1].amount, closeTo(20.0, 0.001));
      expect(points[0].amount, 0);
      expect(points[2].amount, 0);
    });
  });

  group("reading goal progress", () {
    setUp(() async {
      var issueId = 900;
      for (final readAt in [
        "2026-03-05T10:00:00.000Z",
        "2026-09-10T10:00:00.000Z",
        "2026-09-20T10:00:00.000Z",
        "2025-11-01T10:00:00.000Z",
        "2025-12-15T10:00:00.000Z",
        "2027-01-05T10:00:00.000Z",
      ]) {
        await db.libraryItemDao.upsert(
          LibraryItemsCompanion.insert(
            id: "lib-goal-$issueId",
            userId: "local-user",
            metronIssueId: issueId++,
            metronSeriesId: 0,
            ownershipStatus: "owned",
            isRead: true,
            format: "PRINT",
            firstReadAt: Value(readAt),
            createdAt: "2026-01-01T00:00:00.000Z",
            updatedAt: "2026-01-01T00:00:00.000Z",
          ),
        );
      }
    });

    test("yearly goal counts only the current calendar year", () async {
      final progress = await engine.getReadingGoalProgress(
        target: 50,
        period: "yearly",
        now: now,
      );

      expect(progress.readCount, 3); // 2026 reads only
      expect(progress.from, DateTime.utc(2026, 1, 1));
      expect(progress.to, DateTime.utc(2027, 1, 1));
      expect(progress.percentComplete, closeTo(0.06, 0.001));
      expect(progress.achieved, isFalse);
    });

    test("goal is achieved once the target is reached", () async {
      final progress = await engine.getReadingGoalProgress(
        target: 2,
        period: "yearly",
        now: now,
      );
      expect(progress.achieved, isTrue);
      expect(progress.percentComplete, greaterThan(1.0));
    });

    test("monthly goal counts only the current calendar month", () async {
      final progress = await engine.getReadingGoalProgress(
        target: 10,
        period: "monthly",
        now: now,
      );
      expect(progress.readCount, 2); // Sep 10 and Sep 20 only
      expect(progress.from, DateTime.utc(2026, 9, 1));
      expect(progress.to, DateTime.utc(2026, 10, 1));
      expect(progress.achieved, isFalse);
    });

    test("a non-positive target cannot divide by zero or self-achieve",
        () async {
      final progress = await engine.getReadingGoalProgress(
        target: 0,
        period: "yearly",
        now: now,
      );
      expect(progress.percentComplete, 0);
      expect(progress.achieved, isFalse);
    });
  });
}
