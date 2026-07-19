// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'issue_details_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

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
    r'b87a25f6e0e6eba9daf6c0c58b60fc494cad885b';

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
