import "package:drift/drift.dart";
import "package:drift/native.dart";
import "package:flutter_test/flutter_test.dart";
import "package:takion/src/data/common/drift/database.dart";

/// Creates an in-memory [AppDatabase] suitable for isolated unit and DAO testing.
AppDatabase createInMemoryDatabase() {
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  addTearDown(() async {
    await db.close();
  });
  return db;
}

/// Helper fixture generator for [LibraryItemsCompanion].
LibraryItemsCompanion createTestLibraryItem({
  required int issueId,
  int seriesId = 1,
  String ownershipStatus = "owned",
  bool isRead = false,
  int? rating,
  String format = "print",
  String? notes,
  DateTime? createdAt,
}) {
  final now = (createdAt ?? DateTime.now().toUtc()).toIso8601String();
  return LibraryItemsCompanion(
    id: Value("lib-$issueId"),
    userId: const Value("test-user"),
    metronIssueId: Value(issueId),
    metronSeriesId: Value(seriesId),
    ownershipStatus: Value(ownershipStatus),
    isRead: Value(isRead),
    rating: Value(rating),
    format: Value(format),
    notes: Value(notes),
    createdAt: Value(now),
    updatedAt: Value(now),
  );
}

/// Helper fixture generator for [MetronSeriesCompanion].
MetronSeriesCompanion createTestSeriesStub({
  required int id,
  required String name,
  int volume = 1,
  int yearBegan = 2020,
  int issueCount = 10,
  String? coverUrl,
}) {
  return MetronSeriesCompanion.insert(
    id: Value(id),
    name: name,
    volume: Value(volume),
    yearBegan: Value(yearBegan),
    issueCount: Value(issueCount),
    computedCoverUrl: Value(
      coverUrl ?? "https://metron.cloud/media/series_$id.jpg",
    ),
  );
}

/// Helper fixture generator for [MetronIssuesCompanion].
MetronIssuesCompanion createTestIssueStub({
  required int id,
  required int seriesId,
  required String number,
  String? description,
  String? coverDate,
  String? imageUrl,
}) {
  return MetronIssuesCompanion.insert(
    id: Value(id),
    seriesId: Value(seriesId),
    number: number,
    description: Value(description),
    coverDate: Value(coverDate ?? "2020-01-01"),
    imageUrl: Value(imageUrl ?? "https://metron.cloud/media/issue_$id.jpg"),
  );
}
