import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:takion/src/core/cache/user_state_cache.dart';
import 'package:takion/src/data/catalog/datasources/local/metron_local_data_source.dart';
import 'package:takion/src/data/catalog/datasources/local/series_name_index.dart'
    as series_index;
import 'package:takion/src/data/catalog/datasources/remote/metron_remote_data_source.dart';
import 'package:takion/src/data/catalog/dto/dto.dart';
import 'package:takion/src/data/catalog/repositories/metron_repository_impl.dart';
import 'package:takion/src/data/common/drift/database.dart';
import 'package:takion/src/data/common/drift/daos/junction_dao.dart';
import 'package:takion/src/data/common/drift/daos/metron_entity_dao.dart';
import 'package:takion/src/data/subscription/repositories/local_subscription_repository.dart';

class FakeMetronRemoteDataSource implements MetronRemoteDataSource {
  int getIssueListCalls = 0;

  @override
  Future<IssueSearchResponseDto> getIssueList({
    Uri? nextUrl,
    int page = 1,
    String? ordering,
    DateTime? modifiedGt,
    int? limit,
    CancelToken? cancelToken,
  }) async {
    getIssueListCalls++;
    return IssueSearchResponseDto(
      count: 1,
      next: null,
      previous: null,
      results: [
        IssueListDto(
          id: 501,
          number: '1',
          series: IssueListSeriesDto(
            id: 900,
            name: 'Test Series',
            volume: 1,
            yearBegan: 2026,
          ),
          coverDate: '2026-10-14',
          storeDate: '2026-10-14',
          image: null,
          issueName: 'Test Series #1',
          modified: '2026-10-01T00:00:00Z',
          coverHash: null,
        ),
      ],
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError('${invocation.memberName}');
  }
}

void main() {
  late AppDatabase db;

  Future<PullListEntry?> waitForPullEntry(
    AppDatabase database,
    int issueId,
  ) async {
    for (var i = 0; i < 50; i++) {
      final entry = await database.pullListDao.getByIssueId(issueId);
      if (entry != null) return entry;
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    return database.pullListDao.getByIssueId(issueId);
  }

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.customStatement('SELECT 1');
    await db.close();
  });

  MetronRepositoryImpl buildRepo(FakeMetronRemoteDataSource remote) {
    return MetronRepositoryImpl(
      remote,
      MetronLocalDataSourceImpl(db),
      MetronEntityDao(db),
      JunctionDao(db),
      series_index.SeriesNameIndex(db),
    );
  }

  test('ingesting an issue for a subscribed auto-add series creates a pull entry',
      () async {
    final remote = FakeMetronRemoteDataSource();
    final repo = buildRepo(remote);
    final subscriptionRepo = LocalSubscriptionRepository(db, UserStateCache());

    await subscriptionRepo.subscribe(
      metronSeriesId: 900,
      autoAddToPullList: true,
    );

    final page = await repo.getIssueList(
      modifiedGt: DateTime.utc(2026, 10, 1),
    );
    expect(page.results.map((i) => i.id), [501]);

    final entry = await waitForPullEntry(db, 501);
    expect(entry, isNotNull);
    expect(entry!.metronSeriesId, 900);
    expect(entry.entryStatus, 'upcoming');
    expect(entry.source, 'subscription');
    expect(entry.releaseDate, isNotNull);
  });

  test('ingesting an issue for a subscribed non-auto-add series does not pull',
      () async {
    final remote = FakeMetronRemoteDataSource();
    final repo = buildRepo(remote);
    final subscriptionRepo = LocalSubscriptionRepository(db, UserStateCache());

    await subscriptionRepo.subscribe(
      metronSeriesId: 900,
      autoAddToPullList: false,
    );

    final page = await repo.getIssueList(
      modifiedGt: DateTime.utc(2026, 10, 1),
    );
    expect(page.results.map((i) => i.id), [501]);

    final entry = await db.pullListDao.getByIssueId(501);
    expect(entry, isNull);
  });

  test('ingesting an issue for an unsubscribed series does not pull', () async {
    final remote = FakeMetronRemoteDataSource();
    final repo = buildRepo(remote);

    final page = await repo.getIssueList(
      modifiedGt: DateTime.utc(2026, 10, 1),
    );
    expect(page.results.map((i) => i.id), [501]);

    final entry = await db.pullListDao.getByIssueId(501);
    expect(entry, isNull);
  });
}
