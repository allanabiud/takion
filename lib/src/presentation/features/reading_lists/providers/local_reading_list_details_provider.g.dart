// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_reading_list_details_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(localReadingListDetails)
final localReadingListDetailsProvider = LocalReadingListDetailsFamily._();

final class LocalReadingListDetailsProvider
    extends
        $FunctionalProvider<
          AsyncValue<LocalReadingList?>,
          LocalReadingList?,
          FutureOr<LocalReadingList?>
        >
    with
        $FutureModifier<LocalReadingList?>,
        $FutureProvider<LocalReadingList?> {
  LocalReadingListDetailsProvider._({
    required LocalReadingListDetailsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'localReadingListDetailsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$localReadingListDetailsHash();

  @override
  String toString() {
    return r'localReadingListDetailsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<LocalReadingList?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<LocalReadingList?> create(Ref ref) {
    final argument = this.argument as String;
    return localReadingListDetails(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is LocalReadingListDetailsProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$localReadingListDetailsHash() =>
    r'22a833f74d1ec1bff8044d4807fabfa19a2a45a1';

final class LocalReadingListDetailsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<LocalReadingList?>, String> {
  LocalReadingListDetailsFamily._()
    : super(
        retry: null,
        name: r'localReadingListDetailsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  LocalReadingListDetailsProvider call(String listId) =>
      LocalReadingListDetailsProvider._(argument: listId, from: this);

  @override
  String toString() => r'localReadingListDetailsProvider';
}

@ProviderFor(LocalReadingListEditMode)
final localReadingListEditModeProvider = LocalReadingListEditModeFamily._();

final class LocalReadingListEditModeProvider
    extends $NotifierProvider<LocalReadingListEditMode, bool> {
  LocalReadingListEditModeProvider._({
    required LocalReadingListEditModeFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'localReadingListEditModeProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$localReadingListEditModeHash();

  @override
  String toString() {
    return r'localReadingListEditModeProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  LocalReadingListEditMode create() => LocalReadingListEditMode();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is LocalReadingListEditModeProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$localReadingListEditModeHash() =>
    r'3bb30d65343ebb57f42ba7d198a6164e4ccfd23b';

final class LocalReadingListEditModeFamily extends $Family
    with
        $ClassFamilyOverride<
          LocalReadingListEditMode,
          bool,
          bool,
          bool,
          String
        > {
  LocalReadingListEditModeFamily._()
    : super(
        retry: null,
        name: r'localReadingListEditModeProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  LocalReadingListEditModeProvider call(String listId) =>
      LocalReadingListEditModeProvider._(argument: listId, from: this);

  @override
  String toString() => r'localReadingListEditModeProvider';
}

abstract class _$LocalReadingListEditMode extends $Notifier<bool> {
  late final _$args = ref.$arg as String;
  String get listId => _$args;

  bool build(String listId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
