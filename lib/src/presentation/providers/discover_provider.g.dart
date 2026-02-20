// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discover_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DiscoverSearch)
final discoverSearchProvider = DiscoverSearchProvider._();

final class DiscoverSearchProvider
    extends $NotifierProvider<DiscoverSearch, SearchState> {
  DiscoverSearchProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'discoverSearchProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$discoverSearchHash();

  @$internal
  @override
  DiscoverSearch create() => DiscoverSearch();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SearchState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SearchState>(value),
    );
  }
}

String _$discoverSearchHash() => r'0e7929bef928d031ba1e822b8a2988db2f813805';

abstract class _$DiscoverSearch extends $Notifier<SearchState> {
  SearchState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SearchState, SearchState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SearchState, SearchState>,
              SearchState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
