import "package:drift/native.dart";
import "package:flutter_test/flutter_test.dart";
import "package:takion/src/data/common/drift/database.dart";
import "package:takion/src/data/reading_list/repositories/local_reading_list_local_data_source.dart";
import "package:takion/src/domain/entities.dart";
import "package:takion/src/domain/repositories.dart";

void main() {
  late AppDatabase db;
  late LocalReadingListRepository repository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = LocalReadingListLocalDataSource(db);
  });

  tearDown(() async {
    await db.close();
  });

  LocalReadingListItem issueItem(String targetId) => LocalReadingListItem(
    targetId: targetId,
    isSeries: false,
    role: ItemRole.standard,
    isRead: false,
    seriesName: "Amazing Spider-Man",
    seriesVolume: 1,
    issueNumber: "5",
    seriesId: 7,
    yearBegan: 1963,
    coverDate: DateTime(2020, 1, 1),
    storeDate: DateTime(2020, 1, 15),
  );

  LocalReadingList arcList({int arcId = 42, List<LocalReadingListItem>? items}) {
    final now = DateTime.now();
    return LocalReadingList(
      id: "arc-list",
      title: "Civil War",
      description: "An arc import",
      isOrdered: true,
      contentType: ListContentType.issue,
      createdAt: now,
      updatedAt: now,
      items: items ?? [issueItem("issue-1")],
      metronArcId: arcId,
      metronAttributionSource: "Metron Arc",
      metronImageUrl: "https://example.com/arc.jpg",
      lastSyncedAt: now,
    );
  }

  test("findByMetronArcId returns the imported arc list", () async {
    await repository.createList(arcList());

    final found = await repository.findByMetronArcId(42);
    expect(found, isNotNull);
    expect(found!.id, "arc-list");
    expect(found.metronArcId, 42);
    expect(found.metronAttributionSource, "Metron Arc");
    expect(found.metronImageUrl, "https://example.com/arc.jpg");
  });

  test("metronSourceId and metronArcId do not collide", () async {
    final now = DateTime.now();
    await repository.createList(arcList(arcId: 7));
    await repository.createList(
      LocalReadingList(
        id: "source-list",
        title: "Reading List #7",
        description: "",
        isOrdered: true,
        contentType: ListContentType.issue,
        createdAt: now,
        updatedAt: now,
        items: [issueItem("issue-1")],
        metronSourceId: 7,
      ),
    );

    final byArc = await repository.findByMetronArcId(7);
    final bySource = await repository.findByMetronSourceId(7);
    expect(byArc!.id, "arc-list");
    expect(bySource!.id, "source-list");
  });

  test("round-trip via getAllLists preserves metronArcId and items", () async {
    await repository.createList(
      arcList(items: [issueItem("issue-1"), issueItem("issue-2")]),
    );

    final list = (await repository.getAllLists()).single;
    expect(list.metronArcId, 42);
    expect(list.items, hasLength(2));
    expect(list.items.first.targetId, "issue-1");
    expect(list.items.first.seriesName, "Amazing Spider-Man");
    expect(list.isMetronImported, isTrue);
  });

  test("arc import mirrors items into reading_list_items", () async {
    await repository.createList(
      arcList(items: [issueItem("issue-1"), issueItem("issue-2")]),
    );

    final rows = await db.select(db.readingListItems).get();
    expect(rows, hasLength(2));
    expect(rows.map((r) => r.listId).toSet(), {"arc-list"});
    expect(rows.map((r) => r.targetId).toSet(), {"issue-1", "issue-2"});
  });

  group("localReadingListItemFromIssueList", () {
    test("maps all issue metadata onto a reading list item", () {
      final issue = IssueList(
        id: 9001,
        name: "Amazing Spider-Man #5",
        number: "5",
        series: const Series(
          id: 7,
          name: "Amazing Spider-Man",
          volume: 1,
          yearBegan: 1963,
        ),
        coverDate: DateTime(2020, 1, 1),
        storeDate: DateTime(2020, 1, 15),
        image: "https://example.com/cover.jpg",
        modified: null,
      );

      final item = localReadingListItemFromIssueList(issue);

      expect(item.targetId, "issue-9001");
      expect(item.isSeries, isFalse);
      expect(item.role, ItemRole.standard);
      expect(item.isRead, isFalse);
      expect(item.seriesName, "Amazing Spider-Man");
      expect(item.seriesVolume, 1);
      expect(item.issueNumber, "5");
      expect(item.seriesId, 7);
      expect(item.yearBegan, 1963);
      expect(item.coverDate, DateTime(2020, 1, 1));
      expect(item.storeDate, DateTime(2020, 1, 15));
    });

    test("falls back to issue name when series is missing", () {
      final issue = const IssueList(
        id: 2,
        name: "Mystery Book",
        number: "1",
        series: null,
        coverDate: null,
        storeDate: null,
        image: null,
        modified: null,
      );

      final item = localReadingListItemFromIssueList(issue);
      expect(item.seriesName, "Mystery Book");
      expect(item.seriesVolume, isNull);
      expect(item.seriesId, isNull);
      expect(item.yearBegan, isNull);
    });
  });
}
