part of 'metron_repository_impl.dart';

mixin _CharactersRepositoryMixin on _RepositoryState {

  Future<CharacterListPage> getCharacterList({
    String? nextUrl,
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  }) async {
    final dto = nextUrl != null
        ? await _remoteDataSource.getCharacterList(
            nextUrl: Uri.parse(nextUrl),
            limit: limit,
            cancelToken: cancelToken,
          )
        : await _remoteDataSource.getCharacterList(
            page: page,
            limit: limit,
            cancelToken: cancelToken,
          );
    return CharacterListPage(
      count: dto.count,
      next: dto.next,
      previous: dto.previous,
      results: dto.results.map((e) => e.toEntity()).toList(),
      currentPage: page,
    );
  }

  Future<CharacterListPage> searchCharacters(
    String query, {
    String? nextUrl,
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  }) async {
    final cachedDtos = await _localDataSource.getCharacterSearchResults(
      query,
      page: page,
      limit: limit,
    );
    final cachedAt = await _localDataSource.getCharacterSearchResultsCachedAt(
      query,
      page: page,
      limit: limit,
    );
    final cachedMeta = await _localDataSource.getCharacterSearchResultsMeta(
      query,
      page: page,
      limit: limit,
    );

    if (!forceRefresh && cachedDtos != null && cachedDtos.isNotEmpty) {
      final isFresh =
          cachedAt != null &&
          MetronCachePolicies.searchResults.isFresh(cachedAt, _now());
      if (!isFresh) {
        _refreshInBackground(
          task: () async {
            final remotePage = nextUrl != null
                ? await _remoteDataSource.searchCharacters(
                    query,
                    nextUrl: Uri.parse(nextUrl),
                    limit: limit,
                    cancelToken: cancelToken,
                  )
                : await _remoteDataSource.searchCharacters(
                    query,
                    page: page,
                    limit: limit,
                    cancelToken: cancelToken,
                  );
            await _localDataSource.cacheCharacterSearchResults(
              query,
              remotePage.results,
              page: page,
              limit: limit,
              count: remotePage.count,
              next: remotePage.next,
              previous: remotePage.previous,
            );
          },
          cacheKey: nextUrl ?? 'search:character:$query:$page',
          cooldown: MetronCachePolicies.searchResults.refreshCooldown,
        );
      }
      if (cachedMeta != null) {
        return CharacterListPage(
          count: cachedMeta.count,
          next: cachedMeta.next,
          previous: cachedMeta.previous,
          results: cachedDtos.map((entry) => entry.toEntity()).toList(),
          currentPage: page,
        );
      }
    }

    try {
      final remotePage = nextUrl != null
          ? await _remoteDataSource.searchCharacters(
              query,
              nextUrl: Uri.parse(nextUrl),
              limit: limit,
              cancelToken: cancelToken,
            )
          : await _remoteDataSource.searchCharacters(
              query,
              page: page,
              limit: limit,
              cancelToken: cancelToken,
            );
      await _localDataSource.cacheCharacterSearchResults(
        query,
        remotePage.results,
        page: page,
        limit: limit,
        count: remotePage.count,
        next: remotePage.next,
        previous: remotePage.previous,
      );
      return CharacterListPage(
        count: remotePage.count,
        next: remotePage.next,
        previous: remotePage.previous,
        results:
            remotePage.results.map((entry) => entry.toEntity()).toList(),
        currentPage: page,
      );
    } catch (error) {
      if (_isCancelled(error)) rethrow;
      if (cachedDtos != null && cachedDtos.isNotEmpty && cachedMeta != null) {
        return CharacterListPage(
          count: cachedMeta.count,
          next: cachedMeta.next,
          previous: cachedMeta.previous,
          results: cachedDtos.map((entry) => entry.toEntity()).toList(),
          currentPage: page,
        );
      }
      rethrow;
    }
  }

  Future<CharacterDetails> getCharacterDetails(
    int characterId, {
    bool forceRefresh = false,
  }) async {
    final cachedDto = await _localDataSource.getCharacterDetails(characterId);
    final cachedAt =
        await _localDataSource.getCharacterDetailsCachedAt(characterId);

    if (!forceRefresh && cachedDto != null) {
      final isFresh =
          cachedAt != null &&
          MetronCachePolicies.characterDetails.isFresh(cachedAt, _now());
      if (!isFresh) {
        _refreshInBackground(
          task: () async {
            await _characterDetailsGate.acquire();
            try {
              final remoteDto =
                  await _remoteDataSource.getCharacterDetails(characterId);
              await _localDataSource.cacheCharacterDetails(remoteDto);
            } finally {
              _characterDetailsGate.release();
            }
          },
          cacheKey: 'character_details:$characterId',
          cooldown: MetronCachePolicies.characterDetails.refreshCooldown,
        );
      }
      return cachedDto.toEntity();
    }

    try {
      final key = '$characterId|$forceRefresh';
      return _coalesce(_characterDetailsInFlight, key, () async {
        await _characterDetailsGate.acquire();
        try {
          final remoteDto =
              await _remoteDataSource.getCharacterDetails(characterId);
          await _localDataSource.cacheCharacterDetails(remoteDto);
          return remoteDto.toEntity();
        } finally {
          _characterDetailsGate.release();
        }
      }, timeout: const Duration(seconds: 30));
    } catch (e) {
      AppLogger.error('Failed to fetch character details', error: e);
      if (cachedDto != null) {
        return cachedDto.toEntity();
      }
      rethrow;
    }
  }

  Future<CharacterIssueListPage> getCharacterIssueList(
    int characterId, {
    String? nextUrl,
    int page = 1,
    int limit = metronDefaultPageSize,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  }) async {
    final cachedDtos = await _localDataSource.getCharacterIssueListResults(
      characterId,
      page: page,
      limit: limit,
    );
    final cachedAt =
        await _localDataSource.getCharacterIssueListResultsCachedAt(
      characterId,
      page: page,
      limit: limit,
    );
    final cachedMeta =
        await _localDataSource.getCharacterIssueListResultsMeta(
      characterId,
      page: page,
      limit: limit,
    );

    if (!forceRefresh && cachedDtos != null && cachedDtos.isNotEmpty) {
      final isFresh =
          cachedAt != null &&
          MetronCachePolicies.characterIssueList.isFresh(cachedAt, _now());
      if (!isFresh) {
        _refreshInBackground(
          task: () async {
            final remotePage = nextUrl != null
                ? await _remoteDataSource.getCharacterIssueList(
                    characterId,
                    nextUrl: Uri.parse(nextUrl),
                    limit: limit,
                    cancelToken: cancelToken,
                  )
                : await _remoteDataSource.getCharacterIssueList(
                    characterId,
                    page: page,
                    limit: limit,
                    cancelToken: cancelToken,
                  );
            await _localDataSource.cacheCharacterIssueListResults(
              characterId,
              remotePage.results,
              page: page,
              limit: limit,
              count: remotePage.count,
              next: remotePage.next,
              previous: remotePage.previous,
            );
            _indexSeriesNamesFromIssueList(remotePage.results);
          },
          cacheKey: nextUrl ?? 'character_issue_list:$characterId:$page',
          cooldown: MetronCachePolicies.characterIssueList.refreshCooldown,
        );
      }
      if (cachedMeta != null) {
        return CharacterIssueListPage(
          count: cachedMeta.count,
          next: cachedMeta.next,
          previous: cachedMeta.previous,
          results: cachedDtos.map((entry) => entry.toEntity()).toList(),
          currentPage: page,
        );
      }
    }

    try {
      final key = nextUrl ?? '$characterId|$page|$forceRefresh';
      return _coalesce(_characterIssueListInFlight, key, () async {
        final remotePage = nextUrl != null
            ? await _remoteDataSource.getCharacterIssueList(
                characterId,
                nextUrl: Uri.parse(nextUrl),
                limit: limit,
                cancelToken: cancelToken,
              )
            : await _remoteDataSource.getCharacterIssueList(
                characterId,
                page: page,
                limit: limit,
                cancelToken: cancelToken,
              );
        await _localDataSource.cacheCharacterIssueListResults(
          characterId,
          remotePage.results,
          page: page,
          limit: limit,
          count: remotePage.count,
          next: remotePage.next,
          previous: remotePage.previous,
        );
        _indexSeriesNamesFromIssueList(remotePage.results);
        return CharacterIssueListPage(
          count: remotePage.count,
          next: remotePage.next,
          previous: remotePage.previous,
          results:
              remotePage.results.map((entry) => entry.toEntity()).toList(),
          currentPage: page,
        );
      }, timeout: const Duration(seconds: 30));
    } catch (error) {
      if (_isCancelled(error)) rethrow;
      if (cachedDtos != null && cachedDtos.isNotEmpty && cachedMeta != null) {
        return CharacterIssueListPage(
          count: cachedMeta.count,
          next: cachedMeta.next,
          previous: cachedMeta.previous,
          results: cachedDtos.map((entry) => entry.toEntity()).toList(),
          currentPage: page,
        );
      }
      rethrow;
    }
  }
}
