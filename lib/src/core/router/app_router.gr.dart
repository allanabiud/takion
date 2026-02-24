// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i21;
import 'package:collection/collection.dart' as _i23;
import 'package:flutter/material.dart' as _i22;
import 'package:takion/src/presentation/screens/collection_read_status_screen.dart'
    as _i1;
import 'package:takion/src/presentation/screens/discover_screen.dart' as _i2;
import 'package:takion/src/presentation/screens/home_screen.dart' as _i3;
import 'package:takion/src/presentation/screens/incomplete_series_screen.dart'
    as _i4;
import 'package:takion/src/presentation/screens/issue_cover_gallery_screen.dart'
    as _i5;
import 'package:takion/src/presentation/screens/issue_details_screen.dart'
    as _i6;
import 'package:takion/src/presentation/screens/library_screen.dart' as _i7;
import 'package:takion/src/presentation/screens/login_screen.dart' as _i8;
import 'package:takion/src/presentation/screens/main_screen.dart' as _i9;
import 'package:takion/src/presentation/screens/my_comics_screen.dart' as _i10;
import 'package:takion/src/presentation/screens/my_pulls_screen.dart' as _i11;
import 'package:takion/src/presentation/screens/new_first_issues_screen.dart'
    as _i12;
import 'package:takion/src/presentation/screens/onboarding_screen.dart' as _i13;
import 'package:takion/src/presentation/screens/profile_screen.dart' as _i19;
import 'package:takion/src/presentation/screens/releases_screen.dart' as _i14;
import 'package:takion/src/presentation/screens/search_results_screen.dart'
    as _i15;
import 'package:takion/src/presentation/screens/search_screen.dart' as _i16;
import 'package:takion/src/presentation/screens/series_details_screen.dart'
    as _i17;
import 'package:takion/src/presentation/screens/settings_screen.dart' as _i18;
import 'package:takion/src/presentation/screens/weekly_releases_screen.dart'
    as _i20;

/// generated route for
/// [_i1.CollectionReadStatusScreen]
class CollectionReadStatusRoute
    extends _i21.PageRouteInfo<CollectionReadStatusRouteArgs> {
  CollectionReadStatusRoute({
    _i22.Key? key,
    required bool isRead,
    List<_i21.PageRouteInfo>? children,
  }) : super(
         CollectionReadStatusRoute.name,
         args: CollectionReadStatusRouteArgs(key: key, isRead: isRead),
         initialChildren: children,
       );

  static const String name = 'CollectionReadStatusRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CollectionReadStatusRouteArgs>();
      return _i1.CollectionReadStatusScreen(key: args.key, isRead: args.isRead);
    },
  );
}

class CollectionReadStatusRouteArgs {
  const CollectionReadStatusRouteArgs({this.key, required this.isRead});

  final _i22.Key? key;

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
/// [_i2.DiscoverScreen]
class DiscoverRoute extends _i21.PageRouteInfo<void> {
  const DiscoverRoute({List<_i21.PageRouteInfo>? children})
    : super(DiscoverRoute.name, initialChildren: children);

  static const String name = 'DiscoverRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      return const _i2.DiscoverScreen();
    },
  );
}

/// generated route for
/// [_i3.HomeScreen]
class HomeRoute extends _i21.PageRouteInfo<void> {
  const HomeRoute({List<_i21.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      return const _i3.HomeScreen();
    },
  );
}

/// generated route for
/// [_i4.IncompleteSeriesScreen]
class IncompleteSeriesRoute extends _i21.PageRouteInfo<void> {
  const IncompleteSeriesRoute({List<_i21.PageRouteInfo>? children})
    : super(IncompleteSeriesRoute.name, initialChildren: children);

  static const String name = 'IncompleteSeriesRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      return const _i4.IncompleteSeriesScreen();
    },
  );
}

