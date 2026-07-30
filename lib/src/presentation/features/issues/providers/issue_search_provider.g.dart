// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'issue_search_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(IssueSearch)
final issueSearchProvider = IssueSearchFamily._();

final class IssueSearchProvider
    extends $AsyncNotifierProvider<IssueSearch, IssueSearchPage> {
  IssueSearchProvider._({
    required IssueSearchFamily super.from,
    required SearchArgs super.argument,
  }) : super(
         retry: null,
         name: r'issueSearchProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$issueSearchHash();

  @override
  String toString() {
    return r'issueSearchProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  IssueSearch create() => IssueSearch();

  @override
  bool operator ==(Object other) {
    return other is IssueSearchProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$issueSearchHash() => r'77d73b4887a16b74b05c8c8ec3b783650f60ab84';

final class IssueSearchFamily extends $Family
    with
        $ClassFamilyOverride<
          IssueSearch,
          AsyncValue<IssueSearchPage>,
          IssueSearchPage,
          FutureOr<IssueSearchPage>,
          SearchArgs
        > {
  IssueSearchFamily._()
    : super(
        retry: null,
        name: r'issueSearchProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  IssueSearchProvider call(SearchArgs args) =>
      IssueSearchProvider._(argument: args, from: this);

  @override
  String toString() => r'issueSearchProvider';
}

abstract class _$IssueSearch extends $AsyncNotifier<IssueSearchPage> {
  late final _$args = ref.$arg as SearchArgs;
  SearchArgs get args => _$args;

  FutureOr<IssueSearchPage> build(SearchArgs args);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<IssueSearchPage>, IssueSearchPage>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<IssueSearchPage>, IssueSearchPage>,
              AsyncValue<IssueSearchPage>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
