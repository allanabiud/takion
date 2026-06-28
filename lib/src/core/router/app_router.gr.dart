// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i37;
import 'package:collection/collection.dart' as _i39;
import 'package:flutter/material.dart' as _i38;
import 'package:takion/src/presentation/components/image_preview_screen.dart'
    as _i10;
import 'package:takion/src/presentation/features/characters/character_details_screen.dart'
    as _i3;
import 'package:takion/src/presentation/features/characters/character_issues_screen.dart'
    as _i4;
import 'package:takion/src/presentation/features/home/all_done_screen.dart'
    as _i1;
import 'package:takion/src/presentation/features/home/home_screen.dart' as _i9;
import 'package:takion/src/presentation/features/home/main_screen.dart' as _i16;
import 'package:takion/src/presentation/features/home/onboarding_screen.dart'
    as _i23;
import 'package:takion/src/presentation/features/issues/collection_read_status_screen.dart'
    as _i5;
import 'package:takion/src/presentation/features/issues/issue_characters_screen.dart'
    as _i11;
import 'package:takion/src/presentation/features/issues/issue_cover_gallery_screen.dart'
    as _i12;
import 'package:takion/src/presentation/features/issues/issue_creators_screen.dart'
    as _i13;
import 'package:takion/src/presentation/features/issues/issue_details_screen.dart'
    as _i14;
import 'package:takion/src/presentation/features/library/continue_reading_screen.dart'
    as _i6;
import 'package:takion/src/presentation/features/library/favorites_screen.dart'
    as _i7;
import 'package:takion/src/presentation/features/library/library_screen.dart'
    as _i15;
import 'package:takion/src/presentation/features/library/my_comics_screen.dart'
    as _i19;
import 'package:takion/src/presentation/features/library/my_pulls_screen.dart'
    as _i20;
import 'package:takion/src/presentation/features/library/reading_history_screen.dart'
    as _i24;
import 'package:takion/src/presentation/features/library/subscriptions_screen.dart'
    as _i32;
import 'package:takion/src/presentation/features/library/unrated_issues_screen.dart'
    as _i33;
import 'package:takion/src/presentation/features/library/wishlist_screen.dart'
    as _i36;
import 'package:takion/src/presentation/features/profile/authorize_metron_screen.dart'
    as _i2;
import 'package:takion/src/presentation/features/profile/metron_connect_screen.dart'
    as _i17;
import 'package:takion/src/presentation/features/profile/metron_info_screen.dart'
    as _i18;
import 'package:takion/src/presentation/features/profile/profile_screen.dart'
    as _i34;
import 'package:takion/src/presentation/features/reading_lists/my_reading_lists_screen.dart'
    as _i21;
import 'package:takion/src/presentation/features/reading_lists/reading_list_details_screen.dart'
    as _i25;
import 'package:takion/src/presentation/features/reading_lists/reading_list_edit_screen.dart'
    as _i26;
import 'package:takion/src/presentation/features/releases/foc_releases_screen.dart'
    as _i8;
import 'package:takion/src/presentation/features/releases/new_first_issues_screen.dart'
    as _i22;
import 'package:takion/src/presentation/features/releases/releases_screen.dart'
    as _i27;
import 'package:takion/src/presentation/features/releases/weekly_releases_screen.dart'
    as _i35;
import 'package:takion/src/presentation/features/search/search_results_screen.dart'
    as _i28;
import 'package:takion/src/presentation/features/series/series_details_screen.dart'
    as _i29;
import 'package:takion/src/presentation/features/series/series_issues_screen.dart'
    as _i30;
import 'package:takion/src/presentation/features/settings/settings_screen.dart'
    as _i31;

/// generated route for
/// [_i1.AllDoneScreen]
class AllDoneRoute extends _i37.PageRouteInfo<void> {
  const AllDoneRoute({List<_i37.PageRouteInfo>? children})
    : super(AllDoneRoute.name, initialChildren: children);

