import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppConnectivityStatus { online, offline }

final connectivityProvider = Provider<Connectivity>((ref) {
  return Connectivity();
});

final connectivityStatusProvider = StreamProvider<AppConnectivityStatus>((ref) {
  final connectivity = ref.watch(connectivityProvider);
  final controller = StreamController<AppConnectivityStatus>();

  AppConnectivityStatus mapStatus(List<ConnectivityResult> results) {
    final hasNetwork = results.any(
      (result) => result != ConnectivityResult.none,
    );
    return hasNetwork
        ? AppConnectivityStatus.online
        : AppConnectivityStatus.offline;
  }

  Future<void> emitInitialStatus() async {
    final initial = await connectivity.checkConnectivity();
    if (!controller.isClosed) {
      controller.add(mapStatus(initial));
    }
  }

  emitInitialStatus();

  final subscription = connectivity.onConnectivityChanged.listen((results) {
    if (!controller.isClosed) {
      controller.add(mapStatus(results));
    }
  });

  ref.onDispose(() {
    subscription.cancel();
    controller.close();
  });

  return controller.stream.distinct();
});
