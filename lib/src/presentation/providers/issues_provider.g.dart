// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'issues_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(weeklyReleases)
final weeklyReleasesProvider = WeeklyReleasesProvider._();

final class WeeklyReleasesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Issue>>,
          List<Issue>,
          FutureOr<List<Issue>>
        >
    with $FutureModifier<List<Issue>>, $FutureProvider<List<Issue>> {
  WeeklyReleasesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'weeklyReleasesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$weeklyReleasesHash();

  @$internal
  @override
  $FutureProviderElement<List<Issue>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Issue>> create(Ref ref) {
    return weeklyReleases(ref);
  }
}

String _$weeklyReleasesHash() => r'00057712b71bce9c14791977b5fd3f4dcd016aec';