  static const String name = 'AllDoneRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      return const _i1.AllDoneScreen();
    },
  );
}

/// generated route for
/// [_i2.AuthorizeMetronScreen]
class AuthorizeMetronRoute extends _i37.PageRouteInfo<void> {
  const AuthorizeMetronRoute({List<_i37.PageRouteInfo>? children})
    : super(AuthorizeMetronRoute.name, initialChildren: children);

  static const String name = 'AuthorizeMetronRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      return const _i2.AuthorizeMetronScreen();
    },
  );
}

/// generated route for
/// [_i3.CharacterDetailsScreen]
class CharacterDetailsRoute
    extends _i37.PageRouteInfo<CharacterDetailsRouteArgs> {
  CharacterDetailsRoute({
    _i38.Key? key,
    required int characterId,
    String? initialImageUrl,
    List<_i37.PageRouteInfo>? children,
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

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<CharacterDetailsRouteArgs>(
        orElse: () => CharacterDetailsRouteArgs(
          characterId: pathParams.getInt('characterId'),
        ),
      );
      return _i3.CharacterDetailsScreen(
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

  final _i38.Key? key;

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
/// [_i4.CharacterIssuesScreen]
class CharacterIssuesRoute
    extends _i37.PageRouteInfo<CharacterIssuesRouteArgs> {
  CharacterIssuesRoute({
    _i38.Key? key,
    required int characterId,
    List<_i37.PageRouteInfo>? children,
  }) : super(
         CharacterIssuesRoute.name,
         args: CharacterIssuesRouteArgs(key: key, characterId: characterId),
         rawPathParams: {'characterId': characterId},
         initialChildren: children,
       );

  static const String name = 'CharacterIssuesRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<CharacterIssuesRouteArgs>(
        orElse: () => CharacterIssuesRouteArgs(
          characterId: pathParams.getInt('characterId'),
        ),
      );
      return _i4.CharacterIssuesScreen(
        key: args.key,
        characterId: args.characterId,
      );
    },
  );
}

class CharacterIssuesRouteArgs {
  const CharacterIssuesRouteArgs({this.key, required this.characterId});

  final _i38.Key? key;

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
/// [_i5.CollectionReadStatusScreen]
class CollectionReadStatusRoute
    extends _i37.PageRouteInfo<CollectionReadStatusRouteArgs> {
  CollectionReadStatusRoute({
    _i38.Key? key,
    required bool isRead,
    List<_i37.PageRouteInfo>? children,
  }) : super(
         CollectionReadStatusRoute.name,
         args: CollectionReadStatusRouteArgs(key: key, isRead: isRead),
         initialChildren: children,
       );

  static const String name = 'CollectionReadStatusRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CollectionReadStatusRouteArgs>();
      return _i5.CollectionReadStatusScreen(key: args.key, isRead: args.isRead);
    },
  );
}

class CollectionReadStatusRouteArgs {
  const CollectionReadStatusRouteArgs({this.key, required this.isRead});

  final _i38.Key? key;

  final bool isRead;

  @override
  String toString() {
    return 'CollectionReadStatusRouteArgs{key: $key, isRead: $isRead}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CollectionReadStatusRouteArgs) return false;
    return key == other.key && isRead == other.isRead;
  }

  @override
  int get hashCode => key.hashCode ^ isRead.hashCode;
}

/// generated route for
/// [_i6.ContinueReadingScreen]
class ContinueReadingRoute extends _i37.PageRouteInfo<void> {
  const ContinueReadingRoute({List<_i37.PageRouteInfo>? children})
    : super(ContinueReadingRoute.name, initialChildren: children);

  static const String name = 'ContinueReadingRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      return const _i6.ContinueReadingScreen();
    },
  );
}

/// generated route for
/// [_i7.FavoritesScreen]
class FavoritesRoute extends _i37.PageRouteInfo<void> {
  const FavoritesRoute({List<_i37.PageRouteInfo>? children})
    : super(FavoritesRoute.name, initialChildren: children);

