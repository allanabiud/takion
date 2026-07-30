// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'arc_search_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ArcSearch)
final arcSearchProvider = ArcSearchFamily._();

final class ArcSearchProvider
    extends $AsyncNotifierProvider<ArcSearch, ArcListPage> {
  ArcSearchProvider._({
    required ArcSearchFamily super.from,
    required SearchArgs super.argument,
  }) : super(
         retry: null,
         name: r'arcSearchProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$arcSearchHash();

  @override
  String toString() {
    return r'arcSearchProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ArcSearch create() => ArcSearch();

  @override
  bool operator ==(Object other) {
    return other is ArcSearchProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$arcSearchHash() => r'fe71050ed29447e7753a87531862ca391f86157b';

final class ArcSearchFamily extends $Family
    with
        $ClassFamilyOverride<
          ArcSearch,
          AsyncValue<ArcListPage>,
          ArcListPage,
          FutureOr<ArcListPage>,
          SearchArgs
        > {
  ArcSearchFamily._()
    : super(
        retry: null,
        name: r'arcSearchProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ArcSearchProvider call(SearchArgs args) =>
      ArcSearchProvider._(argument: args, from: this);

  @override
  String toString() => r'arcSearchProvider';
}

abstract class _$ArcSearch extends $AsyncNotifier<ArcListPage> {
  late final _$args = ref.$arg as SearchArgs;
  SearchArgs get args => _$args;

  FutureOr<ArcListPage> build(SearchArgs args);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<ArcListPage>, ArcListPage>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ArcListPage>, ArcListPage>,
              AsyncValue<ArcListPage>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
