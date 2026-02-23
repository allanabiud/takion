// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i14;
import 'package:collection/collection.dart' as _i16;
import 'package:flutter/material.dart' as _i15;
import 'package:takion/src/presentation/screens/discover_screen.dart' as _i1;
import 'package:takion/src/presentation/screens/home_screen.dart' as _i2;
import 'package:takion/src/presentation/screens/issue_cover_gallery_screen.dart'
    as _i3;
import 'package:takion/src/presentation/screens/issue_details_screen.dart'
    as _i4;
import 'package:takion/src/presentation/screens/library_screen.dart' as _i5;
import 'package:takion/src/presentation/screens/login_screen.dart' as _i6;
import 'package:takion/src/presentation/screens/main_screen.dart' as _i7;
import 'package:takion/src/presentation/screens/new_first_issues_screen.dart'
    as _i8;
import 'package:takion/src/presentation/screens/onboarding_screen.dart' as _i9;
import 'package:takion/src/presentation/screens/profile_screen.dart' as _i12;
import 'package:takion/src/presentation/screens/releases_screen.dart' as _i10;
import 'package:takion/src/presentation/screens/settings_screen.dart' as _i11;
import 'package:takion/src/presentation/screens/weekly_releases_screen.dart'
    as _i13;

/// generated route for
/// [_i1.DiscoverScreen]
class DiscoverRoute extends _i14.PageRouteInfo<void> {
  const DiscoverRoute({List<_i14.PageRouteInfo>? children})
    : super(DiscoverRoute.name, initialChildren: children);

  static const String name = 'DiscoverRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      return const _i1.DiscoverScreen();
    },
  );
}

/// generated route for
/// [_i2.HomeScreen]
class HomeRoute extends _i14.PageRouteInfo<void> {
  const HomeRoute({List<_i14.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      return const _i2.HomeScreen();
    },
  );
}

/// generated route for
/// [_i3.IssueCoverGalleryScreen]
class IssueCoverGalleryRoute
    extends _i14.PageRouteInfo<IssueCoverGalleryRouteArgs> {
  IssueCoverGalleryRoute({
    _i15.Key? key,
    required List<String> imageUrls,
    List<String>? imageLabels,
    List<String>? imageCaptions,
    int initialIndex = 0,
    String? title,
    String? heroTag,
    List<_i14.PageRouteInfo>? children,
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

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<IssueCoverGalleryRouteArgs>();
      return _i3.IssueCoverGalleryScreen(
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

  final _i15.Key? key;

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
        const _i16.ListEquality<String>().equals(imageUrls, other.imageUrls) &&
        const _i16.ListEquality<String>().equals(
          imageLabels,
          other.imageLabels,
        ) &&
        const _i16.ListEquality<String>().equals(
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
      const _i16.ListEquality<String>().hash(imageUrls) ^
      const _i16.ListEquality<String>().hash(imageLabels) ^
      const _i16.ListEquality<String>().hash(imageCaptions) ^
      initialIndex.hashCode ^
      title.hashCode ^
      heroTag.hashCode;
}

/// generated route for
/// [_i4.IssueDetailsScreen]
class IssueDetailsRoute extends _i14.PageRouteInfo<IssueDetailsRouteArgs> {
  IssueDetailsRoute({
    _i15.Key? key,
    required int issueId,
    String? initialImageUrl,
    List<_i14.PageRouteInfo>? children,
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

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<IssueDetailsRouteArgs>(
        orElse: () =>
            IssueDetailsRouteArgs(issueId: pathParams.getInt('issueId')),
      );
      return _i4.IssueDetailsScreen(
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

  final _i15.Key? key;

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
/// [_i5.LibraryScreen]
class LibraryRoute extends _i14.PageRouteInfo<void> {
  const LibraryRoute({List<_i14.PageRouteInfo>? children})
    : super(LibraryRoute.name, initialChildren: children);

  static const String name = 'LibraryRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      return const _i5.LibraryScreen();
    },
  );
}

/// generated route for
/// [_i6.LoginScreen]
class LoginRoute extends _i14.PageRouteInfo<LoginRouteArgs> {
  LoginRoute({
    _i15.Key? key,
    void Function(bool)? onResult,
    List<_i14.PageRouteInfo>? children,
  }) : super(
         LoginRoute.name,
         args: LoginRouteArgs(key: key, onResult: onResult),
         initialChildren: children,
       );

  static const String name = 'LoginRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<LoginRouteArgs>(
        orElse: () => const LoginRouteArgs(),
      );
      return _i6.LoginScreen(key: args.key, onResult: args.onResult);
    },
  );
}

class LoginRouteArgs {
  const LoginRouteArgs({this.key, this.onResult});

  final _i15.Key? key;

  final void Function(bool)? onResult;

  @override
  String toString() {
    return 'LoginRouteArgs{key: $key, onResult: $onResult}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! LoginRouteArgs) return false;
    return key == other.key;
  }

  @override
  int get hashCode => key.hashCode;
}

/// generated route for
/// [_i7.MainScreen]
class MainRoute extends _i14.PageRouteInfo<void> {
  const MainRoute({List<_i14.PageRouteInfo>? children})
    : super(MainRoute.name, initialChildren: children);

  static const String name = 'MainRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      return const _i7.MainScreen();
    },
  );
}

/// generated route for
/// [_i8.NewFirstIssuesScreen]
class NewFirstIssuesRoute extends _i14.PageRouteInfo<void> {
  const NewFirstIssuesRoute({List<_i14.PageRouteInfo>? children})
    : super(NewFirstIssuesRoute.name, initialChildren: children);

  static const String name = 'NewFirstIssuesRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      return const _i8.NewFirstIssuesScreen();
    },
  );
}

/// generated route for
/// [_i9.OnboardingScreen]
class OnboardingRoute extends _i14.PageRouteInfo<void> {
  const OnboardingRoute({List<_i14.PageRouteInfo>? children})
    : super(OnboardingRoute.name, initialChildren: children);

  static const String name = 'OnboardingRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      return const _i9.OnboardingScreen();
    },
  );
}

/// generated route for
/// [_i10.ReleasesScreen]
class ReleasesRoute extends _i14.PageRouteInfo<void> {
  const ReleasesRoute({List<_i14.PageRouteInfo>? children})
    : super(ReleasesRoute.name, initialChildren: children);

  static const String name = 'ReleasesRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      return const _i10.ReleasesScreen();
    },
  );
}

/// generated route for
/// [_i11.SettingsScreen]
class SettingsRoute extends _i14.PageRouteInfo<void> {
  const SettingsRoute({List<_i14.PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      return const _i11.SettingsScreen();
    },
  );
}

/// generated route for
/// [_i12.UserProfileScreen]
class UserProfileRoute extends _i14.PageRouteInfo<void> {
  const UserProfileRoute({List<_i14.PageRouteInfo>? children})
    : super(UserProfileRoute.name, initialChildren: children);

  static const String name = 'UserProfileRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      return const _i12.UserProfileScreen();
    },
  );
}

/// generated route for
/// [_i13.WeeklyReleasesScreen]
class WeeklyReleasesRoute extends _i14.PageRouteInfo<void> {
  const WeeklyReleasesRoute({List<_i14.PageRouteInfo>? children})
    : super(WeeklyReleasesRoute.name, initialChildren: children);

  static const String name = 'WeeklyReleasesRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      return const _i13.WeeklyReleasesScreen();
    },
  );
}
