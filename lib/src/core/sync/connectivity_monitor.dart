import "dart:async";
import "package:connectivity_plus/connectivity_plus.dart";

class ConnectivityMonitor {
  ConnectivityMonitor({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _wasOnline = true;
  final _onReconnectedControllers = <void Function()>[];

  bool _isResultOnline(List<ConnectivityResult> results) {
    return results.any((r) => r != ConnectivityResult.none);
  }

  Future<bool> isOnline() async {
    final results = await _connectivity.checkConnectivity();
    return _isResultOnline(results);
  }

  Stream<bool> get onOnlineStatusChanged {
    return _connectivity.onConnectivityChanged.map(_isResultOnline).distinct();
  }

  void startMonitoring({void Function()? onReconnected}) {
    if (onReconnected != null) {
      _onReconnectedControllers.add(onReconnected);
    }

    _subscription ??= _connectivity.onConnectivityChanged.listen((results) {
      final online = _isResultOnline(results);
      if (online && !_wasOnline) {
        for (final cb in _onReconnectedControllers) {
          cb();
        }
      }
      _wasOnline = online;
    });
  }

  void addReconnectedListener(void Function() listener) {
    _onReconnectedControllers.add(listener);
  }

  void removeReconnectedListener(void Function() listener) {
    _onReconnectedControllers.remove(listener);
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    _onReconnectedControllers.clear();
  }
}