/// generated route for
/// [_i5.IssueCoverGalleryScreen]
class IssueCoverGalleryRoute
    extends _i21.PageRouteInfo<IssueCoverGalleryRouteArgs> {
  IssueCoverGalleryRoute({
    _i22.Key? key,
    required List<String> imageUrls,
    List<String>? imageLabels,
    List<String>? imageCaptions,
    int initialIndex = 0,
    String? title,
    String? heroTag,
    List<_i21.PageRouteInfo>? children,
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

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<IssueCoverGalleryRouteArgs>();
      return _i5.IssueCoverGalleryScreen(
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

  final _i22.Key? key;

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
        const _i23.ListEquality<String>().equals(imageUrls, other.imageUrls) &&
        const _i23.ListEquality<String>().equals(
          imageLabels,
          other.imageLabels,
        ) &&
        const _i23.ListEquality<String>().equals(
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
      const _i23.ListEquality<String>().hash(imageUrls) ^
      const _i23.ListEquality<String>().hash(imageLabels) ^
      const _i23.ListEquality<String>().hash(imageCaptions) ^
      initialIndex.hashCode ^
      title.hashCode ^
      heroTag.hashCode;
}

/// generated route for
/// [_i6.IssueDetailsScreen]
class IssueDetailsRoute extends _i21.PageRouteInfo<IssueDetailsRouteArgs> {
  IssueDetailsRoute({
    _i22.Key? key,
    required int issueId,
    String? initialImageUrl,
    List<_i21.PageRouteInfo>? children,
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

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<IssueDetailsRouteArgs>(
        orElse: () =>
            IssueDetailsRouteArgs(issueId: pathParams.getInt('issueId')),
      );
      return _i6.IssueDetailsScreen(
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

  final _i22.Key? key;

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
/// [_i7.LibraryScreen]
class LibraryRoute extends _i21.PageRouteInfo<void> {
  const LibraryRoute({List<_i21.PageRouteInfo>? children})
    : super(LibraryRoute.name, initialChildren: children);

  static const String name = 'LibraryRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      return const _i7.LibraryScreen();
    },
  );
}

/// generated route for
/// [_i8.LoginScreen]
class LoginRoute extends _i21.PageRouteInfo<LoginRouteArgs> {
  LoginRoute({
    _i22.Key? key,
    void Function(bool)? onResult,
    List<_i21.PageRouteInfo>? children,
  }) : super(
         LoginRoute.name,
         args: LoginRouteArgs(key: key, onResult: onResult),
         initialChildren: children,
       );

  static const String name = 'LoginRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<LoginRouteArgs>(
        orElse: () => const LoginRouteArgs(),
      );
      return _i8.LoginScreen(key: args.key, onResult: args.onResult);
    },
  );
}

class LoginRouteArgs {
  const LoginRouteArgs({this.key, this.onResult});

  final _i22.Key? key;

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
/// [_i9.MainScreen]
class MainRoute extends _i21.PageRouteInfo<void> {
  const MainRoute({List<_i21.PageRouteInfo>? children})
    : super(MainRoute.name, initialChildren: children);

  static const String name = 'MainRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      return const _i9.MainScreen();
    },
  );
}

/// generated route for
/// [_i10.MyComicsScreen]
class MyComicsRoute extends _i21.PageRouteInfo<void> {
  const MyComicsRoute({List<_i21.PageRouteInfo>? children})
    : super(MyComicsRoute.name, initialChildren: children);

  static const String name = 'MyComicsRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      return const _i10.MyComicsScreen();
    },
  );
}

/// generated route for
/// [_i11.MyPullsScreen]
class MyPullsRoute extends _i21.PageRouteInfo<void> {
  const MyPullsRoute({List<_i21.PageRouteInfo>? children})
    : super(MyPullsRoute.name, initialChildren: children);

  static const String name = 'MyPullsRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      return const _i11.MyPullsScreen();
    },
  );
}

/// generated route for
/// [_i12.NewFirstIssuesScreen]
class NewFirstIssuesRoute extends _i21.PageRouteInfo<void> {
  const NewFirstIssuesRoute({List<_i21.PageRouteInfo>? children})
    : super(NewFirstIssuesRoute.name, initialChildren: children);

