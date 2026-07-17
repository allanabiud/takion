import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/network/dio_client.dart';
import 'package:takion/src/core/network/rate_limit_interceptor.dart';

class RateLimitNotifier extends Notifier<RateLimitState> {
  bool _disposed = false;

  @override
  RateLimitState build() {
    final interceptor = ref.read(rateLimitInterceptorProvider);

    void listener() {
      if (!_disposed) {
        state = interceptor.state;
      }
    }

    interceptor.stateNotifier.addListener(listener);
    ref.onDispose(() {
      _disposed = true;
      interceptor.stateNotifier.removeListener(listener);
    });
    return interceptor.state;
  }
}

final rateLimitStatusProvider =
    NotifierProvider<RateLimitNotifier, RateLimitState>(RateLimitNotifier.new);
