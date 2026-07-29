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
    final cached = await _metronEntityDao.getMetronReadingList(id);

    if (!forceRefresh && cached != null && cached.isFullyHydrated) {
      return MetronReadingListDetail(
        id: cached.id,
        name: cached.name,
        slug: cached.slug,
        desc: cached.description,
        image: cached.imageUrl,
        listType: cached.listType,
        isPrivate: cached.isPrivate ?? false,
        attributionSource: cached.attributionSource,
        attributionUrl: cached.attributionUrl,
        averageRating: cached.averageRating,
        ratingCount: cached.ratingCount ?? 0,
        itemsUrl: cached.itemsUrl,
        resourceUrl: cached.resourceUrl,
        userId: cached.userId,
        username: null,
        modified: cached.modified != null
            ? DateTime.tryParse(cached.modified!)
            : null,
      );
    }

    try {
      final dto = await _remoteDataSource.getReadingListDetail(id);
      if (cached != null &&
          cached.modified != null &&
          dto.modified != null &&
          cached.modified == dto.modified) {
        return MetronReadingListDetail(
          id: cached.id,
          name: cached.name,
          slug: cached.slug,
          desc: cached.description,
          image: cached.imageUrl,
          listType: cached.listType,
          isPrivate: cached.isPrivate ?? false,
          attributionSource: cached.attributionSource,
          attributionUrl: cached.attributionUrl,
          averageRating: cached.averageRating,
          ratingCount: cached.ratingCount ?? 0,
          itemsUrl: cached.itemsUrl,
          resourceUrl: cached.resourceUrl,
          userId: cached.userId,
          username: null,
          modified: cached.modified != null
              ? DateTime.tryParse(cached.modified!)
              : null,
        );
      }
      await _metronEntityDao.upsertMetronReadingList(
        MetronReadingListsCompanion(
          id: Value(dto.id),
          name: Value(dto.name),
          slug: Value(dto.slug),
          userId: Value(dto.userId),
          description: Value(dto.desc),
          imageUrl: Value(dto.image),
          listType: Value(dto.listType),
          isPrivate: Value(dto.isPrivate),
          attributionSource: Value(dto.attributionSource),
          attributionUrl: Value(dto.attributionUrl),
          averageRating: Value(dto.averageRating),
          ratingCount: Value(dto.ratingCount),
          itemsUrl: Value(dto.itemsUrl),
          resourceUrl: Value(dto.resourceUrl),
          modified: Value(dto.modified),
          isFullyHydrated: const Value(true),
        ),
      );
      return dto.toEntity();
    } catch (e) {
      AppLogger.error('Failed to fetch reading list detail', error: e);
      if (cached != null) {
        return MetronReadingListDetail(
          id: cached.id,
          name: cached.name,
          slug: cached.slug,
          desc: cached.description,
          image: cached.imageUrl,
          listType: cached.listType,
          isPrivate: cached.isPrivate ?? false,
          attributionSource: cached.attributionSource,
          attributionUrl: cached.attributionUrl,
          averageRating: cached.averageRating,
          ratingCount: cached.ratingCount ?? 0,
          itemsUrl: cached.itemsUrl,
          resourceUrl: cached.resourceUrl,
          userId: cached.userId,
          username: null,
          modified: cached.modified != null
              ? DateTime.tryParse(cached.modified!)
              : null,
        );
      }
      rethrow;
    }
  }

  Future<List<MetronReadingListItem>> getReadingListItems(
    int id, {
    bool forceRefresh = false,
  }) async {
    final allItems = <MetronReadingListItem>[];
    Uri? nextUrl;

    while (true) {
      final dto = await _remoteDataSource.getReadingListItems(
        id,
        nextUrl: nextUrl,
      );
      for (final item in dto.results) {
        unawaited(
          _metronEntityDao.upsertIssueStub(
            item.issueId,
            item.seriesId,
            item.issueNumber ?? '0',
            null,
            storeDate: item.storeDate != null
                ? DateTime.tryParse(item.storeDate!)
                : null,
            coverDate: item.coverDate != null
                ? DateTime.tryParse(item.coverDate!)
                : null,
          ),
        );
        if (item.seriesId != null && item.seriesName != null) {
          unawaited(
            _metronEntityDao.upsertSeriesStub(
              item.seriesId!,
              item.seriesName!,
              yearBegan: item.yearBegan,
              volume: item.seriesVolume,
            ),
          );
        }
        allItems.add(item.toEntity());
      }
      if (dto.next == null) break;
      nextUrl = Uri.parse(dto.next!);
    }

    return allItems;
  }
}
