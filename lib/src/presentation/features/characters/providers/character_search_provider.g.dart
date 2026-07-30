// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'character_search_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CharacterSearch)
final characterSearchProvider = CharacterSearchFamily._();

final class CharacterSearchProvider
    extends $AsyncNotifierProvider<CharacterSearch, CharacterListPage> {
  CharacterSearchProvider._({
    required CharacterSearchFamily super.from,
    required SearchArgs super.argument,
  }) : super(
         retry: null,
         name: r'characterSearchProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$characterSearchHash();

  @override
  String toString() {
    return r'characterSearchProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  CharacterSearch create() => CharacterSearch();

  @override
  bool operator ==(Object other) {
    return other is CharacterSearchProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$characterSearchHash() => r'8c300dd4c1f3e5ea676b9ba5e8c2667409745815';

final class CharacterSearchFamily extends $Family
    with
        $ClassFamilyOverride<
          CharacterSearch,
          AsyncValue<CharacterListPage>,
          CharacterListPage,
          FutureOr<CharacterListPage>,
          SearchArgs
        > {
  CharacterSearchFamily._()
    : super(
        retry: null,
        name: r'characterSearchProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CharacterSearchProvider call(SearchArgs args) =>
      CharacterSearchProvider._(argument: args, from: this);

  @override
  String toString() => r'characterSearchProvider';
}

abstract class _$CharacterSearch extends $AsyncNotifier<CharacterListPage> {
  late final _$args = ref.$arg as SearchArgs;
  SearchArgs get args => _$args;

  FutureOr<CharacterListPage> build(SearchArgs args);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<CharacterListPage>, CharacterListPage>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<CharacterListPage>, CharacterListPage>,
              AsyncValue<CharacterListPage>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