  static const String name = 'FavoritesRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      return const _i7.FavoritesScreen();
    },
  );
}

/// generated route for
/// [_i8.FocReleasesScreen]
class FocReleasesRoute extends _i37.PageRouteInfo<void> {
  const FocReleasesRoute({List<_i37.PageRouteInfo>? children})
    : super(FocReleasesRoute.name, initialChildren: children);

  static const String name = 'FocReleasesRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      return const _i8.FocReleasesScreen();
    },
  );
}

/// generated route for
/// [_i9.HomeScreen]
class HomeRoute extends _i37.PageRouteInfo<void> {
  const HomeRoute({List<_i37.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      return const _i9.HomeScreen();
    },
  );
}

/// generated route for
/// [_i10.ImagePreviewScreen]
class ImagePreviewRoute extends _i37.PageRouteInfo<ImagePreviewRouteArgs> {
  ImagePreviewRoute({
    _i38.Key? key,
    required String imageUrl,
    String? title,
    String? heroTag,
    List<_i37.PageRouteInfo>? children,
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

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ImagePreviewRouteArgs>();
      return _i10.ImagePreviewScreen(
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

  final _i38.Key? key;

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
/// [_i11.IssueCharactersScreen]
class IssueCharactersRoute
    extends _i37.PageRouteInfo<IssueCharactersRouteArgs> {
  IssueCharactersRoute({
    _i38.Key? key,
    required int issueId,
    List<_i37.PageRouteInfo>? children,
  }) : super(
         IssueCharactersRoute.name,
         args: IssueCharactersRouteArgs(key: key, issueId: issueId),
         rawPathParams: {'issueId': issueId},
         initialChildren: children,
       );

  static const String name = 'IssueCharactersRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<IssueCharactersRouteArgs>(
        orElse: () =>
            IssueCharactersRouteArgs(issueId: pathParams.getInt('issueId')),
      );
      return _i11.IssueCharactersScreen(key: args.key, issueId: args.issueId);
    },
  );
}

class IssueCharactersRouteArgs {
  const IssueCharactersRouteArgs({this.key, required this.issueId});

  final _i38.Key? key;

  final int issueId;

  @override
  String toString() {
    return 'IssueCharactersRouteArgs{key: $key, issueId: $issueId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! IssueCharactersRouteArgs) return false;
    return key == other.key && issueId == other.issueId;
  }

