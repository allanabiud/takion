import "package:flutter/services.dart";
import "package:auto_route/auto_route.dart";
import "package:takion/src/core/router/app_router.gr.dart";

class ShortcutHandler {
  static const _channel = MethodChannel("takion/shortcut");

  void Function(PageRouteInfo)? navigateNamed;

  void init() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == "navigate") {
        final route = call.arguments as String?;
        _handleRoute(route);
      }
      return null;
    });
  }

  void checkPending() {
    _channel.invokeMethod<String>("getPendingRoute").then((route) {
      if (route != null) {
        _handleRoute(route);
      }
    });
  }

  static Future<void> enableShortcuts() async {
    await _channel.invokeMethod("enableShortcuts");
  }

  void _handleRoute(String? route) {
    if (route == null || navigateNamed == null) return;
    final pageRoute = _resolve(route);
    if (pageRoute != null) {
      navigateNamed!(pageRoute);
    }
  }

  PageRouteInfo? _resolve(String key) {
    return switch (key) {
      "new-releases" => const WeeklyReleasesRoute(),
      "my-pulls" => const MyPullsRoute(),
      "library" => const LibraryRoute(),
      _ => null,
    };
  }
}
