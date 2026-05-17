import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/network/metron_account_service.dart';

final metronConnectionProvider = FutureProvider<MetronAccountConnection?>(
  (ref) async {
    final service = ref.watch(metronAccountServiceProvider);
    return service.getConnection();
  },
);