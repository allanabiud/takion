// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_results_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SearchResultsNotifier)
final searchResultsProvider = SearchResultsNotifierProvider._();

final class SearchResultsNotifierProvider
    extends $NotifierProvider<SearchResultsNotifier, SearchResultsState> {
  SearchResultsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchResultsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchResultsNotifierHash();

  @$internal
  @override
  SearchResultsNotifier create() => SearchResultsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SearchResultsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SearchResultsState>(value),
    );
  }
}

String _$searchResultsNotifierHash() =>
    r'e30e6a3037abc7d4993ef738ec95dadf8592f3a4';

abstract class _$SearchResultsNotifier extends $Notifier<SearchResultsState> {
  SearchResultsState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SearchResultsState, SearchResultsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SearchResultsState, SearchResultsState>,
              SearchResultsState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