  @override
  int get hashCode => key.hashCode ^ issueId.hashCode;
}

/// generated route for
/// [_i12.IssueCoverGalleryScreen]
class IssueCoverGalleryRoute
    extends _i37.PageRouteInfo<IssueCoverGalleryRouteArgs> {
  IssueCoverGalleryRoute({
    _i38.Key? key,
    required List<String> imageUrls,
    List<String>? imageLabels,
    List<String>? imageCaptions,
    int initialIndex = 0,
    String? title,
    String? heroTag,
    List<_i37.PageRouteInfo>? children,
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

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<IssueCoverGalleryRouteArgs>();
      return _i12.IssueCoverGalleryScreen(
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

  final _i38.Key? key;

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
        const _i39.ListEquality<String>().equals(imageUrls, other.imageUrls) &&
        const _i39.ListEquality<String>().equals(
          imageLabels,
          other.imageLabels,
        ) &&
        const _i39.ListEquality<String>().equals(
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
      const _i39.ListEquality<String>().hash(imageUrls) ^
      const _i39.ListEquality<String>().hash(imageLabels) ^
      const _i39.ListEquality<String>().hash(imageCaptions) ^
      initialIndex.hashCode ^
      title.hashCode ^
      heroTag.hashCode;
}

/// generated route for
/// [_i13.IssueCreatorsScreen]
class IssueCreatorsRoute extends _i37.PageRouteInfo<IssueCreatorsRouteArgs> {
  IssueCreatorsRoute({
    _i38.Key? key,
    required int issueId,
    List<_i37.PageRouteInfo>? children,
  }) : super(
         IssueCreatorsRoute.name,
         args: IssueCreatorsRouteArgs(key: key, issueId: issueId),
         rawPathParams: {'issueId': issueId},
         initialChildren: children,
       );

  static const String name = 'IssueCreatorsRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<IssueCreatorsRouteArgs>(
        orElse: () =>
            IssueCreatorsRouteArgs(issueId: pathParams.getInt('issueId')),
      );
      return _i13.IssueCreatorsScreen(key: args.key, issueId: args.issueId);
    },
  );
}

class IssueCreatorsRouteArgs {
  const IssueCreatorsRouteArgs({this.key, required this.issueId});

  final _i38.Key? key;

  final int issueId;

  @override
  String toString() {
    return 'IssueCreatorsRouteArgs{key: $key, issueId: $issueId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! IssueCreatorsRouteArgs) return false;
    return key == other.key && issueId == other.issueId;
  }

  @override
  int get hashCode => key.hashCode ^ issueId.hashCode;
}

/// generated route for
/// [_i14.IssueDetailsScreen]
class IssueDetailsRoute extends _i37.PageRouteInfo<IssueDetailsRouteArgs> {
  IssueDetailsRoute({
    _i38.Key? key,
    required int issueId,
    String? initialImageUrl,
    List<_i37.PageRouteInfo>? children,
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

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<IssueDetailsRouteArgs>(
        orElse: () =>
            IssueDetailsRouteArgs(issueId: pathParams.getInt('issueId')),
      );
      return _i14.IssueDetailsScreen(
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

  final _i38.Key? key;

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
/// [_i15.LibraryScreen]
class LibraryRoute extends _i37.PageRouteInfo<void> {
  const LibraryRoute({List<_i37.PageRouteInfo>? children})
    : super(LibraryRoute.name, initialChildren: children);

  static const String name = 'LibraryRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      return const _i15.LibraryScreen();
    },
  );
}

/// generated route for
/// [_i16.MainScreen]
class MainRoute extends _i37.PageRouteInfo<void> {
  const MainRoute({List<_i37.PageRouteInfo>? children})
    : super(MainRoute.name, initialChildren: children);

  static const String name = 'MainRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      return const _i16.MainScreen();
    },
  );
}

/// generated route for
/// [_i17.MetronConnectScreen]
class MetronConnectRoute extends _i37.PageRouteInfo<void> {
  const MetronConnectRoute({List<_i37.PageRouteInfo>? children})
    : super(MetronConnectRoute.name, initialChildren: children);

  static const String name = 'MetronConnectRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      return const _i17.MetronConnectScreen();
    },
  );
}

/// generated route for
/// [_i18.MetronInfoScreen]
class MetronInfoRoute extends _i37.PageRouteInfo<void> {
  const MetronInfoRoute({List<_i37.PageRouteInfo>? children})
    : super(MetronInfoRoute.name, initialChildren: children);

  static const String name = 'MetronInfoRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      return const _i18.MetronInfoScreen();
    },
  );
}

/// generated route for
/// [_i19.MyComicsScreen]
class MyComicsRoute extends _i37.PageRouteInfo<void> {
  const MyComicsRoute({List<_i37.PageRouteInfo>? children})
    : super(MyComicsRoute.name, initialChildren: children);

  static const String name = 'MyComicsRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      return const _i19.MyComicsScreen();
    },
  );
}

/// generated route for
/// [_i20.MyPullsScreen]
class MyPullsRoute extends _i37.PageRouteInfo<void> {
  const MyPullsRoute({List<_i37.PageRouteInfo>? children})
    : super(MyPullsRoute.name, initialChildren: children);

  static const String name = 'MyPullsRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      return const _i20.MyPullsScreen();
    },
  );
}

/// generated route for
/// [_i21.MyReadingListsScreen]
class MyReadingListsRoute extends _i37.PageRouteInfo<void> {
  const MyReadingListsRoute({List<_i37.PageRouteInfo>? children})
    : super(MyReadingListsRoute.name, initialChildren: children);

