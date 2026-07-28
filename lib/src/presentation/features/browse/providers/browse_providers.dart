import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities.dart';
import 'package:takion/src/presentation/shared/widgets/components.dart';
import 'package:takion/src/presentation/providers/providers.dart';

class BrowseFilter {
  const BrowseFilter({this.page = 1, this.name});

  final int page;
  final String? name;

  @override
  bool operator ==(Object other) =>
      other is BrowseFilter && other.page == page && other.name == name;

  @override
  int get hashCode => Object.hash(page, name);

  BrowseFilter copyWith({int? page, String? name}) =>
      BrowseFilter(page: page ?? this.page, name: name ?? this.name);
}

BrowsePagedData<T> _browsePageData<T>({
  required int count,
  required List<T> results,
  required int currentPage,
  String? next,
  String? previous,
}) {
  int? pageFromUrl(String? url, {required bool defaultToFirstPage}) {
    if (url == null || url.isEmpty) return null;
    final uri = Uri.tryParse(url);
    if (uri == null) return null;
    final parsed = int.tryParse(uri.queryParameters['page'] ?? '');
    if (parsed != null) return parsed;
    return defaultToFirstPage ? 1 : null;
  }

  return BrowsePagedData(
    results: results,
    count: count,
    currentPage: currentPage,
    hasNext: pageFromUrl(next, defaultToFirstPage: false) != null,
    hasPrevious: pageFromUrl(previous, defaultToFirstPage: true) != null,
    previousPage: pageFromUrl(previous, defaultToFirstPage: true),
    nextPage: pageFromUrl(next, defaultToFirstPage: false),
  );
}

final characterBrowseProvider =
    FutureProvider.family<BrowsePagedData<CharacterList>, BrowseFilter>((
      ref,
      filter,
    ) async {
      final repo = ref.read(metronRepositoryProvider);
      final dynamic pageData =
          filter.name != null && filter.name!.trim().isNotEmpty
          ? await repo.searchCharacters(filter.name!, page: filter.page)
          : await repo.getCharacterList(page: filter.page);
      return _browsePageData<CharacterList>(
        count: pageData.count,
        results: List<CharacterList>.from(pageData.results),
        currentPage: filter.page,
        next: pageData.next,
        previous: pageData.previous,
      );
    });

final seriesBrowseProvider =
    FutureProvider.family<BrowsePagedData<SeriesList>, BrowseFilter>((
      ref,
      filter,
    ) async {
      final repo = ref.read(metronRepositoryProvider);
      final dynamic pageData =
          filter.name != null && filter.name!.trim().isNotEmpty
          ? await repo.searchSeries(filter.name!, page: filter.page)
          : await repo.getSeriesList(page: filter.page);
      return _browsePageData<SeriesList>(
        count: pageData.count,
        results: List<SeriesList>.from(pageData.results),
        currentPage: filter.page,
        next: pageData.next,
        previous: pageData.previous,
      );
    });

final publisherBrowseProvider =
    FutureProvider.family<BrowsePagedData<PublisherList>, BrowseFilter>((
      ref,
      filter,
    ) async {
      final repo = ref.read(metronRepositoryProvider);
      final dynamic pageData =
          filter.name != null && filter.name!.trim().isNotEmpty
          ? await repo.searchPublishers(filter.name!, page: filter.page)
          : await repo.getPublisherList(page: filter.page);
      return _browsePageData<PublisherList>(
        count: pageData.count,
        results: List<PublisherList>.from(pageData.results),
        currentPage: filter.page,
        next: pageData.next,
        previous: pageData.previous,
      );
    });

final teamBrowseProvider =
    FutureProvider.family<BrowsePagedData<TeamList>, BrowseFilter>((
      ref,
      filter,
    ) async {
      final repo = ref.read(metronRepositoryProvider);
      final dynamic pageData =
          filter.name != null && filter.name!.trim().isNotEmpty
          ? await repo.searchTeams(filter.name!, page: filter.page)
          : await repo.getTeamList(page: filter.page);
      return _browsePageData<TeamList>(
        count: pageData.count,
        results: List<TeamList>.from(pageData.results),
        currentPage: filter.page,
        next: pageData.next,
        previous: pageData.previous,
      );
    });

final arcBrowseProvider =
    FutureProvider.family<BrowsePagedData<ArcList>, BrowseFilter>((
      ref,
      filter,
    ) async {
      final repo = ref.read(metronRepositoryProvider);
      final dynamic pageData =
          filter.name != null && filter.name!.trim().isNotEmpty
          ? await repo.searchArcs(filter.name!, page: filter.page)
          : await repo.getArcList(page: filter.page);
      return _browsePageData<ArcList>(
        count: pageData.count,
        results: List<ArcList>.from(pageData.results),
        currentPage: filter.page,
        next: pageData.next,
        previous: pageData.previous,
      );
    });

final universeBrowseProvider =
    FutureProvider.family<BrowsePagedData<UniverseList>, BrowseFilter>((
      ref,
      filter,
    ) async {
      final repo = ref.read(metronRepositoryProvider);
      final dynamic pageData =
          filter.name != null && filter.name!.trim().isNotEmpty
          ? await repo.searchUniverses(filter.name!, page: filter.page)
          : await repo.getUniverseList(page: filter.page);
      return _browsePageData<UniverseList>(
        count: pageData.count,
        results: List<UniverseList>.from(pageData.results),
        currentPage: filter.page,
        next: pageData.next,
        previous: pageData.previous,
      );
    });

final imprintBrowseProvider =
    FutureProvider.family<BrowsePagedData<ImprintList>, BrowseFilter>((
      ref,
      filter,
    ) async {
      final repo = ref.read(metronRepositoryProvider);
      final dynamic pageData =
          filter.name != null && filter.name!.trim().isNotEmpty
          ? await repo.searchImprints(filter.name!, page: filter.page)
          : await repo.getImprintList(page: filter.page);
      return _browsePageData<ImprintList>(
        count: pageData.count,
        results: List<ImprintList>.from(pageData.results),
        currentPage: filter.page,
        next: pageData.next,
        previous: pageData.previous,
      );
    });

final creatorBrowseProvider =
    FutureProvider.family<BrowsePagedData<CreatorList>, BrowseFilter>((
      ref,
      filter,
    ) async {
      final repo = ref.read(metronRepositoryProvider);
      final dynamic pageData =
          filter.name != null && filter.name!.trim().isNotEmpty
          ? await repo.searchCreators(filter.name!, page: filter.page)
          : await repo.getCreatorList(page: filter.page);
      return _browsePageData<CreatorList>(
        count: pageData.count,
        results: List<CreatorList>.from(pageData.results),
        currentPage: filter.page,
        next: pageData.next,
        previous: pageData.previous,
      );
    });
