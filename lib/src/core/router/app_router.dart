import 'package:auto_route/auto_route.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/core/router/auth_guard.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  final AuthGuard authGuard;

  AppRouter(this.authGuard);

  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: OnboardingRoute.page, path: '/', initial: true),
        AutoRoute(page: LoginRoute.page, path: '/login'),
        AutoRoute(
          page: MetronConnectRoute.page,
          path: '/connect-metron',
          guards: [authGuard],
        ),
        AutoRoute(
          page: MainRoute.page,
          path: '/app',
          guards: [authGuard],
          children: [
            AutoRoute(page: HomeRoute.page, path: 'home'),
            AutoRoute(page: ReleasesRoute.page, path: 'releases'),
            AutoRoute(page: LibraryRoute.page, path: 'library'),
            AutoRoute(page: DiscoverRoute.page, path: 'discover'),
          ],
        ),
        AutoRoute(
          page: WeeklyReleasesRoute.page,
          path: '/weekly-releases',
          guards: [authGuard],
        ),
        AutoRoute(
          page: NewFirstIssuesRoute.page,
          path: '/new-first-issues',
          guards: [authGuard],
        ),
        AutoRoute(
          page: IssueDetailsRoute.page,
          path: '/issue/:issueId',
          guards: [authGuard],
        ),
        AutoRoute(
          page: IssueCoverGalleryRoute.page,
          path: '/issue-cover-gallery',
          guards: [authGuard],
        ),
        AutoRoute(
          page: SearchRoute.page,
          path: '/search',
          guards: [authGuard],
        ),
        AutoRoute(
          page: SearchResultsRoute.page,
          path: '/search/results',
          guards: [authGuard],
        ),
        AutoRoute(
          page: CollectionReadStatusRoute.page,
          path: '/my-comics/read-status',
          guards: [authGuard],
        ),
        AutoRoute(
          page: IncompleteSeriesRoute.page,
          path: '/my-comics/incomplete-series',
          guards: [authGuard],
        ),
        AutoRoute(
          page: MyComicsRoute.page,
          path: '/my-comics',
          guards: [authGuard],
        ),
        AutoRoute(
          page: MyPullsRoute.page,
          path: '/my-pulls',
          guards: [authGuard],
        ),
        AutoRoute(
          page: SeriesDetailsRoute.page,
          path: '/series/:seriesId',
          guards: [authGuard],
        ),
        AutoRoute(
          page: UserProfileRoute.page,
          path: '/profile',
          guards: [authGuard],
        ),
        AutoRoute(
          page: SettingsRoute.page,
          path: '/settings',
          guards: [authGuard],
        ),
      ];
}
