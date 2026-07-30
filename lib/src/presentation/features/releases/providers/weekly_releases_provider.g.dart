// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weekly_releases_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(WeeklyReleases)
final weeklyReleasesProvider = WeeklyReleasesFamily._();

final class WeeklyReleasesProvider
    extends $AsyncNotifierProvider<WeeklyReleases, List<IssueList>> {
  WeeklyReleasesProvider._({
    required WeeklyReleasesFamily super.from,
    required DateTime? super.argument,
  }) : super(
         retry: null,
         name: r'weeklyReleasesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$weeklyReleasesHash();

  @override
  String toString() {
    return r'weeklyReleasesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  WeeklyReleases create() => WeeklyReleases();

  @override
  bool operator ==(Object other) {
    return other is WeeklyReleasesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$weeklyReleasesHash() => r'924426513005f28c10368c564f0690f86035333a';

final class WeeklyReleasesFamily extends $Family
    with
        $ClassFamilyOverride<
          WeeklyReleases,
          AsyncValue<List<IssueList>>,
          List<IssueList>,
          FutureOr<List<IssueList>>,
          DateTime?
        > {
  WeeklyReleasesFamily._()
    : super(
        retry: null,
        name: r'weeklyReleasesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WeeklyReleasesProvider call([DateTime? date]) =>
      WeeklyReleasesProvider._(argument: date, from: this);

  @override
  String toString() => r'weeklyReleasesProvider';
}

abstract class _$WeeklyReleases extends $AsyncNotifier<List<IssueList>> {
  late final _$args = ref.$arg as DateTime?;
  DateTime? get date => _$args;

  FutureOr<List<IssueList>> build([DateTime? date]);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<IssueList>>, List<IssueList>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<IssueList>>, List<IssueList>>,
              AsyncValue<List<IssueList>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(FocReleases)
final focReleasesProvider = FocReleasesFamily._();

final class FocReleasesProvider
    extends $AsyncNotifierProvider<FocReleases, List<IssueList>> {
  FocReleasesProvider._({
    required FocReleasesFamily super.from,
    required DateTime super.argument,
  }) : super(
         retry: null,
         name: r'focReleasesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$focReleasesHash();

  @override
  String toString() {
    return r'focReleasesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  FocReleases create() => FocReleases();

  @override
  bool operator ==(Object other) {
    return other is FocReleasesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$focReleasesHash() => r'd2159a35ff1e7119d7f97819844e3278f850b37c';

final class FocReleasesFamily extends $Family
    with
        $ClassFamilyOverride<
          FocReleases,
          AsyncValue<List<IssueList>>,
          List<IssueList>,
          FutureOr<List<IssueList>>,
          DateTime
        > {
  FocReleasesFamily._()
    : super(
        retry: null,
        name: r'focReleasesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FocReleasesProvider call(DateTime date) =>
      FocReleasesProvider._(argument: date, from: this);

  @override
  String toString() => r'focReleasesProvider';
}

abstract class _$FocReleases extends $AsyncNotifier<List<IssueList>> {
  late final _$args = ref.$arg as DateTime;
  DateTime get date => _$args;

  FutureOr<List<IssueList>> build(DateTime date);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<IssueList>>, List<IssueList>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<IssueList>>, List<IssueList>>,
              AsyncValue<List<IssueList>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
