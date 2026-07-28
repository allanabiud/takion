// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i46;
import 'package:collection/collection.dart' as _i48;
import 'package:flutter/material.dart' as _i47;
import 'package:takion/src/presentation/shared/widgets/image_preview_screen.dart'
    as _i13;
import 'package:takion/src/presentation/features/arcs/arc_details_screen.dart'
    as _i2;
import 'package:takion/src/presentation/features/arcs/arc_issues_screen.dart'
    as _i3;
import 'package:takion/src/presentation/features/characters/character_details_screen.dart'
    as _i6;
import 'package:takion/src/presentation/features/characters/character_issues_screen.dart'
    as _i7;
import 'package:takion/src/presentation/features/creators/creator_details_screen.dart'
    as _i9;
import 'package:takion/src/presentation/features/home/authorize_metron_screen.dart'
    as _i4;
import 'package:takion/src/presentation/features/home/home_screen.dart' as _i12;
import 'package:takion/src/presentation/features/home/main_screen.dart' as _i19;
import 'package:takion/src/presentation/features/home/onboarding_screen.dart'
    as _i25;
import 'package:takion/src/presentation/features/imprints/imprint_details_screen.dart'
    as _i14;
import 'package:takion/src/presentation/features/issues/issue_details/issue_cover_gallery_screen.dart'
    as _i15;
import 'package:takion/src/presentation/features/issues/issue_details_screen.dart'
    as _i16;
import 'package:takion/src/presentation/features/library/continue_reading_screen.dart'
    as _i8;
import 'package:takion/src/presentation/features/library/favorites_screen.dart'
    as _i10;
import 'package:takion/src/presentation/features/library/library_screen.dart'
    as _i17;
import 'package:takion/src/presentation/features/library/my_comics_screen.dart'
    as _i22;
import 'package:takion/src/presentation/features/library/my_pulls_screen.dart'
    as _i23;
import 'package:takion/src/presentation/features/library/read_screen.dart'
    as _i28;
import 'package:takion/src/presentation/features/library/reading_history_screen.dart'
    as _i29;
import 'package:takion/src/presentation/features/library/subscriptions_screen.dart'
    as _i38;
import 'package:takion/src/presentation/features/library/unrated_screen.dart'
    as _i42;
import 'package:takion/src/presentation/features/library/unread_screen.dart'
    as _i43;
import 'package:takion/src/presentation/features/library/wishlist_screen.dart'
    as _i45;
import 'package:takion/src/presentation/features/browse/browse_screens.dart'
    as _i1;
import 'package:takion/src/presentation/features/publishers/publisher_details_screen.dart'
    as _i26;
import 'package:takion/src/presentation/features/publishers/publisher_series_screen.dart'
    as _i27;
import 'package:takion/src/presentation/features/reading_lists/metron_reading_list_browser_screen.dart'
    as _i20;
import 'package:takion/src/presentation/features/reading_lists/metron_reading_list_detail_screen.dart'
    as _i21;
import 'package:takion/src/presentation/features/reading_lists/reading_list_details_screen.dart'
    as _i30;
import 'package:takion/src/presentation/features/reading_lists/reading_list_edit_screen.dart'
    as _i31;
import 'package:takion/src/presentation/features/reading_lists/reading_lists_screen.dart'
    as _i32;
import 'package:takion/src/presentation/features/releases/foc_releases_screen.dart'
    as _i11;
import 'package:takion/src/presentation/features/releases/new_first_issues_screen.dart'
    as _i24;
import 'package:takion/src/presentation/features/releases/releases_screen.dart'
    as _i33;
import 'package:takion/src/presentation/features/releases/weekly_releases_screen.dart'
    as _i44;
import 'package:takion/src/presentation/features/search/barcode_scanner_screen.dart'
    as _i5;
import 'package:takion/src/presentation/features/search/search_results_screen.dart'
    as _i34;
import 'package:takion/src/presentation/features/series/library_series_screen.dart'
    as _i18;
import 'package:takion/src/presentation/features/series/series_details_screen.dart'
    as _i35;
import 'package:takion/src/presentation/features/series/series_issues_screen.dart'
    as _i36;
import 'package:takion/src/presentation/features/settings/settings_screen.dart'
    as _i37;
import 'package:takion/src/presentation/features/teams/team_details_screen.dart'
    as _i39;
import 'package:takion/src/presentation/features/teams/team_issues_screen.dart'
    as _i40;
import 'package:takion/src/presentation/features/universes/universe_details_screen.dart'
    as _i41;

/// generated route for
/// [_i1.ArcBrowseScreen]
class ArcBrowseRoute extends _i46.PageRouteInfo<void> {
  const ArcBrowseRoute({List<_i46.PageRouteInfo>? children})
    : super(ArcBrowseRoute.name, initialChildren: children);

  static const String name = 'ArcBrowseRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      return const _i1.ArcBrowseScreen();
    },
  );
}

/// generated route for
/// [_i2.ArcDetailsScreen]
class ArcDetailsRoute extends _i46.PageRouteInfo<ArcDetailsRouteArgs> {
  ArcDetailsRoute({
    _i47.Key? key,
    required int arcId,
    String? initialImageUrl,
    List<_i46.PageRouteInfo>? children,
  }) : super(
         ArcDetailsRoute.name,
         args: ArcDetailsRouteArgs(
           key: key,
           arcId: arcId,
           initialImageUrl: initialImageUrl,
         ),
         rawPathParams: {'arcId': arcId},
         initialChildren: children,
       );

  static const String name = 'ArcDetailsRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<ArcDetailsRouteArgs>(
        orElse: () => ArcDetailsRouteArgs(arcId: pathParams.getInt('arcId')),
      );
      return _i2.ArcDetailsScreen(
        key: args.key,
        arcId: args.arcId,
        initialImageUrl: args.initialImageUrl,
      );
    },
  );
}

class ArcDetailsRouteArgs {
  const ArcDetailsRouteArgs({
    this.key,
    required this.arcId,
    this.initialImageUrl,
  });

  final _i47.Key? key;

  final int arcId;

  final String? initialImageUrl;

