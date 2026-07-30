// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'publisher_search_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PublisherSearch)
final publisherSearchProvider = PublisherSearchFamily._();

final class PublisherSearchProvider
    extends $AsyncNotifierProvider<PublisherSearch, PublisherListPage> {
  PublisherSearchProvider._({
    required PublisherSearchFamily super.from,
    required SearchArgs super.argument,
  }) : super(
         retry: null,
         name: r'publisherSearchProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$publisherSearchHash();

  @override
  String toString() {
    return r'publisherSearchProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  PublisherSearch create() => PublisherSearch();

  @override
  bool operator ==(Object other) {
    return other is PublisherSearchProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$publisherSearchHash() => r'421f3ea58f62f0774f391f36cbf1cb26e442397c';

final class PublisherSearchFamily extends $Family
    with
        $ClassFamilyOverride<
          PublisherSearch,
          AsyncValue<PublisherListPage>,
          PublisherListPage,
          FutureOr<PublisherListPage>,
          SearchArgs
        > {
  PublisherSearchFamily._()
    : super(
        retry: null,
        name: r'publisherSearchProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PublisherSearchProvider call(SearchArgs args) =>
      PublisherSearchProvider._(argument: args, from: this);

  @override
  String toString() => r'publisherSearchProvider';
}

abstract class _$PublisherSearch extends $AsyncNotifier<PublisherListPage> {
  late final _$args = ref.$arg as SearchArgs;
  SearchArgs get args => _$args;

  FutureOr<PublisherListPage> build(SearchArgs args);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<PublisherListPage>, PublisherListPage>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<PublisherListPage>, PublisherListPage>,
              AsyncValue<PublisherListPage>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
