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
    AutoRoute(
      page: AuthorizeMetronRoute.page,
      path: '/authorize-metron',
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
      page: FocReleasesRoute.page,
      path: '/foc-releases',
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
      page: CharacterDetailsRoute.page,
      path: '/character/:characterId',
      guards: [authGuard],
    ),
    AutoRoute(
      page: CharacterIssuesRoute.page,
      path: '/character/:characterId/issues',
      guards: [authGuard],
    ),
    AutoRoute(
      page: CreatorDetailsRoute.page,
      path: '/creator/:creatorId',
      guards: [authGuard],
    ),
    AutoRoute(
      page: UniverseDetailsRoute.page,
      path: '/universe/:universeId',
      guards: [authGuard],
    ),
    AutoRoute(
      page: ImprintDetailsRoute.page,
      path: '/imprint/:imprintId',
      guards: [authGuard],
    ),
    AutoRoute(
      page: TeamDetailsRoute.page,
      path: '/team/:teamId',
      guards: [authGuard],
    ),
    AutoRoute(
      page: ArcDetailsRoute.page,
      path: '/arc/:arcId',
      guards: [authGuard],
    ),
    AutoRoute(
      page: ArcIssuesRoute.page,
      path: '/arc/:arcId/issues',
      guards: [authGuard],
    ),
    AutoRoute(
      page: PublisherDetailsRoute.page,
      path: '/publisher/:publisherId',
      guards: [authGuard],
    ),
    AutoRoute(
      page: PublisherSeriesRoute.page,
      path: '/publisher/:publisherId/series',
      guards: [authGuard],
    ),
    AutoRoute(
      page: ImagePreviewRoute.page,
      path: '/image-preview',
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
      page: UnratedIssuesRoute.page,
      path: '/my-comics/unrated',
      guards: [authGuard],
    ),
    AutoRoute(
      page: ReadingHistoryRoute.page,
      path: '/my-comics/reading-history',
      guards: [authGuard],
    ),
    AutoRoute(
      page: ContinueReadingRoute.page,
      path: '/continue-reading',
      guards: [authGuard],
    ),
    AutoRoute(
      page: WishlistRoute.page,
      path: '/my-comics/wishlist',
      guards: [authGuard],
    ),
    AutoRoute(
      page: MyComicsRoute.page,
      path: '/my-comics',
      guards: [authGuard],
    ),
    AutoRoute(
      page: ReadingListsRoute.page,
      path: '/my-comics/reading-lists',
      guards: [authGuard],
    ),
    AutoRoute(
      page: ReadingListDetailsRoute.page,
      path: '/my-comics/reading-lists/:listId',
      guards: [authGuard],
    ),
    AutoRoute(
      page: ReadingListEditRoute.page,
      path: '/my-comics/reading-lists/:listId/edit',
      guards: [authGuard],
    ),
    AutoRoute(
      page: MetronReadingListBrowserRoute.page,
      path: '/my-comics/reading-lists/browse-metron',
      guards: [authGuard],
    ),
    AutoRoute(
      page: MetronReadingListDetailRoute.page,
      path: '/my-comics/reading-lists/browse-metron/:id',
      guards: [authGuard],
    ),
    AutoRoute(
      page: CharacterBrowseRoute.page,
      path: '/browse/characters',
      guards: [authGuard],
    ),
    AutoRoute(
      page: SeriesBrowseRoute.page,
      path: '/browse/series',
      guards: [authGuard],
    ),
    AutoRoute(
      page: PublisherBrowseRoute.page,
      path: '/browse/publishers',
      guards: [authGuard],
    ),
    AutoRoute(
      page: TeamBrowseRoute.page,
      path: '/browse/teams',
      guards: [authGuard],
    ),
    AutoRoute(
      page: ArcBrowseRoute.page,
      path: '/browse/arcs',
      guards: [authGuard],
    ),
    AutoRoute(
      page: UniverseBrowseRoute.page,
      path: '/browse/universes',
      guards: [authGuard],
    ),
    AutoRoute(
      page: ImprintBrowseRoute.page,
      path: '/browse/imprints',
      guards: [authGuard],
    ),
    AutoRoute(
      page: CreatorBrowseRoute.page,
      path: '/browse/creators',
      guards: [authGuard],
    ),
    AutoRoute(
      page: FavoritesRoute.page,
      path: '/favorites',
      guards: [authGuard],
    ),
    AutoRoute(page: MyPullsRoute.page, path: '/my-pulls', guards: [authGuard]),
    AutoRoute(
      page: SubscriptionsRoute.page,
      path: '/subscriptions',
      guards: [authGuard],
    ),
    AutoRoute(
      page: SeriesDetailsRoute.page,
      path: '/series/:seriesId',
      guards: [authGuard],
    ),
    AutoRoute(
      page: SeriesIssuesRoute.page,
      path: '/series/:seriesId/issues',
      guards: [authGuard],
    ),
    AutoRoute(
      page: UserProfileRoute.page,
      path: '/profile',
      guards: [authGuard],
    ),
    AutoRoute(page: SettingsRoute.page, path: '/settings', guards: [authGuard]),
  ];
}
