import "package:flutter_test/flutter_test.dart";
import "package:takion/src/domain/common/content_sorting.dart";
import "package:takion/src/domain/entities.dart";

IssueList _buildIssue({
  required int id,
  required String name,
  DateTime? storeDate,
  DateTime? coverDate,
  DateTime? modified,
  int? seriesYear,
}) {
  return IssueList(
    id: id,
    name: name,
    number: "$id",
    series: Series(
      id: 1,
      name: "Series",
      volume: 1,
      yearBegan: seriesYear ?? 2020,
    ),
    storeDate: storeDate,
    coverDate: coverDate,
    image: null,
    modified: modified,
  );
}

void main() {
  group("sortIssues and selectRecentIssues", () {
    test(
      "sorts by dateNewest using release/cover dates, not modified timestamp",
      () {
        final oldIssueModifiedRecently = _buildIssue(
          id: 1,
          name: "Old Comic #1",
          storeDate: DateTime(1963, 5, 1),
          coverDate: DateTime(1963, 5, 1),
          modified: DateTime(2026, 8, 1),
        );
        final newIssue = _buildIssue(
          id: 2,
          name: "New Comic #50",
          storeDate: DateTime(2025, 12, 1),
          coverDate: DateTime(2025, 12, 1),
          modified: DateTime(2025, 12, 2),
        );
        final midIssue = _buildIssue(
          id: 3,
          name: "Mid Comic #20",
          storeDate: DateTime(2010, 6, 1),
          coverDate: DateTime(2010, 6, 1),
          modified: DateTime(2026, 1, 1),
        );

        final issues = [oldIssueModifiedRecently, newIssue, midIssue];
        final sorted = sortIssues(issues, ContentSortOption.dateNewest);

        expect(sorted.map((i) => i.id).toList(), [2, 3, 1]);
      },
    );

    test("selectRecentIssues selects newest issues regardless of series", () {
      final issues = [
        _buildIssue(
          id: 10,
          name: "Batman #1",
          storeDate: DateTime(1940, 4, 25),
        ),
        _buildIssue(
          id: 20,
          name: "Detective Comics #27",
          storeDate: DateTime(1939, 3, 30),
        ),
        _buildIssue(
          id: 30,
          name: "Batman #150",
          storeDate: DateTime(2024, 7, 2),
        ),
        _buildIssue(
          id: 40,
          name: "Detective Comics #1085",
          storeDate: DateTime(2024, 5, 28),
        ),
        _buildIssue(
          id: 50,
          name: "Batman / Superman #1",
          storeDate: DateTime(2024, 8, 15),
        ),
        _buildIssue(
          id: 60,
          name: "Justice League #75",
          storeDate: DateTime(2022, 4, 19),
        ),
      ];

      final recent = selectRecentIssues(issues, targetCount: 3);
      expect(recent.map((i) => i.id).toList(), [50, 30, 40]);
    });
  });
}
