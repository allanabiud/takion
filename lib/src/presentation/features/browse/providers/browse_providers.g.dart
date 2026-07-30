// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'browse_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CharacterBrowse)
final characterBrowseProvider = CharacterBrowseFamily._();

final class CharacterBrowseProvider
    extends
        $AsyncNotifierProvider<
          CharacterBrowse,
          BrowsePagedData<CharacterList>
        > {
  CharacterBrowseProvider._({
    required CharacterBrowseFamily super.from,
    required BrowseFilter super.argument,
  }) : super(
         retry: null,
         name: r'characterBrowseProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$characterBrowseHash();

  @override
  String toString() {
    return r'characterBrowseProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  CharacterBrowse create() => CharacterBrowse();

  @override
  bool operator ==(Object other) {
    return other is CharacterBrowseProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$characterBrowseHash() => r'436e3add9cc170d7808dc9910245fab3726e5627';

final class CharacterBrowseFamily extends $Family
    with
        $ClassFamilyOverride<
          CharacterBrowse,
          AsyncValue<BrowsePagedData<CharacterList>>,
          BrowsePagedData<CharacterList>,
          FutureOr<BrowsePagedData<CharacterList>>,
          BrowseFilter
        > {
  CharacterBrowseFamily._()
    : super(
        retry: null,
        name: r'characterBrowseProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CharacterBrowseProvider call(BrowseFilter filter) =>
      CharacterBrowseProvider._(argument: filter, from: this);

  @override
  String toString() => r'characterBrowseProvider';
}

abstract class _$CharacterBrowse
    extends $AsyncNotifier<BrowsePagedData<CharacterList>> {
  late final _$args = ref.$arg as BrowseFilter;
  BrowseFilter get filter => _$args;

  FutureOr<BrowsePagedData<CharacterList>> build(BrowseFilter filter);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<BrowsePagedData<CharacterList>>,
              BrowsePagedData<CharacterList>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<BrowsePagedData<CharacterList>>,
                BrowsePagedData<CharacterList>
              >,
              AsyncValue<BrowsePagedData<CharacterList>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(SeriesBrowse)
final seriesBrowseProvider = SeriesBrowseFamily._();

final class SeriesBrowseProvider
    extends $AsyncNotifierProvider<SeriesBrowse, BrowsePagedData<SeriesList>> {
  SeriesBrowseProvider._({
    required SeriesBrowseFamily super.from,
    required BrowseFilter super.argument,
  }) : super(
         retry: null,
         name: r'seriesBrowseProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$seriesBrowseHash();

  @override
  String toString() {
    return r'seriesBrowseProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  SeriesBrowse create() => SeriesBrowse();

  @override
  bool operator ==(Object other) {
    return other is SeriesBrowseProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$seriesBrowseHash() => r'cbc006b45cb9cbd4cc13480a23f6a92c21059b06';

final class SeriesBrowseFamily extends $Family
    with
        $ClassFamilyOverride<
          SeriesBrowse,
          AsyncValue<BrowsePagedData<SeriesList>>,
          BrowsePagedData<SeriesList>,
          FutureOr<BrowsePagedData<SeriesList>>,
          BrowseFilter
        > {
  SeriesBrowseFamily._()
    : super(
        retry: null,
        name: r'seriesBrowseProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SeriesBrowseProvider call(BrowseFilter filter) =>
      SeriesBrowseProvider._(argument: filter, from: this);

  @override
  String toString() => r'seriesBrowseProvider';
}

abstract class _$SeriesBrowse
    extends $AsyncNotifier<BrowsePagedData<SeriesList>> {
  late final _$args = ref.$arg as BrowseFilter;
  BrowseFilter get filter => _$args;

  FutureOr<BrowsePagedData<SeriesList>> build(BrowseFilter filter);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<BrowsePagedData<SeriesList>>,
              BrowsePagedData<SeriesList>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<BrowsePagedData<SeriesList>>,
                BrowsePagedData<SeriesList>
              >,
              AsyncValue<BrowsePagedData<SeriesList>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(PublisherBrowse)
final publisherBrowseProvider = PublisherBrowseFamily._();

final class PublisherBrowseProvider
    extends
        $AsyncNotifierProvider<
          PublisherBrowse,
          BrowsePagedData<PublisherList>
        > {
  PublisherBrowseProvider._({
    required PublisherBrowseFamily super.from,
    required BrowseFilter super.argument,
  }) : super(
         retry: null,
         name: r'publisherBrowseProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$publisherBrowseHash();

  @override
  String toString() {
    return r'publisherBrowseProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  PublisherBrowse create() => PublisherBrowse();

  @override
  bool operator ==(Object other) {
    return other is PublisherBrowseProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$publisherBrowseHash() => r'e37150966b382c3db22468c7f4164f7d17368473';

final class PublisherBrowseFamily extends $Family
    with
        $ClassFamilyOverride<
          PublisherBrowse,
          AsyncValue<BrowsePagedData<PublisherList>>,
          BrowsePagedData<PublisherList>,
          FutureOr<BrowsePagedData<PublisherList>>,
          BrowseFilter
        > {
  PublisherBrowseFamily._()
    : super(
        retry: null,
        name: r'publisherBrowseProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PublisherBrowseProvider call(BrowseFilter filter) =>
      PublisherBrowseProvider._(argument: filter, from: this);

  @override
  String toString() => r'publisherBrowseProvider';
}

abstract class _$PublisherBrowse
    extends $AsyncNotifier<BrowsePagedData<PublisherList>> {
  late final _$args = ref.$arg as BrowseFilter;
  BrowseFilter get filter => _$args;

  FutureOr<BrowsePagedData<PublisherList>> build(BrowseFilter filter);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<BrowsePagedData<PublisherList>>,
              BrowsePagedData<PublisherList>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<BrowsePagedData<PublisherList>>,
                BrowsePagedData<PublisherList>
              >,
              AsyncValue<BrowsePagedData<PublisherList>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(TeamBrowse)
final teamBrowseProvider = TeamBrowseFamily._();

final class TeamBrowseProvider
    extends $AsyncNotifierProvider<TeamBrowse, BrowsePagedData<TeamList>> {
  TeamBrowseProvider._({
    required TeamBrowseFamily super.from,
    required BrowseFilter super.argument,
  }) : super(
         retry: null,
         name: r'teamBrowseProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$teamBrowseHash();

  @override
  String toString() {
    return r'teamBrowseProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  TeamBrowse create() => TeamBrowse();

  @override
  bool operator ==(Object other) {
    return other is TeamBrowseProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$teamBrowseHash() => r'7403725b096b8355b0d82149e0792fadc5c25cd4';

final class TeamBrowseFamily extends $Family
    with
        $ClassFamilyOverride<
          TeamBrowse,
          AsyncValue<BrowsePagedData<TeamList>>,
          BrowsePagedData<TeamList>,
          FutureOr<BrowsePagedData<TeamList>>,
          BrowseFilter
        > {
  TeamBrowseFamily._()
    : super(
        retry: null,
        name: r'teamBrowseProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TeamBrowseProvider call(BrowseFilter filter) =>
      TeamBrowseProvider._(argument: filter, from: this);

  @override
  String toString() => r'teamBrowseProvider';
}

abstract class _$TeamBrowse extends $AsyncNotifier<BrowsePagedData<TeamList>> {
  late final _$args = ref.$arg as BrowseFilter;
  BrowseFilter get filter => _$args;

  FutureOr<BrowsePagedData<TeamList>> build(BrowseFilter filter);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<BrowsePagedData<TeamList>>,
              BrowsePagedData<TeamList>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<BrowsePagedData<TeamList>>,
                BrowsePagedData<TeamList>
              >,
              AsyncValue<BrowsePagedData<TeamList>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(ArcBrowse)
final arcBrowseProvider = ArcBrowseFamily._();

final class ArcBrowseProvider
    extends $AsyncNotifierProvider<ArcBrowse, BrowsePagedData<ArcList>> {
  ArcBrowseProvider._({
    required ArcBrowseFamily super.from,
    required BrowseFilter super.argument,
  }) : super(
         retry: null,
         name: r'arcBrowseProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$arcBrowseHash();

  @override
  String toString() {
    return r'arcBrowseProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ArcBrowse create() => ArcBrowse();

  @override
  bool operator ==(Object other) {
    return other is ArcBrowseProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$arcBrowseHash() => r'4330fc08b92f6bcc7dc254dbefe5003e5039e49b';

final class ArcBrowseFamily extends $Family
    with
        $ClassFamilyOverride<
          ArcBrowse,
          AsyncValue<BrowsePagedData<ArcList>>,
          BrowsePagedData<ArcList>,
          FutureOr<BrowsePagedData<ArcList>>,
          BrowseFilter
        > {
  ArcBrowseFamily._()
    : super(
        retry: null,
        name: r'arcBrowseProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ArcBrowseProvider call(BrowseFilter filter) =>
      ArcBrowseProvider._(argument: filter, from: this);

  @override
  String toString() => r'arcBrowseProvider';
}

abstract class _$ArcBrowse extends $AsyncNotifier<BrowsePagedData<ArcList>> {
  late final _$args = ref.$arg as BrowseFilter;
  BrowseFilter get filter => _$args;

  FutureOr<BrowsePagedData<ArcList>> build(BrowseFilter filter);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<BrowsePagedData<ArcList>>,
              BrowsePagedData<ArcList>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<BrowsePagedData<ArcList>>,
                BrowsePagedData<ArcList>
              >,
              AsyncValue<BrowsePagedData<ArcList>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(UniverseBrowse)
final universeBrowseProvider = UniverseBrowseFamily._();

final class UniverseBrowseProvider
    extends
        $AsyncNotifierProvider<UniverseBrowse, BrowsePagedData<UniverseList>> {
  UniverseBrowseProvider._({
    required UniverseBrowseFamily super.from,
    required BrowseFilter super.argument,
  }) : super(
         retry: null,
         name: r'universeBrowseProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$universeBrowseHash();

  @override
  String toString() {
    return r'universeBrowseProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  UniverseBrowse create() => UniverseBrowse();

  @override
  bool operator ==(Object other) {
    return other is UniverseBrowseProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$universeBrowseHash() => r'60d4989c3aadfd244fa114fce8ed82c2ac2d7771';

final class UniverseBrowseFamily extends $Family
    with
        $ClassFamilyOverride<
          UniverseBrowse,
          AsyncValue<BrowsePagedData<UniverseList>>,
          BrowsePagedData<UniverseList>,
          FutureOr<BrowsePagedData<UniverseList>>,
          BrowseFilter
        > {
  UniverseBrowseFamily._()
    : super(
        retry: null,
        name: r'universeBrowseProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  UniverseBrowseProvider call(BrowseFilter filter) =>
      UniverseBrowseProvider._(argument: filter, from: this);

  @override
  String toString() => r'universeBrowseProvider';
}

abstract class _$UniverseBrowse
    extends $AsyncNotifier<BrowsePagedData<UniverseList>> {
  late final _$args = ref.$arg as BrowseFilter;
  BrowseFilter get filter => _$args;

  FutureOr<BrowsePagedData<UniverseList>> build(BrowseFilter filter);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<BrowsePagedData<UniverseList>>,
              BrowsePagedData<UniverseList>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<BrowsePagedData<UniverseList>>,
                BrowsePagedData<UniverseList>
              >,
              AsyncValue<BrowsePagedData<UniverseList>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(ImprintBrowse)
final imprintBrowseProvider = ImprintBrowseFamily._();

final class ImprintBrowseProvider
    extends
        $AsyncNotifierProvider<ImprintBrowse, BrowsePagedData<ImprintList>> {
  ImprintBrowseProvider._({
    required ImprintBrowseFamily super.from,
    required BrowseFilter super.argument,
  }) : super(
         retry: null,
         name: r'imprintBrowseProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$imprintBrowseHash();

  @override
  String toString() {
    return r'imprintBrowseProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ImprintBrowse create() => ImprintBrowse();

  @override
  bool operator ==(Object other) {
    return other is ImprintBrowseProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$imprintBrowseHash() => r'4e00f3a3757073deb66d30f1651cbaa75251e01e';

final class ImprintBrowseFamily extends $Family
    with
        $ClassFamilyOverride<
          ImprintBrowse,
          AsyncValue<BrowsePagedData<ImprintList>>,
          BrowsePagedData<ImprintList>,
          FutureOr<BrowsePagedData<ImprintList>>,
          BrowseFilter
        > {
  ImprintBrowseFamily._()
    : super(
        retry: null,
        name: r'imprintBrowseProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ImprintBrowseProvider call(BrowseFilter filter) =>
      ImprintBrowseProvider._(argument: filter, from: this);

  @override
  String toString() => r'imprintBrowseProvider';
}

abstract class _$ImprintBrowse
    extends $AsyncNotifier<BrowsePagedData<ImprintList>> {
  late final _$args = ref.$arg as BrowseFilter;
  BrowseFilter get filter => _$args;

  FutureOr<BrowsePagedData<ImprintList>> build(BrowseFilter filter);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<BrowsePagedData<ImprintList>>,
              BrowsePagedData<ImprintList>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<BrowsePagedData<ImprintList>>,
                BrowsePagedData<ImprintList>
              >,
              AsyncValue<BrowsePagedData<ImprintList>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(CreatorBrowse)
final creatorBrowseProvider = CreatorBrowseFamily._();

final class CreatorBrowseProvider
    extends
        $AsyncNotifierProvider<CreatorBrowse, BrowsePagedData<CreatorList>> {
  CreatorBrowseProvider._({
    required CreatorBrowseFamily super.from,
    required BrowseFilter super.argument,
  }) : super(
         retry: null,
         name: r'creatorBrowseProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$creatorBrowseHash();

  @override
  String toString() {
    return r'creatorBrowseProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  CreatorBrowse create() => CreatorBrowse();

  @override
  bool operator ==(Object other) {
    return other is CreatorBrowseProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$creatorBrowseHash() => r'1a69b07534ed96eb1accc6c9c19a118491fd4217';

final class CreatorBrowseFamily extends $Family
    with
        $ClassFamilyOverride<
          CreatorBrowse,
          AsyncValue<BrowsePagedData<CreatorList>>,
          BrowsePagedData<CreatorList>,
          FutureOr<BrowsePagedData<CreatorList>>,
          BrowseFilter
        > {
  CreatorBrowseFamily._()
    : super(
        retry: null,
        name: r'creatorBrowseProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CreatorBrowseProvider call(BrowseFilter filter) =>
      CreatorBrowseProvider._(argument: filter, from: this);

  @override
  String toString() => r'creatorBrowseProvider';
}

abstract class _$CreatorBrowse
    extends $AsyncNotifier<BrowsePagedData<CreatorList>> {
  late final _$args = ref.$arg as BrowseFilter;
  BrowseFilter get filter => _$args;

  FutureOr<BrowsePagedData<CreatorList>> build(BrowseFilter filter);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<BrowsePagedData<CreatorList>>,
              BrowsePagedData<CreatorList>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<BrowsePagedData<CreatorList>>,
                BrowsePagedData<CreatorList>
              >,
              AsyncValue<BrowsePagedData<CreatorList>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