  static const String name = 'MyReadingListsRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      return const _i21.MyReadingListsScreen();
    },
  );
}

/// generated route for
/// [_i22.NewFirstIssuesScreen]
class NewFirstIssuesRoute extends _i37.PageRouteInfo<void> {
  const NewFirstIssuesRoute({List<_i37.PageRouteInfo>? children})
    : super(NewFirstIssuesRoute.name, initialChildren: children);

  static const String name = 'NewFirstIssuesRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      return const _i22.NewFirstIssuesScreen();
    },
  );
}

/// generated route for
/// [_i23.OnboardingScreen]
class OnboardingRoute extends _i37.PageRouteInfo<void> {
  const OnboardingRoute({List<_i37.PageRouteInfo>? children})
    : super(OnboardingRoute.name, initialChildren: children);

  static const String name = 'OnboardingRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      return const _i23.OnboardingScreen();
    },
  );
}

/// generated route for
/// [_i24.ReadingHistoryScreen]
class ReadingHistoryRoute extends _i37.PageRouteInfo<void> {
  const ReadingHistoryRoute({List<_i37.PageRouteInfo>? children})
    : super(ReadingHistoryRoute.name, initialChildren: children);

  static const String name = 'ReadingHistoryRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      return const _i24.ReadingHistoryScreen();
    },
  );
}

/// generated route for
/// [_i25.ReadingListDetailsScreen]
class ReadingListDetailsRoute
    extends _i37.PageRouteInfo<ReadingListDetailsRouteArgs> {
  ReadingListDetailsRoute({
    _i38.Key? key,
    required String listId,
    List<_i37.PageRouteInfo>? children,
  }) : super(
         ReadingListDetailsRoute.name,
         args: ReadingListDetailsRouteArgs(key: key, listId: listId),
         rawPathParams: {'listId': listId},
         initialChildren: children,
       );

  static const String name = 'ReadingListDetailsRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<ReadingListDetailsRouteArgs>(
        orElse: () =>
            ReadingListDetailsRouteArgs(listId: pathParams.getString('listId')),
      );
      return _i25.ReadingListDetailsScreen(key: args.key, listId: args.listId);
    },
  );
}

class ReadingListDetailsRouteArgs {
  const ReadingListDetailsRouteArgs({this.key, required this.listId});

  final _i38.Key? key;

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
/// [_i26.ReadingListEditScreen]
class ReadingListEditRoute
    extends _i37.PageRouteInfo<ReadingListEditRouteArgs> {
  ReadingListEditRoute({
    _i38.Key? key,
    required String listId,
    List<_i37.PageRouteInfo>? children,
  }) : super(
         ReadingListEditRoute.name,
         args: ReadingListEditRouteArgs(key: key, listId: listId),
         rawPathParams: {'listId': listId},
         initialChildren: children,
       );

  static const String name = 'ReadingListEditRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<ReadingListEditRouteArgs>(
        orElse: () =>
            ReadingListEditRouteArgs(listId: pathParams.getString('listId')),
      );
      return _i26.ReadingListEditScreen(key: args.key, listId: args.listId);
    },
  );
}

class ReadingListEditRouteArgs {
  const ReadingListEditRouteArgs({this.key, required this.listId});

  final _i38.Key? key;

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
/// [_i27.ReleasesScreen]
class ReleasesRoute extends _i37.PageRouteInfo<void> {
  const ReleasesRoute({List<_i37.PageRouteInfo>? children})
    : super(ReleasesRoute.name, initialChildren: children);

  static const String name = 'ReleasesRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      return const _i27.ReleasesScreen();
    },
  );
}

