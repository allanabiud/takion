// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weekly_releases_provider.dart';

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
    r'e5dcb74495a323c2798bdde27c8941fb36eb1c3a';

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
