// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i13;
import 'package:flutter/material.dart' as _i14;
import 'package:takion/src/presentation/screens/discover_screen.dart' as _i1;
import 'package:takion/src/presentation/screens/home_screen.dart' as _i2;
import 'package:takion/src/presentation/screens/library_screen.dart' as _i3;
import 'package:takion/src/presentation/screens/login_screen.dart' as _i4;
import 'package:takion/src/presentation/screens/main_screen.dart' as _i5;
import 'package:takion/src/presentation/screens/new_first_issues_screen.dart'
    as _i6;
import 'package:takion/src/presentation/screens/profile_screen.dart' as _i11;
import 'package:takion/src/presentation/screens/releases_screen.dart' as _i7;
import 'package:takion/src/presentation/screens/search_results_screen.dart'
    as _i8;
import 'package:takion/src/presentation/screens/search_screen.dart' as _i9;
import 'package:takion/src/presentation/screens/settings_screen.dart' as _i10;
import 'package:takion/src/presentation/screens/weekly_releases_screen.dart'
    as _i12;

/// generated route for
/// [_i1.DiscoverScreen]
class DiscoverRoute extends _i13.PageRouteInfo<void> {
  const DiscoverRoute({List<_i13.PageRouteInfo>? children})
    : super(DiscoverRoute.name, initialChildren: children);

  static const String name = 'DiscoverRoute';

  static _i13.PageInfo page = _i13.PageInfo(
    name,
    builder: (data) {
      return const _i1.DiscoverScreen();
    },
  );
}

/// generated route for
/// [_i2.HomeScreen]
class HomeRoute extends _i13.PageRouteInfo<void> {
  const HomeRoute({List<_i13.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i13.PageInfo page = _i13.PageInfo(
    name,
    builder: (data) {
      return const _i2.HomeScreen();
    },
  );
}

/// generated route for
/// [_i3.LibraryScreen]
class LibraryRoute extends _i13.PageRouteInfo<void> {
  const LibraryRoute({List<_i13.PageRouteInfo>? children})
    : super(LibraryRoute.name, initialChildren: children);

  static const String name = 'LibraryRoute';

  static _i13.PageInfo page = _i13.PageInfo(
    name,
    builder: (data) {
      return const _i3.LibraryScreen();
    },
  );
}

/// generated route for
/// [_i4.LoginScreen]
class LoginRoute extends _i13.PageRouteInfo<LoginRouteArgs> {
  LoginRoute({
    _i14.Key? key,
    void Function(bool)? onResult,
    List<_i13.PageRouteInfo>? children,
  }) : super(
         LoginRoute.name,
         args: LoginRouteArgs(key: key, onResult: onResult),
         initialChildren: children,
       );

  static const String name = 'LoginRoute';

  static _i13.PageInfo page = _i13.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<LoginRouteArgs>(
        orElse: () => const LoginRouteArgs(),
      );
      return _i4.LoginScreen(key: args.key, onResult: args.onResult);
    },
  );
}

class LoginRouteArgs {
  const LoginRouteArgs({this.key, this.onResult});

  final _i14.Key? key;

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
/// [_i5.MainScreen]
class MainRoute extends _i13.PageRouteInfo<void> {
  const MainRoute({List<_i13.PageRouteInfo>? children})
    : super(MainRoute.name, initialChildren: children);

  static const String name = 'MainRoute';

  static _i13.PageInfo page = _i13.PageInfo(
    name,
    builder: (data) {
      return const _i5.MainScreen();
    },
  );
}

/// generated route for
/// [_i6.NewFirstIssuesScreen]
class NewFirstIssuesRoute extends _i13.PageRouteInfo<void> {
  const NewFirstIssuesRoute({List<_i13.PageRouteInfo>? children})
    : super(NewFirstIssuesRoute.name, initialChildren: children);

  static const String name = 'NewFirstIssuesRoute';

  static _i13.PageInfo page = _i13.PageInfo(
    name,
    builder: (data) {
      return const _i6.NewFirstIssuesScreen();
    },
  );
}

/// generated route for
/// [_i7.ReleasesScreen]
class ReleasesRoute extends _i13.PageRouteInfo<void> {
  const ReleasesRoute({List<_i13.PageRouteInfo>? children})
    : super(ReleasesRoute.name, initialChildren: children);

  static const String name = 'ReleasesRoute';

  static _i13.PageInfo page = _i13.PageInfo(
    name,
    builder: (data) {
      return const _i7.ReleasesScreen();
    },
  );
}

/// generated route for
/// [_i8.SearchResultsScreen]
class SearchResultsRoute extends _i13.PageRouteInfo<void> {
  const SearchResultsRoute({List<_i13.PageRouteInfo>? children})
    : super(SearchResultsRoute.name, initialChildren: children);

  static const String name = 'SearchResultsRoute';

  static _i13.PageInfo page = _i13.PageInfo(
    name,
    builder: (data) {
      return const _i8.SearchResultsScreen();
    },
  );
}

/// generated route for
/// [_i9.SearchScreen]
class SearchRoute extends _i13.PageRouteInfo<void> {
  const SearchRoute({List<_i13.PageRouteInfo>? children})
    : super(SearchRoute.name, initialChildren: children);

  static const String name = 'SearchRoute';

  static _i13.PageInfo page = _i13.PageInfo(
    name,
    builder: (data) {
      return const _i9.SearchScreen();
    },
  );
}

/// generated route for
/// [_i10.SettingsScreen]
class SettingsRoute extends _i13.PageRouteInfo<void> {
  const SettingsRoute({List<_i13.PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static _i13.PageInfo page = _i13.PageInfo(
    name,
    builder: (data) {
      return const _i10.SettingsScreen();
    },
  );
}

/// generated route for
/// [_i11.UserProfileScreen]
class UserProfileRoute extends _i13.PageRouteInfo<void> {
  const UserProfileRoute({List<_i13.PageRouteInfo>? children})
    : super(UserProfileRoute.name, initialChildren: children);

  static const String name = 'UserProfileRoute';

  static _i13.PageInfo page = _i13.PageInfo(
    name,
    builder: (data) {
      return const _i11.UserProfileScreen();
    },
  );
}

/// generated route for
/// [_i12.WeeklyReleasesScreen]
class WeeklyReleasesRoute extends _i13.PageRouteInfo<void> {
  const WeeklyReleasesRoute({List<_i13.PageRouteInfo>? children})
    : super(WeeklyReleasesRoute.name, initialChildren: children);

  static const String name = 'WeeklyReleasesRoute';

  static _i13.PageInfo page = _i13.PageInfo(
    name,
    builder: (data) {
      return const _i12.WeeklyReleasesScreen();
    },
  );
}
