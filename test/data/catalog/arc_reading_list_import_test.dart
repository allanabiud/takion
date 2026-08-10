import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:takion/src/core/constants/pagination.dart';
import 'package:takion/src/data/catalog/datasources/local/metron_local_data_source.dart';
import 'package:takion/src/data/catalog/datasources/local/series_name_index.dart'
    as series_index;
import 'package:takion/src/data/catalog/datasources/remote/metron_remote_data_source.dart';
import 'package:takion/src/data/catalog/dto/dto.dart';
import 'package:takion/src/data/catalog/repositories/metron_repository_impl.dart';
import 'package:takion/src/data/common/drift/database.dart';
import 'package:takion/src/data/common/drift/daos/junction_dao.dart';
import 'package:takion/src/data/common/drift/daos/metron_entity_dao.dart';
import 'package:takion/src/data/reading_list/repositories/local_reading_list_local_data_source.dart';
import 'package:takion/src/domain/entities.dart';

class FakeMetronRemoteDataSource implements MetronRemoteDataSource {
  final List<IssueListDto> arcIssues;

  FakeMetronRemoteDataSource(this.arcIssues);

  @override
  Future<SeriesIssueListResponseDto> getArcIssueList(
    int arcId, {
    Uri? nextUrl,
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
  }) async {
    return SeriesIssueListResponseDto(
      count: arcIssues.length,
      next: null,
      previous: null,
      results: arcIssues,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError('${invocation.memberName}');
  }
}

IssueListDto _issue(int id, {String? image}) {
  return IssueListDto(
    id: id,
    number: '$id',
    series: IssueListSeriesDto(
      id: 900,
      name: 'Test Series',
      volume: 1,
      yearBegan: 2026,
    ),
    coverDate: '2026-10-14',
    storeDate: '2026-10-14',
    image: image,
    issueName: 'Test Series #$id',
    modified: '2026-10-01T00:00:00Z',
    coverHash: null,
  );
}

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.customStatement('SELECT 1');
    await db.close();
  });

  test('getArcIssueListAll returns issues and they land in the reading list',
      () async {
    final remote = FakeMetronRemoteDataSource([_issue(1), _issue(2)]);
    final repo = MetronRepositoryImpl(
      remote,
      MetronLocalDataSourceImpl(db),
      MetronEntityDao(db),
      JunctionDao(db),
      series_index.SeriesNameIndex(db),
    );

    final issues = await repo.getArcIssueListAll(123);
    expect(issues.map((i) => i.id), [1, 2]);

    final readingListRepo = LocalReadingListLocalDataSource(db);
    final list = LocalReadingList(
      id: 'list-1',
      title: 'Arc Name',
      description: '',
      isOrdered: true,
      contentType: ListContentType.issue,
      createdAt: DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
      items: issues.map(localReadingListItemFromIssueList).toList(),
      metronArcId: 123,
      metronAttributionSource: 'Metron Arc',
      lastSyncedAt: DateTime.now().toUtc(),
    );
    expect(list.items, hasLength(2));

    await readingListRepo.createList(list);

    final saved = await db.readingListDao.getById('list-1');
    expect(saved, isNotNull);
    expect(saved!.itemsJson, isNotNull);
    expect(saved.itemsJson, isNotEmpty);

    final reloaded = await readingListRepo.getListById('list-1');
    expect(reloaded, isNotNull);
    expect(reloaded!.items, hasLength(2));
  });
}
