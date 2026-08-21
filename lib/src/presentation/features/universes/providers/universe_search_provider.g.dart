// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'universe_search_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(UniverseSearch)
final universeSearchProvider = UniverseSearchFamily._();

final class UniverseSearchProvider
    extends $AsyncNotifierProvider<UniverseSearch, UniverseListPage> {
  UniverseSearchProvider._({
    required UniverseSearchFamily super.from,
    required SearchArgs super.argument,
  }) : super(
         retry: null,
         name: r'universeSearchProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$universeSearchHash();

  @override
  String toString() {
    return r'universeSearchProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  UniverseSearch create() => UniverseSearch();

  @override
  bool operator ==(Object other) {
    return other is UniverseSearchProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$universeSearchHash() => r'0143c9fac55898ad88905e23465e4297460932b6';

final class UniverseSearchFamily extends $Family
    with
        $ClassFamilyOverride<
          UniverseSearch,
          AsyncValue<UniverseListPage>,
          UniverseListPage,
          FutureOr<UniverseListPage>,
          SearchArgs
        > {
  UniverseSearchFamily._()
    : super(
        retry: null,
        name: r'universeSearchProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  UniverseSearchProvider call(SearchArgs args) =>
      UniverseSearchProvider._(argument: args, from: this);

  @override
  String toString() => r'universeSearchProvider';
}

abstract class _$UniverseSearch extends $AsyncNotifier<UniverseListPage> {
  late final _$args = ref.$arg as SearchArgs;
  SearchArgs get args => _$args;

  FutureOr<UniverseListPage> build(SearchArgs args);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<UniverseListPage>, UniverseListPage>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<UniverseListPage>, UniverseListPage>,
              AsyncValue<UniverseListPage>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
