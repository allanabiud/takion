// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_list_details_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(readingListDetails)
final readingListDetailsProvider = ReadingListDetailsFamily._();

final class ReadingListDetailsProvider
    extends
        $FunctionalProvider<
          AsyncValue<ReadingList?>,
          ReadingList?,
          FutureOr<ReadingList?>
        >
    with $FutureModifier<ReadingList?>, $FutureProvider<ReadingList?> {
  ReadingListDetailsProvider._({
    required ReadingListDetailsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'readingListDetailsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$readingListDetailsHash();

  @override
  String toString() {
    return r'readingListDetailsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ReadingList?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ReadingList?> create(Ref ref) {
    final argument = this.argument as String;
    return readingListDetails(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ReadingListDetailsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$readingListDetailsHash() =>
    r'c5854934863b16783421bc9b1f753200e920843e';

final class ReadingListDetailsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ReadingList?>, String> {
  ReadingListDetailsFamily._()
    : super(
        retry: null,
        name: r'readingListDetailsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ReadingListDetailsProvider call(String listId) =>
      ReadingListDetailsProvider._(argument: listId, from: this);

  @override
  String toString() => r'readingListDetailsProvider';
}

@ProviderFor(ReadingListEditMode)
final readingListEditModeProvider = ReadingListEditModeFamily._();

final class ReadingListEditModeProvider
    extends $NotifierProvider<ReadingListEditMode, bool> {
  ReadingListEditModeProvider._({
    required ReadingListEditModeFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'readingListEditModeProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$readingListEditModeHash();

  @override
  String toString() {
    return r'readingListEditModeProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ReadingListEditMode create() => ReadingListEditMode();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ReadingListEditModeProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$readingListEditModeHash() =>
    r'cc6fff1c088dd97bffb990a341b1fd611a226f82';

final class ReadingListEditModeFamily extends $Family
    with $ClassFamilyOverride<ReadingListEditMode, bool, bool, bool, String> {
  ReadingListEditModeFamily._()
    : super(
        retry: null,
        name: r'readingListEditModeProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ReadingListEditModeProvider call(String listId) =>
      ReadingListEditModeProvider._(argument: listId, from: this);

  @override
  String toString() => r'readingListEditModeProvider';
}

abstract class _$ReadingListEditMode extends $Notifier<bool> {
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
