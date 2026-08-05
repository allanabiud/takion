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

String _$characterBrowseHash() => r'b2aa9ce4dd77aa9e2f6c35ddee658ea594b327ef';

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

String _$seriesBrowseHash() => r'4bf05a34278e7cb7811d441a0656c8c025b8ad0d';

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

String _$publisherBrowseHash() => r'a7a7dec0fd243b259390887935d8eb78c3aaca35';

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

String _$teamBrowseHash() => r'336d11ad6a64883eee22514d5d80ecad7c08b7a2';

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

String _$arcBrowseHash() => r'a171abf5034f9690c37e9c09b030cdeba77ba11d';

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

String _$universeBrowseHash() => r'97269b6e0b96e472fd8d0f10fcbe06af4049952f';

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

String _$imprintBrowseHash() => r'b0bc59a98ff3146836b56a3171f2aad8166f6239';

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

String _$creatorBrowseHash() => r'dd0bf1ff1f5414ab58a18494be4e453bf89430c6';

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