  @override
  String toString() {
    return 'ArcDetailsRouteArgs{key: $key, arcId: $arcId, initialImageUrl: $initialImageUrl}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ArcDetailsRouteArgs) return false;
    return key == other.key &&
        arcId == other.arcId &&
        initialImageUrl == other.initialImageUrl;
  }

  @override
  int get hashCode => key.hashCode ^ arcId.hashCode ^ initialImageUrl.hashCode;
}

/// generated route for
/// [_i3.ArcIssuesScreen]
class ArcIssuesRoute extends _i46.PageRouteInfo<ArcIssuesRouteArgs> {
  ArcIssuesRoute({
    _i47.Key? key,
    required int arcId,
    List<_i46.PageRouteInfo>? children,
  }) : super(
         ArcIssuesRoute.name,
         args: ArcIssuesRouteArgs(key: key, arcId: arcId),
         rawPathParams: {'arcId': arcId},
         initialChildren: children,
       );

  static const String name = 'ArcIssuesRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<ArcIssuesRouteArgs>(
        orElse: () => ArcIssuesRouteArgs(arcId: pathParams.getInt('arcId')),
      );
      return _i3.ArcIssuesScreen(key: args.key, arcId: args.arcId);
    },
  );
}

class ArcIssuesRouteArgs {
  const ArcIssuesRouteArgs({this.key, required this.arcId});

  final _i47.Key? key;

  final int arcId;

  @override
  String toString() {
    return 'ArcIssuesRouteArgs{key: $key, arcId: $arcId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ArcIssuesRouteArgs) return false;
    return key == other.key && arcId == other.arcId;
  }

  @override
  int get hashCode => key.hashCode ^ arcId.hashCode;
}

/// generated route for
/// [_i4.AuthorizeMetronScreen]
class AuthorizeMetronRoute extends _i46.PageRouteInfo<void> {
  const AuthorizeMetronRoute({List<_i46.PageRouteInfo>? children})
    : super(AuthorizeMetronRoute.name, initialChildren: children);

  static const String name = 'AuthorizeMetronRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      return const _i4.AuthorizeMetronScreen();
    },
  );
}

/// generated route for
/// [_i5.BarcodeScannerScreen]
class BarcodeScannerRoute extends _i46.PageRouteInfo<void> {
  const BarcodeScannerRoute({List<_i46.PageRouteInfo>? children})
    : super(BarcodeScannerRoute.name, initialChildren: children);

  static const String name = 'BarcodeScannerRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      return const _i5.BarcodeScannerScreen();
    },
  );
}

/// generated route for
/// [_i1.CharacterBrowseScreen]
class CharacterBrowseRoute extends _i46.PageRouteInfo<void> {
  const CharacterBrowseRoute({List<_i46.PageRouteInfo>? children})
    : super(CharacterBrowseRoute.name, initialChildren: children);

  static const String name = 'CharacterBrowseRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      return const _i1.CharacterBrowseScreen();
    },
  );
}

/// generated route for
/// [_i6.CharacterDetailsScreen]
class CharacterDetailsRoute
    extends _i46.PageRouteInfo<CharacterDetailsRouteArgs> {
  CharacterDetailsRoute({
    _i47.Key? key,
    required int characterId,
    String? initialImageUrl,
    List<_i46.PageRouteInfo>? children,
  }) : super(
         CharacterDetailsRoute.name,
         args: CharacterDetailsRouteArgs(
           key: key,
           characterId: characterId,
           initialImageUrl: initialImageUrl,
         ),
         rawPathParams: {'characterId': characterId},
         initialChildren: children,
       );

  static const String name = 'CharacterDetailsRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<CharacterDetailsRouteArgs>(
        orElse: () => CharacterDetailsRouteArgs(
          characterId: pathParams.getInt('characterId'),
        ),
      );
      return _i6.CharacterDetailsScreen(
        key: args.key,
        characterId: args.characterId,
        initialImageUrl: args.initialImageUrl,
      );
    },
  );
}

class CharacterDetailsRouteArgs {
  const CharacterDetailsRouteArgs({
    this.key,
    required this.characterId,
    this.initialImageUrl,
  });

  final _i47.Key? key;

  final int characterId;

  final String? initialImageUrl;

  @override
  String toString() {
    return 'CharacterDetailsRouteArgs{key: $key, characterId: $characterId, initialImageUrl: $initialImageUrl}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CharacterDetailsRouteArgs) return false;
    return key == other.key &&
        characterId == other.characterId &&
        initialImageUrl == other.initialImageUrl;
  }

  @override
  int get hashCode =>
      key.hashCode ^ characterId.hashCode ^ initialImageUrl.hashCode;
}

/// generated route for
/// [_i7.CharacterIssuesScreen]
class CharacterIssuesRoute
    extends _i46.PageRouteInfo<CharacterIssuesRouteArgs> {
  CharacterIssuesRoute({
    _i47.Key? key,
    required int characterId,
    List<_i46.PageRouteInfo>? children,
  }) : super(
         CharacterIssuesRoute.name,
         args: CharacterIssuesRouteArgs(key: key, characterId: characterId),
         rawPathParams: {'characterId': characterId},
         initialChildren: children,
       );

  static const String name = 'CharacterIssuesRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<CharacterIssuesRouteArgs>(
        orElse: () => CharacterIssuesRouteArgs(
          characterId: pathParams.getInt('characterId'),
        ),
      );
      return _i7.CharacterIssuesScreen(
        key: args.key,
        characterId: args.characterId,
      );
    },
  );
}

class CharacterIssuesRouteArgs {
  const CharacterIssuesRouteArgs({this.key, required this.characterId});

  final _i47.Key? key;

  final int characterId;

  @override
  String toString() {
    return 'CharacterIssuesRouteArgs{key: $key, characterId: $characterId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CharacterIssuesRouteArgs) return false;
    return key == other.key && characterId == other.characterId;
  }

  @override
  int get hashCode => key.hashCode ^ characterId.hashCode;
}

/// generated route for
/// [_i8.ContinueReadingScreen]
class ContinueReadingRoute extends _i46.PageRouteInfo<void> {
  const ContinueReadingRoute({List<_i46.PageRouteInfo>? children})
    : super(ContinueReadingRoute.name, initialChildren: children);

