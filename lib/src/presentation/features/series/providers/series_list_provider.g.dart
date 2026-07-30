// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'series_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SeriesList)
final seriesListProvider = SeriesListFamily._();

final class SeriesListProvider
    extends $AsyncNotifierProvider<SeriesList, SeriesListPage> {
  SeriesListProvider._({
    required SeriesListFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'seriesListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$seriesListHash();

  @override
  String toString() {
    return r'seriesListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  SeriesList create() => SeriesList();

  @override
  bool operator ==(Object other) {
    return other is SeriesListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$seriesListHash() => r'da47ee5f43c1e3f8ed93e13e3dfe6c437f972eb1';

final class SeriesListFamily extends $Family
    with
        $ClassFamilyOverride<
          SeriesList,
          AsyncValue<SeriesListPage>,
          SeriesListPage,
          FutureOr<SeriesListPage>,
          int
        > {
  SeriesListFamily._()
    : super(
        retry: null,
        name: r'seriesListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SeriesListProvider call(int page) =>
      SeriesListProvider._(argument: page, from: this);

  @override
  String toString() => r'seriesListProvider';
}

abstract class _$SeriesList extends $AsyncNotifier<SeriesListPage> {
  late final _$args = ref.$arg as int;
  int get page => _$args;

  FutureOr<SeriesListPage> build(int page);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<SeriesListPage>, SeriesListPage>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<SeriesListPage>, SeriesListPage>,
              AsyncValue<SeriesListPage>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
