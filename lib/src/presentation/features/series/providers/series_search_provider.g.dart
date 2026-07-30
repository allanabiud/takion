// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'series_search_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SeriesSearch)
final seriesSearchProvider = SeriesSearchFamily._();

final class SeriesSearchProvider
    extends $AsyncNotifierProvider<SeriesSearch, SeriesSearchPage> {
  SeriesSearchProvider._({
    required SeriesSearchFamily super.from,
    required SearchArgs super.argument,
  }) : super(
         retry: null,
         name: r'seriesSearchProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$seriesSearchHash();

  @override
  String toString() {
    return r'seriesSearchProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  SeriesSearch create() => SeriesSearch();

  @override
  bool operator ==(Object other) {
    return other is SeriesSearchProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$seriesSearchHash() => r'4178fadafa708acbfea716e1c1c1a35a4b81d895';

final class SeriesSearchFamily extends $Family
    with
        $ClassFamilyOverride<
          SeriesSearch,
          AsyncValue<SeriesSearchPage>,
          SeriesSearchPage,
          FutureOr<SeriesSearchPage>,
          SearchArgs
        > {
  SeriesSearchFamily._()
    : super(
        retry: null,
        name: r'seriesSearchProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SeriesSearchProvider call(SearchArgs args) =>
      SeriesSearchProvider._(argument: args, from: this);

  @override
  String toString() => r'seriesSearchProvider';
}

abstract class _$SeriesSearch extends $AsyncNotifier<SeriesSearchPage> {
  late final _$args = ref.$arg as SearchArgs;
  SearchArgs get args => _$args;

  FutureOr<SeriesSearchPage> build(SearchArgs args);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<SeriesSearchPage>, SeriesSearchPage>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<SeriesSearchPage>, SeriesSearchPage>,
              AsyncValue<SeriesSearchPage>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
