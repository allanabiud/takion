// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'issues_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(WeeklyReleasesNotifier)
final weeklyReleasesProvider = WeeklyReleasesNotifierFamily._();

final class WeeklyReleasesNotifierProvider
    extends $AsyncNotifierProvider<WeeklyReleasesNotifier, List<IssueList>> {
  WeeklyReleasesNotifierProvider._({
    required WeeklyReleasesNotifierFamily super.from,
    required DateTime? super.argument,
  }) : super(
         retry: null,
         name: r'weeklyReleasesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$weeklyReleasesNotifierHash();

  @override
  String toString() {
    return r'weeklyReleasesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  WeeklyReleasesNotifier create() => WeeklyReleasesNotifier();

  @override
  bool operator ==(Object other) {
    return other is WeeklyReleasesNotifierProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$weeklyReleasesNotifierHash() =>
    r'b4a4b97522db1f25bee560f995f8dfe53c091f7a';

final class WeeklyReleasesNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          WeeklyReleasesNotifier,
          AsyncValue<List<IssueList>>,
          List<IssueList>,
          FutureOr<List<IssueList>>,
          DateTime?
        > {
  WeeklyReleasesNotifierFamily._()
    : super(
        retry: null,
        name: r'weeklyReleasesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WeeklyReleasesNotifierProvider call([DateTime? date]) =>
      WeeklyReleasesNotifierProvider._(argument: date, from: this);

  @override
  String toString() => r'weeklyReleasesProvider';
}

abstract class _$WeeklyReleasesNotifier
    extends $AsyncNotifier<List<IssueList>> {
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

@ProviderFor(IssueDetailsNotifier)
final issueDetailsProvider = IssueDetailsNotifierFamily._();

final class IssueDetailsNotifierProvider
    extends $AsyncNotifierProvider<IssueDetailsNotifier, IssueDetails> {
  IssueDetailsNotifierProvider._({
    required IssueDetailsNotifierFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'issueDetailsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$issueDetailsNotifierHash();

  @override
  String toString() {
    return r'issueDetailsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  IssueDetailsNotifier create() => IssueDetailsNotifier();

  @override
  bool operator ==(Object other) {
    return other is IssueDetailsNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$issueDetailsNotifierHash() =>
    r'c936db49c22b90215e6a6a6d1e76e6173e479b32';

final class IssueDetailsNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          IssueDetailsNotifier,
          AsyncValue<IssueDetails>,
          IssueDetails,
          FutureOr<IssueDetails>,
          int
        > {
  IssueDetailsNotifierFamily._()
    : super(
        retry: null,
        name: r'issueDetailsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  IssueDetailsNotifierProvider call(int issueId) =>
      IssueDetailsNotifierProvider._(argument: issueId, from: this);

  @override
  String toString() => r'issueDetailsProvider';
}

abstract class _$IssueDetailsNotifier extends $AsyncNotifier<IssueDetails> {
  late final _$args = ref.$arg as int;
  int get issueId => _$args;

  FutureOr<IssueDetails> build(int issueId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<IssueDetails>, IssueDetails>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<IssueDetails>, IssueDetails>,
              AsyncValue<IssueDetails>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(currentWeeklyReleases)
final currentWeeklyReleasesProvider = CurrentWeeklyReleasesProvider._();

final class CurrentWeeklyReleasesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<IssueList>>,
          List<IssueList>,
          FutureOr<List<IssueList>>
        >
    with $FutureModifier<List<IssueList>>, $FutureProvider<List<IssueList>> {
  CurrentWeeklyReleasesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentWeeklyReleasesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentWeeklyReleasesHash();

  @$internal
  @override
  $FutureProviderElement<List<IssueList>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<IssueList>> create(Ref ref) {
    return currentWeeklyReleases(ref);
  }
}

String _$currentWeeklyReleasesHash() =>
    r'dbb16925f253212eb0b1857cd6196ff87a1150d9';

@ProviderFor(SelectedWeek)
final selectedWeekProvider = SelectedWeekProvider._();

final class SelectedWeekProvider
    extends $NotifierProvider<SelectedWeek, DateTime> {
  SelectedWeekProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedWeekProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedWeekHash();

  @$internal
  @override
  SelectedWeek create() => SelectedWeek();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime>(value),
    );
  }
}

String _$selectedWeekHash() => r'def5ec7a38efeba0f48d3b31a8338c1704663ecb';

abstract class _$SelectedWeek extends $Notifier<DateTime> {
  DateTime build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<DateTime, DateTime>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DateTime, DateTime>,
              DateTime,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