  static const String name = 'ContinueReadingRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      return const _i8.ContinueReadingScreen();
    },
  );
}

/// generated route for
/// [_i1.CreatorBrowseScreen]
class CreatorBrowseRoute extends _i46.PageRouteInfo<void> {
  const CreatorBrowseRoute({List<_i46.PageRouteInfo>? children})
    : super(CreatorBrowseRoute.name, initialChildren: children);

  static const String name = 'CreatorBrowseRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      return const _i1.CreatorBrowseScreen();
    },
  );
}

/// generated route for
/// [_i9.CreatorDetailsScreen]
class CreatorDetailsRoute extends _i46.PageRouteInfo<CreatorDetailsRouteArgs> {
  CreatorDetailsRoute({
    _i47.Key? key,
    required int creatorId,
    String? initialImageUrl,
    List<_i46.PageRouteInfo>? children,
  }) : super(
         CreatorDetailsRoute.name,
         args: CreatorDetailsRouteArgs(
           key: key,
           creatorId: creatorId,
           initialImageUrl: initialImageUrl,
         ),
         rawPathParams: {'creatorId': creatorId},
         initialChildren: children,
       );

  static const String name = 'CreatorDetailsRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<CreatorDetailsRouteArgs>(
        orElse: () =>
            CreatorDetailsRouteArgs(creatorId: pathParams.getInt('creatorId')),
      );
      return _i9.CreatorDetailsScreen(
        key: args.key,
        creatorId: args.creatorId,
        initialImageUrl: args.initialImageUrl,
      );
    },
  );
}

class CreatorDetailsRouteArgs {
  const CreatorDetailsRouteArgs({
    this.key,
    required this.creatorId,
    this.initialImageUrl,
  });

  final _i47.Key? key;

  final int creatorId;

  final String? initialImageUrl;

  @override
  String toString() {
    return 'CreatorDetailsRouteArgs{key: $key, creatorId: $creatorId, initialImageUrl: $initialImageUrl}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CreatorDetailsRouteArgs) return false;
    return key == other.key &&
        creatorId == other.creatorId &&
        initialImageUrl == other.initialImageUrl;
  }

  @override
  int get hashCode =>
      key.hashCode ^ creatorId.hashCode ^ initialImageUrl.hashCode;
}

/// generated route for
/// [_i10.FavoritesScreen]
class FavoritesRoute extends _i46.PageRouteInfo<void> {
  const FavoritesRoute({List<_i46.PageRouteInfo>? children})
    : super(FavoritesRoute.name, initialChildren: children);

  static const String name = 'FavoritesRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      return const _i10.FavoritesScreen();
    },
  );
}

/// generated route for
/// [_i11.FocReleasesScreen]
class FocReleasesRoute extends _i46.PageRouteInfo<void> {
  const FocReleasesRoute({List<_i46.PageRouteInfo>? children})
    : super(FocReleasesRoute.name, initialChildren: children);

  static const String name = 'FocReleasesRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      return const _i11.FocReleasesScreen();
    },
  );
}

/// generated route for
/// [_i12.HomeScreen]
class HomeRoute extends _i46.PageRouteInfo<void> {
  const HomeRoute({List<_i46.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      return const _i12.HomeScreen();
    },
  );
}

/// generated route for
/// [_i13.ImagePreviewScreen]
class ImagePreviewRoute extends _i46.PageRouteInfo<ImagePreviewRouteArgs> {
  ImagePreviewRoute({
    _i47.Key? key,
    required String imageUrl,
    String? title,
    String? heroTag,
    List<_i46.PageRouteInfo>? children,
  }) : super(
         ImagePreviewRoute.name,
         args: ImagePreviewRouteArgs(
           key: key,
           imageUrl: imageUrl,
           title: title,
           heroTag: heroTag,
         ),
         initialChildren: children,
       );

  static const String name = 'ImagePreviewRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ImagePreviewRouteArgs>();
      return _i13.ImagePreviewScreen(
        key: args.key,
        imageUrl: args.imageUrl,
        title: args.title,
        heroTag: args.heroTag,
      );
    },
  );
}

class ImagePreviewRouteArgs {
  const ImagePreviewRouteArgs({
    this.key,
    required this.imageUrl,
    this.title,
    this.heroTag,
  });

  final _i47.Key? key;

  final String imageUrl;

  final String? title;

  final String? heroTag;

  @override
  String toString() {
    return 'ImagePreviewRouteArgs{key: $key, imageUrl: $imageUrl, title: $title, heroTag: $heroTag}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ImagePreviewRouteArgs) return false;
    return key == other.key &&
        imageUrl == other.imageUrl &&
        title == other.title &&
        heroTag == other.heroTag;
  }

  @override
  int get hashCode =>
      key.hashCode ^ imageUrl.hashCode ^ title.hashCode ^ heroTag.hashCode;
}

/// generated route for
/// [_i1.ImprintBrowseScreen]
class ImprintBrowseRoute extends _i46.PageRouteInfo<void> {
  const ImprintBrowseRoute({List<_i46.PageRouteInfo>? children})
    : super(ImprintBrowseRoute.name, initialChildren: children);

  static const String name = 'ImprintBrowseRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      return const _i1.ImprintBrowseScreen();
    },
  );
}

/// generated route for
/// [_i14.ImprintDetailsScreen]
class ImprintDetailsRoute extends _i46.PageRouteInfo<ImprintDetailsRouteArgs> {
  ImprintDetailsRoute({
    _i47.Key? key,
    required int imprintId,
    String? initialImageUrl,
    List<_i46.PageRouteInfo>? children,
  }) : super(
         ImprintDetailsRoute.name,
         args: ImprintDetailsRouteArgs(
           key: key,
           imprintId: imprintId,
           initialImageUrl: initialImageUrl,
         ),
         rawPathParams: {'imprintId': imprintId},
         initialChildren: children,
       );

  static const String name = 'ImprintDetailsRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<ImprintDetailsRouteArgs>(
        orElse: () =>
            ImprintDetailsRouteArgs(imprintId: pathParams.getInt('imprintId')),
      );
      return _i14.ImprintDetailsScreen(
        key: args.key,
        imprintId: args.imprintId,
        initialImageUrl: args.initialImageUrl,
      );
    },
  );
}

