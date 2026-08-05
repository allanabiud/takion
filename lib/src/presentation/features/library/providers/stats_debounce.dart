import 'dart:async';

class DebouncedWorker {
  DebouncedWorker({this.delay = const Duration(milliseconds: 300)});

  final Duration delay;
  Timer? _timer;
  int _generation = 0;

  void schedule(FutureOr<void> Function() task) {
    final generation = ++_generation;
    _timer?.cancel();
    _timer = Timer(delay, () {
      if (generation != _generation) return;
      _run(task, generation);
    });
  }

  Future<void> _run(FutureOr<void> Function() task, int generation) async {
    try {
      await task();
    } catch (_) {
      // Swallow errors; providers emit their own.
    } finally {
      if (generation == _generation) {
        _generation++;
      }
    }
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
    _generation++;
  }
}
