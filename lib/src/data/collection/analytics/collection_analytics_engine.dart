import "package:drift/drift.dart";
import "package:takion/src/data/common/drift/database.dart";
import "package:takion/src/domain/collection/entities/collection_analytics.dart";

/// Fast local SQLite aggregations for collection and reading analytics.
///
/// Everything is computed in SQL over `library_items` (reading activity is
/// derived from `first_read_at`), so screens never load per-row data into
/// Dart just to count it. `watch*` variants re-emit whenever the underlying
/// tables change.
///
/// Ranking methods (`top*`) count distinct issues that are owned **or**
/// read, join through the normalized Metron catalog, and order by count
/// then name. A `limit` of 0 means "no limit".
class CollectionAnalyticsEngine {
  CollectionAnalyticsEngine(this._db);

  final AppDatabase _db;

  /// 1-based month/day helpers that keep comparisons lexicographic (ISO
  /// date prefixes sort chronologically).
  static String _datePrefix(DateTime time) {
    final u = time.toUtc();
    final month = u.month.toString().padLeft(2, "0");
    final day = u.day.toString().padLeft(2, "0");
    return "${u.year.toString().padLeft(4, "0")}-$month-$day";
  }

  static DateTime _atUtcStartOfDay(DateTime time) {
    final u = time.toUtc();
    return DateTime.utc(u.year, u.month, u.day);
  }

  // ---------------------------------------------------------------------------
  // Reading streaks
  // ---------------------------------------------------------------------------

  /// Gap-and-island streak query: distinct read days are grouped into
  /// consecutive runs via `julianday(day) - ROW_NUMBER()`; the longest run is
  /// the record streak and runs whose last day is yesterday or later are
  /// still active (a streak survives until the end of the following day).
  static const String _streakSql = """
    WITH days AS (
      SELECT DISTINCT substr(first_read_at, 1, 10) AS day
      FROM library_items
      WHERE is_read = 1 AND first_read_at IS NOT NULL
    ),
    grouped AS (
      SELECT day,
             julianday(day) - ROW_NUMBER() OVER (ORDER BY day) AS run_id
      FROM days
    ),
    runs AS (
      SELECT COUNT(*) AS len, MAX(day) AS end_day
      FROM grouped
      GROUP BY run_id
    )
    SELECT
      COALESCE((SELECT MAX(len) FROM runs), 0) AS longest_len,
      COALESCE((SELECT MAX(len) FROM runs WHERE end_day >= ?), 0) AS active_len
  """;

  Selectable<QueryRow> _streakQuery(DateTime? now) {
    final effectiveNow = now ?? DateTime.now();
    final cutoff = _datePrefix(
      _atUtcStartOfDay(effectiveNow).subtract(const Duration(days: 1)),
    );
    return _db.customSelect(
      _streakSql,
      variables: [Variable.withString(cutoff)],
      readsFrom: {_db.libraryItems},
    );
  }

  ReadingStreak _streakFromRow(QueryRow row) => ReadingStreak(
    currentDays: row.read<int>("active_len"),
    longestDays: row.read<int>("longest_len"),
  );

  Future<ReadingStreak> getReadingStreak({DateTime? now}) =>
      _streakQuery(now).getSingle().then(_streakFromRow);

  Stream<ReadingStreak> watchReadingStreak({DateTime? now}) =>
      _streakQuery(now).watch().map((rows) => _streakFromRow(rows.first));

  // ---------------------------------------------------------------------------
  // Reading velocity
  // ---------------------------------------------------------------------------

  static const String _velocitySql = """
    SELECT COUNT(*) AS total, MIN(first_read_at) AS first_read
    FROM library_items
    WHERE is_read = 1 AND first_read_at IS NOT NULL
  """;

  /// Average issues finished per week over the span since the first read,
  /// with a minimum span of one week.
  Future<ReadingVelocity> getReadingVelocity({DateTime? now}) async {
    final row = await _db
        .customSelect(_velocitySql, readsFrom: {_db.libraryItems})
        .getSingle();
    final total = row.read<int>("total");
    final firstRead = row.read<String?>("first_read");
    if (total == 0 || firstRead == null) {
      return const ReadingVelocity(
        totalReads: 0,
        avgIssuesPerWeek: 0,
        since: null,
      );
    }
    final since = DateTime.parse(firstRead);
    final effectiveNow = now ?? DateTime.now();
    final days =
        effectiveNow.difference(since).inMilliseconds /
        Duration.millisecondsPerDay;
    final weeks = days < 7 ? 1.0 : days / 7;
    return ReadingVelocity(
      totalReads: total,
      avgIssuesPerWeek: total / weeks,
      since: since,
    );
  }