class ImprintDetailsRouteArgs {
  const ImprintDetailsRouteArgs({
    this.key,
    required this.imprintId,
    this.initialImageUrl,
  });

  final _i47.Key? key;

  final int imprintId;

  final String? initialImageUrl;

  @override
  String toString() {
    return 'ImprintDetailsRouteArgs{key: $key, imprintId: $imprintId, initialImageUrl: $initialImageUrl}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ImprintDetailsRouteArgs) return false;
    return key == other.key &&
        imprintId == other.imprintId &&
        initialImageUrl == other.initialImageUrl;
  }

  @override
  int get hashCode =>
      key.hashCode ^ imprintId.hashCode ^ initialImageUrl.hashCode;
}

/// generated route for
/// [_i15.IssueCoverGalleryScreen]
class IssueCoverGalleryRoute
    extends _i46.PageRouteInfo<IssueCoverGalleryRouteArgs> {
  IssueCoverGalleryRoute({
    _i47.Key? key,
    required List<String> imageUrls,
    List<String>? imageLabels,
    List<String>? imageCaptions,
    int initialIndex = 0,
    String? title,
    String? heroTag,
    List<_i46.PageRouteInfo>? children,
  }) : super(
         IssueCoverGalleryRoute.name,
         args: IssueCoverGalleryRouteArgs(
           key: key,
           imageUrls: imageUrls,
           imageLabels: imageLabels,
           imageCaptions: imageCaptions,
           initialIndex: initialIndex,
           title: title,
           heroTag: heroTag,
         ),
         initialChildren: children,
       );

  static const String name = 'IssueCoverGalleryRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<IssueCoverGalleryRouteArgs>();
      return _i15.IssueCoverGalleryScreen(
        key: args.key,
        imageUrls: args.imageUrls,
        imageLabels: args.imageLabels,
        imageCaptions: args.imageCaptions,
        initialIndex: args.initialIndex,
        title: args.title,
        heroTag: args.heroTag,
      );
    },
  );
}

class IssueCoverGalleryRouteArgs {
  const IssueCoverGalleryRouteArgs({
    this.key,
    required this.imageUrls,
    this.imageLabels,
    this.imageCaptions,
    this.initialIndex = 0,
    this.title,
    this.heroTag,
  });

  final _i47.Key? key;

  final List<String> imageUrls;

  final List<String>? imageLabels;

  final List<String>? imageCaptions;

  final int initialIndex;

  final String? title;

  final String? heroTag;

  @override
  String toString() {
    return 'IssueCoverGalleryRouteArgs{key: $key, imageUrls: $imageUrls, imageLabels: $imageLabels, imageCaptions: $imageCaptions, initialIndex: $initialIndex, title: $title, heroTag: $heroTag}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! IssueCoverGalleryRouteArgs) return false;
    return key == other.key &&
        const _i48.ListEquality<String>().equals(imageUrls, other.imageUrls) &&
        const _i48.ListEquality<String>().equals(
          imageLabels,
          other.imageLabels,
        ) &&
        const _i48.ListEquality<String>().equals(
          imageCaptions,
          other.imageCaptions,
        ) &&
        initialIndex == other.initialIndex &&
        title == other.title &&
        heroTag == other.heroTag;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      const _i48.ListEquality<String>().hash(imageUrls) ^
      const _i48.ListEquality<String>().hash(imageLabels) ^
      const _i48.ListEquality<String>().hash(imageCaptions) ^
      initialIndex.hashCode ^
      title.hashCode ^
      heroTag.hashCode;
}

/// generated route for
/// [_i16.IssueDetailsScreen]
class IssueDetailsRoute extends _i46.PageRouteInfo<IssueDetailsRouteArgs> {
  IssueDetailsRoute({
    _i47.Key? key,
    required int issueId,
    String? initialImageUrl,
    List<_i46.PageRouteInfo>? children,
  }) : super(
         IssueDetailsRoute.name,
         args: IssueDetailsRouteArgs(
           key: key,
           issueId: issueId,
           initialImageUrl: initialImageUrl,
         ),
         rawPathParams: {'issueId': issueId},
         initialChildren: children,
       );

  static const String name = 'IssueDetailsRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<IssueDetailsRouteArgs>(
        orElse: () =>
            IssueDetailsRouteArgs(issueId: pathParams.getInt('issueId')),
      );
      return _i16.IssueDetailsScreen(
        key: args.key,
        issueId: args.issueId,
        initialImageUrl: args.initialImageUrl,
      );
    },
  );
}

class IssueDetailsRouteArgs {
  const IssueDetailsRouteArgs({
    this.key,
    required this.issueId,
    this.initialImageUrl,
  });

  final _i47.Key? key;

  final int issueId;

  final String? initialImageUrl;

  @override
  String toString() {
    return 'IssueDetailsRouteArgs{key: $key, issueId: $issueId, initialImageUrl: $initialImageUrl}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! IssueDetailsRouteArgs) return false;
    return key == other.key &&
        issueId == other.issueId &&
        initialImageUrl == other.initialImageUrl;
  }

  @override
  int get hashCode =>
      key.hashCode ^ issueId.hashCode ^ initialImageUrl.hashCode;
}

/// generated route for
/// [_i17.LibraryScreen]
class LibraryRoute extends _i46.PageRouteInfo<void> {
  const LibraryRoute({List<_i46.PageRouteInfo>? children})
    : super(LibraryRoute.name, initialChildren: children);

  static const String name = 'LibraryRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      return const _i17.LibraryScreen();
    },
  );
}

/// generated route for
/// [_i18.LibrarySeriesScreen]
class LibrarySeriesRoute extends _i46.PageRouteInfo<LibrarySeriesRouteArgs> {
  LibrarySeriesRoute({
    _i47.Key? key,
    required int seriesId,
    required String category,
    String? seriesName,
    List<_i46.PageRouteInfo>? children,
  }) : super(
         LibrarySeriesRoute.name,
         args: LibrarySeriesRouteArgs(
           key: key,
           seriesId: seriesId,
           category: category,
           seriesName: seriesName,
         ),
         rawPathParams: {
           'seriesId': seriesId,
           'category': category,
           'seriesName': seriesName,
         },
         initialChildren: children,
       );

