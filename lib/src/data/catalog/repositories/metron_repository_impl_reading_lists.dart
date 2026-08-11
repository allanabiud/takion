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
    DateTime? modifiedGt,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  }) async {
    final cachedDtos = await _localDataSource.getReadingListResults(
      page: page,
      limit: limit,
      modifiedGt: modifiedGt,
      name: name,
      listType: listType,
      attributionSource: attributionSource,
      publisher: publisher,
    );
    final cachedAt = await _localDataSource.getReadingListResultsCachedAt(
      page: page,
      limit: limit,
      modifiedGt: modifiedGt,
      name: name,
      listType: listType,
      attributionSource: attributionSource,
      publisher: publisher,
    );
    final cachedMeta = await _localDataSource.getReadingListResultsMeta(
      page: page,
      limit: limit,
      modifiedGt: modifiedGt,
      name: name,
      listType: listType,
      attributionSource: attributionSource,
      publisher: publisher,
    );
    final filtersKey =
        'n${(name ?? '').trim().toLowerCase()}'
        ':lt${(listType ?? '').trim().toLowerCase()}'
        ':as${(attributionSource ?? '').trim().toLowerCase()}'
        ':pu${(publisher ?? '').trim().toLowerCase()}';

    if (!forceRefresh && cachedDtos != null && cachedDtos.isNotEmpty) {
      final isFresh =
          cachedAt != null &&
          MetronCachePolicies.readingList.isFresh(cachedAt, _now());
      if (!isFresh) {
        _refreshInBackground(
          task: () async {
            final remotePage = await _remoteDataSource.getReadingLists(
              nextUrl: nextUrl != null ? Uri.parse(nextUrl) : null,
              page: page,
              name: name,
              listType: listType,
              attributionSource: attributionSource,
              publisher: publisher,
              modifiedGt: modifiedGt,
              cancelToken: cancelToken,
            );
            await _localDataSource.cacheReadingListResults(
              remotePage.results,
              page: page,
              limit: limit,
              modifiedGt: modifiedGt,
              name: name,
              listType: listType,
              attributionSource: attributionSource,
              publisher: publisher,
              count: remotePage.count,
              next: remotePage.next,
              previous: remotePage.previous,
            );
          },
          cacheKey: 'reading_list:${nextUrl ?? "$page"}|$filtersKey|$modifiedGt',
          cooldown: MetronCachePolicies.readingList.refreshCooldown,
        );
      }
      if (cachedMeta != null) {
        return MetronReadingListPage(
          count: cachedMeta.count,
          next: cachedMeta.next,
          previous: cachedMeta.previous,
          results: cachedDtos.map((e) => e.toEntity()).toList(),
        );
      }
    }

    try {
      final key = '${nextUrl ?? "$page"}|$filtersKey|$modifiedGt|$forceRefresh';
      return _coalesce(_readingListInFlight, key, () async {
        final remotePage = await _remoteDataSource.getReadingLists(
          nextUrl: nextUrl != null ? Uri.parse(nextUrl) : null,
          page: page,
          name: name,
          listType: listType,
          attributionSource: attributionSource,
          publisher: publisher,
          modifiedGt: modifiedGt,
          cancelToken: cancelToken,
        );
        await _localDataSource.cacheReadingListResults(
          remotePage.results,
          page: page,
          limit: limit,
          modifiedGt: modifiedGt,
          name: name,
          listType: listType,
          attributionSource: attributionSource,
          publisher: publisher,
          count: remotePage.count,
          next: remotePage.next,
          previous: remotePage.previous,
        );
        return MetronReadingListPage(
          count: remotePage.count,
          next: remotePage.next,
          previous: remotePage.previous,
          results: remotePage.results.map((e) => e.toEntity()).toList(),
        );
      }, timeout: const Duration(seconds: 30));
    } catch (error) {
      if (_isCancelled(error)) rethrow;
      if (cachedDtos != null && cachedDtos.isNotEmpty && cachedMeta != null) {
        return MetronReadingListPage(
          count: cachedMeta.count,
          next: cachedMeta.next,
          previous: cachedMeta.previous,
          results: cachedDtos.map((e) => e.toEntity()).toList(),
        );
      }
      rethrow;
    }
  }

  Future<int> refreshReadingListDelta({DateTime? modifiedGt}) {
    return runZoned(
      () async {
        var page = 1;
        var synced = 0;
        while (true) {
          final result = await searchReadingLists(
            page: page,
            limit: metronDefaultPageSize,
            modifiedGt: modifiedGt,
            forceRefresh: true,
          );
          for (final item in result.results) {
            await getReadingListDetail(item.id, forceRefresh: true);
            synced++;
          }
          if (!result.hasNext) break;
          page++;
        }
        return synced;
      },
      zoneValues: {backgroundZoneKey: true},
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
      final response = await _remoteDataSource.getReadingListDetail(id);
      if (response.statusCode == 304) {
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
        throw StateError('Reading list $id not found');
      }
      final dto = ReadingListDetailDto.fromJson(
        response.data as Map<String, dynamic>,
      );
      if (!forceRefresh &&
          cached != null &&
          cached.isFullyHydrated &&
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
    var pageCount = 0;

    while (pageCount < metronMaxWalkPages) {
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
      pageCount++;
      if (dto.next == null) break;
      nextUrl = Uri.parse(dto.next!);
    }

    return allItems;
  }
}