/// generated route for
/// [_i28.SearchResultsScreen]
class SearchResultsRoute extends _i37.PageRouteInfo<SearchResultsRouteArgs> {
  SearchResultsRoute({
    _i38.Key? key,
    required String query,
    String searchChoice = 'Issues',
    List<_i37.PageRouteInfo>? children,
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

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SearchResultsRouteArgs>();
      return _i28.SearchResultsScreen(
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

  final _i38.Key? key;

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
/// [_i29.SeriesDetailsScreen]
class SeriesDetailsRoute extends _i37.PageRouteInfo<SeriesDetailsRouteArgs> {
  SeriesDetailsRoute({
    _i38.Key? key,
    required int seriesId,
    String? initialImageUrl,
    List<_i37.PageRouteInfo>? children,
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

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<SeriesDetailsRouteArgs>(
        orElse: () =>
            SeriesDetailsRouteArgs(seriesId: pathParams.getInt('seriesId')),
      );
      return _i29.SeriesDetailsScreen(
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

  final _i38.Key? key;

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
/// [_i30.SeriesIssuesScreen]
class SeriesIssuesRoute extends _i37.PageRouteInfo<SeriesIssuesRouteArgs> {
  SeriesIssuesRoute({
    _i38.Key? key,
    required int seriesId,
    List<_i37.PageRouteInfo>? children,
  }) : super(
         SeriesIssuesRoute.name,
         args: SeriesIssuesRouteArgs(key: key, seriesId: seriesId),
         rawPathParams: {'seriesId': seriesId},
         initialChildren: children,
       );

  static const String name = 'SeriesIssuesRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<SeriesIssuesRouteArgs>(
        orElse: () =>
            SeriesIssuesRouteArgs(seriesId: pathParams.getInt('seriesId')),
      );
      return _i30.SeriesIssuesScreen(key: args.key, seriesId: args.seriesId);
    },
  );
}

class SeriesIssuesRouteArgs {
  const SeriesIssuesRouteArgs({this.key, required this.seriesId});

  final _i38.Key? key;

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
/// [_i31.SettingsScreen]
class SettingsRoute extends _i37.PageRouteInfo<void> {
  const SettingsRoute({List<_i37.PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      return const _i31.SettingsScreen();
    },
  );
}

/// generated route for
/// [_i32.SubscriptionsScreen]
class SubscriptionsRoute extends _i37.PageRouteInfo<void> {
  const SubscriptionsRoute({List<_i37.PageRouteInfo>? children})
    : super(SubscriptionsRoute.name, initialChildren: children);

  static const String name = 'SubscriptionsRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      return const _i32.SubscriptionsScreen();
    },
  );
}

/// generated route for
/// [_i33.UnratedIssuesScreen]
class UnratedIssuesRoute extends _i37.PageRouteInfo<void> {
  const UnratedIssuesRoute({List<_i37.PageRouteInfo>? children})
    : super(UnratedIssuesRoute.name, initialChildren: children);

  static const String name = 'UnratedIssuesRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      return const _i33.UnratedIssuesScreen();
    },
  );
}

/// generated route for
/// [_i34.UserProfileScreen]
class UserProfileRoute extends _i37.PageRouteInfo<void> {
  const UserProfileRoute({List<_i37.PageRouteInfo>? children})
    : super(UserProfileRoute.name, initialChildren: children);

  static const String name = 'UserProfileRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      return const _i34.UserProfileScreen();
    },
  );
}

/// generated route for
/// [_i35.WeeklyReleasesScreen]
class WeeklyReleasesRoute extends _i37.PageRouteInfo<void> {
  const WeeklyReleasesRoute({List<_i37.PageRouteInfo>? children})
    : super(WeeklyReleasesRoute.name, initialChildren: children);

  static const String name = 'WeeklyReleasesRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      return const _i35.WeeklyReleasesScreen();
    },
  );
}

/// generated route for
/// [_i36.WishlistScreen]
class WishlistRoute extends _i37.PageRouteInfo<void> {
  const WishlistRoute({List<_i37.PageRouteInfo>? children})
    : super(WishlistRoute.name, initialChildren: children);

  static const String name = 'WishlistRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      return const _i36.WishlistScreen();
    },
  );
}