  static const String name = 'NewFirstIssuesRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      return const _i12.NewFirstIssuesScreen();
    },
  );
}

/// generated route for
/// [_i13.OnboardingScreen]
class OnboardingRoute extends _i21.PageRouteInfo<void> {
  const OnboardingRoute({List<_i21.PageRouteInfo>? children})
    : super(OnboardingRoute.name, initialChildren: children);

  static const String name = 'OnboardingRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      return const _i13.OnboardingScreen();
    },
  );
}

/// generated route for
/// [_i14.ReleasesScreen]
class ReleasesRoute extends _i21.PageRouteInfo<void> {
  const ReleasesRoute({List<_i21.PageRouteInfo>? children})
    : super(ReleasesRoute.name, initialChildren: children);

  static const String name = 'ReleasesRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      return const _i14.ReleasesScreen();
    },
  );
}

/// generated route for
/// [_i15.SearchResultsScreen]
class SearchResultsRoute extends _i21.PageRouteInfo<SearchResultsRouteArgs> {
  SearchResultsRoute({
    _i22.Key? key,
    required String query,
    String searchChoice = 'Issues',
    List<_i21.PageRouteInfo>? children,
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

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SearchResultsRouteArgs>();
      return _i15.SearchResultsScreen(
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

  final _i22.Key? key;

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
/// [_i16.SearchScreen]
class SearchRoute extends _i21.PageRouteInfo<void> {
  const SearchRoute({List<_i21.PageRouteInfo>? children})
    : super(SearchRoute.name, initialChildren: children);

  static const String name = 'SearchRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      return const _i16.SearchScreen();
    },
  );
}

/// generated route for
/// [_i17.SeriesDetailsScreen]
class SeriesDetailsRoute extends _i21.PageRouteInfo<SeriesDetailsRouteArgs> {
  SeriesDetailsRoute({
    _i22.Key? key,
    required int seriesId,
    List<_i21.PageRouteInfo>? children,
  }) : super(
         SeriesDetailsRoute.name,
         args: SeriesDetailsRouteArgs(key: key, seriesId: seriesId),
         rawPathParams: {'seriesId': seriesId},
         initialChildren: children,
       );

  static const String name = 'SeriesDetailsRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<SeriesDetailsRouteArgs>(
        orElse: () =>
            SeriesDetailsRouteArgs(seriesId: pathParams.getInt('seriesId')),
      );
      return _i17.SeriesDetailsScreen(key: args.key, seriesId: args.seriesId);
    },
  );
}

class SeriesDetailsRouteArgs {
  const SeriesDetailsRouteArgs({this.key, required this.seriesId});

  final _i22.Key? key;

  final int seriesId;

  @override
  String toString() {
    return 'SeriesDetailsRouteArgs{key: $key, seriesId: $seriesId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SeriesDetailsRouteArgs) return false;
    return key == other.key && seriesId == other.seriesId;
  }

  @override
  int get hashCode => key.hashCode ^ seriesId.hashCode;
}

/// generated route for
/// [_i18.SettingsScreen]
class SettingsRoute extends _i21.PageRouteInfo<void> {
  const SettingsRoute({List<_i21.PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      return const _i18.SettingsScreen();
    },
  );
}

/// generated route for
/// [_i19.UserProfileScreen]
class UserProfileRoute extends _i21.PageRouteInfo<void> {
  const UserProfileRoute({List<_i21.PageRouteInfo>? children})
    : super(UserProfileRoute.name, initialChildren: children);

  static const String name = 'UserProfileRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      return const _i19.UserProfileScreen();
    },
  );
}

/// generated route for
/// [_i20.WeeklyReleasesScreen]
class WeeklyReleasesRoute extends _i21.PageRouteInfo<void> {
  const WeeklyReleasesRoute({List<_i21.PageRouteInfo>? children})
    : super(WeeklyReleasesRoute.name, initialChildren: children);

  static const String name = 'WeeklyReleasesRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      return const _i20.WeeklyReleasesScreen();
    },
  );
}
