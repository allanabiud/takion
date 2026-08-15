import "package:auto_route/auto_route.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/core/auth/auth_provider.dart";
import "package:takion/src/core/router/app_router.gr.dart";

class AuthGuard extends AutoRouteGuard {
  final WidgetRef ref;

  AuthGuard(this.ref);

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) async {
    AuthStatus authState;
    try {
      authState = await ref.read(authStateProvider.future);
    } catch (e) {
      authState = AuthStatus.unauthenticated;
    }
    if (authState == AuthStatus.authenticated) {
      resolver.next(true);
    } else {
      await router.replaceAll([const AuthorizeMetronRoute()]);
      resolver.next(false);
    }
  }
}
