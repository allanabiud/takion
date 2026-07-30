// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'series_issue_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SeriesIssueList)
final seriesIssueListProvider = SeriesIssueListFamily._();

final class SeriesIssueListProvider
    extends $AsyncNotifierProvider<SeriesIssueList, SeriesIssueListPage> {
  SeriesIssueListProvider._({
    required SeriesIssueListFamily super.from,
    required SeriesIssueListArgs super.argument,
  }) : super(
         retry: null,
         name: r'seriesIssueListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$seriesIssueListHash();

  @override
  String toString() {
    return r'seriesIssueListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  SeriesIssueList create() => SeriesIssueList();

  @override
  bool operator ==(Object other) {
    return other is SeriesIssueListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$seriesIssueListHash() => r'b78531907ae6d91c813a14e6ec4d21919205ccad';

final class SeriesIssueListFamily extends $Family
    with
        $ClassFamilyOverride<
          SeriesIssueList,
          AsyncValue<SeriesIssueListPage>,
          SeriesIssueListPage,
          FutureOr<SeriesIssueListPage>,
          SeriesIssueListArgs
        > {
  SeriesIssueListFamily._()
    : super(
        retry: null,
        name: r'seriesIssueListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SeriesIssueListProvider call(SeriesIssueListArgs args) =>
      SeriesIssueListProvider._(argument: args, from: this);

  @override
  String toString() => r'seriesIssueListProvider';
}

abstract class _$SeriesIssueList extends $AsyncNotifier<SeriesIssueListPage> {
  late final _$args = ref.$arg as SeriesIssueListArgs;
  SeriesIssueListArgs get args => _$args;

  FutureOr<SeriesIssueListPage> build(SeriesIssueListArgs args);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<SeriesIssueListPage>, SeriesIssueListPage>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<SeriesIssueListPage>, SeriesIssueListPage>,
              AsyncValue<SeriesIssueListPage>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
