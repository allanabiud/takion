// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collection_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(collectionStats)
final collectionStatsProvider = CollectionStatsProvider._();

final class CollectionStatsProvider
    extends
        $FunctionalProvider<
          AsyncValue<CollectionStats>,
          CollectionStats,
          FutureOr<CollectionStats>
        >
    with $FutureModifier<CollectionStats>, $FutureProvider<CollectionStats> {
  CollectionStatsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'collectionStatsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$collectionStatsHash();

  @$internal
  @override
  $FutureProviderElement<CollectionStats> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CollectionStats> create(Ref ref) {
    return collectionStats(ref);
  }
}

String _$collectionStatsHash() => r'171ed901268f99c98020e30b8dae87e7d802aaa0';

@ProviderFor(readingSuggestion)
final readingSuggestionProvider = ReadingSuggestionProvider._();

final class ReadingSuggestionProvider
    extends $FunctionalProvider<AsyncValue<Issue?>, Issue?, FutureOr<Issue?>>
    with $FutureModifier<Issue?>, $FutureProvider<Issue?> {
  ReadingSuggestionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'readingSuggestionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$readingSuggestionHash();

  @$internal
  @override
  $FutureProviderElement<Issue?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Issue?> create(Ref ref) {
    return readingSuggestion(ref);
  }
}

String _$readingSuggestionHash() => r'81b74d80bcaea1783d747a35de4e687ab7f3d398';

@ProviderFor(CollectionNotifier)
final collectionProvider = CollectionNotifierProvider._();

final class CollectionNotifierProvider
    extends $AsyncNotifierProvider<CollectionNotifier, Map<int, bool>> {
  CollectionNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'collectionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$collectionNotifierHash();

  @$internal
  @override
  CollectionNotifier create() => CollectionNotifier();
}

String _$collectionNotifierHash() =>
    r'c9a40d30a4f9ff4345038957ce8ba7fd7cbe93b3';

abstract class _$CollectionNotifier extends $AsyncNotifier<Map<int, bool>> {
  FutureOr<Map<int, bool>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Map<int, bool>>, Map<int, bool>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Map<int, bool>>, Map<int, bool>>,
              AsyncValue<Map<int, bool>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
