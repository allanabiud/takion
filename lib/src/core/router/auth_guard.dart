import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/presentation/providers/auth_provider.dart';

class AuthGuard extends AutoRouteGuard {
  final WidgetRef ref;

  AuthGuard(this.ref);

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) async {
    final status = await ref.read(authStateProvider.future);
    
    if (status == AuthStatus.authenticated) {
      resolver.next(true);
    } else {
      router.push(LoginRoute(onResult: (success) {
        if (success == true) {
          resolver.next(true);
        }
      }));
    }
  }
}
