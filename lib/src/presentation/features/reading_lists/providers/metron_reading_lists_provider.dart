import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities.dart';
import 'package:takion/src/presentation/shared/widgets/components.dart';
import 'package:takion/src/presentation/providers/providers.dart';

final metronReadingListsProvider =
    FutureProvider.family<List<MetronReadingList>, MetronReadingListFilter>((
      ref,
      filter,
    ) async {
      final repository = ref.read(metronRepositoryProvider);
      final page = await repository.searchReadingLists(
        page: filter.page,
        name: filter.name,
        listType: filter.listType,
        attributionSource: filter.attributionSource,
        publisher: filter.publisher,
      );
      return page.results;
    });

final metronReadingListBrowseProvider =
    FutureProvider.family<
      BrowsePagedData<MetronReadingList>,
      MetronReadingListFilter
    >((ref, filter) async {
      final repository = ref.read(metronRepositoryProvider);
      final page = await repository.searchReadingLists(
        page: filter.page,
        name: filter.name,
        listType: filter.listType,
        attributionSource: filter.attributionSource,
        publisher: filter.publisher,
      );
      return BrowsePagedData(
        results: page.results,
        count: page.count,
        currentPage: filter.page,
        hasPrevious: page.hasPrevious,
        hasNext: page.hasNext,
        previousPage: page.previousPage,
        nextPage: page.nextPage,
      );
    });

class MetronReadingListFilter {
  const MetronReadingListFilter({
    this.page = 1,
    this.name,
    this.listType,
    this.attributionSource,
    this.publisher,
  });

  final int page;
  final String? name;
  final String? listType;
  final String? attributionSource;
  final String? publisher;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MetronReadingListFilter &&
        other.page == page &&
        other.name == name &&
        other.listType == listType &&
        other.attributionSource == attributionSource &&
        other.publisher == publisher;
  }

  @override
  int get hashCode =>
      Object.hash(page, name, listType, attributionSource, publisher);

  MetronReadingListFilter copyWith({
    int? page,
    String? name,
    String? listType,
    String? attributionSource,
    String? publisher,
  }) {
    return MetronReadingListFilter(
      page: page ?? this.page,
      name: name ?? this.name,
      listType: listType ?? this.listType,
      attributionSource: attributionSource ?? this.attributionSource,
      publisher: publisher ?? this.publisher,
    );
  }

  MetronReadingListFilter resetPage() {
    return copyWith(page: 1);
  }

  MetronReadingListFilter nextPage() {
    return copyWith(page: page + 1);
  }
}

final metronReadingListDetailProvider =
    FutureProvider.family<MetronReadingListDetailData, int>((ref, id) async {
      final repository = ref.read(metronRepositoryProvider);
      final detail = await repository.getReadingListDetail(id);
      final items = await repository.getReadingListItems(id);
      return MetronReadingListDetailData(detail: detail, items: items);
    });

class MetronReadingListDetailData {
  const MetronReadingListDetailData({
    required this.detail,
    required this.items,
  });

  final MetronReadingListDetail detail;
  final List<MetronReadingListItem> items;
}

class MetronListPreviewItemsNotifier
    extends Notifier<Map<int, List<ReadingListItem>>> {
  @override
  Map<int, List<ReadingListItem>> build() => const {};

  void setPreviewItems(int listId, List<ReadingListItem> items) {
    state = Map<int, List<ReadingListItem>>.from(state)..[listId] = items;
  }
}

final metronListPreviewItemsProvider =
    NotifierProvider<
      MetronListPreviewItemsNotifier,
      Map<int, List<ReadingListItem>>
    >(MetronListPreviewItemsNotifier.new);
