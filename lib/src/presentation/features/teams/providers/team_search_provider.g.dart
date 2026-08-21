// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team_search_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TeamSearch)
final teamSearchProvider = TeamSearchFamily._();

final class TeamSearchProvider
    extends $AsyncNotifierProvider<TeamSearch, TeamListPage> {
  TeamSearchProvider._({
    required TeamSearchFamily super.from,
    required SearchArgs super.argument,
  }) : super(
         retry: null,
         name: r'teamSearchProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$teamSearchHash();

  @override
  String toString() {
    return r'teamSearchProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  TeamSearch create() => TeamSearch();

  @override
  bool operator ==(Object other) {
    return other is TeamSearchProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$teamSearchHash() => r'c7f96ca3b4508c589b4b1ffe319180bb3a1c5a89';

final class TeamSearchFamily extends $Family
    with
        $ClassFamilyOverride<
          TeamSearch,
          AsyncValue<TeamListPage>,
          TeamListPage,
          FutureOr<TeamListPage>,
          SearchArgs
        > {
  TeamSearchFamily._()
    : super(
        retry: null,
        name: r'teamSearchProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TeamSearchProvider call(SearchArgs args) =>
      TeamSearchProvider._(argument: args, from: this);

  @override
  String toString() => r'teamSearchProvider';
}

abstract class _$TeamSearch extends $AsyncNotifier<TeamListPage> {
  late final _$args = ref.$arg as SearchArgs;
  SearchArgs get args => _$args;

  FutureOr<TeamListPage> build(SearchArgs args);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<TeamListPage>, TeamListPage>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<TeamListPage>, TeamListPage>,
              AsyncValue<TeamListPage>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
