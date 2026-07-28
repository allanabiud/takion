class RequestCoalescer {
  RequestCoalescer({this.maxEntries = 50});

  final int maxEntries;
  final _inFlight = <String, Future<dynamic>>{};

  Future<T> getOrCreate<T>(String key, Future<T> Function() factory) {
    final existing = _inFlight[key];
    if (existing != null) return existing as Future<T>;

    _evictIfNeeded();

    final future = factory();
    _inFlight[key] = future;
    future.whenComplete(() {
      if (identical(_inFlight[key], future)) {
        _inFlight.remove(key);
      }
    });
    return future;
  }

  void _evictIfNeeded() {
    while (_inFlight.length >= maxEntries) {
      _inFlight.remove(_inFlight.keys.first);
    }
  }
}
