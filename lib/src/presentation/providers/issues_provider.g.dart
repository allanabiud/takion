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
    extends $AsyncNotifierProvider<WeeklyReleasesNotifier, List<Issue>> {
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
    r'022d4ce565ad35ac2796b42d9312cdbcfc101b5b';

final class WeeklyReleasesNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          WeeklyReleasesNotifier,
          AsyncValue<List<Issue>>,
          List<Issue>,
          FutureOr<List<Issue>>,
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

abstract class _$WeeklyReleasesNotifier extends $AsyncNotifier<List<Issue>> {
  late final _$args = ref.$arg as DateTime?;
  DateTime? get date => _$args;

  FutureOr<List<Issue>> build([DateTime? date]);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Issue>>, List<Issue>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Issue>>, List<Issue>>,
              AsyncValue<List<Issue>>,
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
          AsyncValue<List<Issue>>,
          List<Issue>,
          FutureOr<List<Issue>>
        >
    with $FutureModifier<List<Issue>>, $FutureProvider<List<Issue>> {
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
  $FutureProviderElement<List<Issue>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Issue>> create(Ref ref) {
    return currentWeeklyReleases(ref);
  }
}

String _$currentWeeklyReleasesHash() =>
    r'f39b6d0ec1c413925c0c1bc69ad442dab3fe6635';

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
