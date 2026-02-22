// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ThemeNotifier)
final themeProvider = ThemeNotifierProvider._();

final class ThemeNotifierProvider
    extends $AsyncNotifierProvider<ThemeNotifier, ThemeSettings> {
  ThemeNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$themeNotifierHash();

  @$internal
  @override
  ThemeNotifier create() => ThemeNotifier();
}

String _$themeNotifierHash() => r'15958c5ea7e006306748ae73967409e714aac8f8';

abstract class _$ThemeNotifier extends $AsyncNotifier<ThemeSettings> {
  FutureOr<ThemeSettings> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<ThemeSettings>, ThemeSettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ThemeSettings>, ThemeSettings>,
              AsyncValue<ThemeSettings>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
