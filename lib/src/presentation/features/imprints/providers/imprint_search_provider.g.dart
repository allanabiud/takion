// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'imprint_search_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ImprintSearch)
final imprintSearchProvider = ImprintSearchFamily._();

final class ImprintSearchProvider
    extends $AsyncNotifierProvider<ImprintSearch, ImprintListPage> {
  ImprintSearchProvider._({
    required ImprintSearchFamily super.from,
    required SearchArgs super.argument,
  }) : super(
         retry: null,
         name: r'imprintSearchProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$imprintSearchHash();

  @override
  String toString() {
    return r'imprintSearchProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ImprintSearch create() => ImprintSearch();

  @override
  bool operator ==(Object other) {
    return other is ImprintSearchProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$imprintSearchHash() => r'900cf6c5887777b7cbe32e377298acd20af1ab9e';

final class ImprintSearchFamily extends $Family
    with
        $ClassFamilyOverride<
          ImprintSearch,
          AsyncValue<ImprintListPage>,
          ImprintListPage,
          FutureOr<ImprintListPage>,
          SearchArgs
        > {
  ImprintSearchFamily._()
    : super(
        retry: null,
        name: r'imprintSearchProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ImprintSearchProvider call(SearchArgs args) =>
      ImprintSearchProvider._(argument: args, from: this);

  @override
  String toString() => r'imprintSearchProvider';
}

abstract class _$ImprintSearch extends $AsyncNotifier<ImprintListPage> {
  late final _$args = ref.$arg as SearchArgs;
  SearchArgs get args => _$args;

  FutureOr<ImprintListPage> build(SearchArgs args);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<ImprintListPage>, ImprintListPage>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ImprintListPage>, ImprintListPage>,
              AsyncValue<ImprintListPage>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