  static const String name = 'LibrarySeriesRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<LibrarySeriesRouteArgs>(
        orElse: () => LibrarySeriesRouteArgs(
          seriesId: pathParams.getInt('seriesId'),
          category: pathParams.getString('category'),
          seriesName: pathParams.optString('seriesName'),
        ),
      );
      return _i18.LibrarySeriesScreen(
        key: args.key,
        seriesId: args.seriesId,
        category: args.category,
        seriesName: args.seriesName,
      );
    },
  );
}

class LibrarySeriesRouteArgs {
  const LibrarySeriesRouteArgs({
    this.key,
    required this.seriesId,
    required this.category,
    this.seriesName,
  });

  final _i47.Key? key;

  final int seriesId;

  final String category;

  final String? seriesName;

  @override
  String toString() {
    return 'LibrarySeriesRouteArgs{key: $key, seriesId: $seriesId, category: $category, seriesName: $seriesName}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! LibrarySeriesRouteArgs) return false;
    return key == other.key &&
        seriesId == other.seriesId &&
        category == other.category &&
        seriesName == other.seriesName;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      seriesId.hashCode ^
      category.hashCode ^
      seriesName.hashCode;
}

/// generated route for
/// [_i19.MainScreen]
class MainRoute extends _i46.PageRouteInfo<void> {
  const MainRoute({List<_i46.PageRouteInfo>? children})
    : super(MainRoute.name, initialChildren: children);

  static const String name = 'MainRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      return const _i19.MainScreen();
    },
  );
}

/// generated route for
/// [_i20.MetronReadingListBrowserScreen]
class MetronReadingListBrowserRoute extends _i46.PageRouteInfo<void> {
  const MetronReadingListBrowserRoute({List<_i46.PageRouteInfo>? children})
    : super(MetronReadingListBrowserRoute.name, initialChildren: children);

  static const String name = 'MetronReadingListBrowserRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      return const _i20.MetronReadingListBrowserScreen();
    },
  );
}

/// generated route for
/// [_i21.MetronReadingListDetailScreen]
class MetronReadingListDetailRoute
    extends _i46.PageRouteInfo<MetronReadingListDetailRouteArgs> {
  MetronReadingListDetailRoute({
    _i47.Key? key,
    required int id,
    List<_i46.PageRouteInfo>? children,
  }) : super(
         MetronReadingListDetailRoute.name,
         args: MetronReadingListDetailRouteArgs(key: key, id: id),
         rawPathParams: {'id': id},
         initialChildren: children,
       );

  static const String name = 'MetronReadingListDetailRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<MetronReadingListDetailRouteArgs>(
        orElse: () =>
            MetronReadingListDetailRouteArgs(id: pathParams.getInt('id')),
      );
      return _i21.MetronReadingListDetailScreen(key: args.key, id: args.id);
    },
  );
}

class MetronReadingListDetailRouteArgs {
  const MetronReadingListDetailRouteArgs({this.key, required this.id});

  final _i47.Key? key;

  final int id;

  @override
  String toString() {
    return 'MetronReadingListDetailRouteArgs{key: $key, id: $id}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! MetronReadingListDetailRouteArgs) return false;
    return key == other.key && id == other.id;
  }

  @override
  int get hashCode => key.hashCode ^ id.hashCode;
}

/// generated route for
/// [_i22.MyComicsScreen]
class MyComicsRoute extends _i46.PageRouteInfo<void> {
  const MyComicsRoute({List<_i46.PageRouteInfo>? children})
    : super(MyComicsRoute.name, initialChildren: children);

  static const String name = 'MyComicsRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      return const _i22.MyComicsScreen();
    },
  );
}

/// generated route for
/// [_i23.MyPullsScreen]
class MyPullsRoute extends _i46.PageRouteInfo<void> {
  const MyPullsRoute({List<_i46.PageRouteInfo>? children})
    : super(MyPullsRoute.name, initialChildren: children);

  static const String name = 'MyPullsRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      return const _i23.MyPullsScreen();
    },
  );
}

/// generated route for
/// [_i24.NewFirstIssuesScreen]
class NewFirstIssuesRoute extends _i46.PageRouteInfo<void> {
  const NewFirstIssuesRoute({List<_i46.PageRouteInfo>? children})
    : super(NewFirstIssuesRoute.name, initialChildren: children);

  static const String name = 'NewFirstIssuesRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      return const _i24.NewFirstIssuesScreen();
    },
  );
}

/// generated route for
/// [_i25.OnboardingScreen]
class OnboardingRoute extends _i46.PageRouteInfo<void> {
  const OnboardingRoute({List<_i46.PageRouteInfo>? children})
    : super(OnboardingRoute.name, initialChildren: children);

  static const String name = 'OnboardingRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      return const _i25.OnboardingScreen();
    },
  );
}

/// generated route for
/// [_i1.PublisherBrowseScreen]
class PublisherBrowseRoute extends _i46.PageRouteInfo<void> {
  const PublisherBrowseRoute({List<_i46.PageRouteInfo>? children})
    : super(PublisherBrowseRoute.name, initialChildren: children);

  static const String name = 'PublisherBrowseRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      return const _i1.PublisherBrowseScreen();
    },
  );
}

/// generated route for
/// [_i26.PublisherDetailsScreen]
class PublisherDetailsRoute
    extends _i46.PageRouteInfo<PublisherDetailsRouteArgs> {
  PublisherDetailsRoute({
    _i47.Key? key,
    required int publisherId,
    String? initialImageUrl,
    List<_i46.PageRouteInfo>? children,
  }) : super(
         PublisherDetailsRoute.name,
         args: PublisherDetailsRouteArgs(
           key: key,
           publisherId: publisherId,
           initialImageUrl: initialImageUrl,
         ),
         rawPathParams: {'publisherId': publisherId},
         initialChildren: children,
       );

  static const String name = 'PublisherDetailsRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<PublisherDetailsRouteArgs>(
        orElse: () => PublisherDetailsRouteArgs(
          publisherId: pathParams.getInt('publisherId'),
        ),
      );
      return _i26.PublisherDetailsScreen(
        key: args.key,
        publisherId: args.publisherId,
        initialImageUrl: args.initialImageUrl,
      );
    },
  );
}

