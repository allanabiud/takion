import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/router/app_router.dart';
import 'package:takion/src/core/router/auth_guard.dart';
import 'package:takion/src/core/theme/app_theme.dart';
import 'package:takion/src/presentation/providers/auth_provider.dart';
import 'package:takion/src/presentation/providers/theme_provider.dart';

class TakionApp extends ConsumerStatefulWidget {
  const TakionApp({super.key});

  @override
  ConsumerState<TakionApp> createState() => _TakionAppState();
}

class _TakionAppState extends ConsumerState<TakionApp> {
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _appRouter = AppRouter(AuthGuard(ref));
  }

  @override
  Widget build(BuildContext context) {
    final themeSettings = ref.watch(themeProvider);

    // Re-evaluate guards when auth state changes (e.g. on logout/login)
    ref.listen(authStateProvider, (previous, next) {
      if (!next.isLoading && previous?.value != next.value) {
        _appRouter.reevaluateGuards();
      }
    });

    return MaterialApp.router(
      title: 'Takion',
      theme: AppThemes.light(),
      darkTheme: AppThemes.dark(darkIsTrueBlack: themeSettings.darkIsTrueBlack),
      themeMode: themeSettings.themeMode,
      debugShowCheckedModeBanner: false,
      routerConfig: _appRouter.config(),
      builder: (context, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: FlexColorScheme.themedSystemNavigationBar(
            context,
            systemNavBarStyle: FlexSystemNavBarStyle.transparent,
          ),
          child: child!,
        );
      },
    );
  }
}