  // ---------------------------------------------------------------------------
  // Monthly reading totals
  // ---------------------------------------------------------------------------

  /// Zero-filled monthly read counts for the last [months] months (ascending,
  /// ending with the month containing [now]).
  Future<List<MonthlyReadingTotal>> getMonthlyReadingTotals({
    DateTime? now,
    int months = 12,
  }) async {
    if (months < 1) return const [];
    final effectiveNow = now ?? DateTime.now();
    final startMonth = DateTime.utc(
      effectiveNow.year,
      effectiveNow.month - (months - 1),
      1,
    );
    final endMonth = DateTime.utc(effectiveNow.year, effectiveNow.month + 1, 1);

    final rows = await _db
        .customSelect(
          "SELECT substr(first_read_at, 1, 7) AS month, COUNT(*) AS cnt "
          "FROM library_items "
          "WHERE is_read = 1 AND first_read_at IS NOT NULL "
          "AND first_read_at >= ? AND first_read_at < ? "
          "GROUP BY month",
          variables: [
            Variable.withString(_datePrefix(startMonth)),
            Variable.withString(_datePrefix(endMonth)),
          ],
          readsFrom: {_db.libraryItems},
        )
        .get();
    final counts = <String, int>{
      for (final row in rows) row.read<String>("month"): row.read<int>("cnt"),
    };

    return [
      for (var i = 0; i < months; i++)
        () {
          final month = DateTime.utc(startMonth.year, startMonth.month + i, 1);
          final key = "${month.year}-${month.month.toString().padLeft(2, "0")}";
          return MonthlyReadingTotal(
            year: month.year,
            month: month.month,
            count: counts[key] ?? 0,
          );
        }(),
    ];
  }

  // ---------------------------------------------------------------------------
  // Rankings (publishers, series, creators, characters)
  // ---------------------------------------------------------------------------

  /// The shared "owned or read" issue set every ranking counts over.
  static const String _rankedIssueFilter =
      "(li.ownership_status = 'owned' OR li.is_read = 1)";

  Future<List<RankedEntity>> _rank(
    String sql, {
    required int limit,
    Set<TableInfo<dynamic, dynamic>> readsFrom = const {},
  }) async {
    final rows = await _db
        .customSelect(
          sql,
          variables: [Variable.withInt(limit <= 0 ? -1 : limit)],
          readsFrom: readsFrom,
        )
        .get();
    return _rankedFromRows(rows);
  }

  Stream<List<RankedEntity>> _rankWatch(
    String sql, {
    required int limit,
    Set<TableInfo<dynamic, dynamic>> readsFrom = const {},
  }) {
    return _db
        .customSelect(
          sql,
          variables: [Variable.withInt(limit <= 0 ? -1 : limit)],
          readsFrom: readsFrom,
        )
        .watch()
        .map(_rankedFromRows);
  }

  List<RankedEntity> _rankedFromRows(List<QueryRow> rows) => [
    for (final row in rows)
      RankedEntity(
        id: row.read<int>("id"),
        name: row.read<String>("name"),
        count: row.read<int>("cnt"),
      ),
  ];

  static const String _topPublishersSql =
      """
    SELECT mp.id AS id, mp.name AS name,
           COUNT(DISTINCT li.metron_issue_id) AS cnt
    FROM library_items li
    JOIN metron_issues mi ON mi.id = li.metron_issue_id
    JOIN metron_series ms
      ON ms.id = COALESCE(NULLIF(li.metron_series_id, 0), mi.series_id)
    JOIN metron_publishers mp
      ON mp.id = COALESCE(mi.publisher_id, ms.publisher_id)
    WHERE $_rankedIssueFilter
    GROUP BY mp.id, mp.name
    ORDER BY cnt DESC, mp.name ASC
    LIMIT ?
  """;

  Future<List<RankedEntity>> topPublishers({int limit = 10}) => _rank(
    _topPublishersSql,
    limit: limit,
    readsFrom: {
      _db.libraryItems,
      _db.metronIssues,
      _db.metronSeries,
      _db.metronPublishers,
    },
  );

  Stream<List<RankedEntity>> watchTopPublishers({int limit = 10}) => _rankWatch(
    _topPublishersSql,
    limit: limit,
    readsFrom: {
      _db.libraryItems,
      _db.metronIssues,
      _db.metronSeries,
      _db.metronPublishers,
    },
  );

