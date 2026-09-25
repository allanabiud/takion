/// Result types for the local SQL analytics aggregations (streaks, velocity,
/// rankings, spend time series, and reading-goal progress).
library;

/// Consecutive-day reading streaks, computed entirely in SQL.
class ReadingStreak {
  const ReadingStreak({required this.currentDays, required this.longestDays});

  /// Length of the active run of consecutive read days. A run stays active
  /// until the end of the day after its last read day.
  final int currentDays;

  /// Longest run of consecutive read days ever recorded.
  final int longestDays;
}

/// Reading pace derived from the span between the first and latest reads.
class ReadingVelocity {
  const ReadingVelocity({
    required this.totalReads,
    required this.avgIssuesPerWeek,
    required this.since,
  });

  final int totalReads;

  /// Issues finished per week over the span since [since] (minimum span of
  /// one week so a single-day burst cannot skew the number).
  final double avgIssuesPerWeek;

  /// When the first issue was read, or null when nothing has been read.
  final DateTime? since;
}

/// Number of issues first read within one calendar month.
class MonthlyReadingTotal {
  const MonthlyReadingTotal({
    required this.year,
    required this.month,
    required this.count,
  });

  final int year;

  /// 1-12.
  final int month;

  final int count;
}

/// A catalog entity ranked by how many collected/read issues reference it.
class RankedEntity {
  const RankedEntity({required this.id, required this.name, required this.count});

  final int id;
  final String name;

  /// Number of distinct issues (owned or read) referencing this entity.
  final int count;
}

/// Bucket granularity for [SpendTimeSeriesPoint] series.
enum SpendBucket { day, month }

/// Total spend inside one day/month bucket, keyed by acquisition date
/// (`acquired_on`, falling back to `purchase_date` then `created_at`).
class SpendTimeSeriesPoint {
  const SpendTimeSeriesPoint({required this.date, required this.amount});

  /// Bucket start (UTC, at the start of the day/month).
  final DateTime date;

  final double amount;
}

/// Progress of a ("monthly" or "yearly") reading challenge for the period
/// window containing "now", counted over `first_read_at`.
class ReadingGoalProgress {
  const ReadingGoalProgress({
    required this.target,
    required this.period,
    required this.from,
    required this.to,
    required this.readCount,
    required this.percentComplete,
    required this.achieved,
  });

  final int target;

  /// "monthly" or "yearly".
  final String period;

  /// Inclusive window start (UTC).
  final DateTime from;

  /// Exclusive window end (UTC).
  final DateTime to;

  final int readCount;

  /// `readCount / target`, unclamped; 0 when the target is not positive.
  final double percentComplete;

  final bool achieved;
}
