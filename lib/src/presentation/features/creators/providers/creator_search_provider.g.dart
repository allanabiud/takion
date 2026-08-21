// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'creator_search_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CreatorSearch)
final creatorSearchProvider = CreatorSearchFamily._();

final class CreatorSearchProvider
    extends $AsyncNotifierProvider<CreatorSearch, CreatorListPage> {
  CreatorSearchProvider._({
    required CreatorSearchFamily super.from,
    required SearchArgs super.argument,
  }) : super(
         retry: null,
         name: r'creatorSearchProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$creatorSearchHash();

  @override
  String toString() {
    return r'creatorSearchProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  CreatorSearch create() => CreatorSearch();

  @override
  bool operator ==(Object other) {
    return other is CreatorSearchProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$creatorSearchHash() => r'05a9b5adbd4f3e2ab1485743ab7d25a5c5c2b645';

final class CreatorSearchFamily extends $Family
    with
        $ClassFamilyOverride<
          CreatorSearch,
          AsyncValue<CreatorListPage>,
          CreatorListPage,
          FutureOr<CreatorListPage>,
          SearchArgs
        > {
  CreatorSearchFamily._()
    : super(
        retry: null,
        name: r'creatorSearchProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CreatorSearchProvider call(SearchArgs args) =>
      CreatorSearchProvider._(argument: args, from: this);

  @override
  String toString() => r'creatorSearchProvider';
}

abstract class _$CreatorSearch extends $AsyncNotifier<CreatorListPage> {
  late final _$args = ref.$arg as SearchArgs;
  SearchArgs get args => _$args;

  FutureOr<CreatorListPage> build(SearchArgs args);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<CreatorListPage>, CreatorListPage>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<CreatorListPage>, CreatorListPage>,
              AsyncValue<CreatorListPage>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