  static const String _topSeriesSql =
      """
    SELECT ms.id AS id, ms.name AS name,
           COUNT(DISTINCT li.metron_issue_id) AS cnt
    FROM library_items li
    JOIN metron_issues mi ON mi.id = li.metron_issue_id
    JOIN metron_series ms
      ON ms.id = COALESCE(NULLIF(li.metron_series_id, 0), mi.series_id)
    WHERE $_rankedIssueFilter
    GROUP BY ms.id, ms.name
    ORDER BY cnt DESC, ms.name ASC
    LIMIT ?
  """;

  Future<List<RankedEntity>> topSeries({int limit = 10}) => _rank(
    _topSeriesSql,
    limit: limit,
    readsFrom: {_db.libraryItems, _db.metronIssues, _db.metronSeries},
  );

  Stream<List<RankedEntity>> watchTopSeries({int limit = 10}) => _rankWatch(
    _topSeriesSql,
    limit: limit,
    readsFrom: {_db.libraryItems, _db.metronIssues, _db.metronSeries},
  );

  static const String _topCreatorsSql =
      """
    SELECT mc.id AS id, mc.name AS name,
           COUNT(DISTINCT li.metron_issue_id) AS cnt
    FROM library_items li
    JOIN issue_creators ic ON ic.issue_id = li.metron_issue_id
    JOIN metron_creators mc ON mc.id = ic.creator_id
    WHERE $_rankedIssueFilter
    GROUP BY mc.id, mc.name
    ORDER BY cnt DESC, mc.name ASC
    LIMIT ?
  """;

  Future<List<RankedEntity>> topCreators({int limit = 10}) => _rank(
    _topCreatorsSql,
    limit: limit,
    readsFrom: {_db.libraryItems, _db.issueCreators, _db.metronCreators},
  );

  Stream<List<RankedEntity>> watchTopCreators({int limit = 10}) => _rankWatch(
    _topCreatorsSql,
    limit: limit,
    readsFrom: {_db.libraryItems, _db.issueCreators, _db.metronCreators},
  );

  static const String _topCharactersSql =
      """
    SELECT mch.id AS id, mch.name AS name,
           COUNT(DISTINCT li.metron_issue_id) AS cnt
    FROM library_items li
    JOIN issue_characters ic ON ic.issue_id = li.metron_issue_id
    JOIN metron_characters mch ON mch.id = ic.character_id
    WHERE $_rankedIssueFilter
    GROUP BY mch.id, mch.name
    ORDER BY cnt DESC, mch.name ASC
    LIMIT ?
  """;

  Future<List<RankedEntity>> topCharacters({int limit = 10}) => _rank(
    _topCharactersSql,
    limit: limit,
    readsFrom: {_db.libraryItems, _db.issueCharacters, _db.metronCharacters},
  );

  Stream<List<RankedEntity>> watchTopCharacters({int limit = 10}) => _rankWatch(
    _topCharactersSql,
    limit: limit,
    readsFrom: {_db.libraryItems, _db.issueCharacters, _db.metronCharacters},
  );

  // ---------------------------------------------------------------------------
  // Spend time series
  // ---------------------------------------------------------------------------

  /// When an item was acquired: `acquired_on`, then `purchase_date`, then the
  /// row's `created_at`.
  static const String _spendDateExpr =
      "COALESCE(acquired_on, purchase_date, created_at)";

