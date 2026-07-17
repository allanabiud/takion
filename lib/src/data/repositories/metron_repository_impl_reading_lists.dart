part of 'metron_repository_impl.dart';

mixin _ReadingListsRepositoryMixin on _RepositoryState {

  Future<MetronReadingListPage> searchReadingLists({
    String? nextUrl,
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
      nextUrl: nextUrl != null ? Uri.parse(nextUrl) : null,
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
    final allItems = <MetronReadingListItem>[];
    Uri? nextUrl;

    while (true) {
      final dto = await _remoteDataSource.getReadingListItems(
        id,
        nextUrl: nextUrl,
      );
      allItems.addAll(dto.results.map((e) => e.toEntity()));
      if (dto.next == null) break;
      nextUrl = Uri.parse(dto.next!);
    }

    return allItems;
  }
}