class PublisherDetailsRouteArgs {
  const PublisherDetailsRouteArgs({
    this.key,
    required this.publisherId,
    this.initialImageUrl,
  });

  final _i47.Key? key;

  final int publisherId;

  final String? initialImageUrl;

  @override
  String toString() {
    return 'PublisherDetailsRouteArgs{key: $key, publisherId: $publisherId, initialImageUrl: $initialImageUrl}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PublisherDetailsRouteArgs) return false;
    return key == other.key &&
        publisherId == other.publisherId &&
        initialImageUrl == other.initialImageUrl;
  }

  @override
  int get hashCode =>
      key.hashCode ^ publisherId.hashCode ^ initialImageUrl.hashCode;
}

/// generated route for
/// [_i27.PublisherSeriesScreen]
class PublisherSeriesRoute
    extends _i46.PageRouteInfo<PublisherSeriesRouteArgs> {
  PublisherSeriesRoute({
    _i47.Key? key,
    required int publisherId,
    List<_i46.PageRouteInfo>? children,
  }) : super(
         PublisherSeriesRoute.name,
         args: PublisherSeriesRouteArgs(key: key, publisherId: publisherId),
         rawPathParams: {'publisherId': publisherId},
         initialChildren: children,
       );

  static const String name = 'PublisherSeriesRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<PublisherSeriesRouteArgs>(
        orElse: () => PublisherSeriesRouteArgs(
          publisherId: pathParams.getInt('publisherId'),
        ),
      );
      return _i27.PublisherSeriesScreen(
        key: args.key,
        publisherId: args.publisherId,
      );
    },
  );
}

class PublisherSeriesRouteArgs {
  const PublisherSeriesRouteArgs({this.key, required this.publisherId});

  final _i47.Key? key;

  final int publisherId;

  @override
  String toString() {
    return 'PublisherSeriesRouteArgs{key: $key, publisherId: $publisherId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PublisherSeriesRouteArgs) return false;
    return key == other.key && publisherId == other.publisherId;
  }

  @override
  int get hashCode => key.hashCode ^ publisherId.hashCode;
}

/// generated route for
/// [_i28.ReadScreen]
class ReadRoute extends _i46.PageRouteInfo<void> {
  const ReadRoute({List<_i46.PageRouteInfo>? children})
    : super(ReadRoute.name, initialChildren: children);

  static const String name = 'ReadRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      return const _i28.ReadScreen();
    },
  );
}

/// generated route for
/// [_i29.ReadingHistoryScreen]
class ReadingHistoryRoute extends _i46.PageRouteInfo<void> {
  const ReadingHistoryRoute({List<_i46.PageRouteInfo>? children})
    : super(ReadingHistoryRoute.name, initialChildren: children);

  static const String name = 'ReadingHistoryRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      return const _i29.ReadingHistoryScreen();
    },
  );
}

/// generated route for
/// [_i30.ReadingListDetailsScreen]
class ReadingListDetailsRoute
    extends _i46.PageRouteInfo<ReadingListDetailsRouteArgs> {
  ReadingListDetailsRoute({
    _i47.Key? key,
    required String listId,
    List<_i46.PageRouteInfo>? children,
  }) : super(
         ReadingListDetailsRoute.name,
         args: ReadingListDetailsRouteArgs(key: key, listId: listId),
         rawPathParams: {'listId': listId},
         initialChildren: children,
       );

  static const String name = 'ReadingListDetailsRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<ReadingListDetailsRouteArgs>(
        orElse: () =>
            ReadingListDetailsRouteArgs(listId: pathParams.getString('listId')),
      );
      return _i30.ReadingListDetailsScreen(key: args.key, listId: args.listId);
    },
  );
}

class ReadingListDetailsRouteArgs {
  const ReadingListDetailsRouteArgs({this.key, required this.listId});

  final _i47.Key? key;

  final String listId;

  @override
  String toString() {
    return 'ReadingListDetailsRouteArgs{key: $key, listId: $listId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ReadingListDetailsRouteArgs) return false;
    return key == other.key && listId == other.listId;
  }

  @override
  int get hashCode => key.hashCode ^ listId.hashCode;
}

/// generated route for
/// [_i31.ReadingListEditScreen]
class ReadingListEditRoute
    extends _i46.PageRouteInfo<ReadingListEditRouteArgs> {
  ReadingListEditRoute({
    _i47.Key? key,
    required String listId,
    List<_i46.PageRouteInfo>? children,
  }) : super(
         ReadingListEditRoute.name,
         args: ReadingListEditRouteArgs(key: key, listId: listId),
         rawPathParams: {'listId': listId},
         initialChildren: children,
       );

  static const String name = 'ReadingListEditRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<ReadingListEditRouteArgs>(
        orElse: () =>
            ReadingListEditRouteArgs(listId: pathParams.getString('listId')),
      );
      return _i31.ReadingListEditScreen(key: args.key, listId: args.listId);
    },
  );
}

class ReadingListEditRouteArgs {
  const ReadingListEditRouteArgs({this.key, required this.listId});

  final _i47.Key? key;

  final String listId;

  @override
  String toString() {
    return 'ReadingListEditRouteArgs{key: $key, listId: $listId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ReadingListEditRouteArgs) return false;
    return key == other.key && listId == other.listId;
  }

  @override
  int get hashCode => key.hashCode ^ listId.hashCode;
}

/// generated route for
/// [_i32.ReadingListsScreen]
class ReadingListsRoute extends _i46.PageRouteInfo<void> {
  const ReadingListsRoute({List<_i46.PageRouteInfo>? children})
    : super(ReadingListsRoute.name, initialChildren: children);

  static const String name = 'ReadingListsRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      return const _i32.ReadingListsScreen();
    },
  );
}

/// generated route for
/// [_i33.ReleasesScreen]
class ReleasesRoute extends _i46.PageRouteInfo<void> {
  const ReleasesRoute({List<_i46.PageRouteInfo>? children})
    : super(ReleasesRoute.name, initialChildren: children);

  static const String name = 'ReleasesRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      return const _i33.ReleasesScreen();
    },
  );
}

