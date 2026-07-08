part of 'metron_repository_impl.dart';

mixin _ReadingListsRepositoryMixin on _RepositoryState {

  Future<MetronReadingListPage> searchReadingLists({
    int page = 1,
    int limit = metronDefaultPageSize,
    String? name,
    String? listType,
    String? attributionSource,
    String? publisher,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  }) async {
    final dto = await _remoteDataSource.getReadingLists(
      page: page,
      name: name,
      listType: listType,
      attributionSource: attributionSource,
      publisher: publisher,
      cancelToken: cancelToken,
    );
    return MetronReadingListPage(
      count: dto.count,
      next: dto.next,
      previous: dto.previous,
      results: dto.results.map((e) => e.toEntity()).toList(),
    );
  }

  Future<MetronReadingListDetail> getReadingListDetail(
    int id, {
    bool forceRefresh = false,
  }) async {
    final dto = await _remoteDataSource.getReadingListDetail(id);
    return dto.toEntity();
  }

  Future<List<MetronReadingListItem>> getReadingListItems(int id) async {
    var page = 1;
    final allItems = <MetronReadingListItem>[];

    while (true) {
      final dto = await _remoteDataSource.getReadingListItems(id, page: page);
      allItems.addAll(dto.results.map((e) => e.toEntity()));
      if (dto.next == null) break;
      page++;
    }

    return allItems;
  }
}
