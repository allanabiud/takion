import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/network/metron_account_service.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/presentation/providers/auth_provider.dart';

class AuthGuard extends AutoRouteGuard {
  final WidgetRef ref;

  AuthGuard(this.ref);

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) async {
    // Try to get current value first to avoid unnecessary waiting if already resolved
    final currentStatus = ref.read(authStateProvider).value;
    
    final status = currentStatus ?? await ref.read(authStateProvider.future);
    
    if (status == AuthStatus.authenticated) {
      resolver.next(true);
    } else {
      router.push(LoginRoute(onResult: (success) {
        if (success == true) {
          Future<void>(() async {
            final metronService = ref.read(metronAccountServiceProvider);
            final connection = await metronService.getConnection();

            resolver.next(false);
            if (connection != null) {
              router.replaceAll([const MainRoute()]);
            } else {
              router.replaceAll([const MetronConnectRoute()]);
            }
          });
          return;
        }

        resolver.next(false);
      }));
    }
  }
}