/// generated route for
/// [_i34.SearchResultsScreen]
class SearchResultsRoute extends _i46.PageRouteInfo<SearchResultsRouteArgs> {
  SearchResultsRoute({
    _i47.Key? key,
    required String query,
    String searchChoice = 'Issues',
    List<_i46.PageRouteInfo>? children,
  }) : super(
         SearchResultsRoute.name,
         args: SearchResultsRouteArgs(
           key: key,
           query: query,
           searchChoice: searchChoice,
         ),
         initialChildren: children,
       );

  static const String name = 'SearchResultsRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SearchResultsRouteArgs>();
      return _i34.SearchResultsScreen(
        key: args.key,
        query: args.query,
        searchChoice: args.searchChoice,
      );
    },
  );
}

class SearchResultsRouteArgs {
  const SearchResultsRouteArgs({
    this.key,
    required this.query,
    this.searchChoice = 'Issues',
  });

  final _i47.Key? key;

  final String query;

  final String searchChoice;

  @override
  String toString() {
    return 'SearchResultsRouteArgs{key: $key, query: $query, searchChoice: $searchChoice}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SearchResultsRouteArgs) return false;
    return key == other.key &&
        query == other.query &&
        searchChoice == other.searchChoice;
  }

  @override
  int get hashCode => key.hashCode ^ query.hashCode ^ searchChoice.hashCode;
}

/// generated route for
/// [_i1.SeriesBrowseScreen]
class SeriesBrowseRoute extends _i46.PageRouteInfo<void> {
  const SeriesBrowseRoute({List<_i46.PageRouteInfo>? children})
    : super(SeriesBrowseRoute.name, initialChildren: children);

  static const String name = 'SeriesBrowseRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      return const _i1.SeriesBrowseScreen();
    },
  );
}

/// generated route for
/// [_i35.SeriesDetailsScreen]
class SeriesDetailsRoute extends _i46.PageRouteInfo<SeriesDetailsRouteArgs> {
  SeriesDetailsRoute({
    _i47.Key? key,
    required int seriesId,
    String? initialImageUrl,
    List<_i46.PageRouteInfo>? children,
  }) : super(
         SeriesDetailsRoute.name,
         args: SeriesDetailsRouteArgs(
           key: key,
           seriesId: seriesId,
           initialImageUrl: initialImageUrl,
         ),
         rawPathParams: {'seriesId': seriesId},
         initialChildren: children,
       );

  static const String name = 'SeriesDetailsRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<SeriesDetailsRouteArgs>(
        orElse: () =>
            SeriesDetailsRouteArgs(seriesId: pathParams.getInt('seriesId')),
      );
      return _i35.SeriesDetailsScreen(
        key: args.key,
        seriesId: args.seriesId,
        initialImageUrl: args.initialImageUrl,
      );
    },
  );
}

class SeriesDetailsRouteArgs {
  const SeriesDetailsRouteArgs({
    this.key,
    required this.seriesId,
    this.initialImageUrl,
  });

  final _i47.Key? key;

  final int seriesId;

  final String? initialImageUrl;

  @override
  String toString() {
    return 'SeriesDetailsRouteArgs{key: $key, seriesId: $seriesId, initialImageUrl: $initialImageUrl}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SeriesDetailsRouteArgs) return false;
    return key == other.key &&
        seriesId == other.seriesId &&
        initialImageUrl == other.initialImageUrl;
  }

  @override
  int get hashCode =>
      key.hashCode ^ seriesId.hashCode ^ initialImageUrl.hashCode;
}

/// generated route for
/// [_i36.SeriesIssuesScreen]
class SeriesIssuesRoute extends _i46.PageRouteInfo<SeriesIssuesRouteArgs> {
  SeriesIssuesRoute({
    _i47.Key? key,
    required int seriesId,
    List<_i46.PageRouteInfo>? children,
  }) : super(
         SeriesIssuesRoute.name,
         args: SeriesIssuesRouteArgs(key: key, seriesId: seriesId),
         rawPathParams: {'seriesId': seriesId},
         initialChildren: children,
       );

  static const String name = 'SeriesIssuesRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<SeriesIssuesRouteArgs>(
        orElse: () =>
            SeriesIssuesRouteArgs(seriesId: pathParams.getInt('seriesId')),
      );
      return _i36.SeriesIssuesScreen(key: args.key, seriesId: args.seriesId);
    },
  );
}

class SeriesIssuesRouteArgs {
  const SeriesIssuesRouteArgs({this.key, required this.seriesId});

  final _i47.Key? key;

  final int seriesId;

  @override
  String toString() {
    return 'SeriesIssuesRouteArgs{key: $key, seriesId: $seriesId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SeriesIssuesRouteArgs) return false;
    return key == other.key && seriesId == other.seriesId;
  }

  @override
  int get hashCode => key.hashCode ^ seriesId.hashCode;
}

/// generated route for
/// [_i37.SettingsScreen]
class SettingsRoute extends _i46.PageRouteInfo<void> {
  const SettingsRoute({List<_i46.PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      return const _i37.SettingsScreen();
    },
  );
}

/// generated route for
/// [_i38.SubscriptionsScreen]
class SubscriptionsRoute extends _i46.PageRouteInfo<void> {
  const SubscriptionsRoute({List<_i46.PageRouteInfo>? children})
    : super(SubscriptionsRoute.name, initialChildren: children);

  static const String name = 'SubscriptionsRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      return const _i38.SubscriptionsScreen();
    },
  );
}

/// generated route for
/// [_i1.TeamBrowseScreen]
class TeamBrowseRoute extends _i46.PageRouteInfo<void> {
  const TeamBrowseRoute({List<_i46.PageRouteInfo>? children})
    : super(TeamBrowseRoute.name, initialChildren: children);

  static const String name = 'TeamBrowseRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      return const _i1.TeamBrowseScreen();
    },
  );
}

/// generated route for
/// [_i39.TeamDetailsScreen]
class TeamDetailsRoute extends _i46.PageRouteInfo<TeamDetailsRouteArgs> {
  TeamDetailsRoute({
    _i47.Key? key,
    required int teamId,
    String? initialImageUrl,
    List<_i46.PageRouteInfo>? children,
  }) : super(
         TeamDetailsRoute.name,
         args: TeamDetailsRouteArgs(
           key: key,
           teamId: teamId,
           initialImageUrl: initialImageUrl,
         ),
         rawPathParams: {'teamId': teamId},
         initialChildren: children,
       );