  /// Zero-filled spend buckets between [from] and [to] (both exclusive at
  /// the date boundary, floored to whole days). Defaults to the 12 months
  /// ending one month from now.
  Future<List<SpendTimeSeriesPoint>> spendTimeSeries({
    DateTime? from,
    DateTime? to,
    SpendBucket bucket = SpendBucket.month,
  }) async {
    final now = DateTime.now();
    final effectiveTo = to ?? DateTime.utc(now.year, now.month + 1, 1).toUtc();
    final effectiveFrom =
        from ??
        DateTime.utc(effectiveTo.year, effectiveTo.month - 12, 1).toUtc();
    final fromDate = _atUtcStartOfDay(effectiveFrom);
    final toDate = _atUtcStartOfDay(effectiveTo);
    if (!toDate.isAfter(fromDate)) return const [];

    final patternLength = bucket == SpendBucket.day ? 10 : 7;
    final rows = await _db
        .customSelect(
          "SELECT substr($_spendDateExpr, 1, $patternLength) AS bucket, "
          "COALESCE(SUM(price_paid * quantity_owned), 0.0) AS amount "
          "FROM library_items "
          "WHERE price_paid IS NOT NULL "
          "AND $_spendDateExpr >= ? AND $_spendDateExpr < ? "
          "GROUP BY bucket",
          variables: [
            Variable.withString(_datePrefix(fromDate)),
            Variable.withString(_datePrefix(toDate)),
          ],
          readsFrom: {_db.libraryItems},
        )
        .get();
    final amounts = <String, double>{
      for (final row in rows)
        row.read<String>("bucket"):
            (row.data["amount"] as num?)?.toDouble() ?? 0,
    };

    // Fill every bucket in the window, including a partial trailing
    // month/day when the range does not end on a boundary.
    final points = <SpendTimeSeriesPoint>[];
    var cursor = bucket == SpendBucket.day
        ? fromDate
        : DateTime.utc(fromDate.year, fromDate.month, 1);
    var end = bucket == SpendBucket.day
        ? toDate
        : DateTime.utc(toDate.year, toDate.month, 1);
    if (end.isBefore(toDate)) {
      end = DateTime.utc(end.year, end.month + 1, 1);
    }
    var guard = 0;
    while (cursor.isBefore(end) && guard < 4000) {
      final key = bucket == SpendBucket.day
          ? _datePrefix(cursor)
          : "${cursor.year}-${cursor.month.toString().padLeft(2, "0")}";
      points.add(SpendTimeSeriesPoint(date: cursor, amount: amounts[key] ?? 0));
      cursor = bucket == SpendBucket.day
          ? cursor.add(const Duration(days: 1))
          : DateTime.utc(cursor.year, cursor.month + 1, 1);
      guard++;
    }
    return points;
  }

  // ---------------------------------------------------------------------------
  // Reading goal progress
  // ---------------------------------------------------------------------------

  /// The UTC window of the period containing [now]: a calendar year for a
  /// "yearly" goal, otherwise the current calendar month.
  ({DateTime from, DateTime to}) _goalWindow(String period, DateTime now) {
    final u = now.toUtc();
    if (period.toLowerCase() == "yearly") {
      return (
        from: DateTime.utc(u.year, 1, 1),
        to: DateTime.utc(u.year + 1, 1, 1),
      );
    }
    return (
      from: DateTime.utc(u.year, u.month, 1),
      to: DateTime.utc(u.year, u.month + 1, 1),
    );
  }

  static const String _goalCountSql =
      "SELECT COUNT(*) AS cnt FROM library_items "
      "WHERE is_read = 1 AND first_read_at >= ? AND first_read_at < ?";

  Selectable<QueryRow> _goalCountQuery(String period, DateTime now) {
    final window = _goalWindow(period, now);
    return _db.customSelect(
      _goalCountSql,
      variables: [
        Variable.withString(_datePrefix(window.from)),
        Variable.withString(_datePrefix(window.to)),
      ],
      readsFrom: {_db.libraryItems},
    );
  }

  ReadingGoalProgress _goalProgress(
    int target,
    String period,
    DateTime now,
    int readCount,
  ) {
    final window = _goalWindow(period, now);
    return ReadingGoalProgress(
      target: target,
      period: period,
      from: window.from,
      to: window.to,
      readCount: readCount,
      percentComplete: target > 0 ? readCount / target : 0.0,
      achieved: target > 0 && readCount >= target,
    );
  }

  /// Progress of a reading goal for the period window containing [now],
  /// counted over `first_read_at` (independent of any UI filter).
  Future<ReadingGoalProgress> getReadingGoalProgress({
    required int target,
    required String period,
    DateTime? now,
  }) async {
    final effectiveNow = now ?? DateTime.now();
    final row = await _goalCountQuery(period, effectiveNow).getSingle();
    return _goalProgress(target, period, effectiveNow, row.read<int>("cnt"));
  }

  /// Reactive variant of [getReadingGoalProgress]; re-emits whenever
  /// `library_items` changes.
  Stream<ReadingGoalProgress> watchReadingGoalProgress({
    required int target,
    required String period,
    DateTime? now,
  }) {
    final effectiveNow = now ?? DateTime.now();
    return _goalCountQuery(period, effectiveNow).watch().map(
      (rows) => _goalProgress(
        target,
        period,
        effectiveNow,
        rows.first.read<int>("cnt"),
      ),
    );
  }
}
