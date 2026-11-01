import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:takion/src/data/collection/datasources/remote/metron_collection_remote_data_source.dart";
import "package:takion/src/data/collection/dto/collection_item_dto.dart";
import "package:takion/src/data/collection/dto/collection_stats_dto.dart";
import "package:takion/src/data/collection/dto/missing_issues_dto.dart";
import "package:takion/src/data/collection/dto/scrobble_dto.dart";
import "package:takion/src/data/collection/repositories/metron_collection_repository_impl.dart";

class MockMetronCollectionRemoteDataSource extends Mock
    implements MetronCollectionRemoteDataSource {}

void main() {
  group("MetronCollectionRepositoryImpl", () {
    late MockMetronCollectionRemoteDataSource remoteDataSource;
    late MetronCollectionRepositoryImpl repository;

    setUp(() {
      remoteDataSource = MockMetronCollectionRemoteDataSource();
      repository = MetronCollectionRepositoryImpl(remoteDataSource);
    });

    test("getCollection maps DTOs to entities", () async {
      when(
        () => remoteDataSource.getCollection(
          page: any(named: "page"),
          bookFormat: any(named: "bookFormat"),
          dateRead: any(named: "dateRead"),
          grade: any(named: "grade"),
          gradingCompany: any(named: "gradingCompany"),
          isRead: any(named: "isRead"),
          modifiedGt: any(named: "modifiedGt"),
          rating: any(named: "rating"),
        ),
      ).thenAnswer(
        (_) async => [
          const CollectionItemDto(
            id: 1,
            issueId: 10,
            seriesId: 100,
            seriesName: "Spider-Man",
            issueNumber: "1",
            quantity: 1,
            bookFormat: "PRINT",
            isRead: true,
          ),
        ],
      );

      final items = await repository.getCollection(page: 1);
      expect(items.length, 1);
      expect(items.first.id, 1);
      expect(items.first.issueId, 10);
      expect(items.first.seriesName, "Spider-Man");
      expect(items.first.isRead, true);
    });

    test("addToCollection delegates to remote data source", () async {
      when(
        () => remoteDataSource.addToCollection(
          issueId: 10,
          quantity: 1,
          bookFormat: "PRINT",
          grade: null,
          gradingCompany: null,
          purchaseDate: null,
          purchasePrice: null,
          purchasePriceCurrency: "USD",
          purchaseStore: null,
          storageLocation: null,
          notes: null,
        ),
      ).thenAnswer(
        (_) async => const CollectionItemDto(
          id: 5,
          issueId: 10,
          seriesId: 100,
          seriesName: "Spider-Man",
          issueNumber: "1",
        ),
      );

      final result = await repository.addToCollection(issueId: 10);
      expect(result.id, 5);
      expect(result.issueId, 10);
    });

    test("scrobble delegates and maps response", () async {
      registerFallbackValue(const ScrobbleRequestDto(issueId: 10));

      when(() => remoteDataSource.scrobble(any())).thenAnswer(
        (_) async => const ScrobbleResponseDto(
          id: 99,
          isRead: true,
          dateRead: "2026-09-04",
        ),
      );

      final result = await repository.scrobble(issueId: 10);
      expect(result.id, 99);
      expect(result.isRead, true);
    });

    test("getCollectionStats maps stats DTO to entity", () async {
      when(() => remoteDataSource.getCollectionStats()).thenAnswer(
        (_) async => const CollectionStatsDto(
          totalItems: 50,
          totalQuantity: 55,
          readCount: 40,
          unreadCount: 10,
        ),
      );

      final stats = await repository.getCollectionStats();
      expect(stats.totalItems, 50);
      expect(stats.readCount, 40);
      expect(stats.unreadCount, 10);
    });

    test("getMissingIssues maps missing issue DTOs to entities", () async {
      when(() => remoteDataSource.getMissingIssues(100, page: 1)).thenAnswer(
        (_) async => const MissingIssuesPageDto(
          count: 1,
          results: [
            MissingIssueDto(
              id: 201,
              seriesId: 100,
              seriesName: "Spider-Man",
              issueNumber: "2",
            ),
          ],
        ),
      );

      final issuesPage = await repository.getMissingIssues(100);
      expect(issuesPage.count, 1);
      expect(issuesPage.results.length, 1);
      expect(issuesPage.results.first.id, 201);
      expect(issuesPage.results.first.issueNumber, "2");
    });

    test("getMissingSeries maps missing series DTOs to entities", () async {
      when(() => remoteDataSource.getMissingSeries(page: 1)).thenAnswer(
        (_) async => [
          const MissingSeriesDto(
            id: 100,
            name: "Spider-Man",
            totalIssues: 10,
            missingCount: 3,
          ),
        ],
      );

      final series = await repository.getMissingSeries();
      expect(series.length, 1);
      expect(series.first.id, 100);
      expect(series.first.missingCount, 3);
    });
  });
}