  static const String name = 'TeamDetailsRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<TeamDetailsRouteArgs>(
        orElse: () => TeamDetailsRouteArgs(teamId: pathParams.getInt('teamId')),
      );
      return _i39.TeamDetailsScreen(
        key: args.key,
        teamId: args.teamId,
        initialImageUrl: args.initialImageUrl,
      );
    },
  );
}

class TeamDetailsRouteArgs {
  const TeamDetailsRouteArgs({
    this.key,
    required this.teamId,
    this.initialImageUrl,
  });

  final _i47.Key? key;

  final int teamId;

  final String? initialImageUrl;

  @override
  String toString() {
    return 'TeamDetailsRouteArgs{key: $key, teamId: $teamId, initialImageUrl: $initialImageUrl}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TeamDetailsRouteArgs) return false;
    return key == other.key &&
        teamId == other.teamId &&
        initialImageUrl == other.initialImageUrl;
  }

  @override
  int get hashCode => key.hashCode ^ teamId.hashCode ^ initialImageUrl.hashCode;
}

/// generated route for
/// [_i40.TeamIssuesScreen]
class TeamIssuesRoute extends _i46.PageRouteInfo<TeamIssuesRouteArgs> {
  TeamIssuesRoute({
    _i47.Key? key,
    required int teamId,
    List<_i46.PageRouteInfo>? children,
  }) : super(
         TeamIssuesRoute.name,
         args: TeamIssuesRouteArgs(key: key, teamId: teamId),
         rawPathParams: {'teamId': teamId},
         initialChildren: children,
       );

  static const String name = 'TeamIssuesRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<TeamIssuesRouteArgs>(
        orElse: () => TeamIssuesRouteArgs(teamId: pathParams.getInt('teamId')),
      );
      return _i40.TeamIssuesScreen(key: args.key, teamId: args.teamId);
    },
  );
}

class TeamIssuesRouteArgs {
  const TeamIssuesRouteArgs({this.key, required this.teamId});

  final _i47.Key? key;

  final int teamId;

  @override
  String toString() {
    return 'TeamIssuesRouteArgs{key: $key, teamId: $teamId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TeamIssuesRouteArgs) return false;
    return key == other.key && teamId == other.teamId;
  }

  @override
  int get hashCode => key.hashCode ^ teamId.hashCode;
}

/// generated route for
/// [_i1.UniverseBrowseScreen]
class UniverseBrowseRoute extends _i46.PageRouteInfo<void> {
  const UniverseBrowseRoute({List<_i46.PageRouteInfo>? children})
    : super(UniverseBrowseRoute.name, initialChildren: children);

  static const String name = 'UniverseBrowseRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      return const _i1.UniverseBrowseScreen();
    },
  );
}

/// generated route for
/// [_i41.UniverseDetailsScreen]
class UniverseDetailsRoute
    extends _i46.PageRouteInfo<UniverseDetailsRouteArgs> {
  UniverseDetailsRoute({
    _i47.Key? key,
    required int universeId,
    String? initialImageUrl,
    List<_i46.PageRouteInfo>? children,
  }) : super(
         UniverseDetailsRoute.name,
         args: UniverseDetailsRouteArgs(
           key: key,
           universeId: universeId,
           initialImageUrl: initialImageUrl,
         ),
         rawPathParams: {'universeId': universeId},
         initialChildren: children,
       );

  static const String name = 'UniverseDetailsRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<UniverseDetailsRouteArgs>(
        orElse: () => UniverseDetailsRouteArgs(
          universeId: pathParams.getInt('universeId'),
        ),
      );
      return _i41.UniverseDetailsScreen(
        key: args.key,
        universeId: args.universeId,
        initialImageUrl: args.initialImageUrl,
      );
    },
  );
}

class UniverseDetailsRouteArgs {
  const UniverseDetailsRouteArgs({
    this.key,
    required this.universeId,
    this.initialImageUrl,
  });

  final _i47.Key? key;

  final int universeId;

  final String? initialImageUrl;

  @override
  String toString() {
    return 'UniverseDetailsRouteArgs{key: $key, universeId: $universeId, initialImageUrl: $initialImageUrl}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! UniverseDetailsRouteArgs) return false;
    return key == other.key &&
        universeId == other.universeId &&
        initialImageUrl == other.initialImageUrl;
  }

  @override
  int get hashCode =>
      key.hashCode ^ universeId.hashCode ^ initialImageUrl.hashCode;
}

/// generated route for
/// [_i42.UnratedScreen]
class UnratedRoute extends _i46.PageRouteInfo<void> {
  const UnratedRoute({List<_i46.PageRouteInfo>? children})
    : super(UnratedRoute.name, initialChildren: children);

  static const String name = 'UnratedRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      return const _i42.UnratedScreen();
    },
  );
}

/// generated route for
/// [_i43.UnreadScreen]
class UnreadRoute extends _i46.PageRouteInfo<void> {
  const UnreadRoute({List<_i46.PageRouteInfo>? children})
    : super(UnreadRoute.name, initialChildren: children);

  static const String name = 'UnreadRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      return const _i43.UnreadScreen();
    },
  );
}

/// generated route for
/// [_i44.WeeklyReleasesScreen]
class WeeklyReleasesRoute extends _i46.PageRouteInfo<void> {
  const WeeklyReleasesRoute({List<_i46.PageRouteInfo>? children})
    : super(WeeklyReleasesRoute.name, initialChildren: children);

  static const String name = 'WeeklyReleasesRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      return const _i44.WeeklyReleasesScreen();
    },
  );
}

/// generated route for
/// [_i45.WishlistScreen]
class WishlistRoute extends _i46.PageRouteInfo<void> {
  const WishlistRoute({List<_i46.PageRouteInfo>? children})
    : super(WishlistRoute.name, initialChildren: children);

  static const String name = 'WishlistRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      return const _i45.WishlistScreen();
    },
  );
}
